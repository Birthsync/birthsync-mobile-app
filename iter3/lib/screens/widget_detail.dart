import 'package:flutter/material.dart';
import '../models/custom_widget.dart';
import '../models/category_model.dart';

class WidgetDetailPage extends StatefulWidget {
  final CustomWidgetModel widgetModel;
  final List<CategoryModel> availableCategories;

  const WidgetDetailPage({
    Key? key,
    required this.widgetModel,
    required this.availableCategories,
  }) : super(key: key);

  @override
  _WidgetDetailPageState createState() => _WidgetDetailPageState();
}

class _WidgetDetailPageState extends State<WidgetDetailPage> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _folderColorController;
  late String _selectedCategoryId;
  // Если выбран id папки для перемещения, сохраняем его в parentFolderId
  String _selectedFolderId = '';

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.widgetModel.title ?? '');
    _contentController = TextEditingController(text: widget.widgetModel.content ?? '');
    _selectedCategoryId = widget.widgetModel.categoryId;
    _selectedFolderId = widget.widgetModel.parentFolderId ?? '';
    // Если это папка, и у неё уже задан цвет – заполняем контроллер
    _folderColorController = TextEditingController(
        text: widget.widgetModel.folderIconColor ?? (widget.widgetModel.type == CustomWidgetType.folder ? "#FFA500" : ""));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _folderColorController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    setState(() {
      widget.widgetModel.title = _titleController.text;
      widget.widgetModel.content = _contentController.text;
      widget.widgetModel.categoryId = _selectedCategoryId;
      widget.widgetModel.parentFolderId = _selectedFolderId.isNotEmpty ? _selectedFolderId : null;
      if (widget.widgetModel.type == CustomWidgetType.folder) {
        widget.widgetModel.folderIconColor = _folderColorController.text;
      }
    });
    Navigator.pop(context, widget.widgetModel);
  }

  void _deleteWidget() {
    Navigator.pop(context, null);
  }

  @override
  Widget build(BuildContext context) {
    bool isFolder = widget.widgetModel.type == CustomWidgetType.folder;
    return Scaffold(
      appBar: AppBar(
        title: Text('Редактирование виджета'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Удалить виджет?'),
                  content: Text('Удалить виджет "${widget.widgetModel.title}"?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: Text('Отмена')),
                    TextButton(onPressed: _deleteWidget, child: Text('Удалить', style: TextStyle(color: Colors.red))),
                  ],
                ),
              );
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text('Тип: ${widget.widgetModel.type.toString().split('.').last}', style: TextStyle(fontSize: 16)),
              SizedBox(height: 16),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Заголовок'),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _contentController,
                decoration: InputDecoration(labelText: 'Содержимое'),
                maxLines: 5,
              ),
              SizedBox(height: 16),
              if (!isFolder)
                DropdownButtonFormField<String>(
                  value: _selectedCategoryId,
                  decoration: InputDecoration(labelText: 'Категория'),
                  items: widget.availableCategories
                      .map((cat) => DropdownMenuItem(
                    value: cat.id,
                    child: Text(cat.title),
                  ))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedCategoryId = val;
                      });
                    }
                  },
                ),
              SizedBox(height: 16),
              if (!isFolder)
                DropdownButtonFormField<String>(
                  value: _selectedFolderId.isEmpty ? null : _selectedFolderId,
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
                      _selectedFolderId = val ?? '';
                    });
                  },
                ),
              // Если редактируется папка, добавляем возможность смены цвета иконки
              if (isFolder)
                TextField(
                  controller: _folderColorController,
                  decoration: InputDecoration(labelText: 'HEX-цвет иконки (например, #FFA500)'),
                ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveChanges,
                child: Text('Сохранить'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
