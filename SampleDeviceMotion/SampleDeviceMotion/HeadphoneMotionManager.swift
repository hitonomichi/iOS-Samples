//
//  HeadphoneMotionManager.swift
//  SampleDeviceMotion
//

import Foundation
import CoreMotion

enum HeadGesture {
    case up
    case down
    case left
    case right

    var description: String {
        switch self {
        case .up: return "上"
        case .down: return "下"
        case .left: return "左"
        case .right: return "右"
        }
    }
}

protocol HeadphoneMotionManagerDelegate: AnyObject {
    func headphoneMotionManager(_ manager: HeadphoneMotionManager, didDetect gesture: HeadGesture)
    func headphoneMotionManager(_ manager: HeadphoneMotionManager, didUpdateDebugInfo info: String)
}

class HeadphoneMotionManager {

    weak var delegate: HeadphoneMotionManagerDelegate?

    private let motionManager = CMHeadphoneMotionManager()

    // ジェスチャー検知の閾値（ラジアン/フレーム）
    private let pitchThreshold: Double = 0.04  // 約2.3度/フレーム
    private let yawThreshold: Double = 0.04    // 約2.3度/フレーム

    // 前回の値を保持
    private var previousPitch: Double?
    private var previousYaw: Double?

    // 連続検知防止のためのタイムスタンプ
    private var lastGestureTime: Date = Date.distantPast
    private let cooldownInterval: TimeInterval = 0.5

    var isAvailable: Bool {
        return motionManager.isDeviceMotionAvailable
    }

    func startUpdates() {
        guard motionManager.isDeviceMotionAvailable else {
            delegate?.headphoneMotionManager(self, didUpdateDebugInfo: "❌ Headphone motion is not available")
            return
        }

        delegate?.headphoneMotionManager(self, didUpdateDebugInfo: "✅ モーション監視を開始...")

        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
            guard let self = self else { return }

            if let error = error {
                self.delegate?.headphoneMotionManager(self, didUpdateDebugInfo: "❌ エラー: \(error.localizedDescription)")
                return
            }

            guard let motion = motion else {
                return
            }
            self.processMotion(motion)
        }
    }

    func stopUpdates() {
        motionManager.stopDeviceMotionUpdates()
        previousPitch = nil
        previousYaw = nil
    }

    private var debugUpdateCounter = 0

    private func processMotion(_ motion: CMDeviceMotion) {
        let currentPitch = motion.attitude.pitch
        let currentYaw = motion.attitude.yaw

        defer {
            previousPitch = currentPitch
            previousYaw = currentYaw
        }

        guard let prevPitch = previousPitch, let prevYaw = previousYaw else {
            // 初回データ受信
            let info = "📡 初回データ受信 pitch=\(String(format: "%.3f", currentPitch)) yaw=\(String(format: "%.3f", currentYaw))"
            delegate?.headphoneMotionManager(self, didUpdateDebugInfo: info)
            return
        }

        let pitchDelta = currentPitch - prevPitch
        let yawDelta = currentYaw - prevYaw

        // 10回に1回デバッグ情報を出力
        debugUpdateCounter += 1
        if debugUpdateCounter >= 10 {
            debugUpdateCounter = 0
            let info = "pitch=\(String(format: "%.3f", currentPitch)) Δ=\(String(format: "%+.3f", pitchDelta)) | yaw=\(String(format: "%.3f", currentYaw)) Δ=\(String(format: "%+.3f", yawDelta))"
            delegate?.headphoneMotionManager(self, didUpdateDebugInfo: info)
        }

        // クールダウン中は検知しない
        guard Date().timeIntervalSince(lastGestureTime) > cooldownInterval else {
            return
        }

        // 上下の検知（pitchの変化）
        if abs(pitchDelta) > pitchThreshold {
            let gesture: HeadGesture = pitchDelta > 0 ? .up : .down
            notifyGesture(gesture)
            return
        }

        // 左右の検知（yawの変化）
        if abs(yawDelta) > yawThreshold {
            let gesture: HeadGesture = yawDelta > 0 ? .left : .right
            notifyGesture(gesture)
            return
        }
    }

    private func notifyGesture(_ gesture: HeadGesture) {
        lastGestureTime = Date()
        delegate?.headphoneMotionManager(self, didDetect: gesture)
    }
}
