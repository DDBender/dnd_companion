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
import '../models/race.dart';
import '../providers/race_provider.dart';


class RaceSearchQuery extends Notifier<String> {
  @override
  String build() => '';

  void update(String value) => state = value;
}

final raceSearchQueryProvider = NotifierProvider<RaceSearchQuery, String>(RaceSearchQuery.new);

final filteredRacesProvider = Provider<AsyncValue<List<Race>>>((ref) {
  final allRacesAsync = ref.watch(racesProvider);
  final query = ref.watch(raceSearchQueryProvider).toLowerCase();

  return allRacesAsync.whenData((races) {
    if (query.isEmpty) return races;
    

    return races.where((race) {
      return race.name.toLowerCase().contains(query) ||
             (race.type.toLowerCase().contains(query)) ||
             (race.bookName?.toLowerCase().contains(query) ?? false);
    }).toList();
  });
});


class RaceSearchScreen extends ConsumerWidget {
  const RaceSearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final racesAsync = ref.watch(filteredRacesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Race Search'),
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search races...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                hintText: 'Type to filter instantly',
              ),
              onChanged: (value) {

                ref.read(raceSearchQueryProvider.notifier).update(value);
              },
            ),
          ),
          Expanded(
            child: racesAsync.when(
              data: (races) {
                if (races.isEmpty) {
                  return const Center(child: Text('No races found.'));
                }
                return ListView.separated(
                  itemCount: races.length,
                  separatorBuilder: (ctx, i) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final race = races[index];
                    return ListTile(
                      title: Text(race.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${race.type} • ${race.size} • ${race.bookName ?? "Core"}'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {

                        context.push('/races/${race.id}');
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
