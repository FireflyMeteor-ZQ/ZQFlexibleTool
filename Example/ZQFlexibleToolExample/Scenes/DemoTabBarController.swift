//  DemoTabBarController.swift
//  ZQFlexibleToolExample
//
//  Created by JessonZhang on 2026/01/12.
//
import UIKit
import ZQFlexibleTool

final class DemoTabBarController: ZQTabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        appearance.normalTitleColor = .secondaryLabel
        appearance.selectedTitleColor = .systemBlue
        appearance.backgroundColor = .systemBackground
        appearance.isTranslucent = false
        appearance.actionItemImageInsets = UIEdgeInsets(top: -12, left: 0, bottom: 12, right: 0)
        appearance.actionItemTitleOffset = UIOffset(horizontal: 0, vertical: 4)

        configure(items: [
            ZQTabBarItemConfiguration(viewController: DemoHomeViewController(),
                                      title: "Home",
                                      normalImage: UIImage(systemName: "house"),
                                      selectedImage: UIImage(systemName: "house.fill")),
            ZQTabBarItemConfiguration(viewController: DemoToolsViewController(),
                                      title: "Action",
                                      normalImage: UIImage(systemName: "plus.circle.fill"),
                                      selectedImage: UIImage(systemName: "plus.circle.fill"),
                                      isActionItem: true,
                                      actionHandler: {
                                          print("Special action item tapped")
                                      },
                                      tabBarItemConfiguration: { item in
                                          item.imageInsets = UIEdgeInsets(top: -8, left: 0, bottom: 8, right: 0)
                                      }),
            ZQTabBarItemConfiguration(viewController: DemoToolsViewController(),
                                      title: "Tools",
                                      normalImage: UIImage(systemName: "wrench.and.screwdriver"),
                                      selectedImage: UIImage(systemName: "wrench.and.screwdriver.fill"),
                                      badgeValue: "3",
                                      badgeColor: .systemRed)
        ])
    }
}
