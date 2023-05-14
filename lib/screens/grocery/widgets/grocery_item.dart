import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_list/commons/alerts.dart';
import 'package:shopping_list/commons/providers.dart';
import 'package:shopping_list/commons/string_formatter.dart';
import 'package:shopping_list/screens/grocery/model.dart';
import 'package:shopping_list/screens/grocery/views/update_view.dart';

class GroceryListItem extends ConsumerWidget {
  const GroceryListItem({
    super.key,
    required this.groceries,
    required this.index,
    required this.deleteItem,
  });

  final List<GroceryItem> groceries;
  final int index;
  final void Function(int index, String id, GroceryItem item) deleteItem;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String id = groceries[index].id;
    final GroceryItem finalItem = groceries[index];
    final int finalIndex = index;
    final String title = capitalizeFirstLetter(groceries[index].name);

    return Dismissible(
      key: ValueKey(groceries[index].id),
      direction: DismissDirection.horizontal,

      // confirmdismiss
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => UpdateItemScreen(
                id: id,
                name: groceries[index].name,
                quantity: groceries[index].quantity,
                category: groceries[index].category,
              ),
            ),
          );
          return false;
        } else if (direction == DismissDirection.endToStart) {
          showInfoMessage(
              context, "Successfully removed $title from the list!");
          ref.read(groceryItemsProvider.notifier).remove(finalItem);

          // delete the instance
          print(finalIndex);
          print(id);
          print(finalItem);
          deleteItem(finalIndex, id, finalItem);
          print("deleted function ran");

          return true;
        }
        return null;
      },

      // ondismissed fire up another function
      onDismissed: (direction) {
        print(finalIndex);
        print(id);
        print(finalItem);
        deleteItem(finalIndex, id, finalItem);
        print("deleted function ran");
      },
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 14.0),
        color: Colors.red,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: const [
            Text(
              'Delete',
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(
              width: 8,
            ),
            Icon(Icons.delete_forever_outlined, color: Colors.white),
          ],
        ),
      ),
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 14.0),
        color: Colors.blue,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: const [
            Icon(Icons.edit, color: Colors.white),
            SizedBox(
              width: 8,
            ),
            Text(
              'Edit',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
      child: ListTile(
        onTap: () {},
        horizontalTitleGap: 8,
        tileColor: Theme.of(context).colorScheme.secondaryContainer,
        hoverColor: Colors.lightGreen[900],
        leading: const Icon(Icons.shopping_bag),
        iconColor: groceries[index].category.color,
        subtitle: Text(
          groceries[index].category.title,
          style: Theme.of(context).textTheme.bodySmall!.copyWith(
                color: groceries[index].category.color,
                fontWeight: FontWeight.w900,
              ),
        ),
        title: Text(
          capitalizeFirstLetter(groceries[index].name),
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: Theme.of(context).colorScheme.onBackground,
                fontWeight: FontWeight.w900,
              ),
        ),
        trailing: Text(
          groceries[index].quantity.toString(),
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: Theme.of(context).colorScheme.onSecondaryContainer,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
    );
  }
}
