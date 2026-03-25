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
import '../providers/item_provider.dart';
import '../models/item.dart';

class ItemDetailScreen extends ConsumerWidget {
  final int itemId;
  final String itemType;

  const ItemDetailScreen({super.key, required this.itemId, required this.itemType});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    
    final itemAsync = switch (itemType.toLowerCase()) {
      'weapon' => ref.watch(weaponDetailProvider(itemId)),
      'armor'  => ref.watch(armorDetailProvider(itemId)),
      _        => ref.watch(gearDetailProvider(itemId)),
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Item Details')),
      body: itemAsync.when(
        data: (item) => SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(item.name, style: Theme.of(context).textTheme.headlineMedium)),
                  Chip(label: Text(item.itemType)),
                ],
              ),
              if (item.bodySlot != null && item.bodySlot != 'None')
                Text('Slot: ${item.bodySlot}', style: Theme.of(context).textTheme.titleMedium),
              
              const Divider(height: 24),

              _buildInfoRow('Price', item.price != null ? '${item.price} gp' : null),
              _buildInfoRow('Weight', item.weight != null ? '${item.weight} lbs' : null),

              if (item is WeaponItem) _buildWeaponStats(context, item),
              if (item is ArmorItem) _buildArmorStats(context, item),

              const SizedBox(height: 24),
              if (item.description != null) ...[
                Text('Description', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(item.description!),
              ],

              if (item.bookName != null) ...[
                const Divider(height: 32),
                Text(
                  'Source: ${item.bookName} ${item.page != null ? "p.${item.page}" : ""}',
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

  Widget _buildWeaponStats(BuildContext context, WeaponItem item) {
    String? criticalDisplay;
    if (item.criticalMultiplier != null) {
      criticalDisplay = 'x${item.criticalMultiplier}';
      if (item.criticalRange != null && item.criticalRange! < 20) {
        criticalDisplay = '${item.criticalRange}-20/$criticalDisplay';
      }
    }

    return Column(
      children: [
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: Text('Weapon Stats', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        ),
        _buildInfoRow('Category', item.weaponCategory),
        _buildInfoRow('Type', item.weaponType),
        _buildInfoRow('Handedness', item.handedness),
        _buildInfoRow('Range', item.range != null ? '${item.range} ft.' : null),
        _buildInfoRow('Damage', item.damage),
        _buildInfoRow('Critical', criticalDisplay),
      ],
    );
  }

  Widget _buildArmorStats(BuildContext context, ArmorItem item) {
    return Column(
      children: [
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: Text('Armor Stats', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        ),
        _buildInfoRow('Category', item.armorCategory),
        _buildInfoRow('AC Bonus', item.acBonus != null ? '+${item.acBonus}' : null),
        _buildInfoRow('Max Dex', item.maxDexBonus != null ? '+${item.maxDexBonus}' : null),
        _buildInfoRow('Check Penalty', item.armorCheckPenalty?.toString()),
        _buildInfoRow('Spell Failure', item.arcaneSpellFailure != null ? '${item.arcaneSpellFailure}%' : null),
        _buildInfoRow('Speed (30ft)', item.speedThirty != null ? '${item.speedThirty} ft.' : null),
        _buildInfoRow('Speed (20ft)', item.speedTwenty != null ? '${item.speedTwenty} ft.' : null),
      ],
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(value),
        ],
      ),
    );
  }
}
