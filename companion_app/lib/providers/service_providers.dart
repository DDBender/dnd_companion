import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/player_service.dart';
import '../services/general_service.dart';
import '../services/dm_service.dart';
import 'auth_provider.dart';

final playerServiceProvider = Provider<PlayerService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PlayerService(apiClient);
});

final generalServiceProvider = Provider<GeneralService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return GeneralService(apiClient);
});

final dmServiceProvider = Provider<DmService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return DmService(apiClient);
});