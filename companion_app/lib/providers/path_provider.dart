import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'service_providers.dart';
import '../models/path.dart';


final pathsProvider = FutureProvider.autoDispose<List<Path>>((ref) async {
  final generalService = ref.watch(generalServiceProvider);
  return generalService.getPaths();
});

final pathDetailProvider = FutureProvider.family.autoDispose<Path, int>((ref, pathId) async {
  final generalService = ref.watch(generalServiceProvider);
  return generalService.getPathDetail(pathId);
});