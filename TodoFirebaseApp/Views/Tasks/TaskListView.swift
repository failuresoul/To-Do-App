//
//  TaskListView.swift
//  TodoFirebaseApp
//
//  Created by Developer on 2026-11-14.
//

import SwiftUI

struct TaskListView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @StateObject private var taskViewModel = TaskViewModel()

    @State private var showingAddTaskSheet = false
    @State private var selectedTaskForEdit: TodoItem?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Filter", selection: $taskViewModel.filter) {
                    ForEach(TaskFilter.allCases) { filterOption in
                        Text(filterOption.rawValue).tag(filterOption)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)

                List {
                    ForEach(taskViewModel.filteredTasks) { task in
                        TaskRowView(task: task) {
                            Task {
                                await taskViewModel.toggleTaskCompletion(task)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedTaskForEdit = task
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                Task {
                                    await taskViewModel.deleteTask(task)
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }

                            Button {
                                selectedTaskForEdit = task
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            .tint(.blue)
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .overlay {
                    if taskViewModel.filteredTasks.isEmpty && !taskViewModel.isLoading {
                        if !taskViewModel.searchText.isEmpty || taskViewModel.filter != .all {
                            ContentUnavailableView(
                                "No Matching Tasks",
                                systemImage: "magnifyingglass",
                                description: Text("Try adjusting your search or filter.")
                            )
                        } else {
                            ContentUnavailableView(
                                "No Tasks Yet",
                                systemImage: "checklist",
                                description: Text("Tap the + button to add your first task.")
                            )
                        }
                    }
                }
            }
            .navigationTitle("My Tasks")
            .searchable(text: $taskViewModel.searchText, prompt: "Search tasks...")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Sign Out") {
                        taskViewModel.stopListening()
                        authViewModel.signOut()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddTaskSheet = true
                    } label: {
                        Image(systemName: "plus")
                            .fontWeight(.semibold)
                    }
                }
            }
            .sheet(isPresented: $showingAddTaskSheet) {
                AddEditTaskView { title, notes, priority, dueDate in
                    Task {
                        await taskViewModel.addTask(
                            title: title,
                            notes: notes,
                            priority: priority,
                            dueDate: dueDate
                        )
                    }
                }
            }
            .sheet(item: $selectedTaskForEdit) { task in
                AddEditTaskView(taskToEdit: task) { title, notes, priority, dueDate in
                    var updatedTask = task
                    updatedTask.title = title
                    updatedTask.notes = notes
                    updatedTask.priority = priority
                    updatedTask.dueDate = dueDate
                    Task {
                        await taskViewModel.updateTask(updatedTask)
                    }
                }
            }
            .alert(
                "Error",
                isPresented: Binding(
                    get: { taskViewModel.errorMessage != nil },
                    set: { if !$0 { taskViewModel.errorMessage = nil } }
                )
            ) {
                Button("OK", role: .cancel) {
                    taskViewModel.errorMessage = nil
                }
            } message: {
                Text(taskViewModel.errorMessage ?? "")
            }
            .onAppear {
                taskViewModel.startListening()
            }
            .onDisappear {
                taskViewModel.stopListening()
            }
        }
    }
}

#Preview {
    TaskListView()
        .environmentObject(AuthViewModel())
}
