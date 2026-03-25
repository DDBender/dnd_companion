import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'service_providers.dart';
import '../models/skill.dart';


final skillsProvider = FutureProvider.autoDispose<List<Skill>>((ref) async {
  final generalService = ref.watch(generalServiceProvider);
  return generalService.getSkills();
});

final skillDetailProvider = FutureProvider.family.autoDispose<Skill, int>((ref, skillId) async {
  final generalService = ref.watch(generalServiceProvider);
  return generalService.getSkillDetail(skillId);
});