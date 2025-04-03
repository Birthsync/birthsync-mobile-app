import 'package:birthsync/widgets/tile_widget.dart';
import 'package:flutter/material.dart';

// Пустая ячейка
class TileWidgetEmpty extends TileWidgetBase {
  TileWidgetEmpty({required int index}) : super(index: index);

  @override
  Widget build(BuildContext context) {
    return const SizedBox(); // Теперь не перекрывает остальные тайлы
  }
}

