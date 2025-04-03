import 'package:flutter/material.dart';
import '../models/custom_widget.dart';
import '../screens/widget_detail.dart';

class WidgetTile extends StatelessWidget {
  final CustomWidgetModel model;

  const WidgetTile({Key? key, required this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Если это спейс-виджет, выводим его во всю ширину.
    if (model.type == CustomWidgetType.widgetSpaceText || model.type == CustomWidgetType.widgetSpaceImage) {
      return _buildFullWidthWidget(context);
    }

    Widget child;
    switch (model.type) {
      case CustomWidgetType.text:
        child = _buildTextWidget();
        break;
      case CustomWidgetType.image:
        child = _buildImageWidget();
        break;
      case CustomWidgetType.color:
        child = _buildColorWidget();
        break;
      case CustomWidgetType.cardLink:
        child = _buildCardLinkWidget();
        break;
      case CustomWidgetType.folder:
        child = _buildFolderWidget(context);
        break;
      default:
        child = Container();
    }

    return Container(
      margin: EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        border: Border.all(color: Colors.blueAccent),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: child,
    );
  }

  Widget _buildFullWidthWidget(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 8.0),
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: model.type == CustomWidgetType.widgetSpaceText ? Colors.blue[50] : Colors.green[50],
        border: Border.all(color: model.type == CustomWidgetType.widgetSpaceText ? Colors.blue : Colors.green),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: model.type == CustomWidgetType.widgetSpaceText
          ? Text(
        model.content ?? '',
        style: TextStyle(fontSize: 16),
      )
          : (model.content != null
          ? Image.network(
        model.content!,
        fit: BoxFit.cover,
      )
          : Container()),
    );
  }

  Widget _buildTextWidget() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        '${model.title}\n\n${model.content}',
        style: TextStyle(fontSize: 14),
      ),
    );
  }

  Widget _buildImageWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          model.title ?? 'Картинка',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 4),
        if (model.content != null)
          Image.network(
            model.content!,
            height: 60,
            width: 60,
            errorBuilder: (context, error, stackTrace) => Icon(Icons.error),
          ),
      ],
    );
  }

  Widget _buildColorWidget() {
    Color color;
    try {
      color = _hexToColor(model.content ?? '#FFFFFF');
    } catch (_) {
      color = Colors.white;
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          model.title ?? 'Цвет',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 4),
        Container(
          height: 40,
          width: 40,
          color: color,
        ),
      ],
    );
  }

  Widget _buildCardLinkWidget() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        '${model.title}\nСсылка: ${model.content}',
        style: TextStyle(fontSize: 14, color: Colors.blue),
      ),
    );
  }

  Widget _buildFolderWidget(BuildContext context) {
    int count = model.children?.length ?? 0;
    return GestureDetector(
      onTap: () {
        // Открываем modal bottom sheet с содержимым папки
        showModalBottomSheet(
          context: context,
          builder: (context) {
            return Container(
              padding: EdgeInsets.all(16.0),
              height: 300,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        model.title ?? 'Папка',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () async {
                          // Редактирование папки
                          final updatedFolder = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WidgetDetailPage(
                                widgetModel: model,
                                availableCategories: [], // Для редактирования папки можно не менять категорию
                              ),
                            ),
                          );
                          if (updatedFolder != null && updatedFolder is CustomWidgetModel) {
                            Navigator.pop(context);
                          }
                        },
                      )
                    ],
                  ),
                  Divider(),
                  Expanded(
                    child: GridView.builder(
                      itemCount: count,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 1.0,
                      ),
                      itemBuilder: (context, index) {
                        final childWidget = model.children![index];
                        return GestureDetector(
                          onTap: () {
                            // Открытие дочернего виджета для редактирования
                          },
                          child: WidgetTile(model: childWidget),
                        );
                      },
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Используем цвет из folderIconColor (если задан), иначе по умолчанию
            Icon(Icons.folder, size: 40, color: model.folderIconColor != null ? _hexToColor(model.folderIconColor!) : Colors.orange),
            SizedBox(height: 4),
            Text(
              model.title ?? 'Папка',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              '$count элементов',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    return Color(int.parse(hex, radix: 16));
  }
}
