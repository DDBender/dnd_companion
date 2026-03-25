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
class Monster {
  final int id;
  final String name;
  final String? type;
  final String? crText;
  final String? bookName;
  
  // Detailed fields
  final double? crNumber;
  final String? alignment;
  final String? hitDice;
  final int? page;
  
  // New fields
  final String? description;
  final int? numDice;
  final int? diceType;
  final int? bonus;
  final String? bookAbbr;

  Monster({
    required this.id,
    required this.name,
    this.type,
    this.crText,
    this.bookName,
    this.crNumber,
    this.alignment,
    this.hitDice,
    this.page,
    this.description,
    this.numDice,
    this.diceType,
    this.bonus,
    this.bookAbbr,
  });

  factory Monster.fromJson(Map<String, dynamic> json) {
    return Monster(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      crText: json['cr_text'],
      bookName: json['book_name'],
      crNumber: json['cr_number'] != null ? (json['cr_number'] as num).toDouble() : null,
      alignment: json['alignment'],
      hitDice: json['hit_dice'],
      page: json['page'],
      description: json['description'],
      numDice: json['num_dice'],
      diceType: json['dice_type'],
      bonus: json['bonus'],
      bookAbbr: json['book_abbr'],
    );
  }
}
