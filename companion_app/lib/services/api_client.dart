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
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiClient {
  final String baseUrl;
  late final Dio _dio;
  
  final SharedPreferencesAsync _prefs = SharedPreferencesAsync();

  String? _token;
  String? _role;
  int? _userId;

  ApiClient({String? baseUrl}) : baseUrl = baseUrl ?? dotenv.env['BASE_URL'] ?? 'https://default-fallback.com' {
    _dio = Dio(BaseOptions(
      baseUrl: this.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ));


    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_token != null) {
          options.headers['Authorization'] = 'Bearer $_token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        if (e.response?.statusCode == 401) {

          logout();
        }
        return handler.next(e);
      },
    ));
  }

  bool get isLoggedIn => _token != null;
  String? get role => _role;
  int? get userId => _userId;
  String? get token => _token;


  Future<void> restoreSession() async {
    _token = await _prefs.getString('auth_token');
    _role = await _prefs.getString('auth_role');
    _userId = await _prefs.getInt('auth_user_id');
  }

  Future<void> login(String username, String password) async {
    try {
      final response = await _dio.post('/api/login', data: {
        'username': username,
        'password': password,
      });

      final data = response.data;
      _token = data['token'];
      _role = data['role'];
      _userId = data['user_id'];


      if (_token != null) await _prefs.setString('auth_token', _token!);
      if (_role != null) await _prefs.setString('auth_role', _role!);
      if (_userId != null) await _prefs.setInt('auth_user_id', _userId!);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Login failed');
    }
  }

  Future<void> register(String username, String password, String email) async {
    try {
      await _dio.post('/api/register', data: {
        'username': username,
        'password': password,
        'email': email
      });
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Registration failed');
    }
  }

  Future<void> logout() async {
    _token = null;
    _role = null;
    _userId = null;
    
    await _prefs.remove('auth_token');
    await _prefs.remove('auth_role');
    await _prefs.remove('auth_user_id');
  }


  Future<dynamic> get(String endpoint) async {
    try {
      final response = await _dio.get(endpoint);
      return response.data;
    } on DioException catch (e) {
      _handleError(e);
    }
  }

  Future<dynamic> post(String endpoint, dynamic data) async {
    try {
      final response = await _dio.post(endpoint, data: data);
      return response.data;
    } on DioException catch (e) {
      _handleError(e);
    }
  }

  Future<dynamic> put(String endpoint, dynamic data) async {
    try {
      final response = await _dio.put(endpoint, data: data);
      return response.data;
    } on DioException catch (e) {
      _handleError(e);
    }
  }

  Future<dynamic> delete(String endpoint) async {
    try {
      final response = await _dio.delete(endpoint);
      return response.data;
    } on DioException catch (e) {
      _handleError(e);
    }
  }

  void _handleError(DioException e) {
    throw Exception(e.response?.data['message'] ?? e.message ?? 'API Error');
  }
}