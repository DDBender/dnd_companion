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
import '../providers/rules_list_provider.dart';
import '../widgets/app_drawer.dart';

class RulesListScreen extends ConsumerWidget {
  const RulesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rulesAsync = ref.watch(rulesListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rules & Reference'),
      ),
      drawer: const AppDrawer(),
      body: rulesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (rules) {
          return ListView.separated(
            itemCount: rules.length + 1,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {

              if (index == 0) {
                return ListTile(
                  leading: const Icon(Icons.bolt, color: Colors.amber),
                  title: const Text(
                    'Cheat Sheet',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text('Quick reference tables'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {

                    context.push(
                      '/combat/view', 
                      extra: 'assets/rules_md/cheat_sheet.md'
                    );
                  },
                );
              }


              final rule = rules[index - 1];

              return ListTile(
                leading: const Icon(Icons.article_outlined),
                title: Text(rule.title),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  context.push('/combat/view', extra: rule.path);
                },
              );
            },
          );
        },
      ),
    );
  }
}
