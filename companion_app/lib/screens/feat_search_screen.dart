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
import '../models/feat.dart';
import '../providers/feat_provider.dart';

class FeatSearchQuery extends Notifier<String> {
  @override
  String build() => '';

  void update(String value) => state = value;
}

final featSearchQueryProvider = NotifierProvider<FeatSearchQuery, String>(FeatSearchQuery.new);

final filteredFeatsProvider = Provider<AsyncValue<List<Feat>>>((ref) {
  final allFeatsAsync = ref.watch(featsProvider);
  final query = ref.watch(featSearchQueryProvider).toLowerCase();

  return allFeatsAsync.whenData((feats) {
    if (query.isEmpty) return feats;
    
    // Local filtering logic
    return feats.where((feat) {
      return feat.name.toLowerCase().contains(query) ||
             (feat.featType?.toLowerCase().contains(query) ?? false) ||
             (feat.bookName?.toLowerCase().contains(query) ?? false);
    }).toList();
  });
});


class FeatSearchScreen extends ConsumerWidget {
  const FeatSearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final featsAsync = ref.watch(filteredFeatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Feat Search'),
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search feats...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                hintText: 'Type to filter instantly',
              ),
              onChanged: (value) {
                ref.read(featSearchQueryProvider.notifier).update(value);
              },
            ),
          ),
          Expanded(
            child: featsAsync.when(
              data: (feats) {
                if (feats.isEmpty) {
                  return const Center(child: Text('No feats found.'));
                }
                return ListView.separated(
                  itemCount: feats.length,
                  separatorBuilder: (ctx, i) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final feat = feats[index];
                    return ListTile(
                      title: Text(feat.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${feat.featType ?? "General"} • ${feat.bookName ?? "Core"}'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        context.push('/feats/${feat.id}');
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
