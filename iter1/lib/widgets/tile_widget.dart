import 'package:flutter/material.dart';

abstract class TileWidgetBase extends StatelessWidget {
  final int index;
  final int widthCells;
  final int heightCells;

  TileWidgetBase({
    required this.index,
    this.widthCells = 1,
    this.heightCells = 1,
  });

  @override
  Widget build(BuildContext context);
}
