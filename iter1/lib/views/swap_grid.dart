import 'package:birthsync/widgets/tile_widget_color.dart';
import 'package:flutter/material.dart';

import '../widgets/tile_widget_empty.dart';

class SwapGrid extends StatefulWidget {
  @override
  _SwapGridState createState() => _SwapGridState();
}

class _SwapGridState extends State<SwapGrid> {
  final int gridSize = 3;
  final double tileSize = 100;
  final double spacing = 8;

  late List<int> positions;

  bool _isEditingMode = false;
  int? _draggedCellIndex;
  int? _targetCellIndex;
  Offset _dragStartGlobal = Offset.zero;
  Offset _currentDragOffset = Offset.zero;
  double _swapProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _initializePositions();
  }

  void _initializePositions() {
    positions = List.generate(gridSize * gridSize, (index) => (index % 2 == 0) ? index : -1);
  }

  Offset cellOffset(int cellIndex) {
    int row = cellIndex ~/ gridSize;
    int col = cellIndex % gridSize;
    return Offset(col * (tileSize + spacing), row * (tileSize + spacing));
  }

  void _finalizeDrag() {
    if (_draggedCellIndex != null && _targetCellIndex != null && _swapProgress > 0.5) {
      setState(() {
        int temp = positions[_draggedCellIndex!];
        positions[_draggedCellIndex!] = positions[_targetCellIndex!];
        positions[_targetCellIndex!] = temp;
      });
    }
    setState(() {
      _draggedCellIndex = null;
      _targetCellIndex = null;
      _swapProgress = 0.0;
      _currentDragOffset = Offset.zero;
    });
  }

  void _addNewTile(int cellIndex) {
    setState(() {
      positions[cellIndex] = positions.where((e) => e != -1).length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Редактирование и плавный переход"),
        actions: [
          IconButton(
            icon: Icon(_isEditingMode ? Icons.lock_open : Icons.lock),
            onPressed: () {
              setState(() {
                _isEditingMode = !_isEditingMode;
              });
            },
          ),
        ],
      ),
      body: Center(
        child: Container(
          width: gridSize * (tileSize + spacing) - spacing,
          height: gridSize * (tileSize + spacing) - spacing,
          color: Colors.grey[200],
          child: Stack(
            children: List.generate(positions.length, (cellIndex) {
              int tileValue = positions[cellIndex];
              bool isEmpty = tileValue == -1;

              Offset baseOffset = cellOffset(cellIndex);

              if (_targetCellIndex != null && cellIndex == _targetCellIndex && _draggedCellIndex != null) {
                Offset targetStart = baseOffset;
                Offset targetEnd = cellOffset(_draggedCellIndex!);
                baseOffset = Offset.lerp(targetStart, targetEnd, _swapProgress)!;
              }

              if (_draggedCellIndex != null && cellIndex == _draggedCellIndex) {
                baseOffset = cellOffset(cellIndex) + _currentDragOffset;
              }

              Widget tileWidget = isEmpty
                  ? EmptyTileWidget(onTap: () => _addNewTile(cellIndex))
                  : TileWidgetColor(index: tileValue);

              bool isDraggingTile = _draggedCellIndex == cellIndex;

              return AnimatedPositioned(
                duration: Duration(milliseconds: isDraggingTile ? 0 : 200),
                curve: Curves.easeInOut,
                left: baseOffset.dx,
                top: baseOffset.dy,
                width: tileSize,
                height: tileSize,
                child: GestureDetector(
                  onPanStart: _isEditingMode && !isEmpty
                      ? (details) {
                    setState(() {
                      _draggedCellIndex = cellIndex;
                      _dragStartGlobal = details.globalPosition;
                      _currentDragOffset = Offset.zero;
                      _swapProgress = 0.0;
                      _targetCellIndex = null;
                    });
                  }
                      : null,
                  onPanUpdate: _isEditingMode && !isEmpty
                      ? (details) {
                    if (_draggedCellIndex == null) return;
                    setState(() {
                      _currentDragOffset = details.globalPosition - _dragStartGlobal;
                    });

                    if (_currentDragOffset.dx.abs() > _currentDragOffset.dy.abs()) {
                      if (_currentDragOffset.dx > 0 && (_draggedCellIndex! % gridSize) < gridSize - 1) {
                        _targetCellIndex = _draggedCellIndex! + 1;
                      } else if (_currentDragOffset.dx < 0 && (_draggedCellIndex! % gridSize) > 0) {
                        _targetCellIndex = _draggedCellIndex! - 1;
                      } else {
                        _targetCellIndex = null;
                      }
                      double distance = _currentDragOffset.dx.abs();
                      _swapProgress = ((distance - tileSize / 2) / (tileSize / 2)).clamp(0.0, 1.0);
                    } else {
                      if (_currentDragOffset.dy > 0 && (_draggedCellIndex! ~/ gridSize) < gridSize - 1) {
                        _targetCellIndex = _draggedCellIndex! + gridSize;
                      } else if (_currentDragOffset.dy < 0 && (_draggedCellIndex! ~/ gridSize) > 0) {
                        _targetCellIndex = _draggedCellIndex! - gridSize;
                      } else {
                        _targetCellIndex = null;
                      }
                      double distance = _currentDragOffset.dy.abs();
                      _swapProgress = ((distance - tileSize / 2) / (tileSize / 2)).clamp(0.0, 1.0);
                    }
                  }
                      : null,
                  onPanEnd: _isEditingMode && !isEmpty
                      ? (details) {
                    _finalizeDrag();
                  }
                      : null,
                  child: AnimatedOpacity(
                    duration: Duration(milliseconds: 100),
                    opacity: (isDraggingTile) ? 0.8 : 1.0,
                    child: Transform.scale(
                      scale: (isDraggingTile) ? 1.05 : 1.0,
                      child: tileWidget,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
