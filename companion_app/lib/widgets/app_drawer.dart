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
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart'; 

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
  child: ListView(
    padding: EdgeInsets.zero,
    children: [
      DrawerHeader(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              '3.5e Companion',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '3.5e Database',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.8),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
      ListTile(
        leading: const Icon(Icons.person),
        title: const Text('My Adventurers'),
        onTap: () {

          Navigator.pop(context);
          context.go('/');
        },
      ),
      const Divider(),
      const Padding(
        padding: EdgeInsets.only(left: 16, top: 8, bottom: 8),
        child: Text('Compendium', style: TextStyle(color: Colors.grey)),
      ),
      ListTile(

        leading: const Icon(Icons.healing), 
        title: const Text('Conditions'),
        onTap: () {
          Navigator.pop(context);
          context.go('/conditions');
        },
      ),
      ListTile(

        leading: const Icon(Icons.shield), 
        title: const Text('Classes'),
        onTap: () {
          Navigator.pop(context);
          context.go('/paths');
        },
      ),
      ListTile(

        leading: const Icon(Icons.workspace_premium), 
        title: const Text('Feats'),
        onTap: () {
          Navigator.pop(context);
          context.go('/feats');
        },
      ),
      ListTile(

        leading: const Icon(Icons.backpack),
        title: const Text('Items'),
        onTap: () {
          Navigator.pop(context);
          context.go('/items');
        },
      ),
      ListTile(

        leading: const Icon(Icons.face), 
        title: const Text('Races'),
        onTap: () {
          Navigator.pop(context);
          context.go('/races');
        },
      ),
      ListTile(

        leading: const Icon(Icons.gavel), 
        title: const Text('Rules'),
        onTap: () {
          Navigator.pop(context);
          context.go('/rules');
        },
      ),
      ListTile(

        leading: const Icon(Icons.handyman), 
        title: const Text('Skills'),
        onTap: () {
          Navigator.pop(context);
          context.go('/skills');
        },
      ),
      ListTile(

        leading: const Icon(Icons.auto_awesome), 
        title: const Text('Spells'),
        onTap: () {
          Navigator.pop(context);
          context.go('/spells');
        },
      ),
      ListTile(

        leading: const Icon(Icons.auto_awesome), 
        title: const Text('Combat'),
        onTap: () {
          Navigator.pop(context);
          context.go('/combat');
        },
      ),
      const Divider(),
      ListTile(
        leading: const Icon(Icons.logout),
        title: const Text('Logout'),
        onTap: () {
          Navigator.pop(context);
          ref.read(authProvider.notifier).logout();
        },
      ),
    ],
  ),
);

  }
}
