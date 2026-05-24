//  ZQNavigationRouter.swift
//  ZQFlexibleTool
//
//  Created by JessonZhang on 2026/01/12.
//
import UIKit

public enum ZQNavigationRouter {
    /// 将控制器 push 到当前导航栈。
    public static func push(_ viewController: UIViewController,
                            from currentViewController: UIViewController,
                            animated: Bool = true) {
        currentViewController.navigationController?.pushViewController(viewController, animated: animated)
    }

    /// 以模态方式展示控制器。
    public static func present(_ viewController: UIViewController,
                               from currentViewController: UIViewController,
                               animated: Bool = true,
                               completion: (() -> Void)? = nil) {
        currentViewController.present(viewController, animated: animated, completion: completion)
    }

    /// 退出当前控制器。
    public static func pop(from currentViewController: UIViewController, animated: Bool = true) {
        _ = currentViewController.navigationController?.popViewController(animated: animated)
    }

    /// 返回到根控制器。
    public static func popToRoot(from currentViewController: UIViewController, animated: Bool = true) {
        _ = currentViewController.navigationController?.popToRootViewController(animated: animated)
    }

    /// 关闭当前被展示的控制器。
    public static func dismiss(from currentViewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) {
        currentViewController.dismiss(animated: animated, completion: completion)
    }
}
