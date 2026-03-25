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
import '../providers/rule_provider.dart';

class RuleDetailScreen extends ConsumerWidget {
  final int ruleId;

  const RuleDetailScreen({super.key, required this.ruleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ruleAsync = ref.watch(ruleDetailProvider(ruleId));

    return Scaffold(
      appBar: AppBar(title: const Text('Rule Details')),
      body: ruleAsync.when(
        data: (rule) => SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(rule.name, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 4),
              Text(
                '${rule.category}${rule.subcategory != null ? " - ${rule.subcategory}" : ""}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontStyle: FontStyle.italic),
              ),
              const Divider(height: 24),

              if (rule.description != null) ...[
                Text('Description', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(rule.description!, style: Theme.of(context).textTheme.bodyMedium),
              ],

              if (rule.bookName != null) ...[
                const Divider(height: 32),
                Text(
                  'Source: ${rule.bookName}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                ),
              ],
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
