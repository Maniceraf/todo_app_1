# Architecture Guide - Task Manager App

## 🏗️ Pattern: Repository Pattern với Dependency Inversion Principle

### 1. Overview

Project này sử dụng **Repository Pattern** kết hợp với **Dependency Inversion Principle (DIP)** - một trong 5 nguyên tắc SOLID.

```
┌─────────────────────────────────────────┐
│         Presentation Layer              │
│  (UI - StatefulWidget/StatelessWidget)  │
│                                         │
│  HomePage, TaskListPage, Forms...      │
└──────────────┬──────────────────────────┘
               │ depends on
               ▼
┌─────────────────────────────────────────┐
│      Repository Interfaces (Abstract)   │
│                                         │
│  CategoryRepository, TaskRepository    │
└──────────────▲──────────────────────────┘
               │ implements
               │
┌──────────────┴──────────────────────────┐
│    Repository Implementations           │
│                                         │
│  CategoryRepositoryImpl, TaskRepositoryImpl  │
└──────────────┬──────────────────────────┘
               │ uses
               ▼
┌─────────────────────────────────────────┐
│          Data Source (Hive)             │
│                                         │
│  Boxes: categories, tasks              │
└─────────────────────────────────────────┘
```

---

## 2. Dependency Inversion Principle (DIP)

### ❌ TRƯỚC ĐÂY (Tight Coupling):

```dart
class HomePage {
  final CategoryService _service = CategoryService(); // ← Phụ thuộc vào concrete class
  
  void loadData() {
    _service.getAllCategories(); // ← Nếu đổi sang Firebase, phải sửa toàn bộ code
  }
}
```

**Vấn đề:**
- UI phụ thuộc trực tiếp vào Hive implementation
- Khó test (không mock được)
- Khó thay đổi database (phải sửa toàn bộ UI)

---

### ✅ SAU KHI REFACTOR (Loose Coupling):

```dart
// 1. Define interface (abstraction)
abstract class CategoryRepository {
  List<Category> getAllCategories();
  Future<Category> createCategory(Category category);
  // ...
}

// 2. Implementation class implements interface
class CategoryRepositoryImpl implements CategoryRepository {
  @override
  List<Category> getAllCategories() {
    return Hive.box('categories').values.cast<Category>().toList();
  }
  
  @override
  Future<Category> createCategory(Category category) async {
    await Hive.box('categories').put(category.id, category);
    return category;
  }
}

// 3. UI depends on interface, NOT concrete class
class HomePage {
  final CategoryRepository _repository = CategoryRepositoryImpl(); // ← Type là interface
  
  void loadData() {
    _repository.getAllCategories(); // ← Không quan tâm implementation
  }
}
```

**Lợi ích:**
- ✅ UI chỉ biết về interface, không biết Hive
- ✅ Dễ test: mock `CategoryRepository`
- ✅ Dễ thay đổi: tạo `FirebaseCategoryService implements CategoryRepository`

---

## 3. Cấu Trúc Folder

```
lib/
├── data/
│   ├── entities/               # ← Hive entities + adapters
│   │   ├── category.dart
│   │   ├── category.g.dart
│   │   ├── task.dart
│   │   └── task.g.dart
│   │
│   └── repositories/           # ← Interfaces + Implementations
│       ├── category_repository.dart           # Interface
│       ├── category_repository_impl.dart      # Implementation
│       ├── task_repository.dart               # Interface
│       └── task_repository_impl.dart          # Implementation
│
├── features/                   # ← UI grouped by feature
│   ├── home/
│   │   └── home_page.dart
│   ├── category/
│   │   └── add_update_category.dart
│   ├── task/
│   │   ├── task_list.dart
│   │   └── create_update_task.dart
│   └── onboarding/
│       ├── splash_page.dart
│       └── onboarding_page.dart
│
└── core/                       # ← Shared utilities
    ├── constants/
    │   └── app_constants.dart
    ├── enums/
    │   └── view_state.dart
    └── extensions/
        └── date_extension.dart
```

---

## 4. Repository Interface

### File: `lib/data/repositories/category_repository.dart`

```dart
abstract class CategoryRepository {
  // Queries
  List<Category> getAllCategories();
  Category? getCategory(String id);
  
  // Commands
  Future<Category> createCategory(Category category);
  Future<void> updateCategory(Category category);
  Future<void> deleteCategory(String id);
  
  // Reactive
  Stream<void> watchCategories();
}
```

**Key points:**
- `abstract class` = interface trong Dart
- Chỉ định nghĩa method signatures, KHÔNG có implementation
- Return types rõ ràng (`Future<Category>`, `List<Category>`)
- Documentation comments giải thích contract

---

## 5. Service Implementation

### File: `lib/data/repositories/category_repository_impl.dart`

```dart
class CategoryRepositoryImpl implements CategoryRepository {
  static const String _boxName = 'categories';
  Box get _box => Hive.box(_boxName);

  @override
  Future<Category> createCategory(Category category) async {
    await _box.put(category.id, category);
    return category; // ← Return created entity
  }

  @override
  Stream<void> watchCategories() {
    return _box.watch().map((_) {}); // ← Convert BoxEvent to void
  }
  
  // ... other implementations
}
```

**Key points:**
- `CategoryRepositoryImpl` = Implementation of `CategoryRepository` interface
- `implements CategoryRepository` bắt buộc phải implement tất cả methods
- Nếu thiếu method, compile error ngay
- Ẩn Hive implementation details
- Có thể thêm methods riêng (vd: `deleteAll()`)

