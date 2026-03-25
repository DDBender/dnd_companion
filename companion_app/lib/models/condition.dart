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
class Condition {
  final int id;
  final String name;
  
  // Detailed fields
  final String? description;
  final String? bookName;
  final String? bookAbbr;
  final int? page;

  Condition({
    required this.id,
    required this.name,
    this.description,
    this.bookName,
    this.bookAbbr,
    this.page,
  });

  factory Condition.fromJson(Map<String, dynamic> json) {
    return Condition(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      bookName: json['book_name'],
      bookAbbr: json['book_abbr'],
      page: json['page'],
    );
  }
}
