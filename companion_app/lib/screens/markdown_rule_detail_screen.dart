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
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:markdown/markdown.dart' as md;
import '../providers/combat_sheets_provider.dart';

class TocEntry {
  final String text;
  final String id;
  final int level;

  TocEntry(this.text, this.id, this.level);
}

class TocNode {
  final TocEntry entry;
  final List<TocNode> children = [];

  TocNode(this.entry);
}

class MarkdownRuleScreen extends ConsumerStatefulWidget {
  final String filePath;

  const MarkdownRuleScreen({
    super.key,
    required this.filePath,
  });

  @override
  ConsumerState<MarkdownRuleScreen> createState() => _MarkdownRuleScreenState();
}

class _MarkdownRuleScreenState extends ConsumerState<MarkdownRuleScreen> {
  final Map<String, GlobalKey> _anchorKeys = {};
  
  List<TocEntry> _toc = [];

  @override
  Widget build(BuildContext context) {
    final markdownAsync = ref.watch(combatSheetsProvider(widget.filePath));

    return markdownAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text('Error: $err')),
      ),
      data: (data) {
        if (_toc.isEmpty) {
          _toc = _generateToc(data);
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Rules'),
            actions: [
              Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.list),
                  tooltip: 'Table of Contents',
                  onPressed: () => Scaffold.of(context).openEndDrawer(),
                ),
              ),
            ],
          ),
          

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
                                    _scrollToAnchor(id);
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


          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: MarkdownBody(
              data: data,
              selectable: true,
              extensionSet: md.ExtensionSet.gitHubWeb,
              

              builders: {
                'h1': _HeaderBuilder(_anchorKeys),
                'h2': _HeaderBuilder(_anchorKeys),
                'h3': _HeaderBuilder(_anchorKeys),
              },
              

              onTapLink: (text, href, title) {
                if (href != null && href.startsWith('#')) {
                  _scrollToAnchor(href.substring(1));
                }
              },
            ),
          ),
        );
      },
    );
  }


  void _scrollToAnchor(String id) {
    final key = _anchorKeys[id];
    if (key != null && key.currentContext != null) {
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      debugPrint('Anchor #$id not found.');
    }
  }


  List<TocEntry> _generateToc(String markdownData) {
    final List<TocEntry> entries = [];
    final lines = markdownData.split('\n');
    

    final RegExp headerRegex = RegExp(r'^(#{1,6})\s+(.*)$');

    for (var line in lines) {
      final match = headerRegex.firstMatch(line);
      if (match != null) {
        final hashes = match.group(1)!;
        final text = match.group(2)!.trim();
        final level = hashes.length;
        


        String id = text.toLowerCase().replaceAll(' ', '-');
        id = id.replaceAll(RegExp(r'[^a-z0-9\-_]'), '');
        
        entries.add(TocEntry(text, id, level));
      }
    }
    return entries;
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


class _HeaderBuilder extends MarkdownElementBuilder {
  final Map<String, GlobalKey> anchorKeys;

  _HeaderBuilder(this.anchorKeys);

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final id = element.generatedId;
    if (id != null) {
      final key = GlobalKey();
      anchorKeys[id] = key;
      return SizedBox(
        key: key,
        child: Text(element.textContent, style: preferredStyle),
      );
    }
    return null;
  }
}
