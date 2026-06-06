# TaskFlow

A native iOS task management app built with SwiftUI. TaskFlow is a small,
focused codebase that demonstrates a clean, testable architecture — MVVM-C,
Clean Architecture layering, dependency injection, the repository pattern, and
modern Swift concurrency (`async/await`).

This README focuses on the **architecture decisions** behind the project: what
was chosen, and *why*.

## Table of Contents

- [Features](#features)
- [Architecture Overview](#architecture-overview)
- [Layer-by-Layer Decisions](#layer-by-layer-decisions)
- [Cross-Cutting Decisions](#cross-cutting-decisions)
- [Data Flow Example](#data-flow-example)
- [Project Structure](#project-structure)
- [Testing Strategy](#testing-strategy)
- [Getting Started](#getting-started)
- [Trade-offs & Future Work](#trade-offs--future-work)

## Features

- List, add, edit, and delete tasks
- Mark tasks complete / active
- Filter by All / Active / Completed
- Task priority, notes, due date, and category
- Read-only task details screen
- Slide-out side menu and user profile screen
- Local persistence via `UserDefaults`

## Architecture Overview

TaskFlow uses **MVVM-C** (Model–View–ViewModel–Coordinator) layered on top of a
**Clean Architecture** dependency rule. The guiding principle is that
dependencies always point *inward*: outer layers know about inner layers, never
the reverse.

```
┌──────────────────────────────────────────────────────────────┐
│                       Presentation                             │
│   Views  ──>  ViewModels  ──>  Coordinator                     │
│     (SwiftUI)   (@MainActor,      (navigation +                │
│                  ObservableObject)  screen factory)            │
└───────────────────────────┬──────────────────────────────────┘
                            │ depends on (protocols)
┌───────────────────────────▼──────────────────────────────────┐
│                          Domain                                │
│   Models  ·  Use Cases  ·  Repository Protocol                 │
│   (pure Swift, no framework or storage knowledge)              │
└───────────────────────────▲──────────────────────────────────┘
                            │ implements
┌───────────────────────────┴──────────────────────────────────┐
│                           Data                                 │
│   TaskRepository  ──>  TaskStorageService  ──>  UserDefaults   │
└──────────────────────────────────────────────────────────────┘

         Core / DI: AppDependencyContainer wires everything together
```

**Why this structure?**

- **Separation of concerns** — UI, business logic, and persistence each live in
  their own layer and can change independently.
- **Testability** — every dependency is expressed as a protocol, so any
  collaborator can be replaced with a mock in unit tests. This is the single
  biggest reason for the protocol-heavy design.
- **Swappable persistence** — the Domain layer never imports `UserDefaults`. If
  we move to Core Data / SwiftData / a remote API tomorrow, only the Data layer
  changes.

## Layer-by-Layer Decisions

### Domain Layer (`Domain/`)

Pure Swift with no UI or storage dependencies. This is the stable core of the
app.

- **Models** (`TaskItem`, `TaskFilter`, `TaskCategory`, `TaskPriority`)
  - `TaskItem` conforms to `Codable` (persistence), `Identifiable` (SwiftUI
    lists), `Equatable`, and `Hashable` (`NavigationPath`).
  - **Decision:** `TaskItem` ships a *custom `Decodable` initializer* so tasks
    saved before `priority`, `notes`, `dueDate`, and `category` existed can
    still be decoded. This keeps schema evolution backward-compatible without a
    migration step — important when persisting raw `Codable` blobs.
- **Repository Protocol** (`TaskRepositoryProtocol`)
  - Defines the data-access contract (`fetchTasks`, `addTask`, `updateTask`,
    `deleteTask`) as `async throws`. The Domain layer owns this *interface*; the
    Data layer provides the *implementation*. This is the dependency-inversion
    boundary that keeps persistence details out of business logic.
- **Use Cases** (`FetchTasksUseCase`, `AddTaskUseCase`, `UpdateTaskUseCase`,
  `DeleteTaskUseCase`)
  - Each use case is a protocol + `...Impl` pair exposing a single
    `execute(...)` method.
  - **Decision:** one use case per operation (Single Responsibility). Although
    they're thin wrappers over the repository today, they give us a dedicated,
    individually-testable seam to add business rules (validation, side effects,
    analytics) without touching view models or the repository.

### Data Layer (`Data/`)

The only layer that knows *how* data is stored.

- **`TaskStorageService`** — low-level persistence backed by `UserDefaults`,
  encoding tasks as JSON. Hidden behind `TaskStorageServiceProtocol` so the
  storage mechanism is mockable and replaceable.
- **`TaskRepository`** — implements `TaskRepositoryProtocol` by delegating to the
  storage service. It is the bridge between the Domain contract and the concrete
  storage.
- **Decision:** the two-level split (Repository → StorageService) keeps the
  repository focused on *what* (CRUD semantics) and the storage service on *how*
  (encoding + `UserDefaults` keys). Swapping `UserDefaults` for a database means
  rewriting only `TaskStorageService`.

### Presentation Layer (`Presentation/`)

- **ViewModels** (`TaskListViewModel`, `TaskDetailViewModel`,
  `TaskDetailsViewModel`, `UserProfileViewModel`)
  - All are `@MainActor final class … : ObservableObject` with `@Published`
    state, so SwiftUI updates happen safely on the main thread.
  - View models depend on **use case protocols**, never on concrete
    implementations or storage — that's what makes them unit-testable.
  - **Decision (anti-flicker):** `TaskListViewModel` only shows the loading
    spinner on the *initial* load (when `tasks` is empty). Subsequent refreshes
    update the array silently to avoid the list flashing on every
    add/edit/complete/delete.
- **Views** (`TaskListView`, `TaskDetailView`, `TaskDetailsView`,
  `UserProfileView`, `SideMenuView`, `MainTabView`, `TaskFlowApp`)
  - Declarative SwiftUI. Views hold a view model and a coordinator reference;
    they never construct their own dependencies.
  - **Decision:** the add/edit sheet uses `.sheet(item:)` with a
    `TaskDetailSheetItem` wrapper rather than `.sheet(isPresented:)`. Because
    `.sheet(isPresented:)` captures its content closure eagerly, the task to edit
    could be `nil` on first presentation; `.sheet(item:)` passes the exact item
    into the closure, so editing always targets the correct task.
- **Coordinator** (`AppCoordinator` + `Coordinator` protocol)
  - **Decision:** navigation lives in the coordinator, not in views. The
    coordinator is also a *screen factory* — `start()`, `showTaskDetail(for:)`,
    and `showTaskDetails(for:)` build fully-wired view models and views. This
    keeps views ignorant of how their successors are assembled and centralizes
    navigation flow in one place.

### Core Layer (`Core/DI/`)

- **`AppDependencyContainer`** — the composition root.
  - Owns single, lazily-created instances of the storage service, repository,
    and use cases, and exposes `make…ViewModel(...)` factory methods that hand
    out fresh view models wired to those shared use cases.
  - **Decision:** manual constructor injection via a single container instead of
    a DI framework. For an app this size it's zero-dependency, fully explicit,
    and trivial to follow — you can read the entire object graph in one file.

## Cross-Cutting Decisions

- **Concurrency: `async/await`** — all data operations are `async throws`.
  ViewModels are `@MainActor`, so UI state mutations stay on the main thread
  while I/O happens off the hot path. No completion handlers or Combine
  pipelines for data flow.
- **Protocol-first design** — every collaborator (storage, repository, use
  cases) is defined as a protocol with a concrete `…Impl`/implementation. This
  is the foundation of the testing strategy.
- **Error handling** — errors propagate via `throws`; view models catch them and
  surface a user-facing `errorMessage` rather than crashing.
- **Persistence format** — JSON-encoded `Codable` in `UserDefaults`. Chosen for
  simplicity; the custom decoder absorbs schema changes.

## Data Flow Example

Adding a task, end to end:

```
TaskDetailView (user taps Save)
   → TaskDetailViewModel.save()
       → AddTaskUseCase.execute(task)
           → TaskRepository.addTask(task)
               → TaskStorageService.save(tasks)  → UserDefaults
   ← sheet dismissed
TaskListView.onDismiss → TaskListViewModel.loadTasks()  (silent refresh)
   → @Published tasks updates → SwiftUI re-renders the list
```

Every arrow crosses a protocol boundary, so every step can be tested in
isolation.

## Project Structure

```
TaskFlow/
├── Domain/
│   ├── Models/
│   │   ├── TaskItem.swift
│   │   ├── TaskFilter.swift
│   │   ├── TaskCategory.swift
│   │   └── TaskPriority.swift
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
│   │   ├── TaskDetailViewModel.swift
│   │   ├── TaskDetailsViewModel.swift
│   │   └── UserProfileViewModel.swift
│   └── Views/
│       ├── TaskFlowApp.swift
│       ├── MainTabView.swift
│       ├── TaskListView.swift
│       ├── TaskDetailView.swift
│       ├── TaskDetailsView.swift
│       ├── SideMenuView.swift
│       └── UserProfileView.swift
├── Core/
│   └── DI/
│       └── AppDependencyContainer.swift
└── Tests/
    ├── TaskModelTests.swift
    ├── TaskStorageServiceTests.swift
    ├── TaskRepositoryTests.swift
    ├── UseCaseTests.swift
    ├── TaskListViewModelTests.swift
    ├── TaskDetailViewModelTests.swift
    ├── TaskListViewTests.swift
    ├── TaskDetailViewTests.swift
    ├── AppCoordinatorTests.swift
    └── AppDependencyContainerTests.swift
```

## Testing Strategy

Tests are written with **Swift Testing** (`@Test`, `#expect`, `@Suite`) rather
than XCTest.

- **Why protocols pay off here:** because every dependency is a protocol, tests
  inject lightweight mocks/spies instead of touching real storage. ViewModels,
  use cases, the repository, and the coordinator are all exercised in isolation.
- **Isolation of `UserDefaults` tests:** storage tests each use a unique
  `UserDefaults` suite (UUID-named) so Swift Testing's parallel execution can't
  let tests interfere with one another.
- **Coverage** spans Domain (models, use cases), Data (storage, repository),
  and Presentation (view models, view construction, coordinator, DI container).

Run all tests in Xcode with **Cmd + U** using the `TaskFlow` scheme.

## Getting Started

### Prerequisites
- Xcode 15.0+
- iOS 17.0+
- Swift 5.9+

### Run

```bash
open TaskFlow.xcodeproj
```

Select a simulator or device and press **Cmd + R**. Run tests with **Cmd + U**.

## Trade-offs & Future Work

These are conscious trade-offs given the app's scope:

- **`UserDefaults` over a database** — simplest thing that works for small,
  local data. The repository/storage split means migrating to Core Data /
  SwiftData touches only the Data layer.
- **Use cases are currently thin** — they add a layer of indirection that only
  pays off once real business rules land. They were kept to preserve a clean
  seam for that growth and for testing.
- **`AnyView` in the coordinator** — type erasure simplifies the factory API at
  a small performance/diagnostics cost; fine at this scale.

Potential enhancements:
- Core Data / SwiftData persistence and CloudKit sync
- Reminders / notifications for due dates
- Search and richer filtering
- Replace mock profile data with real user accounts
