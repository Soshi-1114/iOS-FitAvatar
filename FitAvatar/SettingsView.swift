//
//  SettingsView.swift
//  FitAvatar
//
//  Created by 本村壮志 on 2025/09/03.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject private var appData = AppData.shared
    @State private var showingEditNameAlert = false
    @State private var newUserName = ""

    var body: some View {
        NavigationView {
            List {
                // プロフィールセクション
                profileSection

                // 通知設定セクション
                notificationSection

                // 目標設定セクション
                goalSection

                // アプリ設定セクション
                appSettingsSection

                // データ管理セクション
                dataManagementSection

                // アプリ情報セクション
                aboutSection
            }
            .navigationTitle("設定")
            .navigationBarTitleDisplayMode(.large)
        }
        .alert("名前を変更", isPresented: $showingEditNameAlert) {
            TextField("名前", text: $newUserName)
            Button("キャンセル", role: .cancel) { }
            Button("保存") {
                if !newUserName.isEmpty {
                    appData.userName = newUserName
                }
            }
        } message: {
            Text("表示名を入力してください")
        }
    }

    // MARK: - Profile Section
    private var profileSection: some View {
        Section {
            HStack {
                // アバターアイコン
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [.blue.opacity(0.3), .purple.opacity(0.3)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 70, height: 70)

                    Image(systemName: "person.fill")
                        .font(.system(size: 35))
                        .foregroundColor(.blue)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(appData.userName)
                        .font(.title2)
                        .fontWeight(.bold)
                }

                Spacer()

                Button(action: {
                    newUserName = appData.userName
                    showingEditNameAlert = true
                }) {
                    Text("編集")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }
            .padding(.vertical, 8)
        } header: {
            Text("プロフィール")
        }
    }

    // MARK: - Notification Section
    private var notificationSection: some View {
        Section {
            Toggle(isOn: $appData.notificationsEnabled) {
                Label("通知を許可", systemImage: "bell.fill")
            }

            if appData.notificationsEnabled {
                DatePicker(
                    selection: $appData.dailyReminderTime,
                    displayedComponents: .hourAndMinute
                ) {
                    Label("デイリーリマインダー", systemImage: "clock.fill")
                }

                Toggle(isOn: $appData.workoutReminders) {
                    Label("トレーニングリマインダー", systemImage: "dumbbell.fill")
                }
            }
        } header: {
            Text("通知設定")
        } footer: {
            if appData.notificationsEnabled {
                Text("毎日決まった時間にトレーニングを促す通知を受け取ります")
            }
        }
    }

    // MARK: - Goal Section
    private var goalSection: some View {
        Section {
            Stepper(value: $appData.weeklyWorkoutGoal, in: 1...7) {
                HStack {
                    Label("週間トレーニング目標", systemImage: "target")
                    Spacer()
                    Text("\(appData.weeklyWorkoutGoal)回")
                        .foregroundColor(.secondary)
                }
            }
        } header: {
            Text("目標設定")
        } footer: {
            Text("達成可能な目標を設定して、モチベーションを維持しましょう")
        }
    }

    // MARK: - App Settings Section
    private var appSettingsSection: some View {
        Section {
            Picker(selection: $appData.appearanceMode) {
                ForEach(AppearanceMode.allCases, id: \.self) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            } label: {
                Label("外観モード", systemImage: "circle.lefthalf.filled")
            }

            Toggle(isOn: $appData.hapticFeedback) {
                Label("振動フィードバック", systemImage: "hand.tap.fill")
            }

            NavigationLink(destination: UnitSettingsView()) {
                Label("単位設定", systemImage: "ruler.fill")
            }
        } header: {
            Text("アプリ設定")
        }
    }

    // MARK: - Data Management Section
    private var dataManagementSection: some View {
        Section {
            NavigationLink(destination: ExportDataView()) {
                Label("データをエクスポート", systemImage: "square.and.arrow.up")
            }

            NavigationLink(destination: ImportDataView()) {
                Label("データをインポート", systemImage: "square.and.arrow.down")
            }

            Button(role: .destructive, action: {
                appData.clearAllData()
            }) {
                Label("すべてのデータを削除", systemImage: "trash.fill")
            }
        } header: {
            Text("データ管理")
        } footer: {
            Text("トレーニングデータのバックアップと復元ができます")
        }
    }

    // MARK: - About Section
    private var aboutSection: some View {
        Section {
            HStack {
                Text("バージョン")
                Spacer()
                Text("1.0.0")
                    .foregroundColor(.secondary)
            }

            NavigationLink(destination: PrivacyPolicyView()) {
                Label("プライバシーポリシー", systemImage: "hand.raised.fill")
            }

            NavigationLink(destination: TermsOfServiceView()) {
                Label("利用規約", systemImage: "doc.text.fill")
            }

            NavigationLink(destination: LicensesView()) {
                Label("ライセンス情報", systemImage: "info.circle.fill")
            }

            Link(destination: URL(string: "https://github.com/yourusername/fitavatar")!) {
                Label("GitHubで見る", systemImage: "chevron.left.forwardslash.chevron.right")
            }
        } header: {
            Text("アプリ情報")
        }
    }
}

