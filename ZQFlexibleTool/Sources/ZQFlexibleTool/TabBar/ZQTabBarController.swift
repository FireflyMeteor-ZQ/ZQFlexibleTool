//  ZQTabBarController.swift
//  ZQFlexibleTool
//
//  Created by JessonZhang on 2026/01/12.
//
import UIKit

public struct ZQTabBarAppearance {
    /// 未选中标题颜色。
    public var normalTitleColor: UIColor = .secondaryLabel
    /// 选中标题颜色。
    public var selectedTitleColor: UIColor = .label
    /// TabBar 背景色。
    public var backgroundColor: UIColor = .systemBackground
    /// TabBar 是否半透明。
    public var isTranslucent: Bool = false
    /// 中间特殊动作项的图标偏移。
    public var actionItemImageInsets: UIEdgeInsets = UIEdgeInsets(top: -6, left: 0, bottom: 6, right: 0)
    /// 中间特殊动作项标题偏移。
    public var actionItemTitleOffset: UIOffset = UIOffset(horizontal: 0, vertical: 2)

    public init() {}
}

public struct ZQTabBarItemConfiguration {
    /// Tab 里的根控制器。
    public let viewController: UIViewController
    /// Tab 标题。
    public let title: String
    /// 未选中状态图标。
    public let normalImage: UIImage?
    /// 选中状态图标。
    public let selectedImage: UIImage?
    /// 角标文案，传空字符串可显示红点。
    public let badgeValue: String?
    /// 角标颜色。
    public let badgeColor: UIColor?
    /// 是否为中间特殊动作项。
    public let isActionItem: Bool
    /// 特殊动作项点击回调。
    public let actionHandler: (() -> Void)?
    /// 自定义 tabBarItem 的入口，适合补充 imageInsets、titleOffset 等细节。
    public let tabBarItemConfiguration: ((UITabBarItem) -> Void)?

    public init(viewController: UIViewController,
                title: String,
                normalImage: UIImage?,
                selectedImage: UIImage?,
                badgeValue: String? = nil,
                badgeColor: UIColor? = nil,
                isActionItem: Bool = false,
                actionHandler: (() -> Void)? = nil,
                tabBarItemConfiguration: ((UITabBarItem) -> Void)? = nil) {
        self.viewController = viewController
        self.title = title
        self.normalImage = normalImage
        self.selectedImage = selectedImage
        self.badgeValue = badgeValue
        self.badgeColor = badgeColor
        self.isActionItem = isActionItem
        self.actionHandler = actionHandler
        self.tabBarItemConfiguration = tabBarItemConfiguration
    }
}

open class ZQTabBarController: UITabBarController, UITabBarControllerDelegate {
    /// 统一的 TabBar 外观配置。
    public var appearance = ZQTabBarAppearance() {
        didSet { applyAppearance() }
    }

    /// 用户额外定义的特殊点击处理。
    public var onActionItemTriggered: ((Int) -> Void)?

    private var pendingItems: [ZQTabBarItemConfiguration] = []
    private var pendingSelectedIndex: Int?
    private var actionItems: [Int: (() -> Void)] = [:]
    private var lastSelectedIndex: Int?

    open override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        setupAppearance()
        applyPendingConfigurationIfNeeded()
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        applyPendingConfigurationIfNeeded()
    }

    /// 统一配置 tabs，保持对外入口简单。
    public func configure(items: [ZQTabBarItemConfiguration], selectedIndex: Int? = nil) {
        pendingItems = items
        pendingSelectedIndex = selectedIndex
        applyPendingConfigurationIfNeeded()
    }

    /// 设置角标，传入空字符串可显示红点效果。
    public func setBadge(_ value: String?, at index: Int) {
        guard let item = tabBar.items?[safe: index] else { return }
        item.badgeValue = value
    }

    /// 使用空角标展示红点。
    public func showRedDot(at index: Int) {
        guard canUpdateBadge(at: index) else { return }
        setBadge("", at: index)
    }

    /// 隐藏对应 Tab 的角标。
    public func hideBadge(at index: Int) {
        guard canUpdateBadge(at: index) else { return }
        setBadge(nil, at: index)
    }

    /// 显示数字角标，数量为 0 时自动隐藏。
    public func setBadgeCount(_ count: Int, at index: Int) {
        guard canUpdateBadge(at: index) else { return }
        guard count > 0 else {
            hideBadge(at: index)
            return
        }
        setBadge("\(count)", at: index)
    }

    /// 是否允许重复点击同一个 tab 时回到顶部/重做动作。
    public func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        true
    }

    public func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        guard let index = viewControllers?.firstIndex(of: viewController) else { return }
        if let action = actionItems[index] {
            action()
            onActionItemTriggered?(index)
            if index != lastSelectedIndex, let previousIndex = lastSelectedIndex, let previous = viewControllers?[safe: previousIndex] {
                selectedViewController = previous
            }
            return
        }
        lastSelectedIndex = index
    }

    private func applyPendingConfigurationIfNeeded() {
        guard !pendingItems.isEmpty else { return }

        actionItems.removeAll()
        let controllers = pendingItems.enumerated().map { index, item -> UIViewController in
            let nav = ZQNavigationController(rootViewController: item.viewController)
            let tabBarItem = UITabBarItem(title: item.title,
                                          image: item.normalImage?.withRenderingMode(.alwaysOriginal),
                                          selectedImage: item.selectedImage?.withRenderingMode(.alwaysOriginal))
            tabBarItem.badgeValue = item.badgeValue
            tabBarItem.badgeColor = item.badgeColor
            tabBarItem.titlePositionAdjustment = item.isActionItem ? appearance.actionItemTitleOffset : .zero
            item.tabBarItemConfiguration?(tabBarItem)
            if item.isActionItem, let actionHandler = item.actionHandler {
                actionItems[index] = actionHandler
                tabBarItem.imageInsets = appearance.actionItemImageInsets
            }
            nav.tabBarItem = tabBarItem
            return nav
        }

        viewControllers = controllers
        applyAppearance()

        if let selectedSelectedIndex = pendingSelectedIndex,
           controllers.indices.contains(selectedSelectedIndex) {
            selectedIndex = selectedSelectedIndex
            lastSelectedIndex = selectedSelectedIndex
        } else if controllers.indices.contains(0) {
            selectedIndex = 0
            lastSelectedIndex = 0
        }

        pendingItems.removeAll()
        pendingSelectedIndex = nil
    }

    private func setupAppearance() {
        tabBar.isTranslucent = appearance.isTranslucent
        applyAppearance()
    }

    private func applyAppearance() {
        tabBar.backgroundColor = appearance.backgroundColor
        tabBar.tintColor = appearance.selectedTitleColor
        tabBar.unselectedItemTintColor = appearance.normalTitleColor
        tabBar.items?.forEach { item in
            item.setTitleTextAttributes([.foregroundColor: appearance.normalTitleColor], for: .normal)
            item.setTitleTextAttributes([.foregroundColor: appearance.selectedTitleColor], for: .selected)
        }
    }

    private func canUpdateBadge(at index: Int) -> Bool {
        guard let items = tabBar.items, items.indices.contains(index) else { return false }
        return true
    }
}

private extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
