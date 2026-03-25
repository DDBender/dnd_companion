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
import '../models/spell.dart';
import '../providers/spell_provider.dart';


class SpellSearchQuery extends Notifier<String> {
  @override
  String build() => '';

  void update(String value) => state = value;
}

final spellSearchQueryProvider = NotifierProvider<SpellSearchQuery, String>(SpellSearchQuery.new);

final filteredSpellsProvider = Provider<AsyncValue<List<Spell>>>((ref) {
  final allSpellsAsync = ref.watch(spellsProvider);
  final query = ref.watch(spellSearchQueryProvider).toLowerCase();

  return allSpellsAsync.whenData((spells) {
    if (query.isEmpty) return spells;
    

    return spells.where((spell) {
      return spell.name.toLowerCase().contains(query) ||
             (spell.school.toLowerCase().contains(query)) ||
             (spell.bookName?.toLowerCase().contains(query) ?? false);
    }).toList();
  });
});


class SpellSearchScreen extends ConsumerWidget {
  const SpellSearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final spellsAsync = ref.watch(filteredSpellsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Spell Search'),
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search spells...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                hintText: 'Type to filter instantly',
              ),
              onChanged: (value) {

                ref.read(spellSearchQueryProvider.notifier).update(value);
              },
            ),
          ),
          Expanded(
            child: spellsAsync.when(
              data: (spells) {
                if (spells.isEmpty) {
                  return const Center(child: Text('No spells found.'));
                }
                return ListView.separated(
                  itemCount: spells.length,
                  separatorBuilder: (ctx, i) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final spell = spells[index];
                    return ListTile(
                      title: Text(spell.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${spell.school} • ${spell.bookName ?? "Core"}'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {

                        context.push('/spells/${spell.id}');
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
