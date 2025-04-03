// import 'package:birthsync/widgets/tile_widget_color.dart';
// import 'package:flutter/material.dart';
// import 'dart:math';
//
// class CollisionGridView extends StatefulWidget {
//   const CollisionGridView({super.key});
//
//   @override
//   CollisionGridViewState createState() => CollisionGridViewState();
// }
//
// class CollisionGridViewState extends State<CollisionGridView> {
//   final int gridSize = 4; // Размер сетки (4x4)
//   final double tileSize = 100; // Размер тайлов
//   final double spacing = 8; // Промежутки между ними
//
//   late List<Offset> positions;
//
//   @override
//   void initState() {
//     super.initState();
//     _initPositions();
//   }
//
//   void _initPositions() {
//     positions = List.generate(gridSize * gridSize, (index) {
//       int row = index ~/ gridSize;
//       int col = index % gridSize;
//       return Offset(col * (tileSize + spacing), row * (tileSize + spacing));
//     });
//   }
//
//   void _moveTile(int index, Offset delta) {
//     setState(() {
//       Offset newPosition = positions[index] + delta;
//
//       // Ограничиваем перемещение внутри контейнера
//       double minX = 0;
//       double minY = 0;
//       double maxX = (gridSize - 1) * (tileSize + spacing);
//       double maxY = (gridSize - 1) * (tileSize + spacing);
//
//       newPosition = Offset(
//         newPosition.dx.clamp(minX, maxX),
//         newPosition.dy.clamp(minY, maxY),
//       );
//
//       // Проверяем столкновения и перемещаем тайлы
//       for (int i = 0; i < positions.length; i++) {
//         if (i != index && (positions[i] - newPosition).distance < tileSize / 1.5) {
//           positions[i] += delta;
//         }
//       }
//
//       positions[index] = newPosition;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Перемещение с коллизией")),
//       body: Center(
//         child: Container(
//           width: gridSize * (tileSize + spacing),
//           height: gridSize * (tileSize + spacing),
//           color: Colors.grey[200],
//           child: Stack(
//             children: List.generate(positions.length, (index) {
//               return AnimatedPositioned(
//                 duration: Duration(milliseconds: 100),
//                 left: positions[index].dx,
//                 top: positions[index].dy,
//                 child: GestureDetector(
//                   onPanUpdate: (details) => _moveTile(index, details.delta),
//                   child: TileWidgetColor(index: index),
//                 ),
//               );
//             }),
//           ),
//         ),
//       ),
//     );
//   }
// }