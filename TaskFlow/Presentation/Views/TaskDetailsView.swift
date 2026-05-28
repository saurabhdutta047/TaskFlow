import SwiftUI

/// Read-only detail view for a single task.
///
/// Pushed onto the `NavigationStack` when a task card is tapped in the list.
/// Displays category badge, title, metadata (due date, priority), and notes.
/// Provides actions to toggle completion, delete the task, or open the
/// edit sheet. Auto-pops when the task is deleted.
struct TaskDetailsView: View {
    @StateObject private var viewModel: TaskDetailsViewModel
    private let coordinator: AppCoordinator
    @Environment(\.dismiss) private var dismiss

    @State private var showEditSheet = false

    private let primaryBlue = Color(red: 0.25, green: 0.35, blue: 0.95)

    init(viewModel: TaskDetailsViewModel, coordinator: AppCoordinator) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.coordinator = coordinator
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerBadges
                titleSection
                metadataRow

                Divider()

                if !viewModel.task.notes.isEmpty {
                    descriptionSection
                }

                Spacer(minLength: 20)

                completeButton
                deleteButton
            }
            .padding(20)
        }
        .background(Color(.systemBackground))
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Tasks")
                    }
                    .foregroundColor(primaryBlue)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") { showEditSheet = true }
                    .foregroundColor(primaryBlue)
            }
        }
        .sheet(isPresented: $showEditSheet, onDismiss: {
            Task { await viewModel.reloadTask() }
        }) {
            NavigationView {
                coordinator.showTaskDetail(for: viewModel.task)
            }
        }
        .onChange(of: viewModel.isDeleted) { _, isDeleted in
            if isDeleted { dismiss() }
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") { viewModel.errorMessage = nil }
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
    }

    // MARK: - Header Badges

    private var headerBadges: some View {
        HStack(spacing: 8) {
            Text(viewModel.task.category.rawValue.uppercased())
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(categoryColor(viewModel.task.category))
                .cornerRadius(4)

            Circle()
                .fill(Color.gray.opacity(0.4))
                .frame(width: 4, height: 4)

            Text("Created \(viewModel.task.createdAt.formatted(.dateTime.month(.abbreviated).day().year()))")
                .font(.caption)
                .foregroundColor(.gray)
        }
    }

    // MARK: - Title

    private var titleSection: some View {
        Text(viewModel.task.title)
            .font(.system(size: 28, weight: .bold))
            .strikethrough(viewModel.task.isCompleted)
            .foregroundColor(viewModel.task.isCompleted ? .gray : .primary)
    }

    // MARK: - Metadata Row

    private var metadataRow: some View {
        HStack(spacing: 16) {
            if let dueDate = viewModel.task.dueDate {
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(formattedDueDate(dueDate))
                        .font(.subheadline)
                }
            }

            HStack(spacing: 4) {
                Image(systemName: "exclamationmark.circle.fill")
                    .font(.caption)
                    .foregroundColor(priorityColor(viewModel.task.priority))
                Text("\(viewModel.task.priority.rawValue) Priority")
                    .font(.subheadline)
                    .foregroundColor(priorityColor(viewModel.task.priority))
            }
        }
    }

    // MARK: - Description

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("DESCRIPTION")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.gray)
                .kerning(1.2)

            Text(viewModel.task.notes)
                .font(.body)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    // MARK: - Action Buttons

    private var completeButton: some View {
        Button(action: {
            Task { await viewModel.toggleCompletion() }
        }) {
            HStack {
                Image(systemName: viewModel.task.isCompleted ? "arrow.uturn.backward.circle" : "checkmark.circle")
                Text(viewModel.task.isCompleted ? "Mark as Active" : "Mark as Complete")
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(primaryBlue)
            .cornerRadius(12)
        }
    }

    private var deleteButton: some View {
        Button(action: {
            Task { await viewModel.deleteTask() }
        }) {
            HStack {
                Image(systemName: "trash")
                Text("Delete Task")
            }
            .font(.headline)
            .foregroundColor(.red)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.red.opacity(0.08))
            .cornerRadius(12)
        }
    }

    // MARK: - Helpers

    private func categoryColor(_ category: TaskCategory) -> Color {
        switch category {
        case .work: return primaryBlue
        case .personal: return .purple
        case .health: return .green
        case .education: return .orange
        case .other: return .gray
        }
    }

    private func priorityColor(_ priority: TaskPriority) -> Color {
        switch priority {
        case .high: return .red
        case .medium: return .orange
        case .low: return .green
        }
    }

    private func formattedDueDate(_ date: Date) -> String {
        if Calendar.current.isDateInToday(date) {
            return "Today"
        } else if Calendar.current.isDateInTomorrow(date) {
            return "Tomorrow"
        } else {
            return date.formatted(.dateTime.month(.abbreviated).day())
        }
    }
}
