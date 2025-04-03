import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/category_model.dart';

class CategoryManagementScreen extends StatefulWidget {
  final List<CategoryModel> categories;

  const CategoryManagementScreen({Key? key, required this.categories}) : super(key: key);

  @override
  _CategoryManagementScreenState createState() => _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  late List<CategoryModel> _categories;
  final uuid = Uuid();
  final _newCategoryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _categories = List.from(widget.categories);
  }

  @override
  void dispose() {
    _newCategoryController.dispose();
    super.dispose();
  }

  void _addCategory() {
    if (_newCategoryController.text.isEmpty) return;
    setState(() {
      _categories.add(
        CategoryModel(id: uuid.v4(), title: _newCategoryController.text),
      );
      _newCategoryController.clear();
    });
  }

  void _editCategory(CategoryModel category) {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController(text: category.title);
        return AlertDialog(
          title: Text('Редактировать категорию'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(labelText: 'Название категории'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  category.title = controller.text;
                });
                Navigator.pop(context);
              },
              child: Text('Сохранить'),
            ),
          ],
        );
      },
    );
  }

  void _deleteCategory(CategoryModel category) {
    setState(() {
      _categories.removeWhere((c) => c.id == category.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Управление категориями'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Форма добавления новой категории
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newCategoryController,
                    decoration: InputDecoration(labelText: 'Новая категория'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _addCategory,
                ),
              ],
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  return ListTile(
                    title: Text(category.title),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => _editCategory(category),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _deleteCategory(category),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.save),
        onPressed: () {
          Navigator.pop(context, _categories);
        },
        tooltip: 'Сохранить изменения',
      ),
    );
  }
}
