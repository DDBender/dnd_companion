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
import '../providers/path_provider.dart';



class PathDetailScreen extends ConsumerWidget {
  final int pathId;

  const PathDetailScreen({super.key, required this.pathId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pathAsync = ref.watch(pathDetailProvider(pathId));

    return Scaffold(
      appBar: AppBar(title: const Text('Path Details')),
      body: pathAsync.when(
        data: (path) => SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(path.name, style: Theme.of(context).textTheme.headlineMedium)),
                  if (path.isPrestige == true)
                    Chip(
                      label: const Text('Prestige'),
                      backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
                    ),
                ],
              ),
              const Divider(height: 24),

              if (path.diceType != null)
                _buildInfoRow('Hit Die', 'd${path.diceType}'),
              if (path.numDice != null && path.numDice! > 1)
                 _buildInfoRow('Number of Dice', '${path.numDice}'),
              _buildInfoRow('Main Attribute', path.mainAttr),
              if (path.skillPoints != null)
                _buildInfoRow('Skill Points', '${path.skillPoints} + Int mod'),
              _buildInfoRow('Alignment', path.alignment),

              if (path.bookName != null) ...[
                const Divider(height: 32),
                Text(
                  'Source: ${path.bookName}',
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

  Widget _buildInfoRow(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
