//  ZQFileManagerService.swift
//  ZQFlexibleTool
//
//  Created by JessonZhang on 2026/01/12.
//
import Foundation

public enum ZQFileDirectory {
    /// 该服务支持的常用沙盒目录。
    case documents
    case library
    case caches
    case temporary
    case applicationSupport
    case custom(URL)

    /// 将目录枚举解析为真实 URL。
    var url: URL {
        switch self {
        case .documents:
            return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        case .library:
            return FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first!
        case .caches:
            return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        case .temporary:
            return FileManager.default.temporaryDirectory
        case .applicationSupport:
            return FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        case .custom(let url):
            return url
        }
    }
}

public final class ZQFileManagerService {
    public static let shared = ZQFileManagerService()
    private let fileManager = FileManager.default

    private init() {}

    /// 获取某个沙盒目录的 URL，并可选拼接子路径。
    public func directoryURL(_ directory: ZQFileDirectory, appendingPathComponent path: String? = nil) -> URL {
        guard let path else { return directory.url }
        return directory.url.appendingPathComponent(path)
    }

    /// 创建目录，如果中间层级不存在会自动补齐。
    public func createDirectory(at url: URL) throws {
        try fileManager.createDirectory(at: url, withIntermediateDirectories: true)
    }

    /// 判断指定 URL 是否存在文件或目录。
    public func fileExists(at url: URL) -> Bool {
        fileManager.fileExists(atPath: url.path)
    }

    /// 先创建父目录，再以原子方式写入二进制数据。
    public func write(_ data: Data, to url: URL) throws {
        let parent = url.deletingLastPathComponent()
        try createDirectory(at: parent)
        try data.write(to: url, options: .atomic)
    }

    /// 将字符串编码后写入磁盘。
    public func write(_ string: String, to url: URL, encoding: String.Encoding = .utf8) throws {
        guard let data = string.data(using: encoding) else {
            throw NSError(domain: "ZQFileManagerService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to encode string"])
        }
        try write(data, to: url)
    }

    /// 以 Data 形式读取文件内容。
    public func readData(from url: URL) throws -> Data {
        try Data(contentsOf: url)
    }

    /// 读取文件内容并解码为字符串。
    public func readString(from url: URL, encoding: String.Encoding = .utf8) throws -> String {
        let data = try readData(from: url)
        guard let string = String(data: data, encoding: encoding) else {
            throw NSError(domain: "ZQFileManagerService", code: -2, userInfo: [NSLocalizedDescriptionKey: "Unable to decode string"])
        }
        return string
    }

    /// 删除指定文件或目录，不存在时直接忽略。
    public func deleteItem(at url: URL) throws {
        guard fileExists(at: url) else { return }
        try fileManager.removeItem(at: url)
    }

    /// 移动文件到目标路径，若目标已存在则先删除。
    public func moveItem(at sourceURL: URL, to destinationURL: URL) throws {
        try createDirectory(at: destinationURL.deletingLastPathComponent())
        if fileExists(at: destinationURL) {
            try deleteItem(at: destinationURL)
        }
        try fileManager.moveItem(at: sourceURL, to: destinationURL)
    }

    /// 复制文件到目标路径，若目标已存在则先删除。
    public func copyItem(at sourceURL: URL, to destinationURL: URL) throws {
        try createDirectory(at: destinationURL.deletingLastPathComponent())
        if fileExists(at: destinationURL) {
            try deleteItem(at: destinationURL)
        }
        try fileManager.copyItem(at: sourceURL, to: destinationURL)
    }

    /// 列出目录下的一级子项。
    public func listItems(in directory: URL) throws -> [URL] {
        try fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
    }

    /// 清空目录下所有一级子项。
    public func clearDirectory(_ directory: URL) throws {
        let items = try listItems(in: directory)
        for item in items {
            try deleteItem(at: item)
        }
    }

    /// 获取单个文件大小，单位为字节。
    public func itemSize(at url: URL) throws -> Int64 {
        let attributes = try fileManager.attributesOfItem(atPath: url.path)
        return attributes[.size] as? Int64 ?? 0
    }

    /// 统计目录下所有一级子项的总大小，单位为字节。
    public func totalSize(in directory: URL) throws -> Int64 {
        let items = try listItems(in: directory)
        var total: Int64 = 0
        for item in items {
            total += (try? itemSize(at: item)) ?? 0
        }
        return total
    }

    /// 将任意 Codable 数据编码后保存到磁盘。
    public func saveCodable<T: Codable>(_ value: T, to url: URL, encoder: JSONEncoder = JSONEncoder()) throws {
        let data = try encoder.encode(value)
        try write(data, to: url)
    }

    /// 从磁盘读取并解码任意 Codable 数据。
    public func loadCodable<T: Codable>(_ type: T.Type, from url: URL, decoder: JSONDecoder = JSONDecoder()) throws -> T {
        let data = try readData(from: url)
        return try decoder.decode(T.self, from: data)
    }
}
