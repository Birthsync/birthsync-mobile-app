import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../models/custom_widget.dart';
import 'widget_tile.dart';

class CategoryBlock extends StatefulWidget {
  final CategoryModel category;
  final Function(CustomWidgetModel) onWidgetTap;
  final Function(List<CustomWidgetModel>) onListUpdated;
  final Function(CustomWidgetModel) onWidgetDelete;
  // Callback для перемещения виджета в папку.
  final Function(CustomWidgetModel draggedWidget, CustomWidgetModel folderWidget) onFolderDrop;

  const CategoryBlock({
    Key? key,
    required this.category,
    required this.onWidgetTap,
    required this.onListUpdated,
    required this.onWidgetDelete,
    required this.onFolderDrop,
  }) : super(key: key);

  @override
  _CategoryBlockState createState() => _CategoryBlockState();
}

class _CategoryBlockState extends State<CategoryBlock> {
  late List<CustomWidgetModel> _widgets;
  final int gridSize = 3;
  final double tileSize = 120.0;

  int? _draggedIndex;
  int? _targetIndex;
  Offset _dragOffset = Offset.zero;
  double _swapProgress = 0.0;
  bool _isEditingMode = true;

  @override
  void initState() {
    super.initState();
    _widgets = List.from(widget.category.widgets);
  }

  @override
  void didUpdateWidget(covariant CategoryBlock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.category.widgets != widget.category.widgets) {
      _widgets = List.from(widget.category.widgets);
    }
  }

  void _finalizeDrag() {
    if (_draggedIndex != null && _targetIndex != null) {
      setState(() {
        final temp = _widgets[_draggedIndex!];
        _widgets[_draggedIndex!] = _widgets[_targetIndex!];
        _widgets[_targetIndex!] = temp;
      });
    }
    setState(() {
      _draggedIndex = null;
      _targetIndex = null;
      _swapProgress = 0.0;
      _dragOffset = Offset.zero;
    });
    widget.onListUpdated(_widgets);
  }

  @override
  Widget build(BuildContext context) {
    // Если категория называется "Спейсы", выводим её элементы во всю ширину.
    if (widget.category.title == "Спейсы") {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.category.title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Column(
            children: _widgets.map((widgetModel) {
              return GestureDetector(
                onTap: () => widget.onWidgetTap(widgetModel),
                child: WidgetTile(model: widgetModel),
              );
            }).toList(),
          ),
          SizedBox(height: 16),
        ],
      );
    }

    // Стандартное отображение категории – сетка тайлов.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Заголовок категории (можно сделать перетаскиваемым)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(widget.category.title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            // Кнопки редактирования/удаления категории можно добавить здесь
          ],
        ),
        SizedBox(height: 8),
        Container(
          height: ((_widgets.length / gridSize).ceil()) * tileSize,
          child: GridView.builder(
            physics: NeverScrollableScrollPhysics(),
            itemCount: _widgets.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: gridSize,
              childAspectRatio: 1.0,
            ),
            itemBuilder: (context, index) {
              bool isDragging = _draggedIndex == index;
              final model = _widgets[index];
              // Если элемент – папка, оборачиваем его в DragTarget для принятия виджетов
              Widget content = model.type == CustomWidgetType.folder
                  ? DragTarget<CustomWidgetModel>(
                onWillAccept: (draggedWidget) => draggedWidget != null && draggedWidget.id != model.id,
                onAccept: (draggedWidget) {
                  widget.onFolderDrop(draggedWidget, model);
                },
                builder: (context, candidateData, rejectedData) {
                  return GestureDetector(
                    onTap: () => widget.onWidgetTap(model),
                    onLongPress: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Удалить виджет?'),
                          content: Text('Удалить виджет "${model.title}"?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('Отмена'),
                            ),
                            TextButton(
                              onPressed: () {
                                widget.onWidgetDelete(model);
                                Navigator.pop(context);
                              },
                              child: Text('Удалить', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                    },
                    child: WidgetTile(model: model),
                  );
                },
              )
                  : GestureDetector(
                onTap: () => widget.onWidgetTap(model),
                onLongPress: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Удалить виджет?'),
                      content: Text('Удалить виджет "${model.title}"?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Отмена'),
                        ),
                        TextButton(
                          onPressed: () {
                            widget.onWidgetDelete(model);
                            Navigator.pop(context);
                          },
                          child: Text('Удалить', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                },
                onPanStart: _isEditingMode
                    ? (_) {
                  setState(() {
                    _draggedIndex = index;
                  });
                }
                    : null,
                onPanUpdate: _isEditingMode
                    ? (details) {
                  setState(() {
                    _dragOffset += details.delta;
                    if (_dragOffset.dx.abs() > _dragOffset.dy.abs()) {
                      if (_dragOffset.dx > 0 && (_draggedIndex! % gridSize) < gridSize - 1) {
                        _targetIndex = _draggedIndex! + 1;
                      } else if (_dragOffset.dx < 0 && (_draggedIndex! % gridSize) > 0) {
                        _targetIndex = _draggedIndex! - 1;
                      } else {
                        _targetIndex = null;
                      }
                      double distance = _dragOffset.dx.abs();
                      _swapProgress = ((distance - tileSize / 2) / (tileSize / 2)).clamp(0.0, 1.0);
                    } else {
                      if (_dragOffset.dy > 0 && (_draggedIndex! ~/ gridSize) < ((_widgets.length - 1) ~/ gridSize)) {
                        _targetIndex = _draggedIndex! + gridSize;
                      } else if (_dragOffset.dy < 0 && (_draggedIndex! ~/ gridSize) > 0) {
                        _targetIndex = _draggedIndex! - gridSize;
                      } else {
                        _targetIndex = null;
                      }
                      double distance = _dragOffset.dy.abs();
                      _swapProgress = ((distance - tileSize / 2) / (tileSize / 2)).clamp(0.0, 1.0);
                    }
                  });
                }
                    : null,
                onPanEnd: _isEditingMode
                    ? (_) {
                  _finalizeDrag();
                }
                    : null,
                child: AnimatedOpacity(
                  duration: Duration(milliseconds: 100),
                  opacity: isDragging ? 0.8 : 1.0,
                  child: Transform.scale(
                    scale: isDragging ? 1.05 : 1.0,
                    child: WidgetTile(model: model),
                  ),
                ),
              );
              return content;
            },
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }
}
