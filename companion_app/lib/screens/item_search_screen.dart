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
import '../models/item.dart';
import '../providers/item_provider.dart';

class ItemSearchQuery extends Notifier<String> {
  @override
  String build() => '';

  void update(String value) => state = value;
}

final itemSearchQueryProvider = NotifierProvider<ItemSearchQuery, String>(ItemSearchQuery.new);

final filteredItemsProvider = Provider<AsyncValue<List<Item>>>((ref) {
  final allItemsAsync = ref.watch(itemsProvider);
  final query = ref.watch(itemSearchQueryProvider).toLowerCase();

  return allItemsAsync.whenData((items) {
    if (query.isEmpty) return items;
    
    return items.where((item) {
      return item.name.toLowerCase().contains(query) ||
             (item.itemType.toLowerCase().contains(query)) ||
             (item.bookName?.toLowerCase().contains(query) ?? false);
    }).toList();
  });
});


class ItemSearchScreen extends ConsumerWidget {
  const ItemSearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(filteredItemsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Item Search'),
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search items...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                hintText: 'Type to filter instantly',
              ),
              onChanged: (value) {
                ref.read(itemSearchQueryProvider.notifier).update(value);
              },
            ),
          ),
          Expanded(
            child: itemsAsync.when(
              data: (items) {
                if (items.isEmpty) {
                  return const Center(child: Text('No items found.'));
                }
                return ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (ctx, i) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ListTile(
                      title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${item.itemType} • ${item.bookName ?? "Core"}'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        context.push('/items/${item.id}/${item.itemType}');
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
