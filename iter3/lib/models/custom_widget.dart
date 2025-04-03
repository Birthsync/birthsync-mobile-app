enum CustomWidgetType {
  text,
  image,
  color,
  cardLink,
  folder,
  widgetSpaceText,
  widgetSpaceImage,
}

class CustomWidgetModel {
  final String id;
  CustomWidgetType type;
  // Принадлежность к категории (если виджет не находится внутри папки)
  String categoryId;
  // Если виджет находится в папке – хранит идентификатор родительской папки
  String? parentFolderId;
  String? title;
  String? content;
  // Для виджетов типа folder – HEX-цвет иконки (например, "#FFA500")
  String? folderIconColor;
  List<CustomWidgetModel>? children;

  CustomWidgetModel({
    required this.id,
    required this.type,
    required this.categoryId,
    this.parentFolderId,
    this.title,
    this.content,
    this.folderIconColor,
    this.children,
  });
}
