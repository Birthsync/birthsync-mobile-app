import 'custom_widget.dart';

class WidgetFolder {
  final String id;
  final String name;
  final List<CustomWidgetModel> children;

  WidgetFolder({
    required this.id,
    required this.name,
    required this.children,
  });
}
