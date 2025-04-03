import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/contact.dart';
import '../models/category_model.dart';
import '../models/custom_widget.dart';
import '../widgets/category_block.dart';
import '../widgets/widget_factory.dart';
import 'category_management.dart';
import 'widget_detail.dart';
import 'add_widget.dart';

class ContactDetailPage extends StatefulWidget {
  final Contact contact;

  const ContactDetailPage({Key? key, required this.contact}) : super(key: key);

  @override
  _ContactDetailPageState createState() => _ContactDetailPageState();
}

class _ContactDetailPageState extends State<ContactDetailPage> {
  List<CategoryModel> categories = [];
  final uuid = Uuid();

  @override
  void initState() {
    super.initState();
    // Инициализация тестовых категорий.
    categories = [
      CategoryModel(
        id: uuid.v4(),
        title: 'Общие',
        widgets: [
          CustomWidgetModel(
            id: uuid.v4(),
            type: CustomWidgetType.text,
            categoryId: '', // заполнится ниже
            title: 'Параметры',
            content: 'Рост: 180 см\nВес: 75 кг',
          ),
          CustomWidgetModel(
            id: uuid.v4(),
            type: CustomWidgetType.folder,
            categoryId: '',
            title: 'Аллергии',
            children: [
              CustomWidgetModel(
                id: uuid.v4(),
                type: CustomWidgetType.text,
                categoryId: '',
                title: 'Аллергия на кошек',
                content: 'Чихает, слезятся глаза',
              ),
            ],
          ),
        ],
      ),
      CategoryModel(
        id: uuid.v4(),
        title: 'Избранное',
        widgets: [
          CustomWidgetModel(
            id: uuid.v4(),
            type: CustomWidgetType.image,
            categoryId: '',
            title: 'Доктор Хаус',
            content: 'https://via.placeholder.com/100',
          ),
        ],
      ),
      CategoryModel(
        id: uuid.v4(),
        title: 'Спейсы',
        widgets: [
          CustomWidgetModel(
            id: uuid.v4(),
            type: CustomWidgetType.widgetSpaceText,
            categoryId: '',
            title: 'Большой текст',
            content: 'Это текстовый виджет, занимающий всю ширину экрана.',
          ),
          CustomWidgetModel(
            id: uuid.v4(),
            type: CustomWidgetType.widgetSpaceImage,
            categoryId: '',
            title: 'Большая картинка',
            content: 'https://via.placeholder.com/600x200',
          ),
        ],
      ),
    ];

    // Заполнение поля categoryId для виджетов
    for (var category in categories) {
      for (var widgetModel in category.widgets) {
        widgetModel.categoryId = category.id;
      }
    }
  }

  // Возвращает видимые категории (например, если есть скрытая "default", её не показываем)
  List<CategoryModel> get displayCategories => categories;

  // Если категорий нет, создаём новую категорию с названием "Новая категория"
  CategoryModel _ensureNonDefaultCategory() {
    if (displayCategories.isEmpty) {
      final newCat = CategoryModel(id: uuid.v4(), title: 'Новая категория');
      categories.add(newCat);
      return newCat;
    }
    return displayCategories.first;
  }

  // Добавление нового виджета в выбранную категорию (по умолчанию "Общие")
  void _addNewWidget(CustomWidgetType type) {
    setState(() {
      final targetCategory = displayCategories.isEmpty
          ? _ensureNonDefaultCategory()
          : categories.firstWhere((c) => c.title == 'Общие',
          orElse: () => displayCategories.first);
      final newWidget = WidgetFactory.createCustomWidget(type, targetCategory.id);
      targetCategory.widgets.add(newWidget);
    });
  }

  void _updateCategoryWidgets(String categoryId, List<CustomWidgetModel> updatedList) {
    setState(() {
      final category = categories.firstWhere((c) => c.id == categoryId);
      category.widgets = updatedList;
    });
  }

  // Callback для перемещения виджета в папку.
  void _onFolderDrop(CustomWidgetModel draggedWidget, CustomWidgetModel folderWidget) {
    setState(() {
      // Удаляем виджет из его текущей категории.
      for (var cat in categories) {
        cat.widgets.removeWhere((w) => w.id == draggedWidget.id);
      }
      // Добавляем в children папки.
      folderWidget.children ??= [];
      folderWidget.children!.add(draggedWidget);
    });
  }

