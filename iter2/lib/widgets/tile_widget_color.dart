import 'package:birthsync/widgets/tile_widget.dart';
import 'package:flutter/material.dart';
import 'dart:math';

// Цветной тайл
class TileWidgetColor extends TileWidgetBase {
  final List<Color> colors = [Colors.red, Colors.green, Colors.blue, Colors.orange];

  TileWidgetColor({required int index, int widthCells = 1, int heightCells = 1})
      : super(index: index, widthCells: widthCells, heightCells: heightCells);

  @override
  Widget build(BuildContext context) {
    int random = new Random().nextInt(colors.length);

    return Container(
      decoration: BoxDecoration(
        color: colors[random],
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Text(
        "#${colors[random].toHex()}",
        style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}

extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}
