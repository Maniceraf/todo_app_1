# Dependency Injection vs Dependency Inversion

## 🤔 Câu Hỏi: Chúng khác nhau chỗ nào?

Nhiều người nhầm lẫn 2 khái niệm này vì tên giống nhau, nhưng chúng hoàn toàn khác nhau!

---

## 📚 Định Nghĩa

### 1. **Dependency Inversion Principle (DIP)** - Nguyên Tắc Thiết Kế

**Là gì:** Một trong 5 nguyên tắc SOLID, định nghĩa **CÁCH TỔ CHỨC CODE**.

**Nguyên tắc:**
> High-level modules should NOT depend on low-level modules.  
> Both should depend on **abstractions** (interfaces).

**Mục đích:** Giảm coupling giữa các layer.

---

### 2. **Dependency Injection (DI)** - Kỹ Thuật Implement

**Là gì:** Một **PATTERN** để truyền dependencies vào class từ bên ngoài.

**Nguyên tắc:**
> Don't create dependencies inside the class.  
> **Inject** them from outside (constructor, setter, or method).

**Mục đích:** Giúp code dễ test và flexible hơn.

---

## 🔍 So Sánh Chi Tiết

| Aspect | Dependency Inversion (DIP) | Dependency Injection (DI) |
|--------|---------------------------|--------------------------|
| **Loại** | Nguyên tắc thiết kế (Principle) | Kỹ thuật implement (Pattern) |
| **Thuộc về** | SOLID principles | Design patterns |
| **Focus** | Hướng phụ thuộc (Direction of dependency) | Cách truyền dependency (How to provide) |
| **Giải quyết** | Tight coupling giữa layers | Hard-coded dependencies |
| **Level** | Architecture level | Implementation level |
| **Bắt buộc dùng chung?** | ❌ Không | ❌ Không (nhưng thường đi cùng nhau) |

---

## 💡 Ví Dụ Thực Tế

### Scenario: HomePage cần lấy danh sách categories

---

### ❌ **Không DIP, Không DI** (Bad)

```dart
class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void loadCategories() {
    // Trực tiếp gọi Hive trong UI
    final box = Hive.box('categories');
    final categories = box.values.cast<Category>().toList();
    setState(() { /* ... */ });
  }
}
```

**Vấn đề:**
- ❌ UI phụ thuộc trực tiếp vào Hive (low-level)
- ❌ Không test được (phải có Hive thật)
- ❌ Đổi database = sửa toàn bộ UI

---

### ✅ **Có DIP, Không DI** (Better)

```dart
// 1. Abstraction (interface)
abstract class CategoryRepository {
  List<Category> getAllCategories();
}

// 2. Implementation
class HiveCategoryRepository implements CategoryRepository {
  @override
  List<Category> getAllCategories() {
    return Hive.box('categories').values.cast<Category>().toList();
  }
}

// 3. UI depends on abstraction
class _HomePageState extends State<HomePage> {
  // ✅ Type = interface (DIP applied)
  // ❌ Nhưng vẫn hardcode implementation (No DI)
  final CategoryRepository _repository = HiveCategoryRepository();
  
  void loadCategories() {
    final categories = _repository.getAllCategories();
    setState(() { /* ... */ });
  }
}
```

**Cải thiện:**
- ✅ UI phụ thuộc vào interface (DIP ✓)
- ✅ Có thể mock interface để test
- ⚠️ Nhưng vẫn hardcode `HiveCategoryRepository()` trong UI

**Vấn đề còn lại:**
- Muốn đổi implementation → phải sửa code UI
- Khó config khác nhau cho dev/prod

---

### ✅✅ **Có DIP + Có DI** (Best)

#### **Cách 1: Constructor Injection**

```dart
class _HomePageState extends State<HomePage> {
  final CategoryRepository _repository;
  
  // ✅ Dependency được inject từ bên ngoài
  _HomePageState(this._repository);
  
  void loadCategories() {
    final categories = _repository.getAllCategories();
  }
}

// Usage
void main() {
  runApp(
    MaterialApp(
      home: HomePage(
        repository: HiveCategoryRepository(), // ← Inject ở đây
      ),
    ),
  );
}
```

