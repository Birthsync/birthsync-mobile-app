import 'package:uuid/uuid.dart';
import '../models/custom_widget.dart';

class WidgetFactory {
  static final uuid = Uuid();

  static CustomWidgetModel createCustomWidget(CustomWidgetType type, String categoryId) {
    // Если передан пустой или "default" id, генерируем новый id для категории
    if (categoryId.isEmpty || categoryId == "default") {
      categoryId = uuid.v4();
    }
    return CustomWidgetModel(
      id: uuid.v4(),
      type: type,
      categoryId: categoryId,
      title: _defaultTitleForType(type),
      content: _defaultContentForType(type),
      // Для папок задаём дефолтный цвет иконки
      folderIconColor: type == CustomWidgetType.folder ? "#FFA500" : null,
      children: type == CustomWidgetType.folder ? [] : null,
    );
  }

  static String? _defaultTitleForType(CustomWidgetType type) {
    switch (type) {
      case CustomWidgetType.text:
        return 'Новый текст';
      case CustomWidgetType.image:
        return 'Новая картинка';
      case CustomWidgetType.color:
        return 'Новый цвет';
      case CustomWidgetType.cardLink:
        return 'Ссылка на карточку';
      case CustomWidgetType.folder:
        return 'Новая папка';
      case CustomWidgetType.widgetSpaceText:
        return 'Текстовый спейс';
      case CustomWidgetType.widgetSpaceImage:
        return 'Картинный спейс';
    }
  }

  static String? _defaultContentForType(CustomWidgetType type) {
    switch (type) {
      case CustomWidgetType.text:
        return 'Введите текст...';
      case CustomWidgetType.image:
        return 'https://via.placeholder.com/150';
      case CustomWidgetType.color:
        return '#FFFFFF';
      case CustomWidgetType.cardLink:
        return 'https://example.com';
      case CustomWidgetType.folder:
        return null;
      case CustomWidgetType.widgetSpaceText:
        return 'Это текстовый виджет на весь экран';
      case CustomWidgetType.widgetSpaceImage:
        return 'https://via.placeholder.com/600x200';
    }
  }
}
