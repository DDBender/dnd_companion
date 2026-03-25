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


import 'screens/adventurer_list_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/adventurer_sheet_screen.dart';
import 'screens/feat_search_screen.dart';
import 'screens/feat_detail_screen.dart';
import 'screens/spell_search_screen.dart';
import 'screens/spell_detail_screen.dart';
import 'screens/skill_search_screen.dart';
import 'screens/skill_detail_screen.dart';
import 'screens/item_search_screen.dart';
import 'screens/item_detail_screen.dart';
import 'screens/condition_search_screen.dart';
import 'screens/condition_detail_screen.dart';
import 'screens/rule_detail_screen.dart';
import 'screens/rule_search_screen.dart';
import 'screens/path_detail_screen.dart';
import 'screens/path_search_screen.dart';
import 'screens/race_detail_screen.dart';
import 'screens/race_search_screen.dart';
import 'screens/markdown_rule_detail_screen.dart';
import 'screens/rule_list_screen.dart';
import 'providers/auth_provider.dart'; 

final routerProvider = Provider<GoRouter>((ref) {

  final authStateNotifier = ValueNotifier(ref.read(authProvider));

  ref.listen(authProvider, (_, next) {
    authStateNotifier.value = next;
  });

  return GoRouter(
    initialLocation: '/characters',
    refreshListenable: authStateNotifier,
    redirect: (context, state) {
      final authState = authStateNotifier.value;

      if (authState.isLoading) return null;

      final isLoggedIn = authState.isAuthenticated;
      final isLoggingIn = state.uri.path == '/login' || state.uri.path == '/register';

      if (!isLoggedIn && !isLoggingIn) {
        return '/login';
      }

      if (isLoggedIn && isLoggingIn) {
        return '/characters';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/characters',
        builder: (context, state) => const AdventurerListScreen(),
        routes: [
          GoRoute(
            path: '/:id',
            builder: (context, state) {
              final id = int.parse(state.pathParameters['id']!);
              return AdventurerSheetScreen(adventurerId: id);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/feats',
        builder: (context, state) => const FeatSearchScreen(),
        routes: [
          GoRoute(
            path: '/:id',
            builder: (context, state) {
              final id = int.parse(state.pathParameters['id']!);
              return FeatDetailScreen(featId: id);
            },
          ),
        ],
      ),

      GoRoute(
        path: '/items',
        builder: (context, state) => const ItemSearchScreen(),
        routes: [
          GoRoute(
            path: '/:id/:type',
            builder: (context, state) {
              final id = int.parse(state.pathParameters['id']!);
              final itemType =state.pathParameters['type']!;
              return ItemDetailScreen(itemId: id, itemType: itemType,);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/spells',
        builder: (context, state) => const SpellSearchScreen(),
        routes: [
          GoRoute(
            path: '/:id',
            builder: (context, state) {
              final id = int.parse(state.pathParameters['id']!);
              return SpellDetailScreen(spellId: id);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/conditions',
        builder: (context, state) => const ConditionSearchScreen(),
        routes: [
          GoRoute(
            path: '/:id',
            builder: (context, state) {
              final id = int.parse(state.pathParameters['id']!);
              return ConditionDetailScreen(conditionId: id);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/skills',
        builder: (context, state) => const SkillSearchScreen(),
        routes: [
          GoRoute(
            path: '/:id',
            builder: (context, state) {
              final id = int.parse(state.pathParameters['id']!);
              return SkillDetailScreen(skillId: id);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/rules',
        builder: (context, state) => const RuleSearchScreen(),
        routes: [
          GoRoute(
            path: '/:id',
            builder: (context, state) {
              final id = int.parse(state.pathParameters['id']!);
              return RuleDetailScreen(ruleId: id);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/paths',
        builder: (context, state) => const PathSearchScreen(),
        routes: [
          GoRoute(
            path: '/:id',
            builder: (context, state) {
              final id = int.parse(state.pathParameters['id']!);
              return PathDetailScreen(pathId: id);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/races',
        builder: (context, state) => const RaceSearchScreen(),
        routes: [
          GoRoute(
            path: '/:id',
            builder: (context, state) {
              final id = int.parse(state.pathParameters['id']!);
              return RaceDetailScreen(raceId: id);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/combat',
        builder: (context, state) => const RulesListScreen(),
        
      ),
      GoRoute(
        path: '/combat/view',
        builder: (context, state) {

          final filePath = state.extra as String; 
          return MarkdownRuleScreen(filePath: filePath);
        },
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
    ],
  );
});
