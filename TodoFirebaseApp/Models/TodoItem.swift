//
//  TodoItem.swift
//  TodoFirebaseApp
//
//  Created by Developer on 2026-11-14.
//

import Foundation
import FirebaseFirestore

enum Priority: String, Codable, CaseIterable, Identifiable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"

    var id: String { rawValue }
}

struct TodoItem: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    var userId: String
    var title: String
    var notes: String
    var isCompleted: Bool
    var priority: Priority
    var dueDate: Date?
    var createdAt: Date

    init(
        id: String? = nil,
        userId: String,
        title: String,
        notes: String = "",
        isCompleted: Bool = false,
        priority: Priority = .medium,
        dueDate: Date? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.title = title
        self.notes = notes
        self.isCompleted = isCompleted
        self.priority = priority
        self.dueDate = dueDate
        self.createdAt = createdAt
    }

    static let mockItems: [TodoItem] = [
        TodoItem(
            id: "mock-1",
            userId: "preview-user-123",
            title: "Configure Firebase Firestore",
            notes: "Set up user-scoped security rules and indexes in Firebase Console.",
            isCompleted: true,
            priority: .high,
            dueDate: Calendar.current.date(byAdding: .day, value: -1, to: Date()),
            createdAt: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date()
        ),
        TodoItem(
            id: "mock-2",
            userId: "preview-user-123",
            title: "Build SwiftUI Task List UI",
            notes: "Include priority badges, due date labels, and swipe-to-delete actions.",
            isCompleted: false,
            priority: .medium,
            dueDate: Calendar.current.date(byAdding: .day, value: 1, to: Date()),
            createdAt: Calendar.current.date(byAdding: .hour, value: -5, to: Date()) ?? Date()
        ),
        TodoItem(
            id: "mock-3",
            userId: "preview-user-123",
            title: "Review Pull Request",
            notes: "Verify Xcode 16 project settings and SwiftPM package resolution.",
            isCompleted: false,
            priority: .low,
            dueDate: nil,
            createdAt: Date()
        )
    ]
}
