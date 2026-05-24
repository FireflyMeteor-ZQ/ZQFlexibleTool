//  DemoToolsViewController.swift
//  ZQFlexibleToolExample
//
//  Created by JessonZhang on 2026/01/12.
//
import UIKit
import ZQFlexibleTool
import TangramKit

final class DemoToolsViewController: ZQBaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBarTitle = "Daily Tool"

        let textView = UITextView()
        textView.isEditable = false
        textView.font = .systemFont(ofSize: 15)
        textView.text = [
            "String blank: \("  demo  ".zq_isBlank)",
            "Trimmed: \("  demo  ".zq_trimmed)",
            "Substring from 2: \("Hello".zq_substring(from: 2))",
            "Safe array access: \(["a", "b"][zq_safe: 2] ?? "nil")",
            "Merged dictionary: \(Dictionary<String, Int>(dictionaryLiteral: ("a", 1)).merging(["b": 2], uniquingKeysWith: { $1 }).count)",
            "Date format: \(Date().zq_string())",
            "Hex color: \(UIColor(zq_hex: "#FF6600") != nil)",
            "Top VC available: \(ZQDailyTool.topViewController() != nil)"
        ].joined(separator: "\n")

        addContentSubview(textView)
        textView.tg_width.equal(.fill)
        textView.tg_height.equal(260)
        textView.tg_top.equal(12)
        contentContainerView.tg_padding = UIEdgeInsets(top: 16, left: 16, bottom: 24, right: 16)
        contentContainerView.tg_gravity = TGGravity.vert.fill
    }
}
