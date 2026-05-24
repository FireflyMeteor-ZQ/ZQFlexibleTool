//  SceneDelegate.swift
//  ZQFlexibleToolExample
//
//  Created by JessonZhang on 2026/01/12.
//
import UIKit
import ZQFlexibleTool

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = DemoTabBarController()
        if #available(iOS 13.0, *) {
            window.overrideUserInterfaceStyle = .light
        }
        self.window = window
        window.makeKeyAndVisible()
    }
}
