//  DemoPermissionViewController.swift
//  ZQFlexibleToolExample
//
//  Created by JessonZhang on 2026/01/12.
//
import UIKit
import ZQFlexibleTool
import TangramKit

final class DemoPermissionViewController: ZQBaseViewController {
    private let statusLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBarTitle = "Permissions"

        statusLabel.numberOfLines = 0
        statusLabel.text = "Tap a button to request a permission."
        addContentSubview(statusLabel)

        let cameraButton = makeButton(title: "Request Camera") { [weak self] in
            ZQPermissionManager.shared.request(.camera) { status in
                self?.statusLabel.text = "Camera: \(status)"
            }
        }

        let photoButton = makeButton(title: "Request Photos") { [weak self] in
            ZQPermissionManager.shared.request(.photos) { status in
                self?.statusLabel.text = "Photos: \(status)"
            }
        }

        let settingButton = makeButton(title: "Open Settings") {
            ZQPermissionManager.shared.openAppSettings()
        }

        [cameraButton, photoButton, settingButton].forEach { addContentSubview($0) }
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
        return button
    }
}
