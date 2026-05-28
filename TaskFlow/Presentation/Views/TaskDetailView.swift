import SwiftUI

/// Form view for creating a new task or editing an existing one.
///
/// Presented as a modal sheet with Cancel/Save toolbar buttons.
/// Fields include title, priority selector, notes, due date, and category.
/// The form auto-dismisses on successful save.
struct TaskDetailView: View {
    @StateObject private var viewModel: TaskDetailViewModel
    private let coordinator: AppCoordinator
    @Environment(\.dismiss) private var dismiss

    private let primaryBlue = Color(red: 0.25, green: 0.35, blue: 0.95)

    init(viewModel: TaskDetailViewModel, coordinator: AppCoordinator) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.coordinator = coordinator
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                titleField
                prioritySection
                notesSection
                dueDateAndCategoryRow
                motivationalCard
            }
            .padding(20)
        }
        .background(Color(.systemBackground))
        .navigationTitle(viewModel.isEditMode ? "Edit Task" : "New Task")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") { dismiss() }
                    .foregroundColor(primaryBlue)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    Task {
                        await viewModel.saveTask()
                        if viewModel.isSaved { dismiss() }
                    }
                }
                .foregroundColor(primaryBlue)
                .fontWeight(.semibold)
                .disabled(viewModel.isSaving || viewModel.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") { viewModel.errorMessage = nil }
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
    }

    // MARK: - Title

    private var titleField: some View {
        TextField("What needs to be done", text: $viewModel.title)
            .font(.title2)
            .fontWeight(.medium)
            .padding(.top, 8)
    }

    // MARK: - Priority

    private var prioritySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("PRIORITY LEVEL")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.gray)
                .kerning(1.2)

            HStack(spacing: 0) {
                ForEach(TaskPriority.allCases, id: \.self) { priority in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.priority = priority
                        }
                    }) {
                        Text(priority.rawValue)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(viewModel.priority == priority ? .primary : .gray)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(viewModel.priority == priority ? Color.white : Color.clear)
                                    .shadow(color: viewModel.priority == priority ? Color.black.opacity(0.08) : .clear, radius: 4, x: 0, y: 2)
                            )
                    }
                }
            }
            .padding(4)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.systemGray6))
            )
        }
    }

    // MARK: - Notes

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "text.alignleft")
                    .font(.caption)
                    .foregroundColor(.gray)
                Text("Notes & Details")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }

            ZStack(alignment: .topLeading) {
                TextEditor(text: $viewModel.notes)
                    .frame(minHeight: 100)
                    .padding(8)

                if viewModel.notes.isEmpty {
                    Text("Add more information about this task...")
                        .foregroundColor(.gray.opacity(0.5))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 16)
                        .allowsHitTesting(false)
                }
            }
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
    }

    // MARK: - Due Date & Category

    private var dueDateAndCategoryRow: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("Due Date")
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                DatePicker("", selection: $viewModel.dueDate, displayedComponents: .date)
                    .labelsHidden()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(Color(.systemGray6))
            .cornerRadius(10)

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    Image(systemName: "tag")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("Category")
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                Picker("", selection: $viewModel.category) {
                    ForEach(TaskCategory.allCases, id: \.self) { category in
                        Text(category.rawValue).tag(category)
                    }
                }
                .labelsHidden()
                .tint(.primary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
    }

    // MARK: - Motivational Card

    private var motivationalCard: some View {
        VStack(spacing: 8) {
            Text("Stay Focused")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text("\"Efficiency is doing things right; effectiveness is doing the right things.\"")
                .font(.caption)
                .foregroundColor(.white.opacity(0.85))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.35, green: 0.40, blue: 0.85),
                    Color(red: 0.50, green: 0.55, blue: 0.95)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
    }
}
