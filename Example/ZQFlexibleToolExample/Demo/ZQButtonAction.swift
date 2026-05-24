//  ZQButtonActionTrampoline.swift
//  ZQFlexibleToolExample
//
//  Created by JessonZhang on 2026/01/12.
//
import UIKit

final class ZQButtonActionTrampoline: NSObject {
    let action: () -> Void

    init(action: @escaping () -> Void) {
        self.action = action
    }

    @objc func invoke() {
        action()
    }
}

private var zqButtonActionKey: UInt8 = 0

extension UIButton {
    func zq_setOnTapAction(_ action: @escaping () -> Void) {
        let trampoline = ZQButtonActionTrampoline(action: action)
        objc_setAssociatedObject(self, &zqButtonActionKey, trampoline, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        addTarget(trampoline, action: #selector(ZQButtonActionTrampoline.invoke), for: .touchUpInside)
    }
}
