//
//  AddEditTaskView.swift
//  TodoFirebaseApp
//
//  Created by Developer on 2026-11-14.
//

import SwiftUI

struct AddEditTaskView: View {
    @Environment(\.dismiss) private var dismiss

    let taskToEdit: TodoItem?
    let onSave: (String, String, Priority, Date?) -> Void

    @State private var title: String
    @State private var notes: String
    @State private var priority: Priority
    @State private var hasDueDate: Bool
    @State private var dueDate: Date

    init(
        taskToEdit: TodoItem? = nil,
        onSave: @escaping (String, String, Priority, Date?) -> Void
    ) {
        self.taskToEdit = taskToEdit
        self.onSave = onSave
        _title = State(initialValue: taskToEdit?.title ?? "")
        _notes = State(initialValue: taskToEdit?.notes ?? "")
        _priority = State(initialValue: taskToEdit?.priority ?? .medium)
        _hasDueDate = State(initialValue: taskToEdit?.dueDate != nil)
        _dueDate = State(initialValue: taskToEdit?.dueDate ?? Date())
    }

    private var isTitleValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Task Info") {
                    TextField("Task title", text: $title)
                    TextField("Notes (optional)", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section("Priority") {
                    Picker("Priority", selection: $priority) {
                        ForEach(Priority.allCases) { level in
                            Text(level.rawValue).tag(level)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Due Date") {
                    Toggle("Set Due Date", isOn: $hasDueDate.animation())

                    if hasDueDate {
                        DatePicker(
                            "Date",
                            selection: $dueDate,
                            displayedComponents: [.date]
                        )
                    }
                }
            }
            .navigationTitle(taskToEdit == nil ? "New Task" : "Edit Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
                        let trimmedNotes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
                        onSave(
                            trimmedTitle,
                            trimmedNotes,
                            priority,
                            hasDueDate ? dueDate : nil
                        )
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(!isTitleValid)
                }
            }
        }
    }
}

#Preview("Add Task") {
    AddEditTaskView { _, _, _, _ in }
}

#Preview("Edit Task") {
    AddEditTaskView(taskToEdit: TodoItem.mockItems[0]) { _, _, _, _ in }
}
