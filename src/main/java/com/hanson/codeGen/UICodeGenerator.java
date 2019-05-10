package com.hanson.codeGen;

import com.hanson.codeGen.util.FileUtils;
import com.hanson.codeGen.util.Configure;

import java.io.IOException;
import java.util.Scanner;

public class UICodeGenerator {
	private static Scanner sc;

	public static void main(String[] args) throws IOException {
		System.out.println("小心！！！！此程序会覆盖原有文件，请输入yes确定继续执行。");
		sc = new Scanner(System.in);
		String nextLine = sc.nextLine();
		if(!"yes".equals(nextLine)) {
			System.out.println("程序退出");
			System.exit(0);
		}
		//加载配置
		Configure.getInstance("conf.properties");
		//生成文件
		Configure.setProValue("template", "ui_api.ftl");
		FileUtils.gen();
		Configure.setProValue("template", "ui_vue.ftl");
		FileUtils.gen();
	}
}
