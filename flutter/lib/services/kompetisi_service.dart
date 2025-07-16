import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../config/api_config.dart';
import '../models/kompetisi.dart';
import '../services/firebase_service.dart';

class KompetisiService {
  static const String baseUrl = ApiConfig.baseUrl;

  static Future<Map<String, dynamic>> getKompetisi() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId == null) {
        throw Exception('User ID tidak ditemukan');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/kompetisis/$userId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final List<dynamic> activeData = data['active_competitions'];
        final List<Kompetisi> activeCompetitions =
            activeData.map((json) => Kompetisi.fromJson(json)).toList();

        final List<dynamic> pastData = data['past_competitions'];
        final List<Kompetisi> pastCompetitions =
            pastData.map((json) => Kompetisi.fromJson(json)).toList();

        final List<dynamic> invitationsData = data['invitations'];
        final List<KompetisiUndangan> invitations = invitationsData
            .map((json) => KompetisiUndangan.fromJson(json))
            .toList();

        return {
          'active_competitions': activeCompetitions,
          'past_competitions': pastCompetitions,
          'invitations': invitations,
        };
      } else {
        throw Exception('Gagal memuat kompetisi: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error getKompetisi: $e');
      throw Exception('Error: $e');
    }
  }

  static Future<Map<String, dynamic>> getDetailKompetisi(
      int kompetisiId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId == null) {
        throw Exception('User ID tidak ditemukan');
      }

      debugPrint(
          'Fetching competition details for ID: $kompetisiId, user: $userId');

      final response = await http.get(
        Uri.parse('$baseUrl/kompetisi/$kompetisiId?user_id=$userId'),
      );

      debugPrint('Detail response status: ${response.statusCode}');

      // Check if response body starts with <! which indicates HTML instead of JSON
      if (response.body.trim().startsWith('<!')) {
        debugPrint('Warning: Server returned HTML instead of JSON');
        throw Exception(
            'Server error: Unexpected response format. Mungkin server sedang error.');
      }

      // Print a truncated version of the response body to avoid flooding logs
      if (response.body.length > 500) {
        debugPrint(
            'Detail response body (truncated): ${response.body.substring(0, 500)}...');
      } else {
        debugPrint('Detail response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        // Try to parse the JSON response
        Map<String, dynamic> data;
        try {
          data = jsonDecode(response.body);
        } catch (e) {
          debugPrint('Failed to parse JSON: $e');
          throw Exception('Format respons tidak valid: $e');
        }

        // Parse kompetisi dengan debug
        try {
          // Try both keys to be more resilient
          final kompetisiJson = data['kompetisi'] ?? data['competition'];
          if (kompetisiJson == null) {
            throw Exception('Data kompetisi tidak ditemukan dalam respons');
          }

          final Kompetisi kompetisi = Kompetisi.fromJson(kompetisiJson);
          debugPrint('Successfully parsed competition data');

          // Parse peserta dengan debug
          final List<dynamic> leaderboardJson =
              data['peserta'] ?? data['leaderboard'] ?? [];
          final List<KompetisiPeserta> peserta = [];

          for (var item in leaderboardJson) {
            try {
              peserta.add(KompetisiPeserta.fromJson(item));
            } catch (e) {
              debugPrint('Failed to parse leaderboard item: $e');
              debugPrint('Data: $item');
            }
          }

          debugPrint('Successfully parsed ${peserta.length} participants');

          final bool isParticipant = data['is_participant'] ?? false;

          return {
            'kompetisi': kompetisi,
            'peserta': peserta,
            'is_participant': isParticipant,
          };
        } catch (e) {
          debugPrint('Error parsing competition data: $e');
          throw Exception('Format data kompetisi tidak valid: $e');
        }
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage =
            errorData['error'] ?? 'Gagal memuat detail kompetisi';
        throw Exception(
            'Gagal memuat detail kompetisi: ${response.statusCode} - $errorMessage');
      }
    } catch (e) {
      debugPrint('Error getDetailKompetisi: $e');
      throw Exception('Gagal memuat detail kompetisi: $e');
    }
  }

  static Future<int> buatKompetisi({
    required String nama,
    required String deskripsi,
    required DateTime tanggalMulai,
    required DateTime tanggalSelesai,
    required String tipe,
    required List<int> pesertaIds,
    required double targetHarian,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId == null) {
        throw Exception('User ID tidak ditemukan');
      }

      // Format tanggal dengan format yang sesuai backend
      final formatter = DateFormat('yyyy-MM-dd');
      final startDate = formatter.format(tanggalMulai);
      final endDate = formatter.format(tanggalSelesai);

      final response = await http.post(
        Uri.parse('$baseUrl/buat-kompetisi'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'nama': nama,
          'deskripsi': deskripsi,
          'tanggal_mulai': startDate,
          'tanggal_selesai': endDate,
          'tipe': tipe,
          'peserta_ids': pesertaIds,
          'target_harian': targetHarian,
        }),
      );

      debugPrint('Competition creation response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['competition_id'] ?? -1;
      } else {
        final error = jsonDecode(response.body)['error'];
        throw Exception(error ?? 'Gagal membuat kompetisi');
      }
    } catch (e) {
      debugPrint('Error creating competition: $e');
      throw Exception('Gagal membuat kompetisi: $e');
    }
  }

  static Future<Map<String, dynamic>> catatKonsumsiKompetisi(
    int kompetisiId,
    double jumlahKonsumsi,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId == null) {
        throw Exception('User ID tidak ditemukan');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/competition-track'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'kompetisi_id': kompetisiId,
          'jumlah_konsumsi': jumlahKonsumsi,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body)['error'];
        throw Exception(error ?? 'Gagal mencatat konsumsi untuk kompetisi');
      }
    } catch (e) {
      debugPrint('Error catatKonsumsiKompetisi: $e');
      throw Exception('Error: $e');
    }
  }

  static Future<bool> responUndangan(int undanganId, bool accept) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId == null) {
        throw Exception('User ID tidak ditemukan');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/respond-competition-invitation'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'invitation_id': undanganId,
          'accept': accept,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        final error = jsonDecode(response.body)['error'];
        throw Exception(error ?? 'Gagal merespons undangan kompetisi');
      }
    } catch (e) {
      debugPrint('Error responUndangan: $e');
      throw Exception('Error: $e');
    }
  }

  static Future<bool> catatKonsumsiAir({
    required int kompetisiId,
    required double jumlah,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId == null) {
        throw Exception('User ID tidak ditemukan');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/catat-konsum'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'competition_id': kompetisiId,
          'amount': jumlah,
          'recorded_at': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage =
            errorData['error'] ?? 'Gagal mencatat konsumsi air';
        throw Exception(errorMessage);
      }
    } catch (e) {
      debugPrint('Error recording water intake: $e');
      throw Exception('Gagal mencatat konsumsi air: $e');
    }
  }

  static Future<Map<String, dynamic>> catatKonsumsiKompetisiEnhanced({
    required int kompetisiId,
    required double jumlahKonsumsi,
    // Removed 'catatan' parameter as it doesn't exist in the database schema
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId == null) {
        throw Exception('User ID tidak ditemukan');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/lacak-konsumsi-kompetisi'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'kompetisi_id': kompetisiId,
          'jumlah_konsumsi': jumlahKonsumsi,
          // Removed 'catatan' field as it doesn't exist in the database schema
        }),
      );

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          // Notifikasi ke chat room kompetisi
          try {
            final userName = prefs.getString('user_name') ?? 'User';
            final chatRoomId = 'comp_$kompetisiId';

            await FirebaseService.sendWaterIntakeUpdate(
              chatRoomId,
              userName,
              jumlahKonsumsi,
              data['data']['peringkat'],
            );
          } catch (e) {
            debugPrint('Error sending chat notification: $e');
            // Tidak throw exception, karena pencatatan sudah berhasil
          }

          return data['data'];
        } else {
          throw Exception(
              data['error'] ?? 'Gagal mencatat konsumsi untuk kompetisi');
        }
      } else {
        final error = jsonDecode(response.body)['error'];
        throw Exception(error ?? 'Gagal mencatat konsumsi untuk kompetisi');
      }
    } catch (e) {
      debugPrint('Error catatKonsumsiKompetisiEnhanced: $e');
      throw Exception('Error: $e');
    }
  }
}
