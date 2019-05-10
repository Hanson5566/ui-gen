<template>
	<div class="main_container">
		<div class="filter-container">
			<div class="input">
                <!--输入框-->
		<#list fields as field>
            <#if field.type?contains("Enum")>
            <#-- 枚举类型则是下拉列表 -->
            	<!--下拉列表-->
				<el-select v-model="listQuery.${field.name}" size="small" clearable placeholder="${field.describe}">
					<el-option
							v-for="item in select${field.name?cap_first}Array"
							:key="item.name"
							:label="item.text"
							:value="item.name">
					</el-option>
				</el-select>
                <#elseif field.type?contains("Date")>
                <#-- 日期类型则是下拉列表 -->
                <!--日期选择-->
                <el-date-picker
                        size="small"
                        v-model="listQuery.${field.name}"
                        type="date"
                        value-format="yyyy-MM-dd"
                        placeholder="选择日期">
                </el-date-picker>
                <#else >
                <el-input  v-model="listQuery.${field.name}" size="small" clearable placeholder="${field.describe}" @keyup.enter.native="search"></el-input>
            </#if>
        </#list>
			</div>
			<!--条件按钮-->
			<div class="search">
				<el-button type="primary" size="mini" icon="el-icon-search" @click="search">搜索</el-button>
				<el-button type="default" size="mini" icon="el-icon-refresh" @click="resetSearch">重置</el-button>
			</div>
		</div>
		<!--工具按钮-->
		<div class="toolbar_container">
			<el-button type="success" size="small" icon="el-icon-plus" @click="handleCreate">新增</el-button>
			<el-button type="primary" size="small" icon="el-icon-download" @click="handleDownload">导出</el-button>
		</div>
		<!--列表-->
		<div class="list_container">
			<el-table v-loading="loading" :data="tableData" element-loading-text="加载中.." stripe border highlight-current-rowstripe>
                <!--展开列-->
                <el-table-column type="expand">
                    <template slot-scope="props">
                        <el-form label-position="left" inline class="table-expand">
                        <#list fields as field>
                        <#-- 前5列之后，其他行为展开列 -->
                        <#if field_index gt 5>
                            <el-form-item label="${field.describe}">
                                <span>{{ props.row.${field.name}}}</span>
                            </el-form-item>
                        </#if>
                        </#list>
                        </el-form>
                    </template>
                </el-table-column>
                <#list fields as field>
                <#-- 前5列之后，其他行为展开列 -->
                    <#if field_index lt 5>
                        <el-form-item label="${field.describe}">
				<el-table-column align="center" prop="${field.name}"label="${field.describe}" sortable></el-table-column>
                        </el-form-item>
                    </#if>
                </#list>
				<el-table-column align="center" label="操作">
					<template slot-scope="scope">
						<el-tooltip content="编辑" placement="top">
							<el-button type="primary" circle size="mini" icon="el-icon-edit" @click="handleUpdate(scope.row)"></el-button>
						</el-tooltip>
						<el-tooltip content="删除" placement="top">
							<el-button type="danger" circle size="mini" icon="el-icon-delete" @click="handleDelete(scope.row)"></el-button>
						</el-tooltip>
					</template>
				</el-table-column>
			</el-table>
		</div>
		<div class="pagination-container">
			<el-pagination
					background
					@current-change="handleCurrentChange"
					layout="total, prev, pager, next"
					:current-page="listQuery.pageNum"
					:page-size="listQuery.limit"
					:total="totalCount"
			></el-pagination>
		</div>
		<!--新增&修改弹窗-->
		<div class="editor-container">
			<el-dialog :title="textMap[dialogStatus]" :visible.sync="dialogFormVisible">
				<el-form ref="formData" :rules="validateForm" :model="formData" label-position="left" label-width="120px" style="width: 400px; margin-left:70px;">
                    <#list fields as field>
                        <#if field.type?contains("Enum")>
                        <#-- 枚举类型则是下拉列表 -->
                            <!--下拉列表-->
                            <el-form-item label="${field.describe}" prop="${field.name}">
                                <el-select v-model="formData.${field.name}" class="filter-item">
                                    <el-option v-for="item in select${field.name?cap_first}Array" :key="item.code" :label="item.text" :value="item.name" />
                                </el-select>
                            </el-form-item>
                        <#elseif field.type?contains("Date")>
                        <#-- 日期类型则是下拉列表 -->
                            <el-form-item label="${field.describe}" prop="${field.name}">
                                <el-date-picker v-model="formData.${field.name}" type="date" value-format="yyyy-MM-dd" placeholder="请选择日期" />
                            </el-form-item>
                        <#else >
                            <el-form-item label="${field.describe}">
                                <el-input v-model="formData.${field.name}"></el-input>
                            </el-form-item>
                        </#if>
                    </#list>
				</el-form>
				<div slot="footer" class="dialog-footer">
					<el-button @click="dialogFormVisible = false">取消</el-button>
					<el-button type="primary" @click="dialogStatus==='create'?save():update()">确定</el-button>
				</div>
			</el-dialog>
		</div>
	</div>
</template>

