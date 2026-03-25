import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'service_providers.dart';
import '../models/spell.dart';


final spellsProvider = FutureProvider.autoDispose<List<Spell>>((ref) async {
  final generalService = ref.watch(generalServiceProvider);
  return generalService.getSpells();
});

final spellDetailProvider = FutureProvider.family.autoDispose<Spell, int>((ref, spellId) async {
  final generalService = ref.watch(generalServiceProvider);
  return generalService.getSpellDetail(spellId);
});