//
//  TaskService.swift
//  TodoFirebaseApp
//
//  Created by Developer on 2026-11-14.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

enum TaskServiceError: LocalizedError {
    case unauthorized
    case missingDocumentID

    var errorDescription: String? {
        switch self {
        case .unauthorized:
            return "You must be signed in to access or modify your tasks."
        case .missingDocumentID:
            return "The task document ID is missing."
        }
    }
}

final class TaskService {
    static let shared = TaskService()

    private let db = Firestore.firestore()
    private let collectionName = "tasks"
    private var listenerRegistration: ListenerRegistration?

    init() {}

    deinit {
        removeListener()
    }

    // MARK: - Real-time Listener (User-Scoped)

    func listenToTasks(completion: @escaping (Result<[TodoItem], Error>) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(.failure(TaskServiceError.unauthorized))
            return
        }

        removeListener()

        listenerRegistration = db.collection(collectionName)
            .whereField("userId", isEqualTo: uid)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let documents = snapshot?.documents else {
                    completion(.success([]))
                    return
                }

                let tasks = documents.compactMap { document -> TodoItem? in
                    try? document.data(as: TodoItem.self)
                }
                completion(.success(tasks))
            }
    }

    func removeListener() {
        listenerRegistration?.remove()
        listenerRegistration = nil
    }

    // MARK: - CRUD Operations (User-Scoped)

    func addTask(
        title: String,
        notes: String = "",
        priority: Priority = .medium,
        dueDate: Date? = nil
    ) async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let newTask = TodoItem(
            userId: uid,
            title: title,
            notes: notes,
            isCompleted: false,
            priority: priority,
            dueDate: dueDate,
            createdAt: Date()
        )

        _ = try db.collection(collectionName).addDocument(from: newTask)
    }

    func addTask(_ task: TodoItem) async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        var userScopedTask = task
        userScopedTask.userId = uid
        _ = try db.collection(collectionName).addDocument(from: userScopedTask)
    }

    func updateTask(_ task: TodoItem) async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard task.userId == uid, let documentId = task.id else { return }

        try db.collection(collectionName)
            .document(documentId)
            .setData(from: task, merge: true)
    }

    func toggleTaskCompletion(_ task: TodoItem) async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard task.userId == uid, let documentId = task.id else { return }

        try await db.collection(collectionName)
            .document(documentId)
            .updateData([
                "isCompleted": !task.isCompleted
            ])
    }

    func deleteTask(_ task: TodoItem) async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard task.userId == uid, let documentId = task.id else { return }

        try await db.collection(collectionName)
            .document(documentId)
            .delete()
    }
}
