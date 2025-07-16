import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/botol.dart';
import '../config/api_config.dart';
import '../models/pencapaian.dart';
import '../services/pencapaian_service.dart';

class BotolService {
  static const String baseUrl = ApiConfig.baseUrl;

  static Future<List<Botol>> getBotolDefault() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.botolDefault}'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Botol.fromJsonDefault(json)).toList();
      } else {
        throw Exception(
            'Gagal memuat daftar botol default: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<List<Botol>> getBotolKustom() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId == null) {
        throw Exception('User ID tidak ditemukan');
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.botolPengguna}/$userId'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Botol.fromJsonKustom(json)).toList();
      } else {
        throw Exception(
            'Gagal memuat daftar botol kustom: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<Botol> addBotolKustom(
      String nama, double ukuran, Color warna, JenisBotol jenis) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId == null) {
        throw Exception('User ID tidak ditemukan');
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.tambahBotol}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'nama': nama,
          'ukuran': ukuran,
          'warna': '#${warna.value.toRadixString(16).substring(2, 8)}',
          'jenis': _jenisBotolToString(jenis),
        }),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        return Botol(
          id: data['id'],
          nama: nama,
          ukuran: ukuran,
          warna: warna,
          jenis: jenis,
          isFavorite: false,
          createdAt: DateTime.now(),
          isDefault: false,
        );
      } else {
        throw Exception(
            'Gagal menambahkan botol kustom: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<void> updateBotolKustom(Botol botol) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.editBotol}/${botol.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(botol.toJson()),
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Gagal memperbarui botol kustom: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<void> deleteBotolKustom(int botolId) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.hapusBotol}/$botolId'),
      );

      if (response.statusCode != 200) {
        throw Exception('Gagal menghapus botol kustom: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<List<Pencapaian>> catatKonsumsiDenganBotol(
    Botol botol, {
    double? ukuranOverride,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId == null) {
        throw Exception('User ID tidak ditemukan');
      }

      double ukuranLiter = ukuranOverride ?? botol.ukuran;

      if (ukuranLiter > 100) {
        ukuranLiter = ukuranLiter / 1000.0;
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.catatKonsumsi}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'jumlah_konsumsi': ukuranLiter,
          'nama_botol': botol.nama,
          'botol_id': botol.id
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['pencapaian_baru'] != null &&
            data['pencapaian_baru'] is List) {
          final List<dynamic> pencapaianData = data['pencapaian_baru'];
          final List<Pencapaian> pencapaianBaru =
              pencapaianData.map((item) => Pencapaian.fromJson(item)).toList();
          return pencapaianBaru;
        }

        return [];
      } else {
        return await PencapaianService.catatKonsumsi(ukuranLiter);
      }
    } catch (e) {
      debugPrint('Error mencatat konsumsi dengan botol: $e');
      try {
        final ukuran = ukuranOverride ?? botol.ukuran;
        double ukuranLiter = (ukuran > 100) ? ukuran / 1000.0 : ukuran;
        return await PencapaianService.catatKonsumsi(ukuranLiter);
      } catch (fallbackError) {
        throw Exception('Tidak dapat mencatat konsumsi: $e, $fallbackError');
      }
    }
  }

  // Helper untuk mengkonversi enum ke string
  static String _jenisBotolToString(JenisBotol jenis) {
    switch (jenis) {
      case JenisBotol.gelas:
        return 'gelas';
      case JenisBotol.mug:
        return 'mug';
      case JenisBotol.lainnya:
        return 'lainnya';
      default:
        return 'botol';
    }
  }
}
