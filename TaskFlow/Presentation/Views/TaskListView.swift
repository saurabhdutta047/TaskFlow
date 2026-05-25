import SwiftUI

struct TaskDetailSheetItem: Identifiable {
    let id = UUID()
    let task: TaskItem?
}

struct TaskListView: View {
    @StateObject private var viewModel: TaskListViewModel
    private let coordinator: AppCoordinator

    @State private var sheetItem: TaskDetailSheetItem?
    @State private var navigationPath = NavigationPath()

    private let primaryBlue = Color(red: 0.25, green: 0.35, blue: 0.95)

    init(viewModel: TaskListViewModel, coordinator: AppCoordinator) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.coordinator = coordinator
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack(alignment: .bottomTrailing) {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                if viewModel.isLoading {
                    ProgressView("Loading tasks...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            headerView
                            dateSection

                            if !viewModel.tasks.isEmpty {
                                filterTabs
                            }

                            if viewModel.tasks.isEmpty {
                                emptyStateView
                            } else if viewModel.filteredTasks.isEmpty {
                                emptyFilterView
                            } else {
                                taskCards
                            }

                            if !viewModel.tasks.isEmpty {
                                insightsSection
                            }

                            Spacer(minLength: 80)
                        }
                    }
                }

                fabButton
            }
            .navigationBarHidden(true)
            .navigationDestination(for: TaskItem.self) { task in
                coordinator.showTaskDetails(for: task)
            }
            .sheet(item: $sheetItem, onDismiss: {
                Task { await viewModel.loadTasks() }
            }) { item in
                NavigationView {
                    coordinator.showTaskDetail(for: item.task)
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
            .onAppear {
                Task { await viewModel.loadTasks() }
            }
        }
    }

    // MARK: - Header

    private var headerView: some View {
        HStack {
            Image(systemName: "line.3.horizontal")
                .font(.title2)
                .foregroundColor(.primary)

            Text("Tasks")
                .font(.title2)
                .fontWeight(.bold)

            Spacer()

            Circle()
                .fill(primaryBlue.opacity(0.15))
                .frame(width: 36, height: 36)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.system(size: 16))
                        .foregroundColor(primaryBlue)
                )
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }

    // MARK: - Date Section

    private var dateSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(Date().formatted(.dateTime.weekday(.wide).month(.wide).day()).uppercased())
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.gray)
                .kerning(1.2)

            Text("Today")
                .font(.system(size: 34, weight: .bold))
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
    }

    // MARK: - Filter Tabs

    private var filterTabs: some View {
        HStack(spacing: 0) {
            ForEach(TaskFilter.allCases, id: \.self) { filter in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.filter = filter
                    }
                }) {
                    Text(filter.rawValue)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(viewModel.filter == filter ? .white : .gray)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(viewModel.filter == filter ? primaryBlue : Color.clear)
                        )
                }
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemGray6))
        )
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
    }

    // MARK: - Task Cards

    private var taskCards: some View {
        LazyVStack(spacing: 12) {
            ForEach(viewModel.filteredTasks) { task in
                TaskRowView(
                    task: task,
                    onToggle: { await viewModel.toggleTaskCompletion(task) },
                    onTap: { navigationPath.append(task) },
                    onDelete: { await viewModel.deleteTask(task) }
                )
            }
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Empty States

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "tray")
                .font(.system(size: 56))
                .foregroundColor(.gray.opacity(0.4))
            Text("No tasks yet")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.gray)
            Text("Tap the + button to add your first task")
                .font(.subheadline)
                .foregroundColor(.gray.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }

    private var emptyFilterView: some View {
        VStack(spacing: 16) {
            Image(systemName: viewModel.filter == .completed ? "checkmark.circle" : "circle.dashed")
                .font(.system(size: 48))
                .foregroundColor(.gray.opacity(0.4))
            Text(viewModel.filter == .completed ? "No completed tasks" : "No active tasks")
                .font(.headline)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }

    // MARK: - Insights

    private var insightsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Insights")
                .font(.title3)
                .fontWeight(.bold)
                .padding(.horizontal, 20)
                .padding(.top, 24)

            insightsCard
                .padding(.horizontal, 20)
        }
    }

    private var insightsCard: some View {
        let completedCount = viewModel.tasks.filter { $0.isCompleted }.count
        let totalCount = viewModel.tasks.count
        let score = totalCount > 0 ? Int(Double(completedCount) / Double(totalCount) * 100) : 0

        return VStack(alignment: .leading, spacing: 8) {
            Text("PRODUCTIVITY SCORE")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white.opacity(0.8))
                .kerning(1.5)

            Text("\(score)%")
                .font(.system(size: 44, weight: .bold))
                .foregroundColor(.white)

            Text("You've completed \(completedCount) of \(totalCount) tasks. \(score >= 50 ? "Keep the momentum!" : "Keep going!")")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.9))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            LinearGradient(
                colors: [
                    primaryBlue,
                    Color(red: 0.35, green: 0.50, blue: 0.98)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(16)
    }

    // MARK: - FAB

    private var fabButton: some View {
        Button(action: {
            sheetItem = TaskDetailSheetItem(task: nil)
        }) {
            Image(systemName: "plus")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(primaryBlue)
                .clipShape(Circle())
                .shadow(color: primaryBlue.opacity(0.4), radius: 8, x: 0, y: 4)
        }
        .padding(.trailing, 20)
        .padding(.bottom, 20)
    }
}

// MARK: - Task Row

struct TaskRowView: View {
    let task: TaskItem
    let onToggle: () async -> Void
    let onTap: () -> Void
    let onDelete: () async -> Void

    private let primaryBlue = Color(red: 0.25, green: 0.35, blue: 0.95)

    var body: some View {
        HStack(spacing: 14) {
            Button(action: { Task { await onToggle() } }) {
                ZStack {
                    Circle()
                        .stroke(task.isCompleted ? primaryBlue : Color.gray.opacity(0.3), lineWidth: 2)
                        .frame(width: 28, height: 28)

                    if task.isCompleted {
                        Circle()
                            .fill(primaryBlue)
                            .frame(width: 28, height: 28)

                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.body)
                    .fontWeight(.medium)
                    .strikethrough(task.isCompleted)
                    .foregroundColor(task.isCompleted ? .gray : .primary)

                Text(task.createdAt, style: .date)
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.gray.opacity(0.4))
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
        .contentShape(Rectangle())
        .onTapGesture { onTap() }
        .contextMenu {
            Button(action: { onTap() }) {
                Label("View Details", systemImage: "eye")
            }
            Button(role: .destructive, action: { Task { await onDelete() } }) {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}
