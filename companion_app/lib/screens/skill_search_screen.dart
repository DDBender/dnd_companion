/*
3.5e Database Companion
Copyright (C) 2026 Daniel Bender

-----------------------------------------------------------------------
AI DISCLOSURE: 
This file was developed with the assistance of Gemini Code Assist. 
AI-generated logic and boilerplate have been reviewed, refined, and 
verified by the human author for accuracy and project integration.
-----------------------------------------------------------------------

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.
*/
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/app_drawer.dart';
import '../models/skill.dart';
import '../providers/skill_provider.dart';


class SkillSearchQuery extends Notifier<String> {
  @override
  String build() => '';

  void update(String value) => state = value;
}

final skillSearchQueryProvider = NotifierProvider<SkillSearchQuery, String>(SkillSearchQuery.new);

final filteredSkillsProvider = Provider<AsyncValue<List<Skill>>>((ref) {
  final allSkillsAsync = ref.watch(skillsProvider);
  final query = ref.watch(skillSearchQueryProvider).toLowerCase();

  return allSkillsAsync.whenData((skills) {
    if (query.isEmpty) return skills;
    

    return skills.where((skill) {
      return skill.name.toLowerCase().contains(query) ||
             (skill.keyAttribute.toLowerCase().contains(query));
    }).toList();
  });
});


class SkillSearchScreen extends ConsumerWidget {
  const SkillSearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final skillsAsync = ref.watch(filteredSkillsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Skill Search'),
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search skills...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                hintText: 'Type to filter instantly',
              ),
              onChanged: (value) {

                ref.read(skillSearchQueryProvider.notifier).update(value);
              },
            ),
          ),
          Expanded(
            child: skillsAsync.when(
              data: (skills) {
                if (skills.isEmpty) {
                  return const Center(child: Text('No skills found.'));
                }
                return ListView.separated(
                  itemCount: skills.length,
                  separatorBuilder: (ctx, i) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final skill = skills[index];
                    return ListTile(
                      title: Text(skill.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${skill.keyAttribute} • ${skill.bookName}'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {

                        context.push('/skills/${skill.id}');
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }
}
