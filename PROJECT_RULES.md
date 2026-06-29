# Architectural Guidelines - Priora Mobile

To ensure codebase maintainability, scalability, and code readability, the project follows these architectural rules when developing new screens and features:

## 1. Separation of Concerns (UI vs. Logic)
- **Views (Screens)**: A screen/view must strictly focus on building the visual widget tree layout. It should contain minimal to no logic.
- **Controllers**: Any state updates, action handlers, event dispatching, or business logic must be isolated in a dedicated Controller class.
- **Data Layer**: Repositories and BLoCs handle network requests and globally broadcasted state transitions.

## 2. File Size & Modular Widgets
- Files must be kept short, concise, and easy to read. A single file should generally avoid exceeding **150-200 lines**.
- If a screen requires helper widgets (e.g., custom cards, buttons, sections), these widgets must be extracted into a dedicated local `widgets/` folder inside the feature module's presentation layer:
  ```text
  presentation/
  ├── widgets/
  │   ├── custom_card.dart
  │   └── action_button.dart
  └── feature_screen.dart
  ```

## 3. Directory Layout Pattern
For each module or feature, organize files using this standard directory pattern:
- `controller/`: Component controller classes managing local view state.
- `presentation/`:
  - `widgets/`: Modular, extraction-only presentation components.
  - `<feature>_screen.dart`: Composition entry point using widgets.
