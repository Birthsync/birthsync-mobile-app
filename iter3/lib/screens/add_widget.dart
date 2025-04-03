import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/custom_widget.dart';
import '../models/category_model.dart';
import '../widgets/widget_factory.dart';

class AddWidgetPage extends StatefulWidget {
  final List<CategoryModel> availableCategories;
  const AddWidgetPage({Key? key, required this.availableCategories}) : super(key: key);

  @override
  _AddWidgetPageState createState() => _AddWidgetPageState();
}

class _AddWidgetPageState extends State<AddWidgetPage> {
  final _formKey = GlobalKey<FormState>();
  CustomWidgetType? _selectedType;
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _selectedCategoryId = "";
  String _selectedFolderId = "";

  // Если не выбрана ни одна категория, можно использовать "standalone" (например, без привязки)
  @override
  void initState() {
    super.initState();
    if (widget.availableCategories.isNotEmpty) {
      _selectedCategoryId = widget.availableCategories.first.id;
    }
  }

  void _saveWidget() {
    if (_formKey.currentState!.validate() && _selectedType != null) {
      // Создаем виджет через фабрику с указанными данными.
      // Если пользователь указал папку для перемещения, установим parentFolderId.
      CustomWidgetModel newWidget = CustomWidgetModel(
        id: Uuid().v4(),
        type: _selectedType!,
        categoryId: _selectedCategoryId,
        parentFolderId: _selectedFolderId.isNotEmpty ? _selectedFolderId : null,
        title: _titleController.text,
        content: _contentController.text,
        // Для папок можно задать дефолтный цвет и пустой список children.
        folderIconColor: _selectedType == CustomWidgetType.folder ? "#FFA500" : null,
        children: _selectedType == CustomWidgetType.folder ? [] : null,
      );
      Navigator.pop(context, newWidget);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Создать виджет'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<CustomWidgetType>(
                value: _selectedType,
                decoration: InputDecoration(labelText: 'Тип виджета'),
                items: CustomWidgetType.values
                    .map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(type.toString().split('.').last),
                ))
                    .toList(),
                validator: (value) => value == null ? 'Выберите тип виджета' : null,
                onChanged: (value) {
                  setState(() {
                    _selectedType = value;
                  });
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Заголовок'),
                validator: (value) => value == null || value.isEmpty ? 'Введите заголовок' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                decoration: InputDecoration(labelText: 'Содержимое'),
                maxLines: 3,
                validator: (value) => value == null || value.isEmpty ? 'Введите содержимое' : null,
              ),
              SizedBox(height: 16),
              // Выбор категории – опционально. Если нет категорий, можно оставить пустым.
              DropdownButtonFormField<String>(
                value: _selectedCategoryId.isNotEmpty ? _selectedCategoryId : null,
                decoration: InputDecoration(labelText: 'Категория (опционально)'),
                items: widget.availableCategories
                    .map((cat) => DropdownMenuItem(
                  value: cat.id,
                  child: Text(cat.title),
                ))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedCategoryId = val ?? "";
                  });
                },
              ),
              SizedBox(height: 16),
              // Выбор папки – тоже опционально
              DropdownButtonFormField<String>(
                value: _selectedFolderId.isNotEmpty ? _selectedFolderId : null,
                decoration: InputDecoration(labelText: 'Переместить в папку (опционально)'),
                items: widget.availableCategories
                    .expand((cat) => cat.widgets)
                    .where((w) => w.type == CustomWidgetType.folder)
                    .map((folder) => DropdownMenuItem(
                  value: folder.id,
                  child: Text(folder.title ?? 'Папка'),
                ))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedFolderId = val ?? "";
                  });
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveWidget,
                child: Text('Создать'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
