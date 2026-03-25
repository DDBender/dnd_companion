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
import '../widgets/app_drawer.dart';
import '../models/monster.dart';
import '../providers/monster_provider.dart';


class MonsterSearchQuery extends Notifier<String> {
  @override
  String build() => '';

  void update(String value) => state = value;
}

final monsterSearchQueryProvider = NotifierProvider<MonsterSearchQuery, String>(MonsterSearchQuery.new);

final filteredMonstersProvider = Provider<AsyncValue<List<Monster>>>((ref) {
  final allMonstersAsync = ref.watch(monstersProvider);
  final query = ref.watch(monsterSearchQueryProvider).toLowerCase();

  return allMonstersAsync.whenData((monsters) {
    if (query.isEmpty) return monsters;
    

    return monsters.where((monster) {
      return monster.name.toLowerCase().contains(query) ||
             (monster.type?.toLowerCase().contains(query) ?? false) ||
             (monster.bookName?.toLowerCase().contains(query) ?? false);
    }).toList();
  });
});


class MonsterSearchScreen extends ConsumerWidget {
  const MonsterSearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final monstersAsync = ref.watch(filteredMonstersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Monster Search'),
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search monsters...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                hintText: 'Type to filter instantly',
              ),
              onChanged: (value) {

                ref.read(monsterSearchQueryProvider.notifier).update(value);
              },
            ),
          ),
          Expanded(
            child: monstersAsync.when(
              data: (monsters) {
                if (monsters.isEmpty) {
                  return const Center(child: Text('No monsters found.'));
                }
                return ListView.separated(
                  itemCount: monsters.length,
                  separatorBuilder: (ctx, i) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final monster = monsters[index];
                    return ListTile(
                      title: Text(monster.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${monster.type ?? "Unknown"} • ${monster.bookName ?? "Core"}'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {


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
