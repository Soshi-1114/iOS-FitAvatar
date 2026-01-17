//
//  StatisticsView.swift
//  FitAvatar
//
//  Created by GitHub Copilot on 2025/08/28.
//

import SwiftUI

struct StatisticsView: View {
    @ObservedObject private var appData = AppData.shared
    @State private var selectedPeriod: TimePeriod = .week

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 期間選択セグメント
                    periodSelectionSection

                    // サマリーカード
                    summaryCardsSection

                    // トレーニング頻度チャート（簡易版）
                    trainingFrequencySection

                    // カテゴリ別統計
                    categoryStatsSection

                    // 最近のトレーニング履歴
                    recentWorkoutsSection

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("統計")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    // MARK: - Period Selection Section
    private var periodSelectionSection: some View {
        Picker("期間", selection: $selectedPeriod) {
            ForEach(TimePeriod.allCases, id: \.self) { period in
                Text(period.rawValue).tag(period)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding(.vertical, 10)
    }

    // MARK: - Summary Cards Section
    private var summaryCardsSection: some View {
        VStack(spacing: 15) {
            Text("サマリー")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 15) {
                StatisticCard(
                    title: "総トレーニング",
                    value: "\(filteredWorkouts.count)",
                    unit: "回",
                    icon: "dumbbell.fill",
                    color: .blue
                )

                StatisticCard(
                    title: "総セット数",
                    value: "\(totalSets)",
                    unit: "セット",
                    icon: "checkmark.circle.fill",
                    color: .green
                )

                StatisticCard(
                    title: "総時間",
                    value: "\(totalMinutes)",
                    unit: "分",
                    icon: "clock.fill",
                    color: .orange
                )
            }
        }
    }

    // MARK: - Training Frequency Section
    private var trainingFrequencySection: some View {
        VStack(spacing: 15) {
            Text("トレーニング頻度")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color(.systemGray6))
                    .frame(height: 200)

                VStack(spacing: 10) {
                    // 簡易的な棒グラフ表示
                    HStack(alignment: .bottom, spacing: 8) {
                        ForEach(weeklyData, id: \.day) { data in
                            VStack {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.blue.opacity(0.3))
                                        .frame(width: 30, height: 100)

                                    VStack {
                                        Spacer()
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(Color.blue)
                                            .frame(width: 30, height: CGFloat(data.count) * 15)
                                    }
                                }
                                .frame(height: 100)

                                Text(data.day)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding()
                }
            }
        }
    }

    // MARK: - Category Stats Section
    private var categoryStatsSection: some View {
        VStack(spacing: 15) {
            Text("カテゴリ別統計")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            ForEach(ExerciseCategory.allCases, id: \.self) { category in
                CategoryStatRow(
                    category: category,
                    count: categoryCount(for: category),
                    totalCount: filteredWorkouts.count
                )
            }
        }
    }

    // MARK: - Recent Workouts Section
    private var recentWorkoutsSection: some View {
        VStack(spacing: 15) {
            HStack {
                Text("最近のトレーニング")
                    .font(.headline)

                Spacer()

                NavigationLink("すべて見る") {
                    WorkoutHistoryListView(workouts: appData.workoutHistory)
                }
                .font(.subheadline)
                .foregroundColor(.blue)
            }

            if filteredWorkouts.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "chart.bar.doc.horizontal")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)

                    Text("まだトレーニングデータがありません")
                        .foregroundColor(.secondary)
                }
                .frame(height: 120)
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(15)
            } else {
                ForEach(filteredWorkouts.prefix(5)) { workout in
                    WorkoutHistoryRow(workout: workout)
                }
            }
        }
    }

    // MARK: - Computed Properties
    private var filteredWorkouts: [WorkoutRecord] {
        appData.getFilteredWorkouts(for: selectedPeriod)
    }
    
    private var totalSets: Int {
        filteredWorkouts.reduce(0) { $0 + $1.sets }
    }

    private var totalMinutes: Int {
        filteredWorkouts.reduce(0) { $0 + $1.durationMinutes }
    }

    private var weeklyData: [DayData] {
        let calendar = Calendar.current
        let today = Date()
        
        // 今日の曜日を取得（1=日曜日, 2=月曜日, ..., 7=土曜日）
        let todayWeekday = calendar.component(.weekday, from: today)
        
        // 日本語の曜日表記（日曜始まり）
        let weekDayNames = ["日", "月", "火", "水", "木", "金", "土"]
        
        // 過去7日間のデータを作成（今日を含む）
        return (0..<7).map { dayOffset in
            // 6日前から今日まで
            let date = calendar.date(byAdding: .day, value: dayOffset - 6, to: today)!
            let weekday = calendar.component(.weekday, from: date)
            let dayName = weekDayNames[weekday - 1]  // weekdayは1始まりなので-1
            
            let count = appData.workoutHistory.filter {
                calendar.isDate($0.date, inSameDayAs: date)
            }.count
            
            return DayData(day: dayName, count: count)
        }
    }

    private func categoryCount(for category: ExerciseCategory) -> Int {
        filteredWorkouts.filter { $0.category == category }.count
    }
}

// MARK: - Time Period Enum
enum TimePeriod: String, CaseIterable, Codable {
    case week = "週"
    case month = "月"
    case year = "年"
}

// MARK: - Day Data
struct DayData {
    let day: String
    let count: Int
}

// MARK: - Statistic Card
struct StatisticCard: View {
    let title: String
    let value: String
    let unit: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)

                Spacer()
            }

            HStack(alignment: .bottom, spacing: 2) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)

                Text(unit)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Category Stat Row
