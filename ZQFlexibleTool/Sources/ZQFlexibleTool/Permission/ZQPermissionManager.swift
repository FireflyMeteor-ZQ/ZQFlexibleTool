//  ZQPermissionManager.swift
//  ZQFlexibleTool
//
//  Created by JessonZhang on 2026/01/12.
//
import UIKit
import AVFoundation
import Photos
import CoreLocation
import Contacts
import EventKit
import UserNotifications
import CoreBluetooth
import AppTrackingTransparency

public enum ZQPermissionType {
    /// 相机权限。
    case camera
    /// 相册权限。
    case photos
    /// 麦克风权限。
    case microphone
    /// 使用期间定位权限。
    case locationWhenInUse
    /// 始终定位权限。
    case locationAlways
    /// 通讯录权限。
    case contacts
    /// 日历权限。
    case calendar
    /// 提醒事项权限。
    case reminders
    /// 本地通知权限。
    case notifications
    /// 蓝牙权限。
    case bluetooth
    /// App Tracking Transparency 追踪权限。
    case tracking
}

public enum ZQPermissionStatus: Equatable {
    /// 还未弹出过授权框。
    case notDetermined
    /// 系统限制或家长控制导致不可用。
    case restricted
    /// 用户已拒绝。
    case denied
    /// 用户已授权。
    case authorized
    /// 部分授权，当前主要用于相册。
    case limited
    /// 平台特有状态，无法明确映射时使用。
    case unknown
}

public final class ZQPermissionManager {
    public static let shared = ZQPermissionManager()

    private let eventStore = EKEventStore()
    private let contactStore = CNContactStore()
    private var locationProxy: ZQLocationProxy?
    private var bluetoothProxy: ZQBluetoothProxy?

    private init() {}

