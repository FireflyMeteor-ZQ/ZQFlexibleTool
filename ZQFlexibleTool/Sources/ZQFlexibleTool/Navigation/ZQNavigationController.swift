//  ZQNavigationController.swift
//  ZQFlexibleTool
//
//  Created by JessonZhang on 2026/01/12.
//
import UIKit

public final class ZQNavigationController: UINavigationController, UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    /// 是否启用默认侧滑返回手势。
    public var enablesFullScreenPopGesture: Bool = true

    /// 隐藏系统导航栏，并设置手势代理。
    public override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        navigationBar.isHidden = true
        interactivePopGestureRecognizer?.delegate = self
        interactivePopGestureRecognizer?.isEnabled = true
    }

    /// push 新页面时自动隐藏底部 TabBar。
    public override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if viewControllers.count > 0 {
            viewController.hidesBottomBarWhenPushed = true
        }
        super.pushViewController(viewController, animated: animated)
    }

    /// 根控制器不允许触发侧滑返回。
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard enablesFullScreenPopGesture else { return false }
        return viewControllers.count > 1
    }

    /// 子控制器切换时保持系统导航栏隐藏。
    public func navigationController(_ navigationController: UINavigationController,
                                      willShow viewController: UIViewController,
                                      animated: Bool) {
        navigationBar.isHidden = true
    }
}
