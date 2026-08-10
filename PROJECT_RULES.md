# Architectural Guidelines - Priora Mobile

To ensure codebase maintainability, scalability, and code readability, the project follows these architectural rules when developing new screens and features.

## 1. Module Structure (3-Layer Architecture)

Each feature/module must follow a 3-layer architecture: `data`, `domain`, and `presentation`.

```text
lib/features/
└── <actor>/
    └── <feature>/
        ├── data/                         # 1) DATA LAYER
        │   ├── services/                 #   HTTP clients / API calls (Dio, etc.)
        │   ├── repositories/             #   Repository implementations (API → domain)
        │   └── models/                   #   DTOs / serialization models (fromJson/toJson)
        ├── domain/                       # 2) DOMAIN LAYER
        │   ├── models/                   #   Domain entities (business objects)
        │   └── interfaces/               #   Repository contracts / abstractions
        └── presentation/                 # 3) PRESENTATION LAYER
            ├── controller/               #   View logic (Cubit / Controller / State)
            ├── widgets/                  #   Modular widgets extracted from the view
            └── <feature>_screen.dart     #   The view (widget tree composition only)
```

### data/
- **services/**: Only responsible for making HTTP requests to the API. No business logic.
- **repositories/**: Orchestrate services and map raw API responses into domain models. They implement the contracts defined in `domain/interfaces/`.
- **models/**: Data transfer objects (DTOs) used for serialization (`fromJson` / `toJson`). They should not leak into the presentation layer.

### domain/
- **models/**: Domain entities representing business concepts. Independent of API payloads and Flutter/Dart framework details.
- **interfaces/**: Abstract contracts (e.g., `abstract class AgendaRepository`) that the implementations in `data/repositories/` must implement. This allows the presentation layer to depend only on abstractions.

### presentation/
- **controller/**: Contains the Controller/Cubit classes that hold the view's state and business logic (event handling, state updates, calls to repositories/services).
- **widgets/**: Modular widgets extracted from the view to keep files short, reusable, and readable.
- **<feature>_screen.dart**: The view. Composition entry point that builds the widget tree using the controller and the `widgets/` components. It must contain minimal to no logic.

### Example: `doctor/agenda`

```text
lib/features/doctor/agenda/
├── data/
│   ├── services/
│   │   └── availability_service.dart
│   ├── repositories/
│   │   └── agenda_repository.dart
│   └── models/
│       └── weekly_schedule_dto.dart
├── domain/
│   ├── models/
│   │   └── weekly_schedule.dart
│   └── interfaces/
│       └── agenda_repository.dart
└── presentation/
    ├── controller/
    │   ├── agenda_cubit.dart
    │   └── agenda_state.dart
    ├── widgets/
    │   ├── agenda_skeletons.dart
    │   └── delete_block_sheet.dart
    └── doctor_agenda_screen.dart
```

## 2. Separation of Concerns (UI vs. Logic)

- **Views (Screens)**: A screen/view must strictly focus on building the visual widget tree layout. It should contain minimal to no logic.
- **Minimal View Code**: Views must aim to have the **least amount of code possible**. Anything that can be extracted (widgets, constants, helpers) must be moved out of the view file. If a view exceeds ~100 lines of build code, it is a strong signal that logic and/or widgets must be extracted.
- **Reusability**: Code must be **reusable** by default. Any widget, component, or helper that can be used in more than one place must be extracted (either to the feature's `presentation/widgets/` or to `core/widgets/` if shared across features). Avoid copy-pasting the same UI blocks between screens.
- **Controllers**: Any state updates, action handlers, event dispatching, or business logic must be isolated in a dedicated Controller class inside `presentation/controller/`.
- **Data Layer**: Services and Repositories handle network requests and data mapping.

## 3. Dependency Direction

- `presentation` → `domain` (depends on interfaces and domain models)
- `data` → `domain` (implements interfaces, maps to/from domain models)
- `domain` must NOT depend on `data` or `presentation`.
- `presentation` must NOT import directly from `data`; it must go through `domain` interfaces.

## 4. File Size & Modular Widgets

- Files must be kept short, concise, and easy to read. A single file should generally avoid exceeding **150-200 lines**.
- **One class per file**: A file must contain **exactly one public class** (plus its private helpers if strictly required). Do not declare multiple public classes, models, or widgets in the same file.
- If a screen requires helper widgets (e.g., custom cards, buttons, sections), these widgets must be extracted into a dedicated local `presentation/widgets/` folder inside the feature module.

## 5. Naming Conventions

- **Services**: `snake_case_service.dart` (e.g., `availability_service.dart`)
- **Repositories (data)**: `snake_case_repository.dart` (e.g., `agenda_repository.dart`)
- **Interfaces (domain)**: same name as the repository it contracts (e.g., `domain/interfaces/agenda_repository.dart`)
- **Domain models**: `snake_case.dart` (e.g., `weekly_schedule.dart`)
- **DTOs (data/models)**: `snake_case_dto.dart` when the name collides with a domain model, otherwise plain `snake_case.dart`
- **Controllers**: `<feature>_cubit.dart` / `<feature>_controller.dart` plus `<feature>_state.dart`
- **Screens**: `<feature>_screen.dart` (e.g., `doctor_agenda_screen.dart`)
- **Widgets**: descriptive `snake_case.dart` (e.g., `delete_block_sheet.dart`)

## 6. Linting

The project uses two complementary linting tools (configured in `analysis_options.yaml`):

### very_good_analysis (base)
Strict superset of `flutter_lints` (200+ rules) activated via the `include:` directive. Run it with:

```sh
fvm flutter analyze
# or
fvm dart analyze
```

Auto-fixable issues can be resolved with:

```sh
fvm dart fix --apply
```

### dart_code_linter (architecture rules)
Provides the architecture-oriented rules that enforce this document:

- `prefer-single-widget-per-file` → One widget/class per file.
- `avoid-returning-widgets` → Extract reusable widgets instead of returning them from methods.
- `prefer-extracting-callbacks` → Extract callbacks into reusable methods.

> **Note**: `flutter analyze` / `dart analyze` CLI do NOT load analyzer plugins.
> dart_code_linter must be run through its own CLI:

```sh
fvm dart run dart_code_linter:metrics analyze lib
```

### Enforcement checklist
Before pushing, both commands above must pass without new issues:

1. `fvm flutter analyze` → no errors/warnings in changed files.
2. `fvm dart run dart_code_linter:metrics analyze lib` → no architecture rule violations in changed files.
