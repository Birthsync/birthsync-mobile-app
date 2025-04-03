import 'package:flutter/material.dart';

class EmptyTileWidget extends StatelessWidget {
  final VoidCallback? onTap; // Действие при нажатии

  const EmptyTileWidget({Key? key, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey, width: 2),
          color: Colors.grey[300],
        ),
        child: Center(
          child: Icon(Icons.add, size: 40, color: Colors.grey[600]),
        ),
      ),
    );
  }
}