**Lợi ích:**
- ✅ UI không biết implementation nào được dùng
- ✅ Dễ test: inject mock repository
- ✅ Dễ thay đổi: inject implementation khác

---

#### **Cách 2: DI Framework (Riverpod)**

```dart
// 1. Define provider
final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return HiveCategoryRepository(); // ← Config ở 1 chỗ duy nhất
});

// 2. UI consumes provider
class _HomePageState extends ConsumerState<HomePage> {
  void loadCategories() {
    // ✅ Dependency được inject tự động
    final repository = ref.read(categoryRepositoryProvider);
    final categories = repository.getAllCategories();
  }
}

// 3. Testing: override provider
testWidgets('...', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        categoryRepositoryProvider.overrideWithValue(MockRepository()),
      ],
      child: HomePage(),
    ),
  );
});
```

**Lợi ích:**
- ✅ Tất cả lợi ích của Constructor Injection
- ✅ + Quản lý lifecycle tự động
- ✅ + Lazy loading
- ✅ + Global access (không cần truyền qua nhiều layers)

---

## 🎯 Tóm Tắt Bằng Hình Ảnh

### **Dependency Inversion (DIP)** - Đảo Ngược Hướng Phụ Thuộc

```
❌ TRƯỚC (Không DIP):
┌─────────┐
│   UI    │ ──depends on──> │ Hive │
└─────────┘                 └──────┘
(High-level phụ thuộc Low-level)

✅ SAU (Có DIP):
┌─────────┐                 ┌──────────────┐
│   UI    │ ──depends on──> │ IRepository  │ <── abstraction
└─────────┘                 └──────┬───────┘
                                   │ implements
                            ┌──────▼───────┐
                            │ HiveRepository│
                            └──────────────┘
(Cả 2 đều phụ thuộc abstraction)
```

---

### **Dependency Injection (DI)** - Truyền Dependency Từ Bên Ngoài

```
❌ TRƯỚC (Không DI):
class HomePage {
  final repo = HiveRepository(); // ← Tạo dependency bên trong
}

✅ SAU (Có DI):
class HomePage {
  final IRepository repo;
  HomePage(this.repo); // ← Nhận dependency từ bên ngoài
}

// Inject từ bên ngoài
HomePage(HiveRepository())  // Dev
HomePage(MockRepository())  // Test
HomePage(FirebaseRepository()) // Prod
```

---

## 📊 Bảng Quyết Định

| Tình Huống | DIP | DI | Giải Pháp |
|-----------|-----|----|---------  |
| UI gọi trực tiếp Hive | ❌ | ❌ | Tạo Repository interface |
| UI dùng interface, nhưng hardcode implementation | ✅ | ❌ | Thêm constructor injection |
| UI dùng interface + inject qua constructor | ✅ | ✅ | Perfect! |
| UI dùng interface + inject qua Riverpod | ✅ | ✅ | Best for large apps |

---

## 🔧 Project Hiện Tại Của Bạn

### Đang ở đâu?

```dart
class _HomePageState extends State<HomePage> {
  final CategoryRepository _repository = CategoryService(); // ← Đây
}
```

**Phân tích:**
- ✅ **Có DIP:** Type là `CategoryRepository` (interface)
- ❌ **Không DI:** Hardcode `CategoryService()` trong class

**Level:** **DIP ✓, DI ✗** (Intermediate)

---

### Upgrade lên DI (Optional)

#### **Option 1: Constructor Injection** (Đơn giản)

