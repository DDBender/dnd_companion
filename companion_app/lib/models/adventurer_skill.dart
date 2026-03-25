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
class AdventurerSkill {
  final int id;
  final int adventurerId;
  final double ranks;
  final String? subSkill;
  final String skillName;
  final String keyAttribute;
  final bool trainedOnly;
  final bool armorCheckPenalty;

  AdventurerSkill({
    required this.id,
    required this.adventurerId,
    required this.ranks,
    this.subSkill,
    required this.skillName,
    required this.keyAttribute,
    required this.trainedOnly,
    required this.armorCheckPenalty,
  });

  factory AdventurerSkill.fromJson(Map<String, dynamic> json) {
    return AdventurerSkill(
      id: json['id'],
      adventurerId: json['adventurer_id'],
      ranks: (json['ranks'] as num).toDouble(),
      subSkill: json['sub_skill'],
      skillName: json['skill_name'],
      keyAttribute: json['key_attribute'],
      trainedOnly: json['trained_only'] ?? false,
      armorCheckPenalty: json['armor_check_penalty'] ?? false,
    );
  }
}