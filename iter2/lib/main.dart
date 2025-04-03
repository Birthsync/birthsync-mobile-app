import 'package:birthsync/pages/page_contact.dart';
import 'package:birthsync/views/collision_grid.dart';
import 'package:birthsync/views/swap_grid.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SwapGrid(),
    );
  }
}