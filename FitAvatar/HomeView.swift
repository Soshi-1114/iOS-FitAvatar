//
//  HomeView.swift
//  FitAvatar
//
//  Created by GitHub Copilot on 2025/08/28.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject private var appData = AppData.shared
    @State private var todayWorkouts: [String] = []
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // ヘッダー部分
                    headerSection

                    // 今日のトレーニング部分
                    todayWorkoutSection

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("おかえりなさい！")
                    .font(.title2)
                    .foregroundColor(.secondary)
                Text(appData.userName)
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
            
            Spacer()
            
            // 通知ボタン
            Button(action: {
                // 通知機能は後で実装
            }) {
                Image(systemName: "bell")
                    .font(.title2)
                    .foregroundColor(.primary)
            }
        }
    }
    
    // MARK: - Today's Workout Section
    private var todayWorkoutSection: some View {
        VStack(spacing: 15) {
            HStack {
                Text("今日のトレーニング")
                    .font(.headline)
                
                Spacer()
                
                Button("すべて見る") {
                    // ワークアウト画面へのナビゲーション
                }
                .font(.subheadline)
                .foregroundColor(.blue)
            }
            
            let todayRecords = appData.getTodayWorkouts()
            
            if todayRecords.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "calendar.badge.plus")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    
                    Text("今日のトレーニングを\n追加しましょう！")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                }
                .frame(height: 120)
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(15)
            } else {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 10) {
                    ForEach(todayRecords) { workout in
                        CompletedWorkoutCard(workout: workout)
                    }
                }
            }
        }
    }
    
    
}

// MARK: - Completed Workout Card Component
struct CompletedWorkoutCard: View {
    let workout: WorkoutRecord
    
    var body: some View {
        HStack {
            Image(systemName: "dumbbell")
                .font(.title2)
                .foregroundColor(.green)
            
            VStack(alignment: .leading) {
                Text(workout.exerciseName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("完了 - \(workout.sets)セット")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Workout Card Component
struct WorkoutCard: View {
    let workoutName: String
    
    var body: some View {
        HStack {
            Image(systemName: "dumbbell")
                .font(.title2)
                .foregroundColor(.blue)
            
            VStack(alignment: .leading) {
                Text(workoutName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("未完了")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Quick Workout Button Component
struct QuickWorkoutButton: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        Button(action: {
            // クイックワークアウト開始処理
        }) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundColor(.white)
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
            }
            .frame(height: 80)
            .frame(maxWidth: .infinity)
            .background(color)
            .cornerRadius(15)
        }
    }
}

#Preview {
    HomeView()
}
