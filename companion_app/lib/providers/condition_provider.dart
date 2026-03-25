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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'service_providers.dart';
import '../models/condition.dart';


final conditionsProvider = FutureProvider.autoDispose<List<Condition>>((ref) async {
  final generalService = ref.watch(generalServiceProvider);
  return generalService.getConditions();
});

final conditionDetailProvider = FutureProvider.family.autoDispose<Condition, int>((ref, conditionId) async {
  final generalService = ref.watch(generalServiceProvider);
  return generalService.getConditionDetail(conditionId);
});