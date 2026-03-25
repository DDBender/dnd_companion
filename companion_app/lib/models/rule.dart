/*
3.5e Database Companion
Copyright (C) 2026 Daniel Bender

-----------------------------------------------------------------------
AI DISCLOSURE: 
This file was developed with the assistance of Gemini Code Assist. 
AI-generated logic and boilerplate have been reviewed, refined, and 
verified by the human author for accuracy and project integration.
-----------------------------------------------------------------------

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.
*/
class Rule {
  final int id;
  final String name;
  final String category;
  final String? subcategory;
  final String? bookName;
  
  // Detailed fields
  final String? description;
  final int? sourceId;

  Rule({
    required this.id,
    required this.name,
    required this.category,
    this.subcategory,
    this.description,
    this.sourceId,
    this.bookName,
  });

  factory Rule.fromJson(Map<String, dynamic> json) {
    return Rule(
      id: json['id'],
      name: json['name'],
      bookName: json['book_name'],
      category: json['category'],
      subcategory: json['subcategory'],
      description: json['description'],
      sourceId: json['source_id'],
    );
  }
}