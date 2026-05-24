//  ZQDailyTool.swift
//  ZQFlexibleTool
//
//  Created by JessonZhang on 2026/01/12.
//
import UIKit

public enum ZQDailyTool {
    /// 从当前 keyWindow 的控制器链中获取最上层可见控制器。
    public static func topViewController(from rootViewController: UIViewController? = UIApplication.shared.zq_keyWindowRootViewController) -> UIViewController? {
        guard let rootViewController else { return nil }
        return rootViewController.zq_topMostViewController
    }

    /// 仅在 DEBUG 环境输出日志，避免正式包产生多余打印。
    public static func log(_ items: Any..., separator: String = " ", terminator: String = "\n") {
#if DEBUG
        let message = items.map { "\($0)" }.joined(separator: separator)
        Swift.print("[ZQFlexibleTool]", message, terminator: terminator)
#endif
    }

    /// 获取 App 的 Documents 目录。
    public static func documentsURL() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }

    /// 获取 App 的 Caches 目录。
    public static func cachesURL() -> URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
}

public extension UIApplication {
    /// 遍历当前场景，查找 keyWindow 对应的根控制器。
    var zq_keyWindowRootViewController: UIViewController? {
        connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?
            .rootViewController
    }
}

public extension UIViewController {
    /// 通过 presented、navigation、tab 层级递归查找当前最上层控制器。
    var zq_topMostViewController: UIViewController {
        if let presentedViewController {
            return presentedViewController.zq_topMostViewController
        }
        if let nav = self as? UINavigationController {
            return nav.visibleViewController?.zq_topMostViewController ?? nav
        }
        if let tab = self as? UITabBarController {
            return tab.selectedViewController?.zq_topMostViewController ?? tab
        }
        return self
    }
}

public extension String {
    /// 判断字符串是否只包含空格和换行。
    var zq_isBlank: Bool {
        trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// 去掉首尾空格和换行后的字符串。
    var zq_trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// 按整数起始位置安全截取子串。
    func zq_substring(from index: Int) -> String {
        guard index >= 0, index < count else { return "" }
        let start = self.index(self.startIndex, offsetBy: index)
        return String(self[start...])
    }

    /// 按整数结束位置安全截取子串。
    func zq_substring(to index: Int) -> String {
        guard index > 0, index <= count else { return "" }
        let end = self.index(self.startIndex, offsetBy: index)
        return String(self[..<end])
    }
}

public extension Array {
    /// 安全下标访问，越界时返回 nil。
    subscript(zq_safe index: Int) -> Element? {
        guard indices.contains(index) else { return nil }
        return self[index]
    }

    /// 安全删除元素，越界时不做任何操作。
    mutating func zq_removeSafely(at index: Int) {
        guard indices.contains(index) else { return }
        remove(at: index)
    }
}

public extension Dictionary {
    /// 合并另一个字典，重复 key 直接覆盖。
    mutating func zq_merge(_ other: [Key: Value]) {
        other.forEach { self[$0.key] = $0.value }
    }
}

public extension Date {
    /// 按指定格式和时区输出日期字符串。
    func zq_string(format: String = "yyyy-MM-dd HH:mm:ss", timeZone: TimeZone = .current) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.timeZone = timeZone
        return formatter.string(from: self)
    }
}

public extension UIColor {
    /// 通过 6 位十六进制字符串创建颜色，例如 #FF6600。
    convenience init?(zq_hex: String, alpha: CGFloat = 1.0) {
        var hex = zq_hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if hex.hasPrefix("#") { hex.removeFirst() }
        guard hex.count == 6, let value = Int(hex, radix: 16) else { return nil }
        self.init(
            red: CGFloat((value & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((value & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(value & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
}

public extension UIView {
    /// 让当前视图贴合到容器四边，可传入边距。
    func zq_pinToEdges(of container: UIView, insets: UIEdgeInsets = .zero) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: insets.left),
            trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -insets.right),
            topAnchor.constraint(equalTo: container.topAnchor, constant: insets.top),
            bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -insets.bottom)
        ])
    }
}
