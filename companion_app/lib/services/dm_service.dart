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
import '../models/monster.dart';
import 'api_client.dart';

class DmService {
  final ApiClient _apiClient;

  DmService(this._apiClient);

  Future<List<Monster>> getMonsters({String? search}) async {
    String endpoint = '/api/monsters';
    if (search != null && search.isNotEmpty) endpoint += '?search=$search';

    final response = await _apiClient.get(endpoint);
    return (response as List).map((e) => Monster.fromJson(e)).toList();
  }

  Future<Monster> getMonsterDetail(int id) async {
    final response = await _apiClient.get('/api/monsters/$id');
    return Monster.fromJson(response);
  }
}