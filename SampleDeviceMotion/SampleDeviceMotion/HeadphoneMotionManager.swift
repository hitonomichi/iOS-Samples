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
}

class HeadphoneMotionManager {

    weak var delegate: HeadphoneMotionManagerDelegate?

    private let motionManager = CMHeadphoneMotionManager()

    // ジェスチャー検知の閾値（ラジアン）
    private let pitchThreshold: Double = 0.3  // 約17度
    private let yawThreshold: Double = 0.3    // 約17度

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
            print("Headphone motion is not available")
            return
        }

        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
            guard let self = self, let motion = motion else { return }
            self.processMotion(motion)
        }
    }

    func stopUpdates() {
        motionManager.stopDeviceMotionUpdates()
        previousPitch = nil
        previousYaw = nil
    }

    private func processMotion(_ motion: CMDeviceMotion) {
        let currentPitch = motion.attitude.pitch
        let currentYaw = motion.attitude.yaw

        defer {
            previousPitch = currentPitch
            previousYaw = currentYaw
        }

        guard let prevPitch = previousPitch, let prevYaw = previousYaw else {
            return
        }

        // クールダウン中は検知しない
        guard Date().timeIntervalSince(lastGestureTime) > cooldownInterval else {
            return
        }

        let pitchDelta = currentPitch - prevPitch
        let yawDelta = currentYaw - prevYaw

        // 上下の検知（pitchの変化）
        if abs(pitchDelta) > pitchThreshold {
            let gesture: HeadGesture = pitchDelta > 0 ? .down : .up
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
