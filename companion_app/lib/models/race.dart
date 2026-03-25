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
class Race {
  final int id;
  final String name;
  final String size;
  final String type;
  final String? bookName;
  
  // Detailed fields
  final int? speed;
  final int? sourceId;
  final String? personality;
  final String? physicalDescription;
  final String? relations;
  final String? alignment;
  final String? lands;
  final String? religion;
  final String? language;
  final String? names;
  final String? adventurers;

  Race({
    required this.id,
    required this.name,
    required this.size,
    required this.type,
    this.bookName,
    this.speed,
    this.sourceId,
    this.personality,
    this.physicalDescription,
    this.relations,
    this.alignment,
    this.lands,
    this.religion,
    this.language,
    this.names,
    this.adventurers,
  });

  factory Race.fromJson(Map<String, dynamic> json) {
    return Race(
      id: json['id'],
      name: json['name'],
      bookName: json['book_name'],
      size: json['size'],
      type: json['type'],
      speed: json['speed'],
      sourceId: json['source_id'],
      personality: json['personality'],
      physicalDescription: json['physical_description'],
      relations: json['relations'],
      alignment: json['alignment'],
      lands: json['lands'],
      religion: json['religion'],
      language: json['language'],
      names: json['names'],
      adventurers: json['adventurers'],
    );
  }
}