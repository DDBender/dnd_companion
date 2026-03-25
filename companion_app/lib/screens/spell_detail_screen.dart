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
import '../models/spell.dart';
import '../providers/spell_provider.dart';

class SpellDetailScreen extends ConsumerWidget {
  final int spellId;

  const SpellDetailScreen({super.key, required this.spellId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spellAsync = ref.watch(spellDetailProvider(spellId));

    return Scaffold(
      appBar: AppBar(title: const Text('Spell Details')),
      body: spellAsync.when(
        data: (spell) => SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(spell.name, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 4),
              Text(
                '${spell.school} ${spell.subschool != null ? "(${spell.subschool})" : ""} ${spell.descriptors?.isNotEmpty == true ? "[${spell.descriptors!.join(', ')}]" : ""}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontStyle: FontStyle.italic),
              ),
              const Divider(height: 24),
              
              _buildInfoRow('Level', _formatLevels(spell)),
              _buildInfoRow('Components', spell.components),
              _buildInfoRow('Casting Time', spell.castingTime),
              _buildInfoRow('Range', spell.range),
              _buildInfoRow('Target', spell.target),
              _buildInfoRow('Area', spell.area),
              _buildInfoRow('Effect', spell.effect),
              _buildInfoRow('Duration', spell.duration),
              _buildInfoRow('Saving Throw', _formatSavingThrow(spell)),
              _buildInfoRow('Spell Resistance', _formatSpellResistance(spell)),
              
              if (spell.gpCost > 0) _buildInfoRow('Cost', '${spell.gpCost} gp'),
              if (spell.xpCost > 0) _buildInfoRow('XP Cost', '${spell.xpCost} XP'),

              const SizedBox(height: 16),
              Text('Description', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(spell.description, style: Theme.of(context).textTheme.bodyMedium),

              if (spell.bookName != null) ...[
                const Divider(height: 32),
                Text(
                  'Source: ${spell.bookName} ${spell.page != null ? "p.${spell.page}" : ""}',
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
            width: 120,
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

  String _formatLevels(Spell spell) {
    final List<String> parts = [];
    

    for (var c in spell.classes) {
      parts.add('${c.name} ${c.level}');
    }
    

    for (var d in spell.domains) {
      parts.add('${d.name} ${d.level}');
    }
    
    return parts.join(', ');
  }

  String? _formatSavingThrow(Spell spell) {
    final save = spell.savingThrow;
    if (save == null) return null;
    
    final mechanics = spell.mechanics;
    if (mechanics != null && mechanics['save'] != null) {
      final tags = mechanics['save']['tag'];
      if (tags is List && tags.isNotEmpty) {
        return '$save (${tags.join(', ')})';
      }
    }
    return save;
  }

  String _formatSpellResistance(Spell spell) {
    final sr = spell.spellResistance ? 'Yes' : 'No';
    
    final mechanics = spell.mechanics;
    if (mechanics != null && mechanics['sr'] != null) {
      final tags = mechanics['sr']['tag'];
      if (tags is List && tags.isNotEmpty) {
        return '$sr (${tags.join(', ')})';
      }
    }
    return sr;
  }
}
