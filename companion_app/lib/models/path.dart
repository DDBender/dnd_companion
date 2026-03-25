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
class Path {
  final int id;
  final String name;
  final String? mainAttr;
  final int? diceType;
  final String? bookName;
  
  // Detailed fields
  final bool? isPrestige;
  final int? skillPoints;
  final String? alignment;
  final int? sourceId;
  final int? numDice;

  Path({
    required this.id,
    required this.name,
    this.bookName,
    this.mainAttr,
    this.diceType,
    this.isPrestige,
    this.skillPoints,
    this.alignment,
    this.sourceId,
    this.numDice,
  });

  factory Path.fromJson(Map<String, dynamic> json) {
    return Path(
      id: json['id'],
      name: json['name'],
      bookName: json['book_name'],
      mainAttr: json['main_attr'],
      diceType: json['dice_type'],
      isPrestige: json['is_prestige'],
      skillPoints: json['skill_points'],
      alignment: json['alignment'],
      sourceId: json['source_id'],
      numDice: json['num_dice'],
    );
  }
}