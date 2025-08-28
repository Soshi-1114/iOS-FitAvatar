//
//  FitAvatarApp.swift
//  FitAvatar
//
//  Created by 本村壮志 on 2025/08/28.
//

import SwiftUI

@main
struct FitAvatarApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