// MARK: - Appearance Mode Enum
enum AppearanceMode: String, CaseIterable, Codable {
    case system = "システム設定"
    case light = "ライトモード"
    case dark = "ダークモード"
}

// MARK: - Goal Detail View
struct GoalDetailView: View {
    let weeklyGoal: Int
    let monthlyXPGoal: Int
    @ObservedObject private var appData = AppData.shared

    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                // 週間目標の進捗
                GoalProgressCard(
                    title: "週間トレーニング目標",
                    current: currentWeeklyWorkouts,
                    goal: weeklyGoal,
                    unit: "回",
                    icon: "dumbbell.fill",
                    color: .blue
                )

                // 月間XP目標の進捗
                GoalProgressCard(
                    title: "月間XP目標",
                    current: currentMonthlyXP,
                    goal: monthlyXPGoal,
                    unit: "XP",
                    icon: "star.fill",
                    color: .purple
                )

                // 励ましメッセージ
                MotivationalMessage(
                    weeklyProgress: Double(currentWeeklyWorkouts) / Double(weeklyGoal),
                    monthlyProgress: Double(currentMonthlyXP) / Double(monthlyXPGoal)
                )

                Spacer()
            }
            .padding()
        }
        .navigationTitle("目標の進捗")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var currentWeeklyWorkouts: Int {
        appData.getFilteredWorkouts(for: .week).count
    }
    
    private var currentMonthlyXP: Int {
        appData.getTotalXP(for: .month)
    }
}

// MARK: - Goal Progress Card
struct GoalProgressCard: View {
    let title: String
    let current: Int
    let goal: Int
    let unit: String
    let icon: String
    let color: Color

    private var progress: Double {
        guard goal > 0 else { return 0 }
        return min(Double(current) / Double(goal), 1.0)
    }

    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Label(title, systemImage: icon)
                    .font(.headline)
                    .foregroundColor(color)

                Spacer()
            }

            // 進捗バー
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 20)

                    RoundedRectangle(cornerRadius: 10)
                        .fill(color)
                        .frame(width: geometry.size.width * progress, height: 20)
                }
            }
            .frame(height: 20)

            // 数値表示
            HStack {
                Text("\(current) / \(goal) \(unit)")
                    .font(.title3)
                    .fontWeight(.bold)

                Spacer()

                Text("\(Int(progress * 100))%")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(color)
            }

            // 残り
            if current < goal {
                HStack {
                    Text("あと \(goal - current) \(unit)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Spacer()
                }
            } else {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)

                    Text("目標達成！")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)

                    Spacer()
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Motivational Message
struct MotivationalMessage: View {
    let weeklyProgress: Double
    let monthlyProgress: Double

    private var message: String {
        let averageProgress = (weeklyProgress + monthlyProgress) / 2

        if averageProgress >= 1.0 {
            return "素晴らしい！目標を達成しました！この調子で頑張りましょう！"
        } else if averageProgress >= 0.75 {
            return "あと少しで目標達成です！頑張ってください！"
        } else if averageProgress >= 0.5 {
            return "順調に進んでいます！このペースを維持しましょう！"
        } else if averageProgress >= 0.25 {
            return "良いスタートです！コツコツと続けていきましょう！"
        } else {
            return "目標に向かって一歩ずつ進んでいきましょう！"
        }
    }

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "heart.fill")
                .font(.system(size: 40))
                .foregroundColor(.pink)

            Text(message)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [.pink.opacity(0.1), .purple.opacity(0.1)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(15)
    }
}

