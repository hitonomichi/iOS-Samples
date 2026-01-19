//
//  ViewController.swift
//  SampleDeviceMotion
//
//  Created by 高浜一道 on 2026/01/19.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var logTextView: UITextView!

    private let headphoneMotionManager = HeadphoneMotionManager()
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupMotionManager()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        headphoneMotionManager.startUpdates()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        headphoneMotionManager.stopUpdates()
    }

    private func setupUI() {
        // 準備手順を表示
        instructionLabel.text = """
        【準備】
        1. AirPods Pro または AirPods（第3世代以降）を接続
        2. 設定 > アクセシビリティ > AirPods > ヘッドジェスチャー をON
        3. 初回起動時にモーションアクセスを許可
        """
        instructionLabel.layer.cornerRadius = 8
        instructionLabel.clipsToBounds = true

        logTextView.isEditable = false
        logTextView.font = UIFont.monospacedSystemFont(ofSize: 16, weight: .regular)
        logTextView.text = ""

        if !headphoneMotionManager.isAvailable {
            logTextView.text = "AirPodsが接続されていないか、対応していません"
        }
    }

    private func setupMotionManager() {
        headphoneMotionManager.delegate = self
    }

    private func addLog(_ gesture: HeadGesture) {
        let timestamp = dateFormatter.string(from: Date())
        let logEntry = "\(timestamp) \(gesture.description)"

        if logTextView.text.isEmpty {
            logTextView.text = logEntry
        } else {
            logTextView.text = logEntry + "\n" + logTextView.text
        }
    }
}

extension ViewController: HeadphoneMotionManagerDelegate {
    func headphoneMotionManager(_ manager: HeadphoneMotionManager, didDetect gesture: HeadGesture) {
        addLog(gesture)
    }
}

