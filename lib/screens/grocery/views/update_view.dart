import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_list/commons/alerts.dart';
import 'package:shopping_list/commons/appbar_title.dart';
import 'package:shopping_list/commons/constants.dart';
import 'package:shopping_list/commons/providers.dart';
import 'package:shopping_list/commons/string_formatter.dart';
import 'package:shopping_list/commons/validators.dart';
import 'package:shopping_list/screens/category/data.dart';
import 'package:shopping_list/screens/category/model.dart';
import 'package:shopping_list/screens/grocery/model.dart';

class UpdateItemScreen extends ConsumerStatefulWidget {
  const UpdateItemScreen(
      {super.key,
      required this.id,
      required this.name,
      required this.quantity,
      required this.category});

  final String id;
  final String name;
  final int quantity;
  final Category category;

  @override
  ConsumerState<UpdateItemScreen> createState() => _UpdateItemScreenState();
}

class _UpdateItemScreenState extends ConsumerState<UpdateItemScreen> {
  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    var nameController = widget.name;
    var idController = widget.id;
    var quantityController = widget.quantity;
    var categoryController = widget.category;

    bool isLoading = false;

    void _validateItem() {
      formKey.currentState!.validate();
    }

    void _saveItem() async {
      if (formKey.currentState!.validate()) {
        formKey.currentState!.save();

        // pass the values for adding to the model database data
        final name = nameController;
        final id = idController;
        final quantity = quantityController;
        final category = categoryController;

        // Connect to the Firebase URL
        final url = kDatabaseUrl(id);

        // set the state to loading so the loading screen shows
        setState(() {
          isLoading = true;
        });

        // Post to the connected Firebase URL and then return a response
        final response = await http.put(
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
          isLoading = false;
        });

        if (response.statusCode == 200) {
          // Create a new CategoryItem object using the retrieved values
          final newItem = GroceryItem(
            id: id,
            name: name,
            quantity: quantity,
            category: category,
          );

          ref.read(groceryItemsProvider.notifier).update(newItem);

          if (!context.mounted) {
            return;
          }
          showSuccessMessage(context,
              "${capitalizeFirstLetter(newItem.name)} was updated successfully!");

          Navigator.of(context).pop();
        } else {
          if (!context.mounted) {
            return;
          }
          showWarningMessage(context, response.statusCode.toString());
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        title: AppBarTitle(
          pageTitle:
              "Update ${capitalizeFirstLetter(widget.name)} Grocery Item",
        ),
      ),

      // main body for the create view
      body: Container(
        padding: const EdgeInsets.all(14),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: nameController,
                onChanged: (value) {
                  _validateItem();
                },
                onSaved: (newValue) {
                  nameController = newValue!;
                },
                style: Theme.of(context).textTheme.labelMedium!.copyWith(
                      color: Theme.of(context).colorScheme.onBackground,
                      letterSpacing: 2,
                    ),
                maxLength: 255,
                validator: (value) {
                  if (!validateMinimumLength(value!, 2)) {
                    return "This field take a minimum length of 2.";
                  }

                  if (!validateMaximumLength(value, 255)) {
                    return "The maximum allowed value is 255.";
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
                        quantityController = int.parse(newValue!);
                      },
                      style: Theme.of(context).textTheme.labelMedium!.copyWith(
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                      initialValue: quantityController.toString(),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (!validateNumeric(value!)) {
                          return 'Input a real number';
                        }

                        if (!validateMinimumNumber(value, 1)) {
                          return "Minimum quantity of 1.";
                        }

                        if (!validateMaximumNumber(value, 20)) {
                          return "Maximum quantity of 20.";
                        }

                        return null;
                      },
                      decoration: InputDecoration(
                          label: Text(
                        'Grocery Quantity',
                        style: Theme.of(context).textTheme.labelSmall!.copyWith(
                              color: Theme.of(context).colorScheme.onBackground,
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
                      value: categoryController,
                      onChanged: (value) {
                        categoryController = value!;
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
                    onPressed: isLoading
                        ? null
                        : () {
                            formKey.currentState!.reset();
                          },
                    child: const Text('Reset'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ),
                    onPressed: isLoading ? null : _saveItem,
                    child: isLoading
                        ? Row(
                            children: [
                              Text(
                                'Updating...',
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
                            'Update',
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
    );
  }
}
