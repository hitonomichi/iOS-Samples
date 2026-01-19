# SampleDeviceMotion

AirPodsのモーションセンサー（CMHeadphoneMotionManager）を使用して、頭の動きを検知するiOSサンプルアプリです。

## 機能

- 頷き（上下）の検知
- 首振り（左右）の検知
- タイムスタンプ付きでログ表示

## 対応デバイス

- AirPods Pro
- AirPods（第3世代以降）

## 必要な設定

1. AirPodsをiPhoneに接続
2. 設定 > アクセシビリティ > AirPods > ヘッドジェスチャー をON
3. アプリ初回起動時にモーションアクセスを許可

## 動作環境

- iOS 14.0以降
- Xcode 14.0以降

## 構成

```
SampleDeviceMotion/
├── HeadphoneMotionManager.swift  # モーション検知ロジック
├── ViewController.swift          # UI制御・ログ表示
├── AppDelegate.swift
├── SceneDelegate.swift
└── Info.plist                    # NSMotionUsageDescription設定
```

## 技術詳細

- `CMHeadphoneMotionManager`を使用してAirPodsのモーションデータを取得
- pitch（前後の傾き）とyaw（左右の回転）の変化量から動きを判定
- 閾値: 約17度（0.3ラジアン）
- クールダウン: 0.5秒（連続検知防止）

## ライセンス

MIT License
