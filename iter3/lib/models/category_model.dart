import 'custom_widget.dart';

class CategoryModel {
  String id;
  String title;
  List<CustomWidgetModel> widgets;

  CategoryModel({
    required this.id,
    required this.title,
    List<CustomWidgetModel>? widgets,
  }) : this.widgets = widgets ?? [];
}
