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
    // Extract the nested maps
    final info = json['adventurer_skill_info'] as Map<String, dynamic>;
    final details = json['skill_details'] as Map<String, dynamic>;

    return AdventurerSkill(
      id: info['skill_id'],
      adventurerId: info['adventurer_id'],
      ranks: (info['ranks'] as num).toDouble(),
      subSkill: info['sub_skill'],
      skillName: details['name'], // Mapped from 'name' in skill_details
      keyAttribute: details['key_attribute'],
      trainedOnly: details['trained_only'] ?? false,
      armorCheckPenalty: details['armor_check_penalty'] ?? false,
    );
  }
}