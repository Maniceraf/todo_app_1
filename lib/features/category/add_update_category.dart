import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_manager/core/providers/repository_providers.dart';
import 'package:task_manager/data/entities/category.dart';
import 'package:task_manager/core/constants/app_constants.dart';
import 'package:task_manager/data/repositories/interafaces/i_category_repository.dart';

class AddUpdateCategory extends ConsumerStatefulWidget {
  final Category? category;
  const AddUpdateCategory({super.key, this.category});

  @override
  ConsumerState<AddUpdateCategory> createState() => _AddUpdateCategoryState();
}

class _AddUpdateCategoryState extends ConsumerState<AddUpdateCategory> {
  late ICategoryRepository _categoryRepository;

  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  List<Color> _palette = [];
  List<IconData> _icons = [];

  int _selectedColor = 0;
  int _selectedIcon = 0;

  @override
  void initState() {
    _categoryRepository = ref.read(categoryRepositoryProvider);
    _palette = AppConstants.colors.values.toList();
    _icons = AppConstants.icons.values.toList();
    _nameController.text = widget.category?.name ?? '';
    _selectedColor = widget.category != null ? widget.category!.color - 1 : 0;
    _selectedIcon = widget.category != null ? widget.category!.icon - 1 : 0;
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (widget.category != null) {
        final category = Category(
          id: widget.category!.id,
          name: _nameController.text,
          color: _selectedColor + 1,
          icon: _selectedIcon + 1,
          createdAt: DateTime.now(),
        );
        await _categoryRepository.updateCategory(category);
      } else {
        final category = Category(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: _nameController.text,
          color: _selectedColor + 1,
          icon: _selectedIcon + 1,
          createdAt: DateTime.now(),
        );
        await _categoryRepository.createCategory(category);
      }

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.category != null
              ? "Category updated successfully"
              : "Category created successfully"),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          (widget.category != null ? "Update Category" : "New Category"),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.grey[50],
        foregroundColor: Colors.black,
        actions: [
          IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.close)),
        ],
      ),
      body: Column(
        children: [
          Expanded(
              child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Category Name',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold))),
                      const SizedBox(height: 8),
                      TextFormField(
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintStyle: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.normal),
                          hintText: "Enter category name",
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter category name";
                          }
                          return null;
                        },
                        onChanged: (value) {},
                      ),
                      const SizedBox(height: 20),
                      const Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Select Color',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold))),
                      const SizedBox(height: 8),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          const itemWidth = 40.0;
                          const spacing = 5.0;
                          final availableWidth = constraints.maxWidth;
                          final crossAxisCount = ((availableWidth + spacing) /
                                  (itemWidth + spacing))
                              .floor();
                          final rows =
                              (_palette.length / crossAxisCount).ceil();
                          return SizedBox(
                            height: (rows * itemWidth) + ((rows - 1) * spacing),
                            child: GridView.builder(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: spacing,
                                mainAxisExtent: itemWidth,
                                mainAxisSpacing: spacing,
                              ),
                              itemCount: _palette.length,
                              itemBuilder: (context, index) {
                                final c = _palette[index];
                                final selected = _selectedColor == index;
                                return GestureDetector(
                                  onTap: () => setState(() {
                                    _selectedColor = index;
                                  }),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: selected
                                          ? c.withOpacity(1)
                                          : c.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: selected
                                        ? const Icon(Icons.check,
                                            color: Colors.white, size: 22)
                                        : const SizedBox.shrink(),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      const Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Select Icon',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold))),
                      const SizedBox(height: 8),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          const itemWidth = 40.0;
                          const spacing = 5.0;
                          final availableWidth = constraints.maxWidth;
                          final crossAxisCount = ((availableWidth + spacing) /
                                  (itemWidth + spacing))
                              .floor();
                          final rows = (_icons.length / crossAxisCount).ceil();
                          return SizedBox(
                            height: (rows * itemWidth) + ((rows - 1) * spacing),
                            child: GridView.builder(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: spacing,
                                mainAxisExtent: itemWidth,
                                mainAxisSpacing: spacing,
                              ),
                              itemCount: _icons.length,
                              itemBuilder: (context, index) {
                                final ic = _icons[index];
                                final selected = _selectedIcon == index;
                                return GestureDetector(
                                  onTap: () => setState(() {
                                    _selectedIcon = index;
                                  }),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: selected
                                          ? Colors.black
                                          : Colors.grey[300],
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Icon(ic,
                                        color: selected
                                            ? Colors.white
                                            : Colors.black,
                                        size: 22),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  )),
            ),
          )),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
                ),
                elevation: 0,
              ),
              child: Text(
                widget.category != null ? "Update" : "Create",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