// MARK: - Unit Settings View
struct UnitSettingsView: View {
    @ObservedObject private var appData = AppData.shared

    var body: some View {
        List {
            Section {
                Picker("重量単位", selection: $appData.weightUnit) {
                    ForEach(WeightUnit.allCases, id: \.self) { unit in
                        Text(unit.rawValue).tag(unit)
                    }
                }

                Picker("距離単位", selection: $appData.distanceUnit) {
                    ForEach(DistanceUnit.allCases, id: \.self) { unit in
                        Text(unit.rawValue).tag(unit)
                    }
                }
            } header: {
                Text("単位設定")
            } footer: {
                Text("トレーニング記録で使用する単位を選択します")
            }
        }
        .navigationTitle("単位設定")
        .navigationBarTitleDisplayMode(.inline)
    }
}

enum WeightUnit: String, CaseIterable, Codable {
    case kg = "キログラム (kg)"
    case lb = "ポンド (lb)"
}

enum DistanceUnit: String, CaseIterable, Codable {
    case km = "キロメートル (km)"
    case mile = "マイル (mi)"
}

// MARK: - Placeholder Views for Data Management
struct ExportDataView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "square.and.arrow.up.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)

            Text("データをエクスポート")
                .font(.title2)
                .fontWeight(.bold)

            Text("トレーニングデータをバックアップファイルとしてエクスポートします")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)

            Button(action: {
                // エクスポート処理
            }) {
                Text("エクスポート開始")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal)

            Spacer()
        }
        .padding()
        .navigationTitle("データエクスポート")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ImportDataView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "square.and.arrow.down.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)

            Text("データをインポート")
                .font(.title2)
                .fontWeight(.bold)

            Text("バックアップファイルからトレーニングデータを復元します")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)

            Button(action: {
                // インポート処理
            }) {
                Text("ファイルを選択")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(10)
            }
            .padding(.horizontal)

            Spacer()
        }
        .padding()
        .navigationTitle("データインポート")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Placeholder Views for About Section
struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                Text("プライバシーポリシー")
                    .font(.title)
                    .fontWeight(.bold)

                Text("最終更新日: 2025年9月3日")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Divider()

                Text("1. 収集する情報")
                    .font(.headline)
                    .padding(.top)

                Text("FitAvatarは、トレーニング記録、プロフィール情報、アプリの使用状況などを収集します。")
                    .foregroundColor(.secondary)

                Text("2. 情報の使用")
                    .font(.headline)
                    .padding(.top)

                Text("収集した情報は、アプリの機能提供、改善、カスタマイズに使用されます。")
                    .foregroundColor(.secondary)

                Text("3. 情報の共有")
                    .font(.headline)
                    .padding(.top)

                Text("お客様の個人情報を第三者と共有することはありません。")
                    .foregroundColor(.secondary)

                Spacer()
            }
            .padding()
        }
        .navigationTitle("プライバシーポリシー")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct TermsOfServiceView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                Text("利用規約")
                    .font(.title)
                    .fontWeight(.bold)

                Text("最終更新日: 2025年9月3日")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Divider()

                Text("1. サービスの利用")
                    .font(.headline)
                    .padding(.top)

                Text("FitAvatarは、個人のフィットネス記録と管理を目的としたアプリケーションです。")
                    .foregroundColor(.secondary)

                Text("2. ユーザーの責任")
                    .font(.headline)
                    .padding(.top)

                Text("ユーザーは、適切かつ安全にアプリを使用する責任があります。")
                    .foregroundColor(.secondary)

                Text("3. 免責事項")
                    .font(.headline)
                    .padding(.top)

                Text("本アプリは医療アドバイスを提供するものではありません。トレーニングは自己責任で行ってください。")
                    .foregroundColor(.secondary)

                Spacer()
            }
            .padding()
        }
        .navigationTitle("利用規約")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct LicensesView: View {
    var body: some View {
        List {
            Section {
                Text("SwiftUI")
                    .font(.headline)
                Text("© 2025 Apple Inc.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Section {
                Text("SF Symbols")
                    .font(.headline)
                Text("© 2025 Apple Inc.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Section {
                Text("FitAvatar")
                    .font(.headline)
                Text("© 2025 FitAvatar Team. All rights reserved.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("ライセンス情報")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    SettingsView()
}
