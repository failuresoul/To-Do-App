//
//  TodoFirebaseAppApp.swift
//  TodoFirebaseApp
//
//  Created by Developer on 2026-11-14.
//

import SwiftUI
import FirebaseCore

@main
struct TodoFirebaseAppApp: App {
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
