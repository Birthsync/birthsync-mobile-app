import 'package:flutter/material.dart';
import 'dart:math';

class TileWidgetColor extends StatelessWidget {
  final int index;
  final List<Color> colors = [Colors.red, Colors.green, Colors.orange, Colors.purple];

  TileWidgetColor({required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: colors[index % colors.length],
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Text(
        "${index + 1}",
        style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}