import SwiftUI

struct TaskDetailView: View {
    @StateObject private var viewModel: TaskDetailViewModel
    private let coordinator: AppCoordinator
    @Environment(\.dismiss) private var dismiss
    
    init(viewModel: TaskDetailViewModel, coordinator: AppCoordinator) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.coordinator = coordinator
    }
    
    @ViewBuilder
    private var formContent: some View {
        Section(header: Text(viewModel.isEditMode ? "Edit Task" : "New Task")) {
            TextField("Task title", text: $viewModel.title)
                .textFieldStyle(.plain)
        }
        
        Section {
            Button(action: {
                Task {
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
    
    var body: some View {
        Form(content: { formContent })
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
