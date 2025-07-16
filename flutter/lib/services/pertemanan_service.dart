import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/pertemanan.dart';

class PertemananService {
  static const String baseUrl = ApiConfig.baseUrl;

  static Future<List<Teman>> getDaftarTeman() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId == null) {
        throw Exception('User ID tidak ditemukan');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/daftar-teman/$userId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> friendsData = data['friends'];
        return friendsData.map((json) => Teman.fromJson(json)).toList();
      } else {
        throw Exception('Gagal memuat daftar teman: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error getting friends: $e');
      throw Exception('Error: $e');
    }
  }

  static Future<List<Teman>> getPermintaanPertemanan() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId == null) {
        throw Exception('User ID tidak ditemukan');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/daftar-teman/$userId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final List<dynamic> requestsData = data['requests'] ?? [];

        return requestsData
            .map((json) => Teman(
                  id: json['id'],
                  nama: json['nama'] ?? 'Tidak diketahui',
                  email: json['email'] ?? 'Tidak ada email',
                  fotoProfil: json['foto_profil'],
                ))
            .toList();
      } else {
        throw Exception(
            'Gagal memuat permintaan pertemanan: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error getting friend requests: $e');
      return [];
    }
  }

  static Future<bool> tambahTeman(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId == null) {
        throw Exception('User ID tidak ditemukan');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/kirim-permintaan-teman'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'friend_email': email,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        final error = jsonDecode(response.body)['error'];
        throw Exception(error ?? 'Gagal menambahkan teman');
      }
    } catch (e) {
      debugPrint('Error adding friend: $e');
      throw Exception('Error: $e');
    }
  }

  static Future<bool> responPermintaanPertemanan(
      int friendId, bool accept) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId == null) {
        throw Exception('User ID tidak ditemukan');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/tanggapi-permintaan-teman'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'requester_id': friendId,
          'response': accept ? 'accept' : 'reject'
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
            errorData['error'] ?? 'Gagal merespons permintaan pertemanan');
      }
    } catch (e) {
      debugPrint('Error responding to friend request: $e');
      throw e;
    }
  }
}
