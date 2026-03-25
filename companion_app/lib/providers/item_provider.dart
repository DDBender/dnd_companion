import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'service_providers.dart';
import '../models/item.dart';


final itemsProvider = FutureProvider.autoDispose<List<Item>>((ref) async {
  final generalService = ref.watch(generalServiceProvider);
  return generalService.getItems();
});

final gearDetailProvider = FutureProvider.family.autoDispose<Item, int>((ref, itemId) async {
  final generalService = ref.watch(generalServiceProvider);
  return generalService.getGearDetail(itemId);
});

final weaponDetailProvider = FutureProvider.family.autoDispose<Item, int>((ref, itemId) async {
  final generalService = ref.watch(generalServiceProvider);
  return generalService.getWeaponDetail(itemId);
});

final armorDetailProvider = FutureProvider.family.autoDispose<Item, int>((ref, itemId) async {
  final generalService = ref.watch(generalServiceProvider);
  return generalService.getArmorDetail(itemId);
});