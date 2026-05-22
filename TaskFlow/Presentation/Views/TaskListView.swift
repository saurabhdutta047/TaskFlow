import SwiftUI

struct TaskListView: View {
    @StateObject private var viewModel: TaskListViewModel
    private let coordinator: AppCoordinator
    
    @State private var showingAddTask = false
    
    init(viewModel: TaskListViewModel, coordinator: AppCoordinator) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.coordinator = coordinator
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Loading tasks...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.filteredTasks.isEmpty {
                    emptyStateView
                } else {
                    taskListView
                }
            }
            .navigationTitle("Task Flow")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddTask = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddTask, onDismiss: {
                Task { await viewModel.loadTasks() }
            }) {
                NavigationView {
                    coordinator.showTaskDetail(for: nil)
                }
            }
            .alert(
                "Error",
                isPresented: .constant(viewModel.errorMessage != nil),
                actions: {
                    Button("OK") { viewModel.errorMessage = nil }
                },
                message: {
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                    }
                }
            )
            .task {
                await viewModel.loadTasks()
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: viewModel.filter == .completed ? "checkmark.circle" : "tray")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            Text(viewModel.filter == .completed ? "No completed tasks" : "No tasks yet")
                .font(.headline)
                .foregroundColor(.gray)
            if viewModel.filter == .all {
                Button("Add your first task") {
                    showingAddTask = true
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var taskListView: some View {
        VStack {
            filterPicker
            List {
                ForEach(viewModel.filteredTasks) { task in
                    TaskRowView(
                        task: task,
                        onToggle: { await viewModel.toggleTaskCompletion(task) },
                        onTap: { showingAddTask = true },
                        onDelete: { await viewModel.deleteTask(task) }
                    )
                }
            }
            .listStyle(.insetGrouped)
        }
    }
    
    private var filterPicker: some View {
        Picker("Filter", selection: $viewModel.filter) {
            ForEach(TaskFilter.allCases, id: \.self) { filter in
                Text(filter.rawValue).tag(filter)
            }
        }
        .pickerStyle(.segmented)
        .padding()
    }
}

struct TaskRowView: View {
    let task: TaskItem
    let onToggle: () async -> Void
    let onTap: () -> Void
    let onDelete: () async -> Void
    
    var body: some View {
        HStack {
            Button(action: { Task { await onToggle() } }) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(task.isCompleted ? .green : .gray)
            }
            .buttonStyle(.plain)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .strikethrough(task.isCompleted)
                    .foregroundColor(task.isCompleted ? .gray : .primary)
                Text(task.createdAt, style: .date)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Button(action: { onTap() }) {
                Image(systemName: "pencil")
                    .foregroundColor(.blue)
            }
            .buttonStyle(.plain)
            
            Button(action: { Task { await onDelete() } }) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
            .buttonStyle(.plain)
        }
        .contentShape(Rectangle())
    }
}