struct CategoryStatRow: View {
    let category: ExerciseCategory
    let count: Int
    let totalCount: Int

    private var percentage: Double {
        guard totalCount > 0 else { return 0 }
        return Double(count) / Double(totalCount)
    }

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Label(category.rawValue, systemImage: category.icon)
                    .font(.subheadline)

                Spacer()

                Text("\(count)回")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(categoryColor)
                        .frame(width: geometry.size.width * percentage, height: 8)
                }
            }
            .frame(height: 8)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }

    private var categoryColor: Color {
        switch category {
        case .upperBody:
            return .blue
        case .lowerBody:
            return .green
        case .core:
            return .orange
        case .cardio:
            return .red
        }
    }
}

// MARK: - Workout History Row
struct WorkoutHistoryRow: View {
    let workout: WorkoutRecord

    var body: some View {
        HStack(spacing: 12) {
            // カテゴリアイコン
            ZStack {
                Circle()
                    .fill(categoryColor.opacity(0.2))
                    .frame(width: 50, height: 50)

                Image(systemName: workout.category.icon)
                    .foregroundColor(categoryColor)
                    .font(.title3)
            }

            // トレーニング情報
            VStack(alignment: .leading, spacing: 4) {
                Text(workout.exerciseName)
                    .font(.headline)
                    .fontWeight(.semibold)

                HStack(spacing: 8) {
                    Text("\(workout.sets)セット")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("•")
                        .foregroundColor(.secondary)

                    Text("\(workout.durationMinutes)分")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            // 日付
            VStack(alignment: .trailing, spacing: 4) {
                Text(formatDate(workout.date))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.1), radius: 3, x: 0, y: 1)
    }

    private var categoryColor: Color {
        switch workout.category {
        case .upperBody:
            return .blue
        case .lowerBody:
            return .green
        case .core:
            return .orange
        case .cardio:
            return .red
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        return formatter.string(from: date)
    }
}

// MARK: - Workout History List View
struct WorkoutHistoryListView: View {
    let workouts: [WorkoutRecord]

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(workouts) { workout in
                    WorkoutHistoryRow(workout: workout)
                }
            }
            .padding()
        }
        .navigationTitle("トレーニング履歴")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Workout Record Model
struct WorkoutRecord: Identifiable {
    let id: UUID
    let exerciseName: String
    let category: ExerciseCategory
    let sets: Int
    let durationMinutes: Int
    let xpEarned: Int
    let date: Date
    let details: [WorkoutSetDetail]
    
    init(id: UUID = UUID(), exerciseName: String, category: ExerciseCategory, sets: Int, durationMinutes: Int, xpEarned: Int, date: Date, details: [WorkoutSetDetail] = []) {
        self.id = id
        self.exerciseName = exerciseName
        self.category = category
        self.sets = sets
        self.durationMinutes = durationMinutes
        self.xpEarned = xpEarned
        self.date = date
        self.details = details
    }
}

// MARK: - Workout Set Detail Model
struct WorkoutSetDetail: Codable, Hashable {
    let weight: Double?
    let reps: Int?
    let duration: Int? // 秒
    let distance: Double? // km
    
    var description: String {
        if let weight = weight, let reps = reps {
            return String(format: "%.1fkg × %d回", weight, reps)
        } else if let reps = reps {
            return "\(reps)回"
        } else if let duration = duration {
            return "\(duration)秒"
        } else if let distance = distance, let duration = duration {
            return String(format: "%.1fkm - %d分", distance, duration / 60)
        } else if let distance = distance {
            return String(format: "%.1fkm", distance)
        }
        return ""
    }
}

// MARK: - Workout History Model
struct WorkoutHistory {
    var workouts: [WorkoutRecord]

    // サンプルデータ
    static var sampleData: WorkoutHistory {
        let calendar = Calendar.current
        let today = Date()

        return WorkoutHistory(workouts: [
            WorkoutRecord(
                exerciseName: "プッシュアップ",
                category: .upperBody,
                sets: 3,
                durationMinutes: 15,
                xpEarned: 45,
                date: today
            ),
            WorkoutRecord(
                exerciseName: "スクワット",
                category: .lowerBody,
                sets: 4,
                durationMinutes: 20,
                xpEarned: 60,
                date: calendar.date(byAdding: .day, value: -1, to: today)!
            ),
            WorkoutRecord(
                exerciseName: "プランク",
                category: .core,
                sets: 3,
                durationMinutes: 12,
                xpEarned: 36,
                date: calendar.date(byAdding: .day, value: -2, to: today)!
            ),
            WorkoutRecord(
                exerciseName: "ランニング",
                category: .cardio,
                sets: 1,
                durationMinutes: 30,
                xpEarned: 90,
                date: calendar.date(byAdding: .day, value: -3, to: today)!
            ),
            WorkoutRecord(
                exerciseName: "ダンベルベンチプレス",
                category: .upperBody,
                sets: 4,
                durationMinutes: 25,
                xpEarned: 75,
                date: calendar.date(byAdding: .day, value: -4, to: today)!
            ),
            WorkoutRecord(
                exerciseName: "ランジ",
                category: .lowerBody,
                sets: 3,
                durationMinutes: 18,
                xpEarned: 54,
                date: calendar.date(byAdding: .day, value: -5, to: today)!
            ),
            WorkoutRecord(
                exerciseName: "クランチ",
                category: .core,
                sets: 3,
                durationMinutes: 10,
                xpEarned: 30,
                date: calendar.date(byAdding: .day, value: -6, to: today)!
            )
        ])
    }
}

#Preview {
    StatisticsView()
}
