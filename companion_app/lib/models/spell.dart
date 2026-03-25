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
class SpellLevel {
  final String name;
  final int level;

  SpellLevel({required this.name, required this.level});
}

class Spell {
  final int id;
  final String name;
  final String school;
  final String? subschool;
  final List<String>? descriptors;
  final String? castingTime;
  final String? range;
  final String? target;
  final String? area;
  final String? effect;
  final String? duration;
  final String? savingThrow;
  final bool spellResistance;
  final Map<String, dynamic>? mechanics;
  final String description;
  final bool hasVerbal;
  final bool hasSomatic;
  final bool hasMaterial;
  final bool hasFocus;
  final bool hasXp;
  final bool hasDivineFocus;
  final String? materialFocusDescription;
  final int gpCost;
  final int xpCost;
  final String? bookName;
  final String? bookAbbr;
  final int? page;
  final List<SpellLevel> classes;
  final List<SpellLevel> domains;

  Spell({
    required this.id,
    required this.name,
    required this.school,
    this.subschool,
    this.descriptors,
    this.castingTime,
    this.range,
    this.target,
    this.area,
    this.effect,
    this.duration,
    this.savingThrow,
    required this.spellResistance,
    this.mechanics,
    required this.description,
    required this.hasVerbal,
    required this.hasSomatic,
    required this.hasMaterial,
    required this.hasFocus,
    required this.hasXp,
    required this.hasDivineFocus,
    this.materialFocusDescription,
    required this.gpCost,
    required this.xpCost,
    this.bookName,
    this.bookAbbr,
    this.page,
    required this.classes,
    required this.domains,
  });

  factory Spell.fromJson(Map<String, dynamic> json) {
    var classesList = <SpellLevel>[];
    if (json['classes'] != null) {
      classesList = (json['classes'] as List)
          .map((i) => SpellLevel(name: i['class'], level: i['level']))
          .toList();
    }

    var domainsList = <SpellLevel>[];
    if (json['domains'] != null) {
      domainsList = (json['domains'] as List)
          .map((i) => SpellLevel(name: i['domain'], level: i['level']))
          .toList();
    }
    
    return Spell(
      id: json['id'],
      name: json['name'],
      school: json['school'],
      subschool: json['subschool'],
      descriptors: (json['descriptors'] as List<dynamic>?)?.cast<String>(),
      castingTime: json['casting_time'],
      range: json['spell_range'],
      target: json['target'],
      area: json['area'],
      effect: json['effect'],
      duration: json['duration'],
      savingThrow: json['saving_throw'],
      spellResistance: json['spell_resistance'] ?? false,
      mechanics: json['mechanics'],
      description: json['description'] ?? "No Description",
      hasVerbal: json['has_verbal_component'] ?? false,
      hasSomatic: json['has_somatic_component'] ?? false,
      hasMaterial: json['has_material_component'] ?? false,
      hasFocus: json['has_focus_component'] ?? false,
      hasXp: json['has_xp_component'] ?? false,
      hasDivineFocus: json['has_divine_focus_component'] ?? false,
      materialFocusDescription: json['material_focus_description'],
      gpCost: json['gp_cost'] ?? 0,
      xpCost: json['xp_cost'] ?? 0,
      bookName: json['book_name'],
      bookAbbr: json['book_abbr'],
      page: json['page'],
      classes: classesList,
      domains: domainsList,
    );
  }

  String get components {
    final comps = <String>[];
    if (hasVerbal) comps.add('V');
    if (hasSomatic) comps.add('S');
    if (hasMaterial) comps.add('M');
    if (hasFocus) comps.add('F');
    if (hasDivineFocus) comps.add('DF');
    if (hasXp) comps.add('XP');
    return comps.join(', ');
  }
}