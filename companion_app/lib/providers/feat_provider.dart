import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'service_providers.dart';
import '../models/feat.dart';


final featsProvider = FutureProvider.autoDispose<List<Feat>>((ref) async {
  final generalService = ref.watch(generalServiceProvider);
  return generalService.getFeats();
});

final featDetailProvider = FutureProvider.family.autoDispose<Feat, int>((ref, featId) async {
  final generalService = ref.watch(generalServiceProvider);
  return generalService.getFeatDetail(featId);
});