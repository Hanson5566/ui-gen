import request from '@/utils/request'

//获取列表
export function list(params) {
return request({
url: '/${entityLower}s/',
method: 'get',
params: params
})
}

//获取详情
export function get(id) {
return request({
url: '/${entityLower}s/'+id,
method: 'get'
})
}

//添加
export function save(params) {
return request({
url: '/${entityLower}s',
method: 'post',
data: params
})
}

//删除
export function del(id) {
return request({
url: '/${entityLower}s/'+id,
method: 'delete'
})
}

//修改
export function update(params) {
return request({
url: '/${entityLower}s/',
method: 'put',
data: params
})
}

