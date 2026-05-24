//  DemoFileManagerViewController.swift
//  ZQFlexibleToolExample
//
//  Created by JessonZhang on 2026/01/12.
//
import UIKit
import ZQFlexibleTool
import TangramKit

final class DemoFileManagerViewController: ZQBaseViewController {
    private let resultLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBarTitle = "File Manager"

        resultLabel.numberOfLines = 0
        resultLabel.text = "File manager demo."
        resultLabel.tg_width.equal(.fill)
        resultLabel.tg_height.equal(.wrap)

        let saveButton = makeButton(title: "Save Sample Text") { [weak self] in
            self?.saveSampleText()
        }
        let readButton = makeButton(title: "Read Sample Text") { [weak self] in
            self?.readSampleText()
        }
        let deleteButton = makeButton(title: "Delete Sample Text") { [weak self] in
            self?.deleteSampleText()
        }

        [resultLabel, saveButton, readButton, deleteButton].forEach { contentContainerView.addSubview($0) }
    }

    private func sampleURL() -> URL {
        ZQFileManagerService.shared
            .directoryURL(.caches, appendingPathComponent: "ZQFlexibleToolDemo/sample.txt")
    }

    private func saveSampleText() {
        do {
            try ZQFileManagerService.shared.write("Hello from ZQFlexibleTool", to: sampleURL())
            resultLabel.text = "Saved to: \(sampleURL().path)"
        } catch {
            resultLabel.text = "Save failed: \(error.localizedDescription)"
        }
    }

    private func readSampleText() {
        do {
            let content = try ZQFileManagerService.shared.readString(from: sampleURL())
            resultLabel.text = "Read: \(content)"
        } catch {
            resultLabel.text = "Read failed: \(error.localizedDescription)"
        }
    }

    private func deleteSampleText() {
        do {
            try ZQFileManagerService.shared.deleteItem(at: sampleURL())
            resultLabel.text = "Deleted sample file."
        } catch {
            resultLabel.text = "Delete failed: \(error.localizedDescription)"
        }
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
