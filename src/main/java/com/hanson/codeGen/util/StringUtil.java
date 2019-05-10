package com.hanson.codeGen.util;

public class StringUtil {
	public static String firstCharToLowerCase(String str) {
		return String.valueOf(str.charAt(0)).toLowerCase().concat(str.substring(1));
	}
	public static String firstCharToUpperCase(String str) {
		return String.valueOf(str.charAt(0)).toUpperCase().concat(str.substring(1));
	}
	public static String getEntityLower(String str,char c) {
		return firstCharToLowerCase(str.substring(str.lastIndexOf(c)+1, str.length()));
	}
	public static String getEntityUpper(String str,char c) {
		return firstCharToUpperCase(str.substring(str.lastIndexOf(c)+1, str.length()));
	}
	public static boolean hasSpecifiedString(String str,String specified){
		return str.indexOf(specified)>=0;
	}
	public static boolean isNotEmpty(String str){
		return str != null && str.length() > 0;
	}
	
}