  void _openWidgetDetail(CustomWidgetModel widgetModel) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WidgetDetailPage(
          widgetModel: widgetModel,
          availableCategories: displayCategories,
        ),
      ),
    );
    if (result != null && result is CustomWidgetModel) {
      setState(() {
        // Удаляем виджет из всех категорий
        for (var category in categories) {
          category.widgets.removeWhere((w) => w.id == result.id);
          // Также удаляем его из children всех папок в данной категории
          for (var w in category.widgets.where((w) => w.type == CustomWidgetType.folder)) {
            w.children?.removeWhere((child) => child.id == result.id);
          }
        }
        // Если виджет перемещается в папку
        if (result.parentFolderId != null) {
          // Ищем папку по id во всех категориях
          bool added = false;
          for (var category in categories) {
            for (var w in category.widgets) {
              if (w.type == CustomWidgetType.folder && w.id == result.parentFolderId) {
                w.children ??= [];
                w.children!.add(result);
                added = true;
                break;
              }
            }
            if (added) break;
          }
          if (!added) {
            // Если папка не найдена, добавляем виджет в первую категорию
            categories.first.widgets.add(result);
          }
        } else {
          // Виджет остается в категории
          final newCategory = categories.firstWhere((c) => c.id == result.categoryId, orElse: () => _ensureNonDefaultCategory());
          newCategory.widgets.add(result);
        }
      });
    }
  }

  void _deleteWidget(CustomWidgetModel widgetModel) {
    setState(() {
      for (var category in categories) {
        category.widgets.removeWhere((w) => w.id == widgetModel.id);
      }
    });
  }

  void _openCategoryManagement() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryManagementScreen(
          categories: displayCategories,
        ),
      ),
    );
    if (result != null && result is List<CategoryModel>) {
      setState(() {
        categories = result;
      });
    }
  }

  // Перемещение категорий через ReorderableListView
  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final item = categories.removeAt(oldIndex);
      categories.insert(newIndex, item);
    });
  }

  @override
  Widget build(BuildContext context) {
    final contact = widget.contact;
    return Scaffold(
      appBar: AppBar(
        title: Text(contact.name),
        actions: [
          IconButton(
            icon: Icon(Icons.category),
            onPressed: _openCategoryManagement,
            tooltip: 'Управление категориями',
          )
        ],
      ),
      body: ReorderableListView(
        header: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _buildContactHeader(contact),
        ),
        onReorder: _onReorder,
        children: displayCategories
            .map(
              (category) => CategoryBlock(
            key: ValueKey(category.id),
            category: category,
            onWidgetTap: (widgetModel) => _openWidgetDetail(widgetModel),
            onListUpdated: (updatedList) => _updateCategoryWidgets(category.id, updatedList),
            onWidgetDelete: _deleteWidget,
            onFolderDrop: _onFolderDrop,
          ),
        )
            .toList(),
      ),
      // Внутри класса ContactDetailPage, в методе build, в блоке floatingActionButton:
      floatingActionButton: PopupMenuButton<String>(
        icon: Icon(Icons.add),
        onSelected: (action) async {
          if (action == "add_widget") {
            final newWidget = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddWidgetPage(availableCategories: displayCategories),
              ),
            );
            if (newWidget != null && newWidget is CustomWidgetModel) {
              setState(() {
                // Если у нового виджета задан parentFolderId – ищем соответствующую папку
                if (newWidget.parentFolderId != null) {
                  bool added = false;
                  for (var cat in categories) {
                    for (var widgetItem in cat.widgets) {
                      if (widgetItem.type == CustomWidgetType.folder && widgetItem.id == newWidget.parentFolderId) {
                        widgetItem.children ??= [];
                        widgetItem.children!.add(newWidget);
                        added = true;
                        break;
                      }
                    }
                    if (added) break;
                  }
                  if (!added) {
                    // Если папка не найдена, добавляем в первую категорию
                    categories.first.widgets.add(newWidget);
                  }
                } else {
                  // Если категория выбрана, добавляем в неё
                  final targetCat = categories.firstWhere(
                        (c) => c.id == newWidget.categoryId,
                    orElse: () => categories.isNotEmpty ? categories.first : CategoryModel(id: "standalone", title: "Без категории"),
                  );
                  targetCat.widgets.add(newWidget);
                }
              });
            }
          }
        },
        itemBuilder: (context) => <PopupMenuEntry<String>>[
          PopupMenuItem(value: "add_widget", child: Text('Добавить виджет')),
        ],
      ),
    );
  }

  Widget _buildContactHeader(Contact contact) {
    return Row(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundImage: contact.avatarUrl != null ? NetworkImage(contact.avatarUrl!) : null,
          child: contact.avatarUrl == null ? Text(contact.name.isNotEmpty ? contact.name[0] : '?') : null,
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(contact.name, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text('Возраст: ???'),
              SizedBox(height: 4),
              Text('День рождения: ${contact.birthDate}'),
            ],
          ),
        ),
      ],
    );
  }
}
