//
//  TaskViewModel.swift
//  TodoFirebaseApp
//
//  Created by Developer on 2026-11-14.
//

import Foundation

enum TaskFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case active = "Active"
    case completed = "Completed"

    var id: String { rawValue }
}

@MainActor
final class TaskViewModel: ObservableObject {
    @Published var tasks: [TodoItem] = []
    @Published var filter: TaskFilter = .all
    @Published var searchText = ""
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let taskService: TaskService

    init(taskService: TaskService = .shared) {
        self.taskService = taskService
    }

    var filteredTasks: [TodoItem] {
        tasks.filter { task in
            let matchesFilter: Bool
            switch filter {
            case .all:
                matchesFilter = true
            case .active:
                matchesFilter = !task.isCompleted
            case .completed:
                matchesFilter = task.isCompleted
            }

            let trimmedQuery = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
            let matchesSearch: Bool
            if trimmedQuery.isEmpty {
                matchesSearch = true
            } else {
                matchesSearch = task.title.localizedCaseInsensitiveContains(trimmedQuery) ||
                    task.notes.localizedCaseInsensitiveContains(trimmedQuery)
            }

            return matchesFilter && matchesSearch
        }
    }

    func startListening() {
        isLoading = true
        errorMessage = nil

        taskService.listenToTasks { [weak self] result in
            Task { @MainActor in
                guard let self = self else { return }
                self.isLoading = false
                switch result {
                case .success(let fetchedTasks):
                    self.tasks = fetchedTasks
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    func stopListening() {
        taskService.removeListener()
    }

    func addTask(
        title: String,
        notes: String,
        priority: Priority,
        dueDate: Date?
    ) async {
        errorMessage = nil
        do {
            try await taskService.addTask(
                title: title,
                notes: notes,
                priority: priority,
                dueDate: dueDate
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func updateTask(_ task: TodoItem) async {
        errorMessage = nil
        do {
            try await taskService.updateTask(task)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func toggleTaskCompletion(_ task: TodoItem) async {
        errorMessage = nil
        do {
            try await taskService.toggleTaskCompletion(task)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteTask(_ task: TodoItem) async {
        errorMessage = nil
        do {
            try await taskService.deleteTask(task)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    static var preview: TaskViewModel {
        let vm = TaskViewModel()
        vm.tasks = TodoItem.mockItems
        return vm
    }
}
