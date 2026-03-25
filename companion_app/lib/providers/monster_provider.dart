import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'service_providers.dart';
import '../models/monster.dart';


final monstersProvider = FutureProvider.autoDispose<List<Monster>>((ref) async {
  final dmService = ref.watch(dmServiceProvider);
  return dmService.getMonsters();
});

final monsterDetailProvider = FutureProvider.family.autoDispose<Monster, int>((ref, monsterId) async {
  final dmService = ref.watch(dmServiceProvider);
  return dmService.getMonsterDetail(monsterId);
});