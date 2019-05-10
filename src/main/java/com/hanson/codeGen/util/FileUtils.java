package com.hanson.codeGen.util;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.StringWriter;
import java.lang.reflect.Field;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.hanson.base.annotation.Describe;
import com.hanson.base.enums.EnumType;
import com.hanson.codeGen.UICodeGenerator;
import freemarker.cache.ClassTemplateLoader;
import freemarker.template.Configuration;
import freemarker.template.DefaultObjectWrapper;
import freemarker.template.Template;
import freemarker.template.TemplateException;

/**
 * 生成UI文件
 */
public class FileUtils {
	public static File createFile() throws IOException {
		//获得目标目录
		String targetFolder = Configure.getProValue("targetFolder");
		//根据类名生成最终文件
		String fullPath = FileUtils.getFullPath(targetFolder);
		//目标输出目录targetFolder+ "\\src\\view || \\api"
		File folder = new File(fullPath);
		//添加类型名称
		String template = Configure.getProValue("template");
		//文件扩展名
		String extName = "";
		if(template.indexOf("api")>=0) {
			//js文件
			extName = ".js";
		}else if(template.indexOf("vue")>=0) {
			//vue文件
			extName = ".vue";
		}
		//目标输出文件targetFolder
		File file = new File(fullPath+ "\\" + Configure.getProValue("entityLower")+extName);
		
		//不存在则创建
		if(!folder.exists()){
			folder.mkdirs();
		}
		if(!file.exists()){
			file.createNewFile();
		}
		return file;
	}
	
	public static String getFullPath(String folder){
		folder += "\\src";
		//添加类型名称
		String template = Configure.getProValue("template");
		if(template.indexOf("api")>=0) {
			folder += "\\api\\";
		}else if(template.indexOf("vue")>=0) {
			folder += "\\views\\"+ Configure.getProValue("entityLower");
		}
		return folder;
	}
	
	public static void gen() {
		Configuration configuration = new Configuration();
		configuration.setObjectWrapper(new DefaultObjectWrapper());
		configuration.setTemplateLoader(new ClassTemplateLoader(UICodeGenerator.class, "/com/hanson/codeGen/template"));
		try {
			Template template = configuration.getTemplate(Configure.getProValue("template"));
			StringWriter writer = new StringWriter();
			File file = FileUtils.createFile();
			Map<String, Object> rootMap = initData();
			FileOutputStream fos = new FileOutputStream(file);
			template.process(rootMap,writer);
			fos.write(writer.toString().getBytes());
			fos.flush();
			fos.close();
			System.err.println("output:   "+file.getPath());
		} catch (IOException e) {
			e.printStackTrace();
		} catch (TemplateException e) {
			e.printStackTrace();
		}
	}

	public static Map<String,Object> initData(){
		Map<String,Object> data = new HashMap<String, Object>();
		data.put("entityLower",Configure.getProValue("entityLower"));
		data.put("entityUpper",Configure.getProValue("entityUpper"));
		String clazzName = Configure.getProValue("entity");
		try {
			//反射类，拿到字段名以及类型
			List<Map<String,String>> fields = new ArrayList<Map<String,String>>();
			Class<?> clazz = Class.forName(clazzName);
			Field[] declaredFields = clazz.getDeclaredFields();
			for (Field declaredField : declaredFields) {
				//如果有JsonIgnore注解则不输出
				if(declaredField.isAnnotationPresent(JsonIgnore.class))
					continue;
				Map<String,String> field = new HashMap<String, String>();
				String name = declaredField.getName();
				Class<?> type = declaredField.getType();
				Describe describe = declaredField.getAnnotation(Describe.class);
				field.put("name",name);
				//枚举由于命名不规范特殊处理
				field.put("type",type.getClass().isAssignableFrom(EnumType.class) ? "Enum" : type.getSimpleName());
				field.put("describe",describe.value());
				fields.add(field);
			}
			data.put("fields",fields);
		} catch (ClassNotFoundException e) {
			e.printStackTrace();
		}
		return data;
	}
}
