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
import 'adventurer_weapon.dart';
import 'adventurer_armor.dart';
import 'adventurer_gear.dart';
import 'adventurer_feat.dart';
import 'adventurer_skill.dart';
import 'adventurer_spell.dart';

class Adventurer {
  final int id;
  final int? userId;
  final String name;
  final String? raceName;
  final String? alignment;
  final String? gender;
  final int? age;
  final String? height;
  final String? weight;
  final String? description;
  final int strength;
  final int dexterity;
  final int constitution;
  final int intelligence;
  final int wisdom;
  final int charisma;
  final int? hitPointsMax;
  final int? hitPointsCurrent;
  final int experiencePoints;
  final int moneyGp;
  final List<AdventurerPath>? paths;
  
  // Detailed fields (populated when fetching specific adventurer)
  final List<AdventurerWeapon>? weapons;
  final List<AdventurerArmor>? armor;
  final List<AdventurerGear>? gear;
  final List<AdventurerFeat>? feats;
  final List<AdventurerSkill>? skills;
  final List<AdventurerSpell>? spells;

  Adventurer({
    required this.id,
    this.userId,
    required this.name,
    this.raceName,
    this.alignment,
    this.gender,
    this.age,
    this.height,
    this.weight,
    this.description,
    this.strength = 10,
    this.dexterity = 10,
    this.constitution = 10,
    this.intelligence = 10,
    this.wisdom = 10,
    this.charisma = 10,
    this.hitPointsMax,
    this.hitPointsCurrent,
    this.experiencePoints = 0,
    this.moneyGp = 0,
    this.paths,
    this.weapons,
    this.armor,
    this.gear,
    this.feats,
    this.skills,
    this.spells,
  });
/*
  factory Adventurer.fromJson(Map<String, dynamic> json) {
    return Adventurer(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      raceName: json['race_name'],
      alignment: json['alignment'],
      gender: json['gender'],
      age: json['age'],
      height: json['height'],
      weight: json['weight'],
      description: json['description'],
      strength: json['strength'] ?? 10,
      dexterity: json['dexterity'] ?? 10,
      constitution: json['constitution'] ?? 10,
      intelligence: json['intelligence'] ?? 10,
      wisdom: json['wisdom'] ?? 10,
      charisma: json['charisma'] ?? 10,
      hitPointsMax: json['hit_points_max'],
      hitPointsCurrent: json['hit_points_current'],
      experiencePoints: json['experience_points'] ?? 0,
      moneyGp: json['money_gp'] ?? 0,
      paths: (json['classes'] as List?)?.map((e) => AdventurerPath.fromJson(e)).toList(),
      weapons: (json['weapons'] as List?)?.map((e) => AdventurerWeapon.fromJson(e)).toList(),
      armor: (json['armor'] as List?)?.map((e) => AdventurerArmor.fromJson(e)).toList(),
      gear: (json['gear'] as List?)?.map((e) => AdventurerGear.fromJson(e)).toList(),
      feats: (json['feats'] as List?)?.map((e) => AdventurerFeat.fromJson(e)).toList(),
      skills: (json['skills'] as List?)?.map((e) => AdventurerSkill.fromJson(e)).toList(),
      spells: (json['spells'] as List?)?.map((e) => AdventurerSpell.fromJson(e)).toList(),
    );
  }
  */

  factory Adventurer.fromJson(Map<String, dynamic> json) {
    // Safely extract nested maps to prevent null errors if the keys are missing
    final baseStats = json['base_stats'] as Map<String, dynamic>? ?? {};
    final raceDetails = json['race_details'] as Map<String, dynamic>? ?? {};

    // --- Extracted Variables ---
    // This allows the debugger to catch exactly which line fails if there is a type mismatch
    
    // Core Identity
    final id = json['adventurer_id'] ?? baseStats['id']; 
    final userId = json['user_id'] ?? baseStats['user_id'];
    final name = json['name'] ?? baseStats['name'];
    
    // Details
    final raceName = raceDetails['name']; 
    final alignment = baseStats['alignment'];
    final gender = baseStats['gender'];
    final age = baseStats['age'];
    final height = baseStats['height'];
    final weight = baseStats['weight'];
    final description = baseStats['description'];
    
    // Stats
    final strength = baseStats['strength'] ?? 10;
    final dexterity = baseStats['dexterity'] ?? 10;
    final constitution = baseStats['constitution'] ?? 10;
    final intelligence = baseStats['intelligence'] ?? 10;
    final wisdom = baseStats['wisdom'] ?? 10;
    final charisma = baseStats['charisma'] ?? 10;
    
    // Vitals & Progression
    final hitPointsMax = baseStats['hit_points_max'];
    final hitPointsCurrent = baseStats['hit_points_current'];
    final experiencePoints = baseStats['experience_points'] ?? 0;
    final moneyGp = baseStats['money_gp'] ?? 0;
    
    // Lists
    final paths = (json['classes'] as List?)?.map((e) => AdventurerPath.summaryFromJson(e)).toList();
    final weapons = (json['weapons'] as List?)?.map((e) => AdventurerWeapon.fromJson(e)).toList();
    final armor = (json['armor'] as List?)?.map((e) => AdventurerArmor.fromJson(e)).toList();
    final gear = (json['gear'] as List?)?.map((e) => AdventurerGear.fromJson(e)).toList();
    final feats = (json['feats'] as List?)?.map((e) => AdventurerFeat.fromJson(e)).toList();
    final skills = (json['skills'] as List?)?.map((e) => AdventurerSkill.fromJson(e)).toList();
    final spells = (json['spells'] as List?)?.map((e) => AdventurerSpell.fromJson(e)).toList();

    // Construct and return
    return Adventurer(
      id: id,
      userId: userId,
      name: name,
      raceName: raceName,
      alignment: alignment,
      gender: gender,
      age: age,
      height: height,
      weight: weight,
      description: description,
      strength: strength,
      dexterity: dexterity,
      constitution: constitution,
      intelligence: intelligence,
      wisdom: wisdom,
      charisma: charisma,
      hitPointsMax: hitPointsMax,
      hitPointsCurrent: hitPointsCurrent,
      experiencePoints: experiencePoints,
      moneyGp: moneyGp,
      paths: paths,
      weapons: weapons,
      armor: armor,
      gear: gear,
      feats: feats,
      skills: skills,
      spells: spells,
    );
}
}