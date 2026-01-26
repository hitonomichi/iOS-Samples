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

    private var debugLabel: UILabel!

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
        1. AirPodsをiPhoneに接続
        2. 設定 > AirPods（自分のAirPodの名前） > 頭のジェスチャー をON
        3. アプリ初回起動時にモーションアクセスを許可
        """
        instructionLabel.layer.cornerRadius = 8
        instructionLabel.clipsToBounds = true

        // デバッグラベルを追加
        debugLabel = UILabel()
        debugLabel.translatesAutoresizingMaskIntoConstraints = false
        debugLabel.font = UIFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        debugLabel.textColor = .systemGray
        debugLabel.numberOfLines = 2
        debugLabel.text = "待機中..."
        view.addSubview(debugLabel)

        NSLayoutConstraint.activate([
            debugLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            debugLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            debugLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8)
        ])

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

    func headphoneMotionManager(_ manager: HeadphoneMotionManager, didUpdateDebugInfo info: String) {
        debugLabel.text = info
        print("[Debug] \(info)")
    }
}

