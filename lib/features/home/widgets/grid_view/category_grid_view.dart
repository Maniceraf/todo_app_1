import 'package:flutter/material.dart';
import 'package:task_manager/data/entities/category.dart';
import 'package:task_manager/features/home/widgets/grid_view/category_grid_item.dart';
import 'package:task_manager/features/task/task_list.dart';

class CategoryGridView extends StatefulWidget {
  final List<Category> categories;
  const CategoryGridView({super.key, required this.categories});

  @override
  State<CategoryGridView> createState() => _CategoryGridViewState();
}

class _CategoryGridViewState extends State<CategoryGridView> {
  final ScrollController _scrollController = ScrollController();
  static const int _itemsPerPage = 10;
  int _displayedCount = 0;

  @override
  void initState() {
    super.initState();
    _displayedCount = widget.categories.length > _itemsPerPage
        ? _itemsPerPage
        : widget.categories.length;
    _scrollController.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(CategoryGridView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.categories.length != oldWidget.categories.length) {
      // Reset pagination khi categories thay đổi
      _displayedCount = widget.categories.length > _itemsPerPage
          ? _itemsPerPage
          : widget.categories.length;
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      // Load thêm khi scroll đến 80% chiều cao
      if (_displayedCount < widget.categories.length) {
        setState(() {
          _displayedCount = (_displayedCount + _itemsPerPage)
              .clamp(0, widget.categories.length);
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayedCategories =
        widget.categories.take(_displayedCount).toList();
    final hasMore = _displayedCount < widget.categories.length;

    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
      ),
      itemCount: displayedCategories.length + (hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= displayedCategories.length) {
          // Loading indicator ở cuối
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }
        final category = displayedCategories[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TaskListPage(categoryId: category.id),
              ),
            );
          },
          child: CategoryGridItem(category: category),
        );
      },
    );
  }
}
