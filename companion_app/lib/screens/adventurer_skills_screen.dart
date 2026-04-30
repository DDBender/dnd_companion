import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/adventurer_provider.dart';
import '../models/adventurer_skill.dart';
import 'package:go_router/go_router.dart';

class AdventurerSkillsScreen extends ConsumerStatefulWidget {
  final int adventurerId;

  const AdventurerSkillsScreen({super.key, required this.adventurerId});

  @override
  ConsumerState<AdventurerSkillsScreen> createState() => _AdventurerSkillsScreenState();
}

class _AdventurerSkillsScreenState extends ConsumerState<AdventurerSkillsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  //TODO: check for better solution than just standard value
  int _getStatModifier(String keyAttribute, dynamic adventurer) {
    int statValue = 10;
    
    switch (keyAttribute.toLowerCase()) {
      case 'strength': statValue = adventurer.strength; break;
      case 'dexterity': statValue = adventurer.dexterity; break;
      case 'constitution': statValue = adventurer.constitution; break;
      case 'intelligence': statValue = adventurer.intelligence; break;
      case 'wisdom': statValue = adventurer.wisdom; break;
      case 'charisma': statValue = adventurer.charisma; break;
    }
    return (statValue - 10) ~/ 2;
  }

  @override
  Widget build(BuildContext context) {
    final adventurerAsync = ref.watch(adventurerDetailProvider(widget.adventurerId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Character Skills'),
      ),
      body: adventurerAsync.when(
        data: (adventurer) {
          List<AdventurerSkill> skills = adventurer.skills ?? [];

          if (_searchQuery.isNotEmpty) {
            skills = skills.where((skill) {
              final matchName = skill.skillName.toLowerCase().contains(_searchQuery.toLowerCase());
              final matchSub = skill.subSkill?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false;
              return matchName || matchSub;
            }).toList();
          }

          skills.sort((a, b) => a.skillName.toLowerCase().compareTo(b.skillName.toLowerCase()));

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Search Skills...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
              ),
              
              Expanded(
                child: ListView.separated(
                  itemCount: skills.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final skill = skills[index];
                    
                    final displayName = skill.subSkill != null 
                        ? '${skill.skillName} (${skill.subSkill})' 
                        : skill.skillName;

                    final int statMod = _getStatModifier(skill.keyAttribute, adventurer);
                    final int itemBonus = 0; // TODO: Replace with actual equipment logic
                    
                    // Calculate total. Using double in case ranks are 0.5
                    final double totalBonus = skill.ranks + statMod + itemBonus; 
                    
                    // Format strings to show +/- signs nicely
                    final String totalBonusStr = totalBonus >= 0 ? '+${totalBonus.toStringAsFixed(totalBonus.truncateToDouble() == totalBonus ? 0 : 1)}' : totalBonus.toString();
                    final String statModStr = statMod >= 0 ? '+$statMod' : '$statMod';
                    final String itemBonusStr = itemBonus >= 0 ? '+$itemBonus' : '$itemBonus';

                    return ListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              displayName, 
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                          Text(
                            totalBonusStr,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green),
                          ),
                        ],
                      ),
                      subtitle: Text(
                        '${skill.keyAttribute} ($statModStr) • Ranks: ${skill.ranks} • Items: $itemBonusStr',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (skill.trainedOnly)
                            const Tooltip(
                              message: 'Trained Only',
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4.0),
                                child: Icon(Icons.school_outlined, size: 20, color: Colors.blue),
                              ),
                            ),
                          if (skill.armorCheckPenalty)
                            const Tooltip(
                              message: 'Armor Check Penalty Applies',
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4.0),
                                child: Icon(Icons.shield_outlined, size: 20, color: Colors.red),
                              ),
                            ),
                        ],
                      ),
                      onTap: () {
                        context.push('/skills/${skill.id}');
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}