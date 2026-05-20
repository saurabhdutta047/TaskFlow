# TaskFlow

A production-quality iOS task management app built with SwiftUI, MVVM-C architecture, async/await, dependency injection, and the repository pattern.

## Features

- **List Tasks**: View all tasks in a clean, organized list
- **Add/Edit Task**: Create new tasks or edit existing ones
- **Delete Task**: Remove tasks you no longer need
- **Mark Complete**: Toggle task completion status with a single tap
- **Filter Tasks**: View All, Active, or Completed tasks
- **Local Persistence**: Tasks are stored locally using UserDefaults

## Architecture

The app follows a clean, layered architecture with clear separation of concerns:

### Domain Layer
Contains business logic and domain models:
- `Task`: Core domain model with Identifiable, Codable, and Equatable conformance
- `TaskFilter`: Enum for filtering tasks (All, Active, Completed)
- `TaskRepositoryProtocol`: Protocol defining repository operations
- Use Cases: `FetchTasksUseCase`, `AddTaskUseCase`, `UpdateTaskUseCase`, `DeleteTaskUseCase`

### Data Layer
Handles data persistence:
- `TaskStorageService`: UserDefaults-based storage service with protocol for testability
- `TaskRepository`: Implementation of TaskRepositoryProtocol using the storage service

### Presentation Layer
Manages UI and user interactions:
- `AppCoordinator`: Navigation coordinator following MVVM-C pattern
- `TaskListViewModel`: ViewModel for the task list with filtering support
- `TaskDetailViewModel`: ViewModel for adding/editing tasks
- `TaskListView`: Main view displaying tasks with filter controls
- `TaskDetailView`: Form view for creating/editing tasks

### Core Layer
Provides dependency injection:
- `AppDependencyContainer`: Centralized dependency container managing all dependencies

## Project Structure

```
TaskFlow/
├── Domain/
│   ├── Models/
│   │   ├── Task.swift
│   │   └── TaskFilter.swift
│   ├── Repositories/
│   │   └── TaskRepositoryProtocol.swift
│   └── UseCases/
│       ├── FetchTasksUseCase.swift
│       ├── AddTaskUseCase.swift
│       ├── UpdateTaskUseCase.swift
│       └── DeleteTaskUseCase.swift
├── Data/
│   ├── Repositories/
│   │   └── TaskRepository.swift
│   └── Storage/
│       └── TaskStorageService.swift
├── Presentation/
│   ├── Coordinators/
│   │   └── AppCoordinator.swift
│   ├── ViewModels/
│   │   ├── TaskListViewModel.swift
│   │   └── TaskDetailViewModel.swift
│   └── Views/
│       ├── TaskFlowApp.swift
│       ├── TaskListView.swift
│       └── TaskDetailView.swift
├── Core/
│   └── DI/
│       └── AppDependencyContainer.swift
└── Tests/
    ├── TaskModelTests.swift
    ├── TaskStorageServiceTests.swift
    ├── TaskRepositoryTests.swift
    ├── UseCaseTests.swift
    └── TaskListViewModelTests.swift
```

## Setup Instructions

### Prerequisites
- Xcode 15.0 or later
- iOS 17.0 or later
- Swift 5.9 or later

### Installation

1. **Open the Project**
   ```bash
   cd TaskFlow
   open TaskFlow.xcodeproj
   ```

2. **Select Target Device**
   - Choose an iOS Simulator or physical device in Xcode's scheme selector

3. **Build and Run**
   - Press `Cmd + R` or click the Play button in Xcode
   - The app will launch on the selected device

### Running Tests

1. **Run All Tests**
   - Press `Cmd + U` in Xcode
   - Or use Product > Test from the menu

2. **Run Specific Test Suite**
   - Navigate to the Test Navigator (Cmd + 6)
   - Click on the test suite or individual test you want to run

## Testing

The app includes comprehensive unit tests covering:
- Domain model tests (Task initialization, Codable, Equatable)
- Storage service tests (save/fetch operations)
- Repository tests (CRUD operations)
- Use case tests (business logic)
- ViewModel tests (UI logic and state management)

All tests use mocks for isolation and can be run independently.

## Key Technologies

- **SwiftUI**: Modern declarative UI framework
- **MVVM-C**: Model-View-ViewModel with Coordinator pattern for navigation
- **async/await**: Modern concurrency for asynchronous operations
- **Dependency Injection**: Loose coupling and testability
- **Repository Pattern**: Abstraction layer for data access
- **UserDefaults**: Simple local persistence
- **XCTest**: Comprehensive unit testing framework

## Usage

1. **Add a Task**
   - Tap the `+` button in the top-right corner
   - Enter a task title
   - Tap "Add Task"

2. **Edit a Task**
   - Tap the pencil icon on any task
   - Modify the title
   - Tap "Update Task"

3. **Mark Complete**
   - Tap the circle icon next to any task
   - The task will be marked as complete with a green checkmark

4. **Delete a Task**
   - Tap the trash icon on any task
   - Confirm deletion

5. **Filter Tasks**
   - Use the segmented control at the top
   - Switch between All, Active, and Completed views

## Future Enhancements

Potential improvements for future versions:
- Core Data or SwiftData for more robust persistence
- CloudKit sync for cross-device support
- Task categories and tags
- Due dates and reminders
- Search functionality
- Dark mode customization
- Widget support
- Siri integration

## License

This project is provided as-is for educational and development purposes.
