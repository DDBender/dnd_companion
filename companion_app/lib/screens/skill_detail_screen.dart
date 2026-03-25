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
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:markdown/markdown.dart' as md;
import '../providers/skill_provider.dart';


class TocEntry {
  final String text;
  final String id;
  final int level; // 1 for h1, 2 for h2, etc.
  TocEntry(this.text, this.id, this.level);
}

class TocNode {
  final TocEntry entry;
  final List<TocNode> children = [];
  TocNode(this.entry);
}


class SkillDetailScreen extends ConsumerStatefulWidget {
  final int skillId;

  const SkillDetailScreen({super.key, required this.skillId});

  @override
  ConsumerState<SkillDetailScreen> createState() => _SkillDetailScreenState();
}

class _SkillDetailScreenState extends ConsumerState<SkillDetailScreen> {

  final Map<String, GlobalKey> _headerKeys = {};
  

  List<TocEntry> _toc = [];


  void _scrollToSection(String headerId) {

    final key = _headerKeys[headerId];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        alignment: 0.1,
      );
    }
  }


  void _parseHeaders(String markdown) {
    _toc.clear();
    _headerKeys.clear();

    final lines = markdown.split('\n');
    final RegExp headerRegex = RegExp(r'^(#{1,6})\s+(.*)$');

    for (var line in lines) {
      final match = headerRegex.firstMatch(line);
      if (match != null) {
        final hashes = match.group(1)!;
        final text = match.group(2)!.trim();
        final level = hashes.length;

        if (text.isNotEmpty) {

          final id = text; 
          
          _toc.add(TocEntry(text, id, level));
          _headerKeys[id] = GlobalKey();
        }
      }
    }
  }


  List<TocNode> _buildTocTree(List<TocEntry> flatList) {
    final List<TocNode> roots = [];
    List<TocNode?> lastNodeAtLevel = List.filled(7, null);

    for (var entry in flatList) {
      final node = TocNode(entry);
      lastNodeAtLevel[entry.level] = node;


      for (int i = entry.level + 1; i < lastNodeAtLevel.length; i++) {
        lastNodeAtLevel[i] = null;
      }


      TocNode? parent;
      for (int i = entry.level - 1; i >= 1; i--) {
        if (lastNodeAtLevel[i] != null) {
          parent = lastNodeAtLevel[i];
          break;
        }
      }

      if (parent != null) {
        parent.children.add(node);
      } else {
        roots.add(node);
      }
    }
    return roots;
  }

  @override
  Widget build(BuildContext context) {
    final skillAsync = ref.watch(skillDetailProvider(widget.skillId));

    return skillAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Loading...')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text('Error: $err')),
      ),
      data: (skill) {

        if (skill.description != null && _toc.isEmpty) {
          _parseHeaders(skill.description!);
        }

        return Scaffold(

          endDrawer: Drawer(
            width: MediaQuery.of(context).size.width * 0.75,
            child: Column(
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                  ),
                  child: Center(
                    child: Text(
                      'Table of Contents',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                    ),
                  ),
                ),
                Expanded(
                  child: _toc.isEmpty
                      ? const Center(child: Text("No sections found"))
                      : Builder(
                          builder: (context) {
                            final tree = _buildTocTree(_toc);
                            return ListView(
                              padding: EdgeInsets.zero,
                              children: tree.map((node) {
                                return _TocItem(
                                  node: node,
                                  onScrollTo: (id) {
                                    _scrollToSection(id);
                                    Navigator.pop(context);
                                  },
                                );
                              }).toList(),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          

          appBar: AppBar(
            title: const Text('Skill Details'),
            actions: [
              Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.toc),
                  tooltip: 'Table of Contents',
                  onPressed: () => Scaffold.of(context).openEndDrawer(),
                ),
              ),
            ],
          ),


          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(skill.name, style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 8),

                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: [
                    Chip(label: Text('Key: ${skill.keyAttribute}')),
                    if (skill.trainedOnly)
                      Chip(
                          label: const Text('Trained Only'),
                          backgroundColor: Theme.of(context).colorScheme.tertiaryContainer),
                    if (skill.psionic)
                      Chip(
                          label: const Text('Psionic'),
                          backgroundColor: Theme.of(context).colorScheme.tertiaryContainer),
                    if (skill.armorCheckPenalty)
                      Chip(
                          label: const Text('Armor Check Penalty'),
                          backgroundColor: Theme.of(context).colorScheme.errorContainer),
                  ],
                ),
                const Divider(height: 24),

                if (skill.description != null) ...[
                  Text('Description',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  
                  MarkdownBody(
                    data: skill.description!,
                    selectable: true,

                    builders: {
                      'h1': _HeaderKeyBuilder(_headerKeys),
                      'h2': _HeaderKeyBuilder(_headerKeys),
                      'h3': _HeaderKeyBuilder(_headerKeys),
                      'h4': _HeaderKeyBuilder(_headerKeys),
                      'h5': _HeaderKeyBuilder(_headerKeys),
                      'h6': _HeaderKeyBuilder(_headerKeys),
                    },
                    styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                      p: Theme.of(context).textTheme.bodyMedium,
                      h1: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                ],

                if (skill.bookName != null) ...[
                  const Divider(height: 32),
                  Text('Source: ${skill.bookName}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
                ],
                const SizedBox(height: 100),
              ],
            ),
          ),
        );
      },
    );
  }
}


class _HeaderKeyBuilder extends MarkdownElementBuilder {
  final Map<String, GlobalKey> keyMap;
  _HeaderKeyBuilder(this.keyMap);

  @override
  Widget? visitText(md.Text text, TextStyle? preferredStyle) {
    final String content = text.text.trim();
    if (keyMap.containsKey(content)) {
      return Container(
        key: keyMap[content], 
        child: Text(text.text, style: preferredStyle),
      );
    }
    return null;
  }
}


class _TocItem extends StatefulWidget {
  final TocNode node;
  final Function(String) onScrollTo;

  const _TocItem({
    required this.node,
    required this.onScrollTo,
  });

  @override
  State<_TocItem> createState() => _TocItemState();
}

class _TocItemState extends State<_TocItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final hasChildren = widget.node.children.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          dense: true,
          contentPadding: const EdgeInsets.only(left: 16.0, right: 8.0),
          visualDensity: const VisualDensity(vertical: -2),
          

          title: Text(
            widget.node.entry.text,
            style: hasChildren 
               ? const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)
               : Theme.of(context).textTheme.bodyMedium,
          ),
          onTap: () => widget.onScrollTo(widget.node.entry.id),


          trailing: hasChildren
              ? IconButton(
                  icon: Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                )
              : null,
        ),
        
        const Divider(height: 1, indent: 16, endIndent: 16),

        if (_isExpanded && hasChildren)
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Column(
              children: widget.node.children.map((childNode) {
                return _TocItem(
                  node: childNode,
                  onScrollTo: widget.onScrollTo,
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}