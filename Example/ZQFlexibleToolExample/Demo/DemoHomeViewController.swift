//  DemoHomeViewController.swift
//  ZQFlexibleToolExample
//
//  Created by JessonZhang on 2026/01/12.
//
import UIKit
import ZQFlexibleTool
import TangramKit

final class DemoHomeViewController: ZQBaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBarTitle = "ZQFlexibleTool"
        contentBackgroundColor = UIColor(red: 0.96, green: 0.97, blue: 0.99, alpha: 1.0)

        let bannerView = makeBanner()
        let titleLabel = makeLabel(font: .systemFont(ofSize: 24, weight: .bold),
                                   text: "ZQFlexibleTool Example")
        let descriptionLabel = makeLabel(font: .systemFont(ofSize: 15),
                                         text: "This example demonstrates the base controller, custom navigation, tab bar red dot, file manager, permission manager, and daily tool extensions.")
        let actionHint = makeLabel(font: .systemFont(ofSize: 13, weight: .medium),
                                   text: "Tap any card below to open the corresponding module demo.")
        actionHint.textColor = .systemBlue

        let navButton = makeButton(title: "Navigation Demo", action: #selector(showNavigationDemo))
        let permissionButton = makeButton(title: "Permission Demo", action: #selector(showPermissionDemo))
        let fileButton = makeButton(title: "File Manager Demo", action: #selector(showFileDemo))
        let toolButton = makeButton(title: "Daily Tool Demo", action: #selector(showToolDemo))

        [bannerView, titleLabel, descriptionLabel, actionHint, navButton, permissionButton, fileButton, toolButton].forEach {
            addCardSubview($0)
        }

        contentContainerView.tg_padding = UIEdgeInsets(top: 16, left: 16, bottom: 24, right: 16)
        contentContainerView.tg_gravity = TGGravity.vert.fill
    }

    private func makeBanner() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.12)
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        view.tg_width.equal(.fill)
        view.tg_height.equal(120)

        let label = UILabel()
        label.numberOfLines = 0
        label.text = "Open the buttons below to inspect each module."
        label.textColor = .systemBlue
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textAlignment = .center
        label.tg_width.equal(.fill)
        label.tg_height.equal(.wrap)
        label.tg_centerY.equal(0)
        label.tg_centerX.equal(0)
        view.addSubview(label)
        return view
    }

    private func makeLabel(font: UIFont, text: String) -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = font
        label.text = text
        label.textColor = .label
        label.tg_width.equal(.fill)
        label.tg_height.equal(.wrap)
        label.tg_top.equal(12)
        label.tg_bottom.equal(12)
        return label
    }

    private func makeButton(title: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 12
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.06
        button.layer.shadowRadius = 10
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.masksToBounds = true
        button.contentEdgeInsets = UIEdgeInsets(top: 14, left: 16, bottom: 14, right: 16)
        button.addTarget(self, action: action, for: .touchUpInside)
        button.tg_width.equal(.fill)
        button.tg_height.equal(52)
        button.tg_top.equal(8)
        return button
    }

    private func addCardSubview(_ view: UIView) {
        contentContainerView.addSubview(view)
    }

    @objc private func showNavigationDemo() {
        navigationController?.pushViewController(DemoNavigationViewController(), animated: true)
    }

    @objc private func showPermissionDemo() {
        navigationController?.pushViewController(DemoPermissionViewController(), animated: true)
    }

    @objc private func showFileDemo() {
        navigationController?.pushViewController(DemoFileManagerViewController(), animated: true)
    }

    @objc private func showToolDemo() {
        navigationController?.pushViewController(DemoToolsViewController(), animated: true)
    }
}
