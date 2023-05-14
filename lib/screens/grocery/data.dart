import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shopping_list/commons/constants.dart';
import 'package:shopping_list/screens/category/data.dart';
import 'package:shopping_list/screens/grocery/model.dart';

// final groceryItems = fetchGroceryItems();

Future<List<GroceryItem>> fetchGroceryItems() async {
  final response = await http.get(kDatabaseUrl(null));

  if (response.statusCode == 200) {
    final List<dynamic> jsonData = json.decode(response.body) as List<dynamic>;
    final List<GroceryItem> itemLists = [];

    for (final item in jsonData) {
      final category = categories.entries
          .firstWhere((element) => element.value.title == item['category'])
          .value; // use firstWhere to get the first item in the list

      itemLists.add(GroceryItem(
        id: item['id'],
        name: item['name'],
        quantity: item['quantity'],
        category: category,
      ));
    }

    return itemLists;
  } else {
    throw Exception('Failed to fetch grocery items');
  }
}




// final groceryItems = [
//   GroceryItem(
//       id: 'a',
//       name: 'Milk',
//       quantity: 1,
//       category: categories[Categories.dairy]!),
//   GroceryItem(
//       id: 'b',
//       name: 'Bananas',
//       quantity: 5,
//       category: categories[Categories.fruit]!),
//   GroceryItem(
//       id: 'c',
//       name: 'Beef Steak',
//       quantity: 1,
//       category: categories[Categories.meat]!),
// ];
