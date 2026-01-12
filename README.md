# FitAvatar

FitAvatarは、ワークアウト追跡とゲーミフィケーションされたアバターシステムを組み合わせたiOSフィットネスアプリケーションです。

FitAvatar is an iOS fitness application that combines workout tracking with a gamified avatar system.

## 概要 / Overview

FitAvatarは、トレーニングを記録しながらアバターを育成するゲーミフィケーション要素を取り入れたフィットネスアプリです。SwiftUIとCore Dataを使用して構築されており、タブベースのナビゲーションパターンを採用しています。

FitAvatar combines workout tracking with avatar growth through a gamification system. Built with SwiftUI and Core Data, it features a tab-based navigation pattern for an intuitive user experience.

## 主な機能 / Features

- **ワークアウト追跡**: 様々なエクササイズを記録・管理
- **アバター成長システム**: トレーニングに応じてアバターが成長
- **統計機能**: トレーニング履歴と進捗の可視化
- **日本語UI**: 完全日本語対応のユーザーインターフェース
- **Core Dataによるローカル保存**: オフラインでもデータを安全に保存

---

- **Workout Tracking**: Record and manage various exercises
- **Avatar Growth System**: Your avatar grows as you train
- **Statistics**: Visualize training history and progress
- **Japanese UI**: Fully localized Japanese user interface
- **Core Data Persistence**: Secure local data storage even offline

## 必要要件 / Requirements

- iOS 17.5+
- Xcode 15.4+
- Swift 5.0+

## セットアップ / Setup

1. リポジトリをクローン / Clone the repository:
```bash
git clone <repository-url>
cd FitAvatar
```

2. Xcodeでプロジェクトを開く / Open the project in Xcode:
```bash
open FitAvatar.xcodeproj
```

3. ビルドして実行 / Build and run the app:
   - シミュレーターまたは実機を選択 / Select a simulator or device
   - `Cmd + R` でビルド＆実行 / Press `Cmd + R` to build and run

## ビルド / Building

### アプリをビルド / Build the App
```bash
xcodebuild -scheme FitAvatar -configuration Debug build
```

### テスト用にビルド / Build for Testing
```bash
xcodebuild -scheme FitAvatar -configuration Debug build-for-testing
```

### ビルドフォルダをクリーン / Clean Build Folder
```bash
xcodebuild clean -scheme FitAvatar
```

## テスト / Testing

### すべてのユニットテストを実行 / Run All Unit Tests
```bash
xcodebuild test -scheme FitAvatar -destination 'platform=iOS Simulator,name=iPhone 15'
```

### 特定のテストターゲットを実行 / Run Specific Test Target
```bash
xcodebuild test -scheme FitAvatar -only-testing:FitAvatarTests -destination 'platform=iOS Simulator,name=iPhone 15'
```

### UIテストを実行 / Run UI Tests
```bash
xcodebuild test -scheme FitAvatar -only-testing:FitAvatarUITests -destination 'platform=iOS Simulator,name=iPhone 15'
```

## アーキテクチャ / Architecture

### ナビゲーション構造 / Navigation Structure

アプリは `MainTabView` をルートナビゲーションコンポーネントとするタブベースのアーキテクチャを採用しています：

The app uses a tab-based architecture with `MainTabView` as the root navigation component:

- **HomeView**: ダッシュボード（アバター、今日のワークアウト、クイックワークアウトショートカット）
- **WorkoutView**: エクササイズライブラリとワークアウト管理
- **StatisticsView**: トレーニング履歴と進捗の可視化
- **SettingsView**: アプリ設定

エントリーポイント / Entry point: `FitAvatarApp.swift` → `ContentView.swift` → `MainTabView.swift`

### データレイヤー / Data Layer

- **Core Data**: `PersistenceController` シングルトンパターンで管理
- **データモデル**: `FitAvatar.xcdatamodeld` にCore Dataスキーマを定義
- **Models**: `FitAvatar/Models/` ディレクトリにアプリレベルのデータ構造
  - `Exercise.swift`: エクササイズ定義（カテゴリー、難易度、対象筋肉群）

### 技術スタック / Tech Stack

- **SwiftUI**: 宣言的UIフレームワーク / Declarative UI framework
- **Core Data**: ローカル永続化 / Local persistence
- **Swift**: プログラミング言語 / Programming language
- **Xcode**: 統合開発環境 / Integrated development environment

## プロジェクト構造 / Project Structure

```
FitAvatar/
├── FitAvatar/
│   ├── FitAvatarApp.swift       # アプリエントリーポイント / App entry point
│   ├── ContentView.swift        # メインコンテンツビュー / Main content view
│   ├── MainTabView.swift        # タブナビゲーション / Tab navigation
│   ├── Views/                   # ビューコンポーネント / View components
│   ├── Models/                  # データモデル / Data models
│   └── Persistence.swift        # Core Data管理 / Core Data management
├── FitAvatarTests/              # ユニットテスト / Unit tests
└── FitAvatarUITests/            # UIテスト / UI tests
```

## 開発ガイド / Development Guide

- 開発者向けの詳細な情報は `CLAUDE.md` を参照してください
- ビュー構成要素は `FitAvatar/Views/` に配置してください
- モデルは `FitAvatar/Models/` に配置してください
- UIテキストは日本語で統一してください

---

- See `CLAUDE.md` for detailed developer information
- Place view components in `FitAvatar/Views/`
- Place models in `FitAvatar/Models/`
- Maintain Japanese language consistency for UI text

## ライセンス / License

このプロジェクトのライセンスについては、リポジトリのライセンスファイルを参照してください。

See the repository's license file for licensing information.
