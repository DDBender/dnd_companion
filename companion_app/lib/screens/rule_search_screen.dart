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
import '../models/rule.dart';
import '../providers/rule_provider.dart';


class RuleSearchQuery extends Notifier<String> {
  @override
  String build() => '';

  void update(String value) => state = value;
}

final ruleSearchQueryProvider = NotifierProvider<RuleSearchQuery, String>(RuleSearchQuery.new);

final filteredRulesProvider = Provider<AsyncValue<List<Rule>>>((ref) {
  final allRulesAsync = ref.watch(rulesProvider);
  final query = ref.watch(ruleSearchQueryProvider).toLowerCase();

  return allRulesAsync.whenData((rules) {
    if (query.isEmpty) return rules;
    

    return rules.where((rule) {
      return rule.name.toLowerCase().contains(query) ||
             (rule.category.toLowerCase().contains(query)) ||
             (rule.bookName?.toLowerCase().contains(query) ?? false);
    }).toList();
  });
});


class RuleSearchScreen extends ConsumerWidget {
  const RuleSearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final rulesAsync = ref.watch(filteredRulesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rule Search'),
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search rules...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                hintText: 'Type to filter instantly',
              ),
              onChanged: (value) {

                ref.read(ruleSearchQueryProvider.notifier).update(value);
              },
            ),
          ),
          Expanded(
            child: rulesAsync.when(
              data: (rules) {
                if (rules.isEmpty) {
                  return const Center(child: Text('No rules found.'));
                }
                return ListView.separated(
                  itemCount: rules.length,
                  separatorBuilder: (ctx, i) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final rule = rules[index];
                    return ListTile(
                      title: Text(rule.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${rule.category} • ${rule.bookName ?? "Core"}'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        context.push('/rules/${rule.id}');
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
