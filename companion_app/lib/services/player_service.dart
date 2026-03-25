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
import '../models/adventurer.dart';
import 'api_client.dart';
import 'package:logger/logger.dart';

class PlayerService {
  final ApiClient _apiClient;

  PlayerService(this._apiClient);
  final logger = Logger();
  
  Future<List<Adventurer>> getAdventurers() async {
    final response = await _apiClient.get('/api/adventurers');
    logger.d(response);
    return (response as List).map((e) => Adventurer.fromJson(e)).toList();
  }

  Future<Adventurer> getAdventurer(int id) async {
    final response = await _apiClient.get('/api/adventurers/$id');
    return Adventurer.fromJson(response);
  }

  Future<int> createAdventurer(Map<String, dynamic> adventurerData) async {
    final response = await _apiClient.post('/api/adventurers', adventurerData);
    return response['adventurer_id'];
  }

  Future<void> updateAdventurer(int id, Map<String, dynamic> updates) async {
    await _apiClient.put('/api/adventurers/$id', updates);
  }

  Future<void> addItemToInventory(int adventurerId, int itemId, {int quantity = 1}) async {
    await _apiClient.post('/api/adventurers/$adventurerId/inventory', {
      'item_id': itemId,
      'quantity': quantity,
    });
  }

  Future<void> addFeatToAdventurer(int adventurerId, int featId, {String? note}) async {
    await _apiClient.post('/api/adventurers/$adventurerId/feats', {
      'feat_id': featId,
      'note': note,
    });
  }

  Future<void> updateSkill(int adventurerId, int skillId, double ranks) async {
    await _apiClient.post('/api/adventurers/$adventurerId/skills', {
      'skill_id': skillId,
      'ranks': ranks,
    });
  }
}