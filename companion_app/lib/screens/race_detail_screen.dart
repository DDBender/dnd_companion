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
import '../providers/race_provider.dart';

class RaceDetailScreen extends ConsumerWidget {
  final int raceId;

  const RaceDetailScreen({super.key, required this.raceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final raceAsync = ref.watch(raceDetailProvider(raceId));

    return Scaffold(
      appBar: AppBar(title: const Text('Race Details')),
      body: raceAsync.when(
        data: (race) => SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(race.name, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: [
                  Chip(label: Text('Type: ${race.type}')),
                  Chip(label: Text('Size: ${race.size}')),
                  if (race.speed != null)
                    Chip(label: Text('Speed: ${race.speed} ft.')),
                ],
              ),
              const Divider(height: 24),

              if (race.personality != null) _buildSection(context, 'Personality', race.personality!),
              if (race.physicalDescription != null) _buildSection(context, 'Physical Description', race.physicalDescription!),
              if (race.relations != null) _buildSection(context, 'Relations', race.relations!),
              if (race.alignment != null) _buildSection(context, 'Alignment', race.alignment!),
              if (race.lands != null) _buildSection(context, 'Lands', race.lands!),
              if (race.religion != null) _buildSection(context, 'Religion', race.religion!),
              if (race.language != null) _buildSection(context, 'Language', race.language!),
              if (race.names != null) _buildSection(context, 'Names', race.names!),
              if (race.adventurers != null) _buildSection(context, 'Adventurers', race.adventurers!),

              if (race.bookName != null) ...[
                const Divider(height: 32),
                Text(
                  'Source: ${race.bookName}',
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

  Widget _buildSection(BuildContext context, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(content, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
