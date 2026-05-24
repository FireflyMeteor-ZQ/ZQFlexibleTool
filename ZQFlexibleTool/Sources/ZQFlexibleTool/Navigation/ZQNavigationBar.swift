//  ZQNavigationBar.swift
//  ZQFlexibleTool
//
//  Created by JessonZhang on 2026/01/12.
//
import UIKit

public final class ZQNavigationBar: UIView {
    /// 承载导航栏内容的容器视图。
    public let contentView = UIView()
    /// 顶部安全区占位视图，用于刘海屏和状态栏区域。
    public let topInsetView = UIView()
    /// 左侧操作区。
    public let leftStackView = UIStackView()
    /// 右侧操作区。
    public let rightStackView = UIStackView()
    /// 中间标题。
    public let titleLabel = UILabel()
    /// 底部分割线。
    public let bottomLineView = UIView()
    /// 基础控制器默认使用的返回按钮。
    public let backButton = UIButton(type: .system)

    /// 返回按钮点击回调。
    public var backButtonAction: (() -> Void)?
    /// 控制底部分割线是否显示。
    public var showBottomLine: Bool = true {
        didSet { bottomLineView.isHidden = !showBottomLine }
    }
    /// 可见内容高度，不包含安全区顶部高度。
    public var contentHeight: CGFloat = 44 {
        didSet { invalidateIntrinsicContentSize() }
    }
    /// 安全区顶部高度，会叠加到总高度里。
    public var safeTopInset: CGFloat = 0 {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    public override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: contentHeight + safeTopInset)
    }

    /// 设置导航标题文本。
    public func setTitle(_ title: String?) {
        titleLabel.text = title
    }

    /// 替换默认返回图标。
    public func setBackButton(image: UIImage?) {
        backButton.setImage(image, for: .normal)
    }

    /// 显示或隐藏默认返回按钮。
    public func setBackButtonHidden(_ hidden: Bool) {
        backButton.isHidden = hidden
    }

    /// 替换左侧操作区的所有视图。
    public func setLeftViews(_ views: [UIView]) {
        leftStackView.arrangedSubviews.forEach {
            leftStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        views.forEach { leftStackView.addArrangedSubview($0) }
    }

    /// 替换右侧操作区的所有视图。
    public func setRightViews(_ views: [UIView]) {
        rightStackView.arrangedSubviews.forEach {
            rightStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        views.forEach { rightStackView.addArrangedSubview($0) }
    }

    /// 构建视图层级并应用默认样式。
    private func setupUI() {
        backgroundColor = .clear
        translatesAutoresizingMaskIntoConstraints = false

        topInsetView.translatesAutoresizingMaskIntoConstraints = false
        topInsetView.backgroundColor = .systemBackground
        addSubview(topInsetView)

        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = .systemBackground
        addSubview(contentView)

        bottomLineView.translatesAutoresizingMaskIntoConstraints = false
        bottomLineView.backgroundColor = .separator
        contentView.addSubview(bottomLineView)

        leftStackView.translatesAutoresizingMaskIntoConstraints = false
        leftStackView.axis = .horizontal
        leftStackView.alignment = .center
        leftStackView.spacing = 8
        contentView.addSubview(leftStackView)

        rightStackView.translatesAutoresizingMaskIntoConstraints = false
        rightStackView.axis = .horizontal
        rightStackView.alignment = .center
        rightStackView.spacing = 8
        contentView.addSubview(rightStackView)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
        titleLabel.lineBreakMode = .byTruncatingTail
        contentView.addSubview(titleLabel)

        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.tintColor = .label
        backButton.setTitle(nil, for: .normal)
        backButton.contentHorizontalAlignment = .left
        backButton.addTarget(self, action: #selector(handleBackButton), for: .touchUpInside)
        leftStackView.addArrangedSubview(backButton)

        NSLayoutConstraint.activate([
            topInsetView.leadingAnchor.constraint(equalTo: leadingAnchor),
            topInsetView.trailingAnchor.constraint(equalTo: trailingAnchor),
            topInsetView.topAnchor.constraint(equalTo: topAnchor),
            topInsetView.heightAnchor.constraint(equalToConstant: safeTopInset),

            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.topAnchor.constraint(equalTo: topInsetView.bottomAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        NSLayoutConstraint.activate([
            leftStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            leftStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            leftStackView.topAnchor.constraint(equalTo: contentView.topAnchor),

            rightStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            rightStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            rightStackView.topAnchor.constraint(equalTo: contentView.topAnchor),

            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: leftStackView.trailingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: rightStackView.leadingAnchor, constant: -8),

            bottomLineView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bottomLineView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bottomLineView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            bottomLineView.heightAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale)
        ])

        showBottomLine = true
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        // 安全区高度变化时，让顶部占位区域和总高度同步更新。
        if let heightConstraint = topInsetView.constraints.first(where: { $0.firstAttribute == .height }) {
            heightConstraint.constant = safeTopInset
        }
    }

    /// 触发配置的返回回调。
    @objc private func handleBackButton() {
        backButtonAction?()
    }
}
