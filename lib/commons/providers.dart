import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_list/screens/grocery/model.dart';

final groceryItemsProvider =
    StateNotifierProvider<GroceryItemsNotifier, List<GroceryItem>>(
  (ref) {
    return GroceryItemsNotifier();
  },
);

class GroceryItemsNotifier extends StateNotifier<List<GroceryItem>> {
  GroceryItemsNotifier() : super([]);

  void setItems(List<GroceryItem> items) {
    state = items;
  }

  void add(GroceryItem item) {
    state = [...state, item];
  }

  void remove(GroceryItem item) {
    final index = state.indexOf(item);
    if (index != -1) {
      state = List.from(state)..removeAt(index);
    }
  }

  void update(GroceryItem item) {
    final index = state.indexWhere((element) => element.id == item.id);
    print('Index of ${item.name}: $index');
    if (index != -1) {
      state = List.from(state)..[index] = item;
    }
  }

  void undoDelete(GroceryItem item, int index) {
    // returns a deleted item when the item on delete throws an error above 400
    print('Index of ${item.name}: $index');
    if (index != -1 && index <= state.length) {
      state.insert(index, item);
      state = [...state];
    }
  }
}


// final groceryItemsProvider =
//     StateNotifierProvider<GroceryItemsNotifier, List<GroceryItem>>((ref) {
//   return GroceryItemsNotifier();
// });

// class GroceryItemsNotifier extends StateNotifier<List<GroceryItem>> {
//   GroceryItemsNotifier() : super(groceryItems);

//   void add(GroceryItem item) {
//     state = [...state, item];
//   }

//   void remove(GroceryItem item) {
//     final index = state.indexOf(item);
//     if (index != -1) {
//       state = [...state]..removeAt(index);
//     }
//   }

//   void update(GroceryItem item) {
//     final index = state.indexWhere((element) => element.id == item.id);
//     print('Index of ${item.name}: $index');
//     if (index != -1) {
//       state[index] = item;
//       state = [...state];
//     }
//   }
// }
