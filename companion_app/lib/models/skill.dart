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
class Skill {
  final int id;
  final String name;
  final String keyAttribute;
  final bool trainedOnly;
  final bool armorCheckPenalty;
  final bool psionic;
  final String? bookName;
  
  // Detailed fields
  final String? description;
  final Map<String, dynamic>? properties;
  final int? sourceId;

  Skill({
    required this.id,
    required this.name,
    required this.keyAttribute,
    required this.trainedOnly,
    required this.armorCheckPenalty,
    required this.psionic,
    this.bookName,
    this.description,
    this.sourceId,
    this.properties,
  });

  factory Skill.fromJson(Map<String, dynamic> json) {
    return Skill(
      id: json['id'],
      name: json['name'],
      bookName: json['book_name'],
      keyAttribute: json['key_attribute'],
      trainedOnly: json['trained_only'] ?? false,
      armorCheckPenalty: json['armor_check_penalty'] ?? false,
      psionic: json['psionic'] ?? false,
      description: json['description'],
      sourceId: json['source_id'],
      properties: json['properties'] != null ? Map<String, dynamic>.from(json['properties']) : null,
    );
  }
}