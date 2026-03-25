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
class AdventurerFeat {
  final int id;
  final int adventurerId;
  final String? note;
  final String featName;
  final String? featType;
  final String benefit;

  AdventurerFeat({
    required this.id,
    required this.adventurerId,
    this.note,
    required this.featName,
    this.featType,
    required this.benefit,
  });

  factory AdventurerFeat.fromJson(Map<String, dynamic> json) {
    return AdventurerFeat(
      id: json['id'],
      adventurerId: json['adventurer_id'],
      note: json['note'],
      featName: json['feat_name'],
      featType: json['feat_type'],
      benefit: json['benefit'],
    );
  }
}