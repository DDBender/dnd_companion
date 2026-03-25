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
import '../models/path.dart';
import '../providers/path_provider.dart';


class PathSearchQuery extends Notifier<String> {
  @override
  String build() => '';

  void update(String value) => state = value;
}

final pathSearchQueryProvider = NotifierProvider<PathSearchQuery, String>(PathSearchQuery.new);

final filteredPathsProvider = Provider<AsyncValue<List<Path>>>((ref) {
  final allPathsAsync = ref.watch(pathsProvider);
  final query = ref.watch(pathSearchQueryProvider).toLowerCase();

  return allPathsAsync.whenData((paths) {
    if (query.isEmpty) return paths;
    

    return paths.where((path) {
      return path.name.toLowerCase().contains(query) ||
             (path.mainAttr?.toLowerCase().contains(query) ?? false) ||
             (path.bookName?.toLowerCase().contains(query) ?? false);
    }).toList();
  });
});


class PathSearchScreen extends ConsumerWidget {
  const PathSearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final pathsAsync = ref.watch(filteredPathsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Path Search'),
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search paths...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                hintText: 'Type to filter instantly',
              ),
              onChanged: (value) {

                ref.read(pathSearchQueryProvider.notifier).update(value);
              },
            ),
          ),
          Expanded(
            child: pathsAsync.when(
              data: (paths) {
                if (paths.isEmpty) {
                  return const Center(child: Text('No paths found.'));
                }
                return ListView.separated(
                  itemCount: paths.length,
                  separatorBuilder: (ctx, i) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final path = paths[index];
                    return ListTile(
                      title: Text(path.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${path.mainAttr ?? "Unknown"} • ${path.bookName ?? "Core"}'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {

                        context.push('/paths/${path.id}');
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
