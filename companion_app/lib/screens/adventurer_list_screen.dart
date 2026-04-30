import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../providers/adventurer_provider.dart';
import '../models/adventurer_summary.dart';
import '../widgets/app_drawer.dart';

class AdventurerListScreen extends ConsumerWidget {
  const AdventurerListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adventurersAsync = ref.watch(adventurersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Adventurers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authProvider.notifier).logout();
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: adventurersAsync.when(
        data: (adventurers) {
          if (adventurers.isEmpty) {
            return const Center(child: Text('No adventurers found. Create one!'));
          }
          return ListView.builder(
            itemCount: adventurers.length,
            itemBuilder: (context, index) {
              final adventurer = adventurers[index];
              return AdventurerCard(adventurer: adventurer);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to create adventurer screen
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AdventurerCard extends StatelessWidget {
  final AdventurerSummary adventurer;
  const AdventurerCard({super.key, required this.adventurer});

  @override
  Widget build(BuildContext context) {
    // Helper to format class string (e.g., "Fighter 1, Wizard 2")
    final classString = adventurer.paths.map((c) => "${c.pathName} ${c.level}").join(", ");

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(adventurer.name.isNotEmpty ? adventurer.name[0].toUpperCase() : '?'),
        ),
        title: Text('${adventurer.name} (${adventurer.raceName}) Lv.${adventurer.totalLevel}'),
        subtitle: Text('$classString, ${adventurer.moneyGp}GP'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          context.push('/characters/${adventurer.id}');
        },
      ),
    );
  }
}