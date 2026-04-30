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

import 'adventurer_path.dart';

class AdventurerSummary {
  final int id;
  final int? userId;
  final String name;
  final List<AdventurerPath> paths;
  final int totalLevel;
  
  // New fields added to the summary
  final String raceName;
  final int moneyGp;
  final String description;

  AdventurerSummary({
    required this.id,
    this.userId,
    required this.name,
    required this.paths,
    required this.totalLevel,
    required this.raceName,
    required this.moneyGp,
    required this.description,
  });

  factory AdventurerSummary.fromJson(Map<String, dynamic> json) {
    // 1. Safely extract the classes array
    final classesList = json['classes'] as List<dynamic>? ?? [];
    
    // 2. Parse into your helper class
    final parsedPaths = classesList
        .map((c) => AdventurerPath.summaryFromJson(c as Map<String, dynamic>))
        .toList();

    // 3. Calculate total level dynamically from the list
    final calculatedTotalLevel = parsedPaths.fold<int>(
      0, 
      (sum, path) => sum + path.level,
    );

    return AdventurerSummary(
      id: json['id'], // Updated to match the "id": 3 in your JSON
      userId: json['user_id'],
      name: json['name'],
      paths: parsedPaths,
      totalLevel: calculatedTotalLevel,
      raceName: json['race_name'] ?? 'Unknown',
      moneyGp: json['money_gp'] ?? 0,
      description: json['description'] ?? '',
    );
  }
}