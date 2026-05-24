//  DemoNavigationViewController.swift
//  ZQFlexibleToolExample
//
//  Created by JessonZhang on 2026/01/12.
//
import UIKit
import ZQFlexibleTool
import TangramKit

final class DemoNavigationViewController: ZQBaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBarTitle = "Navigation Demo"

        let infoLabel = UILabel()
        infoLabel.numberOfLines = 0
        infoLabel.text = "This page demonstrates custom back handling, title control, and the ability to hide/show the custom navigation bar."
        infoLabel.tg_width.equal(.fill)
        infoLabel.tg_height.equal(.wrap)

        let hideButton = makeButton(title: "Hide Navigation Bar") { [weak self] in
            self?.setNavigationBarHidden(true, animated: true)
        }
        let showButton = makeButton(title: "Show Navigation Bar") { [weak self] in
            self?.setNavigationBarHidden(false, animated: true)
        }
        let backButton = makeButton(title: "Custom Back Action") { [weak self] in
            self?.setBackAction {
                ZQDailyTool.log("Custom back action executed")
                self?.navigationController?.popViewController(animated: true)
            }
        }

        [infoLabel, hideButton, showButton, backButton].forEach { contentContainerView.addSubview($0) }
        contentContainerView.tg_padding = UIEdgeInsets(top: 16, left: 16, bottom: 24, right: 16)
        contentContainerView.tg_gravity = TGGravity.vert.fill
    }

    private func makeButton(title: String, action: @escaping () -> Void) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = false
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.05
        button.layer.shadowRadius = 8
        button.layer.shadowOffset = CGSize(width: 0, height: 3)
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        button.zq_setOnTapAction(action)
        button.tg_width.equal(.fill)
        button.tg_height.equal(48)
        button.tg_top.equal(10)
        return button
    }
}
