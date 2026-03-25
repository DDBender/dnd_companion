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
import '../models/condition.dart';
import '../providers/condition_provider.dart';

class ConditionSearchQuery extends Notifier<String> {
  @override
  String build() => '';

  void update(String value) => state = value;
}

final conditionSearchQueryProvider = NotifierProvider<ConditionSearchQuery, String>(ConditionSearchQuery.new);

final filteredConditionsProvider = Provider<AsyncValue<List<Condition>>>((ref) {
  final allConditionsAsync = ref.watch(conditionsProvider);
  final query = ref.watch(conditionSearchQueryProvider).toLowerCase();

  return allConditionsAsync.whenData((conditions) {
    if (query.isEmpty) return conditions;
    
    return conditions.where((condition) {
      return condition.name.toLowerCase().contains(query) ||
             (condition.bookName?.toLowerCase().contains(query) ?? false);
    }).toList();
  });
});


class ConditionSearchScreen extends ConsumerWidget {
  const ConditionSearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conditionsAsync = ref.watch(filteredConditionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Condition Search'),
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search conditions...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                hintText: 'Type to filter instantly',
              ),
              onChanged: (value) {
                ref.read(conditionSearchQueryProvider.notifier).update(value);
              },
            ),
          ),
          Expanded(
            child: conditionsAsync.when(
              data: (conditions) {
                if (conditions.isEmpty) {
                  return const Center(child: Text('No conditions found.'));
                }
                return ListView.separated(
                  itemCount: conditions.length,
                  separatorBuilder: (ctx, i) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final condition = conditions[index];
                    return ListTile(
                      title: Text(condition.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('$condition.bookName ?? "Core"'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        context.push('/conditions/${condition.id}');
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