<script>
	import { list, get, save, del, update }  from "@/api/${entityLower}";
	import { getEnums}  from "@/api/common";
	export default {
		data() {
			return {
				/*列表数据*/
				tableData: [],
				dialogVisible: false,
				loading: false,
				totalCount: 0,
                <#--循环字段，声明所有枚举类型-->
            <#list fields as field>
            <#if field.type?contains("Enum")>
            <#-- 枚举类型则是下拉列表 -->
				select${field.name?cap_first}Array: [],//下拉列表显示
            </#if>
            </#list>
				/*查询参数*/
				listQuery: {
				<#list fields as field>
				<#if field.type?contains("Enum")>
					${field.name}: null,
				</#if>
				</#list>
					limit: 10,
					offset: 0
				},

				/*弹窗form相关*/
				formData: {
				<#list fields as field>
				<#if field.type?contains("Integer")>
					${field.name}: undefined,
					<#else>
					${field.name}: '',
				</#if>
				</#list>
				},
				dialogStatus: '',//弹窗状态
				dialogFormVisible: false,//弹窗是否隐藏
				/*新增或修改显示的文字*/
				textMap: {
					update: '修改',
					create: '新增'
				},
				/*表单验证 在item上添加相应的prop="下面json中的name规则"*/
				validateForm: {
				<#list fields as field>
					<#if field.type?contains("Integer")>
					${field.name}: [{required: true,message: '请输入${field.describe}',trigger: ['blur','change']},{pattern:/^[0-9]*$/, message: '${field.describe}只能为数字'}],
					<#else>
					${field.name}: [{ required: true, message: '请输入${field.describe}', trigger: ['blur','change'] }],
					</#if>
				</#list>
				},
			};
		},
		props: {},
		components: {},
		created() {
			this.getList();
			this.queryDropdown();
		<#list fields as field>
		<#if field.type?contains("Enum")>
			this.select${field.name?cap_first}Array();
		</#if>
		</#list>
		},
		methods: {
			getList() {
				this.loading = true;
				list(this.listQuery).then(response =>{
					this.tableData = response.data;
					this.totalCount = response.pageInfo.totalCount;
					this.loading = false;
				});
			},
			search() {
				//查询置为首页开始
				this.listQuery.offset = 0;
				this.getList();
			},
			save() {
				this.$refs['formData'].validate((valid) => {
					if (valid) {
						save(this.formData).then(() => {
							this.dialogFormVisible = false
							this.$notify({
								title: '成功',
								message: '创建成功',
								type: 'success',
								duration: 2000
							});
							this.getList();
						});
					}
				});
			},
			update() {
				this.$refs['formData'].validate((valid) => {
					if (valid) {
						update(this.formData).then(() => {
							this.dialogFormVisible = false
							this.$notify({
								title: '成功',
								message: '更新成功',
								type: 'success',
								duration: 2000
							});
							this.getList();
						});
					}
				});
			},
			handleDownload() {
				this.$message({
					type: 'error',
					message: '待开发!'
				});
			},
			resetSearch() {
				this.listQuery.offset = 0;
			<#list fields as field>
				this.listQuery.${field.name}= null;
			</#list>
				this.getList();
			},
			/*清空formdata数据*/
			resetFormData() {
				this.formData = {
				<#list fields as field>
				<#if field.type?contains("Integer")>
					${field.name}: undefined,
				<#else>
					${field.name}: '',
				</#if>
				</#list>
				}
			},
			/*页面按钮事件*/
			handleCreate() {
				this.resetFormData();
				this.dialogStatus = 'create';
				this.dialogFormVisible = true;
				this.$nextTick(() => {
					this.$refs['formData'].clearValidate();
				})
			},
			handleUpdate(row) {
				this.formData = Object.assign({}, row); // copy obj
				/*下拉列表与日期格式特殊处理*/
			<#list fields as field>
			<#if field.type?contains("Date")>
				<#--日期特殊处理-->
				this.formData.${field.name} = new Date(this.formData.${field.name});
			<#elseif field.type?contains("Enum")>
				<#--下拉列表特殊处理-->
				this.formData.${field.name} = this.formData.${field.name}.name;
			</#if>
			</#list>
				this.dialogStatus = 'update';
				this.dialogFormVisible = true;
				this.$nextTick(() => {
					this.$refs['formData'].clearValidate();
				})
			},
			handleDelete(row) {
				this.$confirm('是否确认删除此数据?', '提示', {
					confirmButtonText: '确定',
					cancelButtonText: '取消',
					type: 'warning'
				}).then(() => {
					del(row.id).then(response => {
					this.$message({
						type: 'success',
						message: '删除成功!'
				});
				this.getList()
			})
			}).catch(() => {
					/* this.$message({
                       type: 'info',
                       message: '已取消删除'
                     });*/
				})
			},
			handleCurrentChange(val) {
				this.listQuery.pageNum = val;
				this.getList();
			},
			/*查询下拉列表*/
			<#list fields as field>
			<#if field.type?contains("Enum")>
			select${field.name?cap_first}Array(){
				let dictionaries = "${field.name}";
				getEnums(dictionaries).then(response => {
					this.select${field.name?cap_first}Array = response.data;
				})
			},
			</#if>
			</#list>
		}
	};
</script>

<style lang="scss">
	.main_container {
		padding: 32px;
	.filter-container {
		border: 1px solid #f2f2f2;
		padding: 5px 3px;
	& > div {
		  display: inline-block;
	  }
	.el-input{
		width: 200px;
		height: 28px;;
		margin-right: 10px;
	}
	.search {
		margin-right: 40px;
	}
	}
	.list_container {
		margin-top: 10px;
	& > .el-pagination {
		  display: flex;
		  justify-content: center;
	  }
	.table-expand {
		font-size: 0;
	}
	.table-expand label {
		width: 90px;
		color: #99a9bf;
	}
	.table-expand .el-form-item {
		margin-right: 0;
		margin-bottom: 0;
		width: 50%;
	}
	}
	.toolbar_container {
		margin-top: 10px;
	}

	.editor-container{

	}
	}
</style>
