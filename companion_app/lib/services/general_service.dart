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
import '../models/condition.dart';
import '../models/feat.dart';
import '../models/item.dart';
import '../models/path.dart';
import '../models/race.dart';
import '../models/rule.dart';
import '../models/skill.dart';
import '../models/spell.dart';
import 'api_client.dart';

class GeneralService {
  final ApiClient _apiClient;

  GeneralService(this._apiClient);


  Future<List<Item>> getItems({String? search, String? category}) async {
    String endpoint = '/api/items';
    final params = <String>[];
    if (search != null && search.isNotEmpty) params.add('search=$search');
    if (category != null && category.isNotEmpty) params.add('category=$category');
    
    if (params.isNotEmpty) endpoint += '?${params.join('&')}';

    final response = await _apiClient.get(endpoint);
    return (response as List).map((e) => Item.fromJson(e)).toList();
  }

  Future<List<String>> getItemCategories() async {
    final response = await _apiClient.get('/api/items/categories');
    return (response as List).cast<String>();
  }

  Future<Item> getGearDetail(int id) async {
    final response = await _apiClient.get('/api/items/$id');
    return Item.fromJson(response);
  }

  Future<Item> getWeaponDetail(int id) async {
    final response = await _apiClient.get('/api/weapons/$id');
    return Item.fromJson(response);
  }

  Future<Item> getArmorDetail(int id) async {
    final response = await _apiClient.get('/api/armor/$id');
    return Item.fromJson(response);
  }


  Future<List<Feat>> getFeats({String? search}) async {
    String endpoint = '/api/feats';
    if (search != null && search.isNotEmpty) endpoint += '?search=$search';
    
    final response = await _apiClient.get(endpoint);
    return (response as List).map((e) => Feat.fromJson(e)).toList();
  }

  Future<Feat> getFeatDetail(int id) async {
    final response = await _apiClient.get('/api/feats/$id');
    return Feat.fromJson(response);
  }


  Future<List<Skill>> getSkills() async {
    final response = await _apiClient.get('/api/skills');
    return (response as List).map((e) => Skill.fromJson(e)).toList();
  }

  Future<Skill> getSkillDetail(int id) async {
    final response = await _apiClient.get('/api/skills/$id');
    return Skill.fromJson(response);
  }


  Future<List<Spell>> getSpells({String? search}) async {
    String endpoint = '/api/spells';
    if (search != null && search.isNotEmpty) endpoint += '?search=$search';

    final response = await _apiClient.get(endpoint);
    return (response as List).map((e) => Spell.fromJson(e)).toList();
  }

  Future<Spell> getSpellDetail(int id) async {
    final response = await _apiClient.get('/api/spells/$id');
    return Spell.fromJson(response);
  }


  Future<List<Race>> getRaces() async {
    final response = await _apiClient.get('/api/races');
    return (response as List).map((e) => Race.fromJson(e)).toList();
  }

  Future<Race> getRaceDetail(int id) async {
    final response = await _apiClient.get('/api/races/$id');
    return Race.fromJson(response);
  }


  Future<List<Path>> getPaths() async {
    final response = await _apiClient.get('/api/classes');
    return (response as List).map((e) => Path.fromJson(e)).toList();
  }

  Future<Path> getPathDetail(int id) async {
    final response = await _apiClient.get('/api/classes/$id');
    return Path.fromJson(response);
  }


  Future<List<Rule>> getRules({String? search, String? category}) async {
    String endpoint = '/api/rules';
    final params = <String>[];
    if (search != null && search.isNotEmpty) params.add('search=$search');
    if (category != null && category.isNotEmpty) params.add('category=$category');
    
    if (params.isNotEmpty) endpoint += '?${params.join('&')}';

    final response = await _apiClient.get(endpoint);
    return (response as List).map((e) => Rule.fromJson(e)).toList();
  }

  Future<List<String>> getRuleCategories() async {
    final response = await _apiClient.get('/api/rules/categories');
    return (response as List).cast<String>();
  }

  Future<Rule> getRuleDetail(int id) async {
    final response = await _apiClient.get('/api/rules/$id');
    return Rule.fromJson(response);
  }


  Future<List<Condition>> getConditions({String? search}) async {
    String endpoint = '/api/conditions';
    if (search != null && search.isNotEmpty) endpoint += '?search=$search';

    final response = await _apiClient.get(endpoint);
    return (response as List).map((e) => Condition.fromJson(e)).toList();
  }

  Future<Condition> getConditionDetail(int id) async {
    final response = await _apiClient.get('/api/conditions/$id');
    return Condition.fromJson(response);
  }
}