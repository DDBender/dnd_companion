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
class Feat {
  final int id;
  final String name;
  final String? featType;
  final String? bookName;
  
  // Detailed fields
  final String? benefit;
  final String? normal;
  final String? special;
  final String? bookAbbr;
  final int? page;
  final List<Map<String, dynamic>>? prereqAttributes;
  final List<Map<String, dynamic>>? prereqFeats;
  final List<Map<String, dynamic>>? prereqSkills;

  Feat({
    required this.id,
    required this.name,
    this.featType,
    this.bookName,
    this.benefit,
    this.normal,
    this.special,
    this.bookAbbr,
    this.page,
    this.prereqAttributes,
    this.prereqFeats,
    this.prereqSkills,
  });

  factory Feat.fromJson(Map<String, dynamic> json) {
    return Feat(
      id: json['id'],
      name: json['name'],
      featType: json['feat_type'],
      bookName: json['book_name'],
      benefit: json['benefit'],
      normal: json['normal'],
      special: json['special'],
      bookAbbr: json['book_abbr'],
      page: json['page'],
      prereqAttributes: (json['prereq_attributes'] as List?)?.cast<Map<String, dynamic>>(),
      prereqFeats: (json['prereq_feats'] as List?)?.cast<Map<String, dynamic>>(),
      prereqSkills: (json['prereq_skills'] as List?)?.cast<Map<String, dynamic>>(),
    );
  }

  /// Generates a single Markdown string from the structured fields.
  String get markdownContent {
    final buffer = StringBuffer();

    void addSection(String title, String? content) {
      if (content != null && content.trim().isNotEmpty) {
        // Use H2 (##) so it nests nicely under the page title
        buffer.writeln('## $title'); 
        buffer.writeln(content.trim());
        buffer.writeln(''); // Blank line for spacing
      }
    }

    addSection('Benefit', benefit);
    addSection('Normal', normal);
    addSection('Special', special);

    return buffer.toString();
  }
}