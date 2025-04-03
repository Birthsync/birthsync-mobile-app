import 'package:flutter/material.dart';
import '../models/custom_widget.dart';
import 'widget_tile.dart';

class DragWidgetGrid extends StatefulWidget {
  final List<CustomWidgetModel> customWidgets;
  final Function(List<CustomWidgetModel>) onListUpdated;
  final Function(CustomWidgetModel) onWidgetTap;

  const DragWidgetGrid({
    Key? key,
    required this.customWidgets,
    required this.onListUpdated,
    required this.onWidgetTap,
  }) : super(key: key);

  @override
  _DragWidgetGridState createState() => _DragWidgetGridState();
}

class _DragWidgetGridState extends State<DragWidgetGrid> {
  late List<CustomWidgetModel> _widgets;
  final int gridSize = 3;
  final double tileSize = 120.0;

  int? _draggedCellIndex;
  int? _targetCellIndex;
  Offset _currentDragOffset = Offset.zero;
  double _swapProgress = 0.0;
  bool _isEditingMode = true; // включаем режим редактирования

  @override
  void initState() {
    super.initState();
    _widgets = List.from(widget.customWidgets);
  }

  @override
  void didUpdateWidget(covariant DragWidgetGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.customWidgets != widget.customWidgets) {
      _widgets = List.from(widget.customWidgets);
    }
  }

  void _finalizeDrag() {
    if (_draggedCellIndex != null && _targetCellIndex != null) {
      setState(() {
        final temp = _widgets[_draggedCellIndex!];
        _widgets[_draggedCellIndex!] = _widgets[_targetCellIndex!];
        _widgets[_targetCellIndex!] = temp;
      });
    }
    setState(() {
      _draggedCellIndex = null;
      _targetCellIndex = null;
      _swapProgress = 0.0;
      _currentDragOffset = Offset.zero;
    });
    widget.onListUpdated(_widgets);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: ((widget.customWidgets.length / gridSize).ceil() * tileSize),
      // можно сделать динамическую высоту в зависимости от количества виджетов
      child: GridView.builder(
        physics: NeverScrollableScrollPhysics(),
        itemCount: _widgets.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: gridSize,
          childAspectRatio: 1.0,
        ),
        itemBuilder: (context, index) {
          bool isDraggingTile = _draggedCellIndex == index;
          final model = _widgets[index];

          return GestureDetector(
            onTap: () {
              if (!_isEditingMode) return;
              widget.onWidgetTap(model);
            },
            onPanStart: _isEditingMode
                ? (_) {
              setState(() {
                _draggedCellIndex = index;
              });
            }
                : null,
            onPanUpdate: _isEditingMode
                ? (details) {
              setState(() {
                _currentDragOffset += details.delta;
                if (_currentDragOffset.dx.abs() > _currentDragOffset.dy.abs()) {
                  if (_currentDragOffset.dx > 0 &&
                      (_draggedCellIndex! % gridSize) < gridSize - 1) {
                    _targetCellIndex = _draggedCellIndex! + 1;
                  } else if (_currentDragOffset.dx < 0 &&
                      (_draggedCellIndex! % gridSize) > 0) {
                    _targetCellIndex = _draggedCellIndex! - 1;
                  } else {
                    _targetCellIndex = null;
                  }
                  double distance = _currentDragOffset.dx.abs();
                  _swapProgress =
                      ((distance - tileSize / 2) / (tileSize / 2)).clamp(0.0, 1.0);
                } else {
                  if (_currentDragOffset.dy > 0 &&
                      (_draggedCellIndex! ~/ gridSize) < gridSize - 1) {
                    _targetCellIndex = _draggedCellIndex! + gridSize;
                  } else if (_currentDragOffset.dy < 0 &&
                      (_draggedCellIndex! ~/ gridSize) > 0) {
                    _targetCellIndex = _draggedCellIndex! - gridSize;
                  } else {
                    _targetCellIndex = null;
                  }
                  double distance = _currentDragOffset.dy.abs();
                  _swapProgress =
                      ((distance - tileSize / 2) / (tileSize / 2)).clamp(0.0, 1.0);
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
              opacity: isDraggingTile ? 0.8 : 1.0,
              child: Transform.scale(
                scale: isDraggingTile ? 1.05 : 1.0,
                child: WidgetTile(model: model),
              ),
            ),
          );
        },
      ),
    );
  }
}
