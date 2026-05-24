//  ZQBaseViewController.swift
//  ZQFlexibleTool
//
//  Created by JessonZhang on 2026/01/12.
//

import UIKit
import TangramKit

open class ZQBaseViewController: UIViewController {
    /// 子类通用的自定义导航栏。
    public let navigationBar = ZQNavigationBar()
    /// 承载内容容器的滚动视图。
    public let contentScrollView = UIScrollView()
    /// 使用 TangramKit 的纵向布局作为内容容器。
    public let contentContainerView = TGLinearLayout(.vert)

    /// 控制自定义导航栏是否显示。
    public var navigationBarHidden: Bool = false {
        didSet { updateChromeVisibility() }
    }
    /// 自定义导航栏标题。
    public var navigationBarTitle: String? {
        didSet { navigationBar.setTitle(navigationBarTitle) }
    }
    /// 内容滚动区域背景色。
    public var contentBackgroundColor: UIColor = .systemBackground {
        didSet { contentScrollView.backgroundColor = contentBackgroundColor }
    }
    /// 自定义导航栏可见高度。
    public var navigationBarHeight: CGFloat = 44 {
        didSet { updateNavigationBarHeight() }
    }
    /// 额外应用到 content 和滚动条的内边距。
    public var contentInsets: UIEdgeInsets = .zero {
        didSet { updateContentInsets() }
    }

    private var contentTopConstraint: NSLayoutConstraint?

    private var customBackAction: (() -> Void)?

    /// 构建全屏布局，并应用初始 UI 状态。
    open override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        updateChromeVisibility()
        updateContentInsets()
    }

    /// 根据安全区变化同步导航栏高度。
    open override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        updateNavigationBarHeight()
        updateContentInsets()
    }

    /// 向可滚动内容容器中添加子视图。
    open func addContentSubview(_ view: UIView) {
        contentContainerView.addSubview(view)
    }

    /// 替换自定义返回按钮的默认行为。
    open func setBackAction(_ action: @escaping () -> Void) {
        customBackAction = action
    }

    /// 替换导航栏右侧内容。
    open func setRightViews(_ views: [UIView]) {
        navigationBar.setRightViews(views)
    }

    /// 替换导航栏左侧内容。
    open func setLeftViews(_ views: [UIView]) {
        navigationBar.setLeftViews(views)
    }

    /// 显示或隐藏自定义导航栏，可选择动画更新布局。
    open func setNavigationBarHidden(_ hidden: Bool, animated: Bool = false) {
        navigationBarHidden = hidden
        if animated {
            UIView.animate(withDuration: 0.25) {
                self.view.layoutIfNeeded()
            }
        }
    }

    /// 默认返回逻辑。
    /// 优先 pop 导航栈；如果没有导航栈则尝试 dismiss。
    open func onBackButtonTapped() {
        if let customBackAction {
            customBackAction()
            return
        }

        if let navigationController, navigationController.viewControllers.first !== self {
            navigationController.popViewController(animated: true)
            return
        }

        if presentingViewController != nil {
            dismiss(animated: true)
        }
    }

    /// 创建容器层级并设置约束。
    private func setupUI() {
        view.backgroundColor = .systemBackground

        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(navigationBar)

        contentScrollView.translatesAutoresizingMaskIntoConstraints = false
        contentScrollView.alwaysBounceVertical = true
        contentScrollView.backgroundColor = contentBackgroundColor
        view.addSubview(contentScrollView)

        contentContainerView.translatesAutoresizingMaskIntoConstraints = false
        contentContainerView.tg_width.equal(.fill)
        contentContainerView.tg_height.equal(.wrap)
        contentScrollView.addSubview(contentContainerView)

        NSLayoutConstraint.activate([
            navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navigationBar.topAnchor.constraint(equalTo: view.topAnchor),

            contentScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentScrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        contentTopConstraint = contentScrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        contentTopConstraint?.isActive = true

        NSLayoutConstraint.activate([
            contentContainerView.leadingAnchor.constraint(equalTo: contentScrollView.contentLayoutGuide.leadingAnchor),
            contentContainerView.trailingAnchor.constraint(equalTo: contentScrollView.contentLayoutGuide.trailingAnchor),
            contentContainerView.topAnchor.constraint(equalTo: contentScrollView.contentLayoutGuide.topAnchor),
            contentContainerView.bottomAnchor.constraint(equalTo: contentScrollView.contentLayoutGuide.bottomAnchor),
            contentContainerView.widthAnchor.constraint(equalTo: contentScrollView.frameLayoutGuide.widthAnchor)
        ])
    }

    /// 将导航栏返回按钮绑定到控制器级处理方法。
    private func setupNavigationBar() {
        navigationBar.backButtonAction = { [weak self] in
            self?.onBackButtonTapped()
        }
        navigationBar.setBackButton(image: UIImage(systemName: "chevron.left"))
    }

    /// 根据导航栏显示状态重新计算内容起始位置。
    private func updateChromeVisibility() {
        navigationBar.isHidden = navigationBarHidden
        contentTopConstraint?.isActive = false
        if navigationBarHidden {
            contentTopConstraint = contentScrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: contentInsets.top)
        } else {
            contentTopConstraint = contentScrollView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: contentInsets.top)
        }
        contentTopConstraint?.isActive = true
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }

    /// 更新自定义导航栏在安全区下的总高度。
    private func updateNavigationBarHeight() {
        navigationBar.safeTopInset = view.safeAreaInsets.top
        navigationBar.contentHeight = navigationBarHeight
        view.setNeedsLayout()
    }

    /// 将滚动视图内边距同步到外部配置值。
    private func updateContentInsets() {
        contentScrollView.contentInset = contentInsets
        contentScrollView.scrollIndicatorInsets = contentInsets
        updateChromeVisibility()
    }
}
