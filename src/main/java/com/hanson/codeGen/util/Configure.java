package com.hanson.codeGen.util;

import java.net.URL;
import java.util.Properties;

/**
 * 根据配置以及反射生成freemaker需要的字段。
 */
public class Configure {
	private static Configure instance;
	private static Properties pros = new Properties();
	
	private Configure(String fileName) {
		super();
		try {
			URL resource = this.getClass().getResource("/");
			System.out.println(resource.getPath());
			pros.load(this.getClass().getResourceAsStream("/"+fileName));
			String entity = pros.getProperty("entity");
			pros.setProperty("entityLower", StringUtil.getEntityLower(entity,'.'));
			pros.setProperty("entityUpper", StringUtil.getEntityUpper(entity,'.'));
		} catch (Exception e) {
			System.err.println("加载配置文件出错");
			System.exit(0);
		}
	}
	
	public static String getProValue(String key) {
		if(!pros.containsKey(key)) {
			System.err.println("未找到配置："+key);
			System.exit(0);
		}
		return (String) pros.get(key);
	}
	
	public static void setProValue(String key,String value) {
		pros.put(key,value);
	}
	
	public static Properties getPros() {
		return pros;
	}
	
	
	
	public static Configure getInstance(String fileName){
		if(instance != null){
			return instance;
		}else{
			return new Configure(fileName);
		}
	}
}
