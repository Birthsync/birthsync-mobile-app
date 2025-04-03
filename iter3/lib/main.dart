import 'package:flutter/material.dart';
import 'screens/contact_list.dart';

void main() {
  runApp(BirthSyncApp());
}

class BirthSyncApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BirthSync',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ContactListPage(),
    );
  }
}