---

## 6. UI Usage (Presentation Layer)

### File: `lib/features/home/home_page.dart`

```dart
class _HomePageState extends State<HomePage> {
  // Type annotation = interface, NOT concrete class
  final CategoryRepository _categoryRepository = CategoryRepositoryImpl();
  final TaskRepository _taskRepository = TaskRepositoryImpl();

  @override
  void initState() {
    super.initState();
    
    // Use repository's watch method (abstraction)
    _categoryRepository.watchCategories().listen((_) {
      _loadCategories();
    });
  }

  Future<void> _loadCategories() async {
    // Call interface methods
    categories = _categoryRepository.getAllCategories();
    tasks = _taskRepository.getAllTasks();
  }
}
```

**Key points:**
- ✅ Type là `CategoryRepository` (interface)
- ✅ Value là `CategoryService()` (implementation)
- ✅ UI code không import `package:hive`
- ✅ UI code chỉ biết về Repository interface

---

## 7. Tại Sao Không Dùng Dependency Injection?

Hiện tại bạn đang dùng:
```dart
final CategoryRepository _repository = CategoryRepositoryImpl(); // ← Hardcoded
```

**Với DI framework (Provider/Riverpod):**
```dart
// 1. Setup (main.dart)
ProviderScope(
  overrides: [
    categoryRepositoryProvider.overrideWithValue(CategoryRepositoryImpl()),
  ],
  child: MyApp(),
)

// 2. Usage (UI)
class _HomePageState extends State<HomePage> {
  late CategoryRepository _repository;
  
  @override
  void initState() {
    _repository = ref.read(categoryRepositoryProvider); // ← Injected
  }
}

// 3. Testing
testWidgets('...', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        categoryRepositoryProvider.overrideWithValue(MockCategoryRepository()), // ← Easy mock
      ],
      child: HomePage(),
    ),
  );
});
```

**Quyết định:**
- ✅ Project nhỏ: hardcode OK (học DIP principle)
- 🔧 Project lớn hơn: dùng Riverpod (học DI pattern)

---

## 8. Testing Example (Future)

```dart
// Mock repository
class MockCategoryRepository implements CategoryRepository {
  @override
  List<Category> getAllCategories() {
    return [
      Category(id: '1', name: 'Test', color: 1, icon: 1, createdAt: DateTime.now()),
    ];
  }
  
  @override
  Future<Category> createCategory(Category category) async {
    return category;
  }
  
  // ... other mocked methods
}

// Test
void main() {
  testWidgets('HomePage displays categories', (tester) async {
    // Inject mock repository
    final mockRepo = MockCategoryRepository();
    
    await tester.pumpWidget(
      MaterialApp(
        home: HomePage(categoryRepository: mockRepo), // ← Constructor injection
      ),
    );
    
    expect(find.text('Test'), findsOneWidget);
  });
}
```

---

## 9. Mở Rộng: Thay Đổi Database

### Scenario: Đổi từ Hive sang Firebase

**Bước 1:** Tạo Firebase implementation
```dart
class FirebaseCategoryRepositoryImpl implements CategoryRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  @override
  Future<Category> createCategory(Category category) async {
    await _firestore.collection('categories').doc(category.id).set(category.toJson());
    return category;
  }
  
  @override
  List<Category> getAllCategories() {
    // Firebase query...
  }
}
```

**Bước 2:** Thay 1 dòng code duy nhất
```dart
// BEFORE
final CategoryRepository _repository = CategoryService();

// AFTER
final CategoryRepository _repository = FirebaseCategoryService();
```

**Bước 3:** UI code không cần thay đổi gì! ✅

---

## 10. SOLID Principles Applied

| Principle | Implementation |
|-----------|---------------|
| **S**ingle Responsibility | Repository chỉ lo data access, Service chỉ lo business logic |
| **O**pen/Closed | Thêm Firebase service mà không sửa code cũ |
| **L**iskov Substitution | `FirebaseCategoryService` thay thế `CategoryService` mà không break code |
| **I**nterface Segregation | Repository interface nhỏ gọn, không thừa methods |
| **D**ependency Inversion | UI phụ thuộc vào interface, không phụ thuộc concrete class |

---

## 11. Kết Luận

### ✅ Ưu Điểm:
- Dễ test (mock repositories)
- Dễ thay đổi database
- Code sạch hơn, dễ maintain
- Học được SOLID principles

### ⚠️ Trade-offs:
- Thêm 2 interface files
- Phải viết thêm abstraction layer
- Overkill cho project rất nhỏ (< 5 screens)

### 🎯 Recommendation:
- ✅ Project này (10+ screens): **Rất phù hợp**
- ✅ Project production: **Bắt buộc**
- ⚠️ Prototype/POC: **Optional** (dùng Service trực tiếp OK)

---

## 12. Next Steps

Để tối ưu hơn nữa:

1. **State Management:** Thêm Riverpod để manage state globally
2. **Use Cases Layer:** Tách business logic ra khỏi UI
3. **Error Handling:** Thêm `Either<Failure, Success>` return types
4. **Testing:** Viết unit tests cho repositories
5. **Caching:** Implement caching layer giữa UI và repository

Nhưng với project học tập hiện tại, **Repository Pattern + DIP là đủ tốt rồi!** 🎉