    /// 仅查询当前权限状态，不会主动弹出系统授权框。
    public func status(for type: ZQPermissionType) -> ZQPermissionStatus {
        switch type {
        case .camera:
            return Self.mapAVAuthorization(AVCaptureDevice.authorizationStatus(for: .video))
        case .photos:
            if #available(iOS 14, *) {
                return Self.mapPhotoAuthorization(PHPhotoLibrary.authorizationStatus(for: .readWrite))
            } else {
                return Self.mapPhotoAuthorization(PHPhotoLibrary.authorizationStatus())
            }
        case .microphone:
            return Self.mapRecordPermission(AVAudioSession.sharedInstance().recordPermission)
        case .locationWhenInUse, .locationAlways:
            return Self.mapLocationAuthorization(CLLocationManager.authorizationStatus())
        case .contacts:
            return Self.mapContactAuthorization(CNContactStore.authorizationStatus(for: .contacts))
        case .calendar:
            return Self.mapAuthorization(EKEventStore.authorizationStatus(for: .event))
        case .reminders:
            return Self.mapAuthorization(EKEventStore.authorizationStatus(for: .reminder))
        case .notifications:
            return .unknown
        case .bluetooth:
            if #available(iOS 13.1, *) {
                return Self.mapBluetoothAuthorization(CBManager.authorization)
            } else {
                return .unknown
            }
        case .tracking:
            if #available(iOS 14, *) {
                return Self.mapTrackingAuthorization(ATTrackingManager.trackingAuthorizationStatus)
            } else {
                return .authorized
            }
        }
    }

    /// 主动请求权限，并在主线程返回最终状态。
    public func request(_ type: ZQPermissionType, completion: @escaping (ZQPermissionStatus) -> Void) {
        switch type {
        case .camera:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                self.finish(granted ? .authorized : .denied, completion)
            }
        case .photos:
            if #available(iOS 14, *) {
                PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                    self.finish(Self.mapPhotoAuthorization(status), completion)
                }
            } else {
                PHPhotoLibrary.requestAuthorization { status in
                    self.finish(Self.mapPhotoAuthorization(status), completion)
                }
            }
        case .microphone:
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                self.finish(granted ? .authorized : .denied, completion)
            }
        case .locationWhenInUse:
            requestLocation(kind: .whenInUse, completion: completion)
        case .locationAlways:
            requestLocation(kind: .always, completion: completion)
        case .contacts:
            contactStore.requestAccess(for: .contacts) { granted, _ in
                self.finish(granted ? .authorized : .denied, completion)
            }
        case .calendar:
            eventStore.requestAccess(to: .event) { granted, _ in
                self.finish(granted ? .authorized : .denied, completion)
            }
        case .reminders:
            eventStore.requestAccess(to: .reminder) { granted, _ in
                self.finish(granted ? .authorized : .denied, completion)
            }
        case .notifications:
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
                self.finish(granted ? .authorized : .denied, completion)
            }
        case .bluetooth:
            requestBluetooth(completion: completion)
        case .tracking:
            if #available(iOS 14, *) {
                ATTrackingManager.requestTrackingAuthorization { status in
                    self.finish(Self.mapTrackingAuthorization(status), completion)
                }
            } else {
                finish(.authorized, completion)
            }
        }
    }

    /// 打开系统设置页，方便用户手动调整权限。
    public func openAppSettings(completion: (() -> Void)? = nil) {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: { _ in
            completion?()
        })
    }

    /// 封装定位权限流程，对外返回统一状态。
    private func requestLocation(kind: LocationRequestKind, completion: @escaping (ZQPermissionStatus) -> Void) {
        let proxy = ZQLocationProxy()
        proxy.completion = { status in
            self.finish(status, completion)
        }
        locationProxy = proxy

        let manager = CLLocationManager()
        manager.delegate = proxy
        proxy.manager = manager

        switch kind {
        case .whenInUse:
            manager.requestWhenInUseAuthorization()
        case .always:
            manager.requestAlwaysAuthorization()
        }
    }

    /// 封装蓝牙中心管理器授权流程。
    private func requestBluetooth(completion: @escaping (ZQPermissionStatus) -> Void) {
        if #available(iOS 13.0, *) {
            let proxy = ZQBluetoothProxy()
            proxy.completion = { status in
                self.finish(status, completion)
            }
            bluetoothProxy = proxy
            proxy.manager = CBCentralManager(delegate: proxy, queue: .main, options: [CBCentralManagerOptionShowPowerAlertKey: true])
        } else {
            finish(.unknown, completion)
        }
    }

    /// 保证回调总是在主线程执行。
    private func finish(_ status: ZQPermissionStatus, _ completion: @escaping (ZQPermissionStatus) -> Void) {
        DispatchQueue.main.async {
            completion(status)
        }
    }

    private enum LocationRequestKind {
        case whenInUse
        case always
    }

    /// 将 AVFoundation 授权状态映射为统一状态。
    private static func mapAVAuthorization(_ status: AVAuthorizationStatus) -> ZQPermissionStatus {
        switch status {
        case .notDetermined: return .notDetermined
        case .restricted: return .restricted
        case .denied: return .denied
        case .authorized: return .authorized
        default: return .unknown
        }
    }

    /// 将相册授权状态映射为统一状态。
    private static func mapPhotoAuthorization(_ status: PHAuthorizationStatus) -> ZQPermissionStatus {
        switch status {
        case .notDetermined: return .notDetermined
        case .restricted: return .restricted
        case .denied: return .denied
        case .authorized: return .authorized
        case .limited: return .limited
        default: return .unknown
        }
    }

    /// 将麦克风录音授权状态映射为统一状态。
    private static func mapRecordPermission(_ permission: AVAudioSession.RecordPermission) -> ZQPermissionStatus {
        switch permission {
        case .undetermined: return .notDetermined
        case .denied: return .denied
        case .granted: return .authorized
        default: return .unknown
        }
    }

    /// 将 Core Location 授权状态映射为统一状态。
    private static func mapLocationAuthorization(_ status: CLAuthorizationStatus) -> ZQPermissionStatus {
        switch status {
        case .notDetermined: return .notDetermined
        case .restricted: return .restricted
        case .denied: return .denied
        case .authorizedAlways, .authorizedWhenInUse: return .authorized
        case .authorized: return .authorized
        default: return .unknown
        }
    }

    /// 将 EventKit 授权状态映射为统一状态。
    private static func mapAuthorization(_ status: EKAuthorizationStatus) -> ZQPermissionStatus {
        switch status {
        case .notDetermined: return .notDetermined
        case .restricted: return .restricted
        case .denied: return .denied
        case .authorized: return .authorized
        case .fullAccess, .writeOnly:
            return .authorized
        default: return .unknown
        }
    }

    /// 将通讯录授权状态映射为统一状态。
    private static func mapContactAuthorization(_ status: CNAuthorizationStatus) -> ZQPermissionStatus {
        switch status {
        case .notDetermined: return .notDetermined
        case .restricted: return .restricted
        case .denied: return .denied
        case .authorized: return .authorized
        case .limited:
            return .limited
        default: return .unknown
        }
    }

    /// 将蓝牙授权状态映射为统一状态。
    private static func mapBluetoothAuthorization(_ authorization: CBManagerAuthorization) -> ZQPermissionStatus {
        switch authorization {
        case .notDetermined: return .notDetermined
        case .restricted: return .restricted
        case .denied: return .denied
        case .allowedAlways: return .authorized
        default: return .unknown
        }
    }

    /// 将 ATT 追踪授权状态映射为统一状态。
    @available(iOS 14, *)
    private static func mapTrackingAuthorization(_ status: ATTrackingManager.AuthorizationStatus) -> ZQPermissionStatus {
        switch status {
        case .notDetermined: return .notDetermined
        case .restricted: return .restricted
        case .denied: return .denied
        case .authorized: return .authorized
        default: return .unknown
        }
    }
}

private final class ZQLocationProxy: NSObject, CLLocationManagerDelegate {
    var manager: CLLocationManager?
    var completion: ((ZQPermissionStatus) -> Void)?

    /// iOS 14 及以上版本的定位授权变化回调。
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        completion?(ZQPermissionManager.shared.status(for: .locationWhenInUse))
    }

    /// 旧版本系统使用的定位授权变化回调。
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        completion?(ZQPermissionManager.shared.status(for: .locationWhenInUse))
    }
}

private final class ZQBluetoothProxy: NSObject, CBCentralManagerDelegate {
    var manager: CBCentralManager?
    var completion: ((ZQPermissionStatus) -> Void)?

    /// 中心管理器状态更新后重新评估蓝牙授权。
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if #available(iOS 13.1, *) {
            completion?(ZQPermissionManager.shared.status(for: .bluetooth))
        } else {
            completion?(.unknown)
        }
    }
}
