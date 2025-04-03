import 'package:birthsync/widgets/tile_widget_color.dart';
import 'package:flutter/material.dart';
import '../widgets/tile_widget.dart';
import '../widgets/tile_widget_empty.dart';

class SwapGrid extends StatefulWidget {
  @override
  _SwapGridState createState() => _SwapGridState();
}

class _SwapGridState extends State<SwapGrid> {
  final int gridSize = 4;
  final double tileSize = 100;
  final double spacing = 8;

  bool _isEditingMode = false;
  int? _draggedTileIndex;
  int? _targetTileIndex;
  Offset _dragStartGlobal = Offset.zero;
  Offset _currentDragOffset = Offset.zero;

  late List<TileWidgetBase?> gridTiles;
  late Map<int, int> tilePositions;

  @override
  void initState() {
    super.initState();
    _initializeTiles();
  }

  void _initializeTiles() {
    gridTiles = List.filled(gridSize * gridSize, null);
    tilePositions = {};

    void addTile(int index, TileWidgetBase tile) {
      gridTiles[index] = tile;
      int row = index ~/ gridSize;
      int col = index % gridSize;

      for (int i = 0; i < tile.heightCells; i++) {
        for (int j = 0; j < tile.widthCells; j++) {
          int cellIndex = (row + i) * gridSize + (col + j);
          tilePositions[cellIndex] = index;
        }
      }
    }

    addTile(0, TileWidgetColor(index: 0, widthCells: 2, heightCells: 2));
    addTile(4, TileWidgetColor(index: 1));
    addTile(5, TileWidgetColor(index: 2, widthCells: 2, heightCells: 1));
    addTile(10, TileWidgetColor(index: 3, widthCells: 1, heightCells: 2));
    addTile(8, TileWidgetColor(index: 8, widthCells: 1, heightCells: 1));

    for (int i = 0; i < gridTiles.length; i++) {
      if (gridTiles[i] == null) {
        gridTiles[i] = TileWidgetEmpty(index: i);
      }
    }
  }

  bool _canMoveTileTo(int newIndex, TileWidgetBase tile, int oldIndex) {
    int newCol = newIndex % gridSize;
    int newRow = newIndex ~/ gridSize;

    if (newCol + tile.widthCells > gridSize || newRow + tile.heightCells > gridSize) {
      return false;
    }

    for (int i = 0; i < tile.heightCells; i++) {
      for (int j = 0; j < tile.widthCells; j++) {
        int checkIndex = (newRow + i) * gridSize + (newCol + j);
        if (tilePositions.containsKey(checkIndex) && tilePositions[checkIndex] != oldIndex) {
          return false;
        }
      }
    }

    return true;
  }

  void _moveTileTo(int oldIndex, int newIndex) {
    TileWidgetBase? tile = gridTiles[oldIndex];
    if (tile == null) return;

    setState(() {
      for (int i = 0; i < tile!.heightCells; i++) {
        for (int j = 0; j < tile.widthCells; j++) {
          int clearIndex = (oldIndex ~/ gridSize + i) * gridSize + (oldIndex % gridSize + j);
          tilePositions.remove(clearIndex);
          gridTiles[clearIndex] = TileWidgetEmpty(index: clearIndex);
        }
      }

      gridTiles[newIndex] = tile;

      for (int i = 0; i < tile.heightCells; i++) {
        for (int j = 0; j < tile.widthCells; j++) {
          int fillIndex = (newIndex ~/ gridSize + i) * gridSize + (newIndex % gridSize + j);
          tilePositions[fillIndex] = newIndex;
        }
      }
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_draggedTileIndex == null) return;

    setState(() {
      _currentDragOffset = details.globalPosition - _dragStartGlobal;
    });

    int newRow = ((_dragStartGlobal.dy + _currentDragOffset.dy) ~/ (tileSize + spacing)).clamp(0, gridSize - 1);
    int newCol = ((_dragStartGlobal.dx + _currentDragOffset.dx) ~/ (tileSize + spacing)).clamp(0, gridSize - 1);
    int newIndex = newRow * gridSize + newCol;

    if (_targetTileIndex != newIndex && _canMoveTileTo(newIndex, gridTiles[_draggedTileIndex!]!, _draggedTileIndex!)) {
      setState(() {
        _targetTileIndex = newIndex;
      });
    }
  }

  void _onPanEnd(DragEndDetails details) {
    if (_draggedTileIndex != null && _targetTileIndex != null) {
      _moveTileTo(_draggedTileIndex!, _targetTileIndex!);
    }

    setState(() {
      _draggedTileIndex = null;
      _targetTileIndex = null;
      _currentDragOffset = Offset.zero;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Редактирование и перемещение"),
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
            children: List.generate(gridTiles.length, (index) {
              TileWidgetBase tile = gridTiles[index]!;
              Offset position = Offset(
                (index % gridSize) * (tileSize + spacing),
                (index ~/ gridSize) * (tileSize + spacing),
              );

              bool isDraggingTile = _draggedTileIndex == index;

              return AnimatedPositioned(
                duration: Duration(milliseconds: isDraggingTile ? 0 : 200),
                curve: Curves.easeInOut,
                left: position.dx,
                top: position.dy,
                width: tile.widthCells * tileSize + (tile.widthCells - 1) * spacing,
                height: tile.heightCells * tileSize + (tile.heightCells - 1) * spacing,
                child: GestureDetector(
                  onPanStart: _isEditingMode && tile is! TileWidgetEmpty
                      ? (details) {
                    setState(() {
                      _draggedTileIndex = index;
                      _dragStartGlobal = details.globalPosition;
                      _currentDragOffset = Offset.zero;
                      _targetTileIndex = null;
                    });
                  }
                      : null,
                  onPanUpdate: _isEditingMode && tile is! TileWidgetEmpty ? _onPanUpdate : null,
                  onPanEnd: _isEditingMode && tile is! TileWidgetEmpty ? _onPanEnd : null,
                  child: Transform.translate(
                    offset: isDraggingTile ? _currentDragOffset : Offset.zero,
                    child: tile,
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
