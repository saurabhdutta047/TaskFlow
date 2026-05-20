import SwiftUI

struct TaskDetailView: View {
    @StateObject private var viewModel: TaskDetailViewModel
    private let coordinator: AppCoordinator
    @Environment(\.dismiss) private var dismiss
    
    init(viewModel: TaskDetailViewModel, coordinator: AppCoordinator) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.coordinator = coordinator
    }
    
    var body: some View {
        Form {
            Section {
                TextField("Task title", text: $viewModel.title)
                    .textFieldStyle(.plain)
            } header: {
                Text(viewModel.isEditMode ? "Edit Task" : "New Task")
            }
            
            Section {
                Button(action: {
                    Swift.Task {
                        await viewModel.saveTask()
                        if viewModel.isSaved {
                            dismiss()
                        }
                    }
                }) {
                    HStack {
                        Spacer()
                        if viewModel.isSaving {
                            ProgressView()
                                .progressViewStyle(.circular)
                        } else {
                            Text(viewModel.isEditMode ? "Update Task" : "Add Task")
                                .fontWeight(.semibold)
                        }
                        Spacer()
                    }
                }
                .disabled(viewModel.isSaving || viewModel.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .navigationTitle(viewModel.isEditMode ? "Edit Task" : "New Task")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
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
}
