import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pencapaian.dart';
import '../config/api_config.dart';

class PencapaianService {
  static const String baseUrl = ApiConfig.baseUrl;

  static Future<Map<String, dynamic>> getPencapaian() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId == null) {
        throw Exception('User ID tidak ditemukan');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/daftar-pencapaian/$userId'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        final List<dynamic> pencapaianData = responseData['pencapaian'] ?? [];
        final List<Pencapaian> pencapaianList =
            pencapaianData.map((json) => Pencapaian.fromJson(json)).toList();

        final Map<String, dynamic> streakData = responseData['streak'] ?? {};
        final int streakNilai = streakData['nilai'] ?? 0;
        final String? streakUpdate = streakData['terakhir_update'];

        return {
          'pencapaian': pencapaianList,
          'streak': {
            'nilai': streakNilai,
            'terakhir_update': streakUpdate,
          }
        };
      } else {
        throw Exception('Gagal memuat data pencapaian: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getPencapaian: $e');
      rethrow;
    }
  }

  static Future<List<Pencapaian>> getPencapaianTerbaru() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId == null) {
        throw Exception('User ID tidak ditemukan');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/daftar-pencapaian/$userId'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic> pencapaianData = responseData['pencapaian'] ?? [];

        final List<Pencapaian> pencapaianTerbuka = pencapaianData
            .map((json) => Pencapaian.fromJson(json))
            .where((p) => p.terbuka)
            .toList();

        return pencapaianTerbuka;
      } else {
        throw Exception('Gagal memuat pencapaian terbaru');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getProgresPencapaian() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId == null) {
        throw Exception('User ID tidak ditemukan');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/daftar-pencapaian/$userId'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic> pencapaianData = responseData['pencapaian'] ?? [];

        Map<String, List<Map<String, dynamic>>> grouped = {};
        for (var item in pencapaianData) {
          String jenis = item['jenis_pencapaian'];
          if (!grouped.containsKey(jenis)) {
            grouped[jenis] = [];
          }
          grouped[jenis]!.add(item);
        }

        return {
          'total_konsumsi': grouped['total_konsumsi'] ?? [],
          'streak_harian': grouped['streak_harian'] ?? [],
          'minggu_sempurna': grouped['minggu_sempurna'] ?? [],
          'jumlah_harian': grouped['jumlah_harian'] ?? [],
          'streak': responseData['streak'] ?? {'nilai': 0}
        };
      } else {
        throw Exception('Gagal memuat progres pencapaian');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<int> getUserStreak() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId == null) {
        throw Exception('User ID tidak ditemukan');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/daftar-pencapaian/$userId'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final Map<String, dynamic> streakData = responseData['streak'] ?? {};
        return streakData['nilai'] ?? 0;
      } else {
        throw Exception('Gagal memuat data streak');
      }
    } catch (e) {
      print('Error getting streak: $e');
      return 0; // Default streak jika terjadi error
    }
  }

  static Future<List<Pencapaian>> updatePencapaian(
      int userId, double jumlahKonsumsi) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/catat-konsumsi'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'jumlah_konsumsi': jumlahKonsumsi,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> newAchievements = data['pencapaian_baru'] ?? [];

        if (newAchievements.isNotEmpty) {
          return newAchievements
              .map((json) => Pencapaian.fromJson(json))
              .toList();
        }
        return [];
      } else {
        throw Exception('Gagal memperbarui pencapaian');
      }
    } catch (e) {
      print('Error updating pencapaian: $e');
      rethrow;
    }
  }

  static Future<List<Pencapaian>> catatKonsumsi(double jumlahKonsumsi,
      {String namaBotol = 'Botol'}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId == null) {
        throw Exception('User ID tidak ditemukan');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/catat-konsumsi'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'jumlah_konsumsi': jumlahKonsumsi,
          'nama_botol': namaBotol,
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
      }

      return [];
    } catch (e) {
      print('Error catat konsumsi: $e');
      rethrow;
    }
  }
}
