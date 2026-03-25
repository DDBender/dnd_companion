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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../services/api_client.dart';

// 1. Provide the ApiClient
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

// 2. Define the Authentication State
class AuthState {
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;
  final String? userRole;

  const AuthState({
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
    this.userRole,
  });
}

// 3. Create the Notifier (Controller) using Notifier instead of StateNotifier
class AuthNotifier extends Notifier<AuthState> {
  late final ApiClient _apiClient;

  @override
  AuthState build() {
    _apiClient = ref.watch(apiClientProvider);
    return const AuthState();
  }

  Future<void> restoreSession() async {
    await _apiClient.restoreSession();
    if (_apiClient.isLoggedIn) {
      state = AuthState(
        isAuthenticated: true,
        userRole: _apiClient.role,
      );
    }
  }

  Future<void> login(String username, String password) async {
    state = const AuthState(isLoading: true);
    try {
      await _apiClient.login(username, password);
      state = AuthState(
        isAuthenticated: true,
        userRole: _apiClient.role,
      );
    } catch (e) {
      state = AuthState(error: e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<bool> register(String username, String password, String email) async {
    state = const AuthState(isLoading: true);
    try {
      await _apiClient.register(username, password, email);
      state = const AuthState(isLoading: false);
      return true;
    } catch (e) {
      state = AuthState(error: e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  Future<void> logout() async {
    await _apiClient.logout();
    state = const AuthState();
  }
}

// 4. Expose the Notifier via a NotifierProvider
final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
class AuthProvider extends ChangeNotifier {
  final ApiClient _apiClient;
  bool _isLoading = false;
  String? _error;

  AuthProvider(this._apiClient);

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _apiClient.isLoggedIn;
  String? get userRole => _apiClient.role;

  Future<void> restoreSession() async {
    await _apiClient.restoreSession();
    notifyListeners();
  }

  Future<void> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _apiClient.login(username, password);
    } catch (e) {
      _error = e.toString();
      // Remove "Exception: " prefix if present for cleaner display
      if (_error!.startsWith('Exception: ')) {
        _error = _error!.substring(11);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String username, String password, String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _apiClient.register(username, password, email);
      return true;
    } catch (e) {
      _error = e.toString();
      if (_error!.startsWith('Exception: ')) {
        _error = _error!.substring(11);
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _apiClient.logout();
    notifyListeners();
  }
}