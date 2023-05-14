import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_list/screens/grocery/views/list_view.dart';
import 'package:shopping_list/theme/colors.dart';

void main() {
  runApp(
    const ProviderScope(child: MainApp()),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Groceries Shopping List',
      theme: theme,
      debugShowCheckedModeBanner: false,
      home: const GroceryListScreen(),
    );
  }
}
