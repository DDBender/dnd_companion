import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'service_providers.dart';
import '../models/race.dart';


final racesProvider = FutureProvider.autoDispose<List<Race>>((ref) async {
  final generalService = ref.watch(generalServiceProvider);
  return generalService.getRaces();
});

final raceDetailProvider = FutureProvider.family.autoDispose<Race, int>((ref, raceId) async {
  final generalService = ref.watch(generalServiceProvider);
  return generalService.getRaceDetail(raceId);
});