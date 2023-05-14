import 'package:flutter/material.dart';

class Category {
  const Category(this.title, this.color);

  final String title;
  final Color color;

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'color': color.value, // Convert the Color to its int value
    };
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      json['title'],
      Color(json['color']),
    );
  }
}
