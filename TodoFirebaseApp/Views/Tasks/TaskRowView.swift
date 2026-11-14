//
//  TaskRowView.swift
//  TodoFirebaseApp
//
//  Created by Developer on 2026-11-14.
//

import SwiftUI

struct TaskRowView: View {
    let task: TodoItem
    let onToggle: () -> Void

    private var priorityColor: Color {
        switch task.priority {
        case .low:
            return .blue
        case .medium:
            return .orange
        case .high:
            return .red
        }
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Button(action: onToggle) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(task.isCompleted ? .green : .secondary)
                    .padding(.top, 2)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .firstTextBaseline) {
                    Text(task.title)
                        .font(.body.weight(.medium))
                        .strikethrough(task.isCompleted)
                        .foregroundStyle(task.isCompleted ? .secondary : .primary)

                    Spacer()

                    Text(task.priority.rawValue)
                        .font(.caption2.weight(.semibold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(priorityColor.opacity(0.15))
                        .foregroundStyle(priorityColor)
                        .clipShape(Capsule())
                }

                if !task.notes.isEmpty {
                    Text(task.notes)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                if let dueDate = task.dueDate {
                    Label {
                        Text(dueDate, format: .dateTime.month(.abbreviated).day().year())
                    } icon: {
                        Image(systemName: "calendar")
                    }
                    .font(.caption)
                    .foregroundStyle(
                        !task.isCompleted && dueDate < Date() ? .red : .secondary
                    )
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    List {
        ForEach(TodoItem.mockItems) { item in
            TaskRowView(task: item, onToggle: {})
        }
    }
}