```dart
class HomePage extends StatefulWidget {
  final CategoryRepository categoryRepository;
  final TaskRepository taskRepository;
  
  const HomePage({
    super.key,
    required this.categoryRepository,
    required this.taskRepository,
  });
  
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late CategoryRepository _repository;
  
  @override
  void initState() {
    super.initState();
    _repository = widget.categoryRepository; // ← Injected
  }
}

// main.dart
void main() {
  runApp(
    MaterialApp(
      home: HomePage(
        categoryRepository: CategoryService(),
        taskRepository: TaskService(),
      ),
    ),
  );
}
```

**Pros:** Đơn giản, rõ ràng  
**Cons:** Phải truyền qua nhiều layers

---

#### **Option 2: Service Locator** (GetIt)

```dart
// Setup (main.dart)
final getIt = GetIt.instance;

void setupDependencies() {
  getIt.registerSingleton<CategoryRepository>(CategoryService());
  getIt.registerSingleton<TaskRepository>(TaskService());
}

// Usage (UI)
class _HomePageState extends State<HomePage> {
  final _repository = getIt<CategoryRepository>(); // ← Injected
}
```

**Pros:** Không cần truyền qua nhiều layers  
**Cons:** "Service Locator" là anti-pattern (ẩn dependencies)

---

#### **Option 3: Riverpod** (Recommended)

```dart
// providers.dart
final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryService();
});

// UI
class HomePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.watch(categoryRepositoryProvider);
    // ...
  }
}
```

**Pros:** Best practice, reactive, testable  
**Cons:** Learning curve

---

## 🎓 Kết Luận

### DIP vs DI - Mối Quan Hệ

```
┌─────────────────────────────────────┐
│  Dependency Inversion Principle     │
│  (WHAT: Depend on abstractions)     │
└──────────────┬──────────────────────┘
               │
               │ implemented by
               ▼
┌─────────────────────────────────────┐
│   Dependency Injection Pattern      │
│   (HOW: Inject from outside)        │
└─────────────────────────────────────┘
```

**Analogy:**
- **DIP:** "Bạn nên ăn healthy" (Nguyên tắc)
- **DI:** "Cách nấu salad" (Kỹ thuật thực hiện)

---

### Recommendation Cho Project Của Bạn

| Stage | DIP | DI | Action |
|-------|-----|----|---------  |
| **Hiện tại** | ✅ | ❌ | Đã đủ tốt để học! |
| **Next step** | ✅ | ✅ | Thêm Riverpod khi cần state management |
| **Production** | ✅ | ✅ | Bắt buộc cả 2 |

**Lời khuyên:**
1. ✅ **Giữ nguyên hiện tại** để hiểu rõ DIP
2. 🔜 Khi project lớn hơn (15+ screens), thêm Riverpod
3. 🎯 Học từng bước: DIP → DI → State Management

---

## 📚 Tài Liệu Tham Khảo

- **DIP:** [SOLID Principles - Uncle Bob](https://blog.cleancoder.com/uncle-bob/2016/01/04/ALittleArchitecture.html)
- **DI in Flutter:** [Riverpod Documentation](https://riverpod.dev/)
- **Repository Pattern:** [Martin Fowler - Repository](https://martinfowler.com/eaaCatalog/repository.html)

---

## ❓ FAQ

**Q: Có DIP mà không có DI được không?**  
A: Được! Project của bạn đang làm vậy. Vẫn tốt cho project nhỏ.

**Q: Có DI mà không có DIP được không?**  
A: Được, nhưng ít giá trị. VD: Inject concrete class `HomePage(CategoryService())` thay vì interface.

**Q: Nên học cái nào trước?**  
A: **DIP trước** (dễ hơn, quan trọng hơn). DI sau khi hiểu rõ DIP.

**Q: Project nhỏ có cần DI không?**  
A: **Không bắt buộc**. DIP đã đủ. Thêm DI khi:
- Cần test nhiều
- Nhiều developers
- Nhiều environments (dev/staging/prod)

---

**TL;DR:**
- **DIP** = Depend on interfaces (WHAT) ← Bạn đã làm ✅
- **DI** = Inject from outside (HOW) ← Chưa cần thiết cho project này

