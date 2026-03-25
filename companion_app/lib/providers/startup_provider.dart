
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';

final appStartupProvider = FutureProvider<void>((ref) async {
  await ref.read(authProvider.notifier).restoreSession();
});
