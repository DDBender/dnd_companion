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
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'router.dart';
import 'providers/startup_provider.dart';

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await dotenv.load(fileName: ".env");

  runApp(const ProviderScope(child: DatabaseCompanionApp()));
}

class DatabaseCompanionApp extends ConsumerWidget {
  const DatabaseCompanionApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final startupState = ref.watch(appStartupProvider);

    return startupState.when(

      data: (_) {
        final router = ref.watch(routerProvider);
        return MaterialApp.router(
          routerConfig: router,
          title: '3.5e Database Companion',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            useMaterial3: true,
          ),
        );
      },

      loading: () => const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      ),

      error: (e, st) => MaterialApp(
        home: Scaffold(
          body: Center(child: Text('Error: $e')),
        ),
      ),
    );
  }
}
