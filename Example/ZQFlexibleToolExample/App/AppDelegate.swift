//  AppDelegate.swift
//  ZQFlexibleToolExample
//
//  Created by JessonZhang on 2026/01/12.
//
import UIKit
import ZQFlexibleTool

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        let root = DemoTabBarController()
        if #available(iOS 13.0, *) {
            root.overrideUserInterfaceStyle = .light
        }
        window?.rootViewController = root
        window?.makeKeyAndVisible()
        // 强制关闭暗黑模式
        if #available(iOS 13.0, *) {
            self.window!.overrideUserInterfaceStyle = .light
        }
        return true
    }
}
