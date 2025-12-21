# 📱 Task Manager - Flutter Todo App

A modern, feature-rich task management application built with Flutter and Hive for local data persistence. This app provides an intuitive interface for organizing tasks by categories with real-time updates and offline-first architecture.

## ✨ Features

- **📂 Category Management**: Create, edit, and delete custom task categories with color-coded icons
- **📝 Task Organization**: Organize tasks by categories with automatic grouping (Late, Today, Future, Done)
- **👤 Personalized Experience**: Onboarding screen to capture user name with persistent storage
- **🔄 Real-time Updates**: Live synchronization using Hive box watchers
- **📊 Multiple Views**: Switch between list and grid views for categories
- **📈 Task Tracking**: Visual progress indicators showing completion rates per category
- **💾 Offline-First**: All data stored locally using Hive database
- **🎨 Material Design 3**: Modern UI with custom theming and animations

## 🛠️ Tech Stack

- **Framework**: Flutter 3.5.1
- **Database**: Hive 2.2.3 (NoSQL local storage)
- **State Management**: StatefulWidget with StreamSubscription
- **UI Components**: Material Design 3
- **Fonts**: Google Fonts (Inter)
- **Local Storage**: SharedPreferences for user preferences

## 🏗️ Architecture

```
lib/
├── app/
│   ├── entities/          # Hive data models (Category, Task)
│   ├── models/            # UI models
│   ├── services/          # Business logic & CRUD operations
│   ├── shared/            # Helpers (colors, icons, date formatting)
│   ├── home_page.dart     # Category overview
│   ├── task_list.dart     # Task management per category
│   ├── splash_page.dart   # App splash screen
│   └── onboarding_page.dart # First-time user setup
└── main.dart              # App entry point & Hive initialization
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.5.1 or higher
- Dart 3.0+

### Installation

1. Clone the repository
```bash
git clone https://github.com/yourusername/task_manager.git
cd task_manager
```

2. Install dependencies
```bash
flutter pub get
```

3. Generate Hive adapters
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

4. Run the app
```bash
flutter run
```

## 📦 Key Dependencies

```yaml
dependencies:
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  google_fonts: ^6.1.0
  shared_preferences: ^2.2.0

dev_dependencies:
  hive_generator: ^2.0.1
  build_runner: ^2.4.6
```

## 📸 Screenshots

<img width="398" height="844" alt="Splash Screen" src="https://github.com/user-attachments/assets/20e3c7e7-8e60-4215-8989-5f9f178c7d5f" />
<img width="390" height="844" alt="Onboarding" src="https://github.com/user-attachments/assets/a2fe2148-80ea-4235-8766-54fa9f86a193" />
<img width="395" height="849" alt="Home - List View" src="https://github.com/user-attachments/assets/c4d32aa1-83cb-4d87-9d2c-1b9cded9c4e5" />
<img width="391" height="845" alt="Home - Grid View" src="https://github.com/user-attachments/assets/c81db917-67c6-47d8-98b4-af5ed65fcf82" />
<img width="392" height="847" alt="Task List" src="https://github.com/user-attachments/assets/6a87cb1e-d48e-4afb-8ada-26c992f69b6d" />
<img width="393" height="848" alt="Create Category" src="https://github.com/user-attachments/assets/5c7d44d3-b2bd-4a69-a2b2-b211f9b99aa9" />
<img width="394" height="845" alt="Create Task" src="https://github.com/user-attachments/assets/ea5fd7fd-b0c7-4afa-a695-1b5778d4aa20" />

## 🎯 Features Breakdown

### Task Smart Grouping
Tasks are automatically organized into:
- **Late**: Overdue tasks that need immediate attention
- **Today**: Tasks due today
- **Future**: Upcoming tasks
- **Done**: Completed tasks

### Category Customization
- Choose from 10+ predefined colors
- Select from 9+ icon options
- Track progress with visual indicators
- View task count per category

## 🔧 Code Highlights

- **Hive Integration**: Type-safe NoSQL database with code generation
- **Stream-based Updates**: Real-time UI updates using Hive watchers
- **Extension Methods**: Custom DateTime extensions for date manipulation
- **Proper Lifecycle Management**: StreamSubscription cleanup to prevent memory leaks
- **Responsive Design**: Adaptive layouts for different screen sizes

## 📝 License

This project is open source and available under the [MIT License](LICENSE).

## 🤝 Contributing

Contributions, issues, and feature requests are welcome! Feel free to check the [issues page](https://github.com/yourusername/task_manager/issues).

## 👨‍💻 Author

Your Name - [@yourhandle](https://github.com/yourusername)

---

⭐ Star this repo if you find it helpful!
