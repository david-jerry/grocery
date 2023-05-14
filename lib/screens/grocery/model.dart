import 'package:shopping_list/screens/category/model.dart';

class GroceryItem {
  static final Set<String> _uniqueNames = {}; // Track unique names

  GroceryItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.category,
  });

  final String id;
  final String name;
  final int quantity;
  final Category category;

  Map<String, dynamic> toJson() {
    // this can be used like this: json.encode(groceryItem.toJson())
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'category':
          category.toJson(), // this needs to have its own json converter
    };
  }

  factory GroceryItem.fromJson(Map<String, dynamic> json) {
    return GroceryItem(
      id: json['id'],
      name: json['name'],
      quantity: json['quantity'],
      category: Category.fromJson(json['category']),
    );
  }
}
