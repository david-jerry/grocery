import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shopping_list/commons/alerts.dart';

// project packages
import 'package:shopping_list/commons/appbar_title.dart';
import 'package:shopping_list/commons/constants.dart';
import 'package:shopping_list/commons/providers.dart';
import 'package:shopping_list/screens/category/data.dart';
import 'package:shopping_list/screens/grocery/model.dart';
import 'package:shopping_list/screens/grocery/views/create_view.dart';
import 'package:shopping_list/screens/grocery/widgets/grocery_item.dart';

class GroceryListScreen extends ConsumerStatefulWidget {
  const GroceryListScreen({super.key});

  @override
  ConsumerState<GroceryListScreen> createState() => _GroceryListScreenState();
}

class _GroceryListScreenState extends ConsumerState<GroceryListScreen> {
  bool isLoaded = false;
  bool deletedError = false;
  GroceryItem? deletedItem;
  int? deletedIndex;

  @override
  void initState() {
    super.initState();
    // this ensures the app runs the get request to get this data from the firebase database
    loadItems();
  }

  void loadItems() async {
    final url = kDatabaseUrl('null');
    print(url);
    final response = await http.get(url);

    final List<GroceryItem> itemLists = [];

    // Check network connectivity
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult != ConnectivityResult.none) {
      if (response.statusCode == 200) {
        if (json.decode(response.body) != null) {
          final Map<String, dynamic> listData = json.decode(response.body);

          print(response.reasonPhrase);

          for (final item in listData.entries) {
            // search for the category map to get the first matching item like using distinct in django filters
            final category = categories.entries
                .firstWhere(
                    (element) => element.value.title == item.value['category'])
                .value;

            itemLists.add(GroceryItem(
              id: item.key,
              name: item.value['name'],
              quantity: item.value['quantity'],
              category: category,
            ));
          }
        }
        isLoaded = true;
        ref.read(groceryItemsProvider.notifier).setItems(itemLists);
      } else {
        isLoaded = true;
        if (!context.mounted) {
          return;
        }
        showErrorMessage(
            context, 'There was an error retrieving grocery items');
        ref.read(groceryItemsProvider.notifier).setItems(itemLists);
      }
    } else if (connectivityResult == ConnectivityResult.vpn) {
      isLoaded = true;
      if (!context.mounted) {
        return;
      }
      showWarningMessage(context, 'We do not allow the use of VPN');
      ref.read(groceryItemsProvider.notifier).setItems(itemLists);
    } else {
      isLoaded = true;
      if (!context.mounted) {
        return;
      }
      showErrorMessage(context, 'No network connection');
      ref.read(groceryItemsProvider.notifier).setItems(itemLists);
    }
  }

  void addNewItem() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => const AddNewItemScreen(),
      ),
    );

    loadItems();
  }

  @override
  Widget build(BuildContext context) {
    var groceries = ref.watch(groceryItemsProvider);

    void deleteItem(int index, String id, GroceryItem item) async {
      final url = kDatabaseUrl(id);
      final response = await http.delete(url);

      if (response.statusCode < 400) {
        deletedError = true;
        deletedIndex = index;
        deletedItem = item;
        deletedError = false;
      } else {
        deletedError = true;
        deletedIndex = index;
        deletedItem = item;

        print("$deletedError  $deletedIndex  $deletedItem");

        showErrorMessage(context, "Something went wrong deleting ${item.name}");
        ref
            .read(groceryItemsProvider.notifier)
            .undoDelete(deletedItem!, deletedIndex!);
        deletedError = false;
      }
      return;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        title: const AppBarTitle(
          pageTitle: "Grocery List",
        ),
        actions: [
          IconButton(
            onPressed: () {
              addNewItem();
            },
            icon: const Icon(Icons.add_box),
          )
        ],
      ),
      body: isLoaded == true
          ? Container(
              padding: const EdgeInsets.all(14),
              child: groceries.isEmpty
                  ? Center(
                      child: Text(
                        'There is no item in the list for now!',
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                              color: Theme.of(context).colorScheme.onBackground,
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: groceries.length,
                      itemBuilder: ((context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: GroceryListItem(
                            groceries: groceries,
                            index: index,
                            deleteItem: deleteItem,
                          ),
                        );
                      }),
                    ),
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
