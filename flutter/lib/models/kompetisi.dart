import 'package:flutter/material.dart';

class Kompetisi {
  final int id;
  final String nama;
  final String deskripsi;
  final DateTime tanggalMulai;
  final DateTime tanggalSelesai;
  final String status;
  final String tipe;
  final int createdBy;
  final String creatorName;

  Kompetisi({
    required this.id,
    required this.nama,
    required this.deskripsi,
    required this.tanggalMulai,
    required this.tanggalSelesai,
    required this.status,
    required this.tipe,
    required this.createdBy,
    required this.creatorName,
  });

  factory Kompetisi.fromJson(Map<String, dynamic> json) {
    // Parse tanggal
    DateTime parseDate(String? dateStr) {
      if (dateStr == null) return DateTime.now();
      try {
        return DateTime.parse(dateStr);
      } catch (e) {
        return DateTime.now();
      }
    }

    return Kompetisi(
      id: json['id'] ?? 0,
      nama: json['nama'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      tanggalMulai: parseDate(json['tanggal_mulai']),
      tanggalSelesai: parseDate(json['tanggal_selesai']),
      status: json['status'] ?? 'ongoing',
      tipe: json['tipe'] ?? 'harian',
      createdBy: json['created_by'] ?? 0,
      creatorName: json['creator_name'] ?? 'Unknown',
    );
  }

  IconData getTipeIcon() {
    switch (tipe) {
      case 'harian':
        return Icons.today;
      case 'mingguan':
        return Icons.calendar_view_week;
      case 'bulanan':
        return Icons.calendar_month;
      case 'kustom':
        return Icons.settings;
      default:
        return Icons.emoji_events;
    }
  }

  String getStatusText() {
    switch (status) {
      case 'upcoming':
        return 'Akan Datang';
      case 'ongoing':
        return 'Sedang Berlangsung';
      case 'completed':
        return 'Selesai';
      default:
        return status;
    }
  }

  Color getStatusColor() {
    switch (status) {
      case 'upcoming':
        return Colors.orange;
      case 'ongoing':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  double getProgress() {
    if (status == 'upcoming') return 0.0;
    if (status == 'completed') return 1.0;

    final now = DateTime.now();
    final total = tanggalSelesai.difference(tanggalMulai).inSeconds;
    final current = now.difference(tanggalMulai).inSeconds;

    if (current <= 0) return 0.0;
    if (current >= total) return 1.0;

    return current / total;
  }

  int getDurationDays() {
    return tanggalSelesai.difference(tanggalMulai).inDays + 1;
  }
}

class KompetisiPeserta {
  final int userId;
  final String nama;
  final double totalKonsumsi;
  final double targetHarian;
  final int streakCurrent;
  final int streakBest;
  final int peringkat;
  final bool isCurrentUser;
  final String? fotoProfil;
  bool isProcessing;

  KompetisiPeserta({
    required this.userId,
    required this.nama,
    required this.totalKonsumsi,
    required this.targetHarian,
    required this.streakCurrent,
    required this.streakBest,
    required this.peringkat,
    required this.isCurrentUser,
    this.fotoProfil,
    this.isProcessing = false,
  });

  factory KompetisiPeserta.fromJson(Map<String, dynamic> json) {
    return KompetisiPeserta(
      userId: json['user_id'] ?? 0,
      nama: json['nama'] ?? 'User',
      totalKonsumsi: json['total_konsumsi'] != null
          ? double.tryParse(json['total_konsumsi'].toString()) ?? 0.0
          : 0.0,
      targetHarian: json['target_harian'] != null
          ? double.tryParse(json['target_harian'].toString()) ?? 0.0
          : 0.0,
      streakCurrent: json['streak_current'] ?? 0,
      streakBest: json['streak_best'] ?? 0,
      peringkat: json['peringkat'] ?? 0,
      isCurrentUser: json['is_current_user'] ?? false,
      fotoProfil: json['foto_profil'],
    );
  }

  double getTargetPercentage() {
    if (targetHarian <= 0) return 0;
    final percentage = (totalKonsumsi / targetHarian) * 100;
    return percentage > 100 ? 100 : percentage;
  }

  Color getRankColor() {
    if (peringkat == 1) return Colors.amber; // Gold
    if (peringkat == 2) return Colors.blueGrey.shade300; // Silver
    if (peringkat == 3) return Colors.brown.shade300; // Bronze

    return Colors.grey.shade600;
  }

  String getRankEmoji() {
    if (peringkat == 1) return '🏆';
    if (peringkat == 2) return '🥈';
    if (peringkat == 3) return '🥉';
    return '';
  }
}

class KompetisiUndangan {
  final int id;
  final int kompetisiId;
  final String namaKompetisi;
  final String pesan;

  KompetisiUndangan({
    required this.id,
    required this.kompetisiId,
    required this.namaKompetisi,
    required this.pesan,
  });

  factory KompetisiUndangan.fromJson(Map<String, dynamic> json) {
    return KompetisiUndangan(
      id: json['id'],
      kompetisiId: json['kompetisi_id'],
      namaKompetisi: json['nama_kompetisi'],
      pesan: json['pesan'],
    );
  }
}

class KompetisiStatistik {
  final double totalKonsumsi;
  final double rataRataHarian;
  final int totalHari;
  final int streakTerbaik;
  final List<double> dataKonsumsiHarian;

  KompetisiStatistik({
    required this.totalKonsumsi,
    required this.rataRataHarian,
    required this.totalHari,
    required this.streakTerbaik,
    required this.dataKonsumsiHarian,
  });

  factory KompetisiStatistik.fromJson(Map<String, dynamic> json) {
    return KompetisiStatistik(
      totalKonsumsi: json['total_konsumsi']?.toDouble() ?? 0.0,
      rataRataHarian: json['rata_rata_harian']?.toDouble() ?? 0.0,
      totalHari: json['total_hari'] ?? 0,
      streakTerbaik: json['streak_terbaik'] ?? 0,
      dataKonsumsiHarian: (json['data_konsumsi_harian'] as List?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [],
    );
  }
}
