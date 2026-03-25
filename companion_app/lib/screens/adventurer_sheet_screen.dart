import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/adventurer_provider.dart';

class AdventurerSheetScreen extends ConsumerWidget {
  final int adventurerId;

  const AdventurerSheetScreen({super.key, required this.adventurerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adventurerAsync = ref.watch(adventurerDetailProvider(adventurerId));

    return Scaffold(
      appBar: AppBar(title: const Text('Character Sheet')),
      body: adventurerAsync.when(
        data: (adventurer) => SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Text(adventurer.name, style: Theme.of(context).textTheme.headlineMedium),
              Text('${adventurer.raceName} ${adventurer.paths?.map((c) => "${c.pathName} ${c.level}").join(" / ") ?? "No Paths"}'),
              const Divider(),

              // Stats Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                childAspectRatio: 1.5,
                children: [
                  _buildStatBox('STR', adventurer.strength),
                  _buildStatBox('DEX', adventurer.dexterity),
                  _buildStatBox('CON', adventurer.constitution),
                  _buildStatBox('INT', adventurer.intelligence),
                  _buildStatBox('WIS', adventurer.wisdom),
                  _buildStatBox('CHA', adventurer.charisma),
                ],
              ),
              const Divider(),

              // Details
              _buildDetailRow('Alignment', adventurer.alignment ?? "Unknown"),
              _buildDetailRow('HP', '${adventurer.hitPointsCurrent} / ${adventurer.hitPointsMax}'),
              _buildDetailRow('Gold', '${adventurer.moneyGp} GP'),
              
              const SizedBox(height: 20),
              Text('Description', style: Theme.of(context).textTheme.titleMedium),
              Text(adventurer.description ?? "No Description given"),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildStatBox(String label, int value) {
    int mod = (value - 10) ~/ 2;
    String modStr = mod >= 0 ? '+$mod' : '$mod';
    return Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text('$value ($modStr)', style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value),
        ],
      ),
    );
  }
}
