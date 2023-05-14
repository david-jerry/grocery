import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

// project package imports
import 'package:shopping_list/commons/alerts.dart';
import 'package:shopping_list/commons/appbar_title.dart';
import 'package:shopping_list/commons/constants.dart';
import 'package:shopping_list/commons/enums.dart';
import 'package:shopping_list/commons/providers.dart';
import 'package:shopping_list/commons/string_formatter.dart';
import 'package:shopping_list/commons/validators.dart';
import 'package:shopping_list/screens/category/data.dart';
import 'package:shopping_list/screens/grocery/model.dart';

class AddNewItemScreen extends ConsumerStatefulWidget {
  const AddNewItemScreen({super.key});

  @override
  ConsumerState<AddNewItemScreen> createState() => _AddNewItemScreenState();
}

class _AddNewItemScreenState extends ConsumerState<AddNewItemScreen> {
  final _formKey = GlobalKey<FormState>();
  var _nameController = '';
  var _quantityController = 1;
  var _categoryController = categories[Categories.vegetables]!;

  bool _isLoading = false;

  void _validateItem() {
    _formKey.currentState!.validate();
  }

  void _saveItem() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Pass the values for adding to the model database data
      final name = _nameController;
      final quantity = _quantityController;
      final category = _categoryController;

      // Connect to the Firebase URL
      final url = kDatabaseUrl('null');

      // set the state to loading so the loading screen shows
      setState(() {
        _isLoading = true;
      });

      // Post to the connected Firebase URL and then return a response
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(
          {
            'name': name,
            'quantity': quantity,
            'category': category.title,
          },
        ),
      );

      setState(() {
        _isLoading = false;
      });

      print(response.body);
      print(response.reasonPhrase);

      if (response.statusCode == 200) {
        print(json.decode(response.body)['name']);
        // Create a new CategoryItem object using the retrieved values
        final newItem = GroceryItem(
          id: json.decode(response.body)['name'],
          name: name,
          quantity: quantity,
          category: category,
        );

        // Reset the form fields
        _nameController = '';
        _quantityController = 1;
        _categoryController = categories[Categories.vegetables]!;

        ref.read(groceryItemsProvider.notifier).add(newItem);

        if (!context.mounted) {
          return;
        }
        showSuccessMessage(context,
            "Successfully added ${capitalizeFirstLetter(newItem.name)} to the shopping list!");

        Navigator.of(context).pop();
      } else {
        if (!context.mounted) {
          return;
        }
        showWarningMessage(context,
            "Error-${response.statusCode.toString()}: ${json.decode(response.body)['error']}");
      }
    } else {
      showWarningMessage(
          context, "Please ensure you have filled all fields correctly.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        title: const AppBarTitle(
          pageTitle: "Add New Grocery Item",
        ),
      ),

      // main body for the create view
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(14),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  onChanged: (value) {
                    _validateItem();
                  },
                  onSaved: (newValue) {
                    _nameController = newValue!;
                  },
                  style: Theme.of(context).textTheme.labelMedium!.copyWith(
                        color: Theme.of(context).colorScheme.onBackground,
                        letterSpacing: 2,
                      ),
                  maxLength: 255,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      setState(() {
                        _isLoading = true;
                      });
                      // Value is empty or null, no validation required
                      return "This cannot be an empty field";
                    } else {
                      setState(() {
                        _isLoading = false;
                      });
                    }

                    if (!validateMinimumLength(value, 2)) {
                      setState(() {
                        _isLoading = true;
                      });
                      return "This field requires a minimum length of 2.";
                    } else {
                      setState(() {
                        _isLoading = false;
                      });
                    }

                    if (ref
                        .read(groceryItemsProvider)
                        .any((element) => element.name == value)) {
                      setState(() {
                        _isLoading = true;
                      });
                      return "This name already exists for a grocery item";
                    } else {
                      setState(() {
                        _isLoading = false;
                      });
                    }

                    if (!validateMaximumLength(value, 255)) {
                      setState(() {
                        _isLoading = true;
                      });
                      return "The maximum allowed value is 255.";
                    } else {
                      setState(() {
                        _isLoading = false;
                      });
                    }

                    return null;
                  },
                  decoration: InputDecoration(
                      label: Text(
                    'Grocery Name',
                    style: Theme.of(context).textTheme.labelSmall!.copyWith(
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                  )),
                ),

                // row to add two input
                Row(
                  verticalDirection: VerticalDirection.down,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextFormField(
                        onChanged: (value) {
                          _validateItem();
                        },
                        onSaved: (newValue) {
                          _quantityController = int.parse(newValue!);
                        },
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium!
                            .copyWith(
                              color: Theme.of(context).colorScheme.onBackground,
                            ),
                        initialValue: '1',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (!validateNumeric(value!)) {
                            setState(() {
                              _isLoading = true;
                            });
                            return 'Input a real number';
                          } else {
                            setState(() {
                              _isLoading = false;
                            });
                          }
                          setState(() {
                            _isLoading = true;
                          });
                          if (!validateMinimumNumber(value, 1)) {
                            return "Minimum quantity of 1.";
                          } else {
                            setState(() {
                              _isLoading = false;
                            });
                          }

                          if (!validateMaximumNumber(value, 20)) {
                            setState(() {
                              _isLoading = true;
                            });
                            return "Maximum quantity of 20.";
                          } else {
                            setState(() {
                              _isLoading = false;
                            });
                          }

                          return null;
                        },
                        decoration: InputDecoration(
                            label: Text(
                          'Grocery Quantity',
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall!
                              .copyWith(
                                color:
                                    Theme.of(context).colorScheme.onBackground,
                              ),
                        )),
                      ),
                    ),

                    const SizedBox(
                      width: 12,
                    ),

                    // category
                    Expanded(
                      child: DropdownButtonFormField(
                        value: _categoryController,
                        onChanged: (value) {
                          _categoryController = value!;
                        },
                        items: [
                          for (final category in categories.entries)
                            DropdownMenuItem(
                              value: category.value,
                              child: Row(
                                children: [
                                  Container(
                                    width: 16,
                                    height: 16,
                                    color: category.value.color,
                                  ),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  Text(
                                    category.value.title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall!
                                        .copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onBackground,
                                        ),
                                  )
                                ],
                              ),
                            ),
                        ],
                      ),
                    )
                  ],
                ),

                const SizedBox(
                  height: 28,
                ),

                // add the submit and reset button
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              _formKey.currentState!.reset();
                            },
                      child: const Text('Reset'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                      ),
                      onPressed: _isLoading ? null : _saveItem,
                      child: _isLoading
                          ? Row(
                              children: [
                                Text(
                                  'Processing...',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelMedium!
                                      .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                        fontWeight: FontWeight.w900,
                                      ),
                                ),
                                const SizedBox(
                                  width: 6,
                                ),
                                SizedBox(
                                  height: 14,
                                  width: 14,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Theme.of(context).colorScheme.onPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              'Submit',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium!
                                  .copyWith(
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
