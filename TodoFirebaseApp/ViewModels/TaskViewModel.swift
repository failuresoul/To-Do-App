//
//  TaskViewModel.swift
//  TodoFirebaseApp
//
//  Created by Developer on 2026-11-14.
//

import Foundation

@MainActor
final class TaskViewModel: ObservableObject {
    @Published var tasks: [TodoItem] = []
}
