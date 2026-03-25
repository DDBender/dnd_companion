import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'service_providers.dart';
import '../models/rule.dart';


final rulesProvider = FutureProvider.autoDispose<List<Rule>>((ref) async {
  final generalService = ref.watch(generalServiceProvider);
  return generalService.getRules();
});

final ruleDetailProvider = FutureProvider.family.autoDispose<Rule, int>((ref, ruleId) async {
  final generalService = ref.watch(generalServiceProvider);
  return generalService.getRuleDetail(ruleId);
});