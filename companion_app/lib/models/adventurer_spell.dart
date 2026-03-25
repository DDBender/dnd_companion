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
class AdventurerSpell {
  final int id;
  final int characterId;
  final bool isPrepared;
  final int preparedCount;
  final bool isKnown;
  final String? notes;
  final String spellName;
  final String school;
  final String? subschool;
  final String description;

  AdventurerSpell({
    required this.id,
    required this.characterId,
    required this.isPrepared,
    required this.preparedCount,
    required this.isKnown,
    this.notes,
    required this.spellName,
    required this.school,
    this.subschool,
    required this.description,
  });

  factory AdventurerSpell.fromJson(Map<String, dynamic> json) {
    return AdventurerSpell(
      id: json['id'],
      characterId: json['character_id'],
      isPrepared: json['is_prepared'] ?? false,
      preparedCount: json['prepared_count'] ?? 0,
      isKnown: json['is_known'] ?? true,
      notes: json['notes'],
      spellName: json['spell_name'],
      school: json['school'],
      subschool: json['subschool'],
      description: json['description'],
    );
  }
}