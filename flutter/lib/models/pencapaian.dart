enum JenisPencapaian {
  totalKonsumsi,
  streakHarian,
  mingguSempurna,
  jumlahHarian,
}

class Pencapaian {
  final int id;
  final String judul;
  final String deskripsi;
  final String namaIkon;
  final int nilaiTarget;
  final JenisPencapaian jenisPencapaian;
  final bool terbuka;
  final double progres;
  final DateTime? tanggalTerbuka;

  Pencapaian({
    required this.id,
    required this.judul,
    required this.deskripsi,
    required this.namaIkon,
    required this.nilaiTarget,
    required this.jenisPencapaian,
    this.terbuka = false,
    this.progres = 0.0,
    this.tanggalTerbuka,
  });

  factory Pencapaian.fromJson(Map<String, dynamic> json) {
    DateTime? tanggalTerbuka;
    if (json['tanggal_terbuka'] != null && json['tanggal_terbuka'] != 'null') {
      try {
        tanggalTerbuka = DateTime.parse(json['tanggal_terbuka']);
      } catch (e) {
        print('Error parsing tanggal_terbuka: $e');
      }
    }

    bool terbuka = false;
    if (json['terbuka'] is bool) {
      terbuka = json['terbuka'];
    } else if (json['terbuka'] is int) {
      terbuka = json['terbuka'] == 1;
    } else if (json['terbuka'] is String) {
      terbuka = json['terbuka'].toLowerCase() == 'true';
    }

    return Pencapaian(
      id: json['id'] ?? 0,
      judul: json['judul'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      namaIkon: json['nama_ikon'] ?? '',
      nilaiTarget: json['nilai_target'] ?? 0,
      jenisPencapaian: _parseJenisPencapaian(json['jenis_pencapaian']),
      terbuka: terbuka,
      progres: (json['progres'] ?? 0.0).toDouble(),
      tanggalTerbuka: tanggalTerbuka,
    );
  }

  static JenisPencapaian _parseJenisPencapaian(String? value) {
    if (value == null) return JenisPencapaian.totalKonsumsi;

    switch (value.toLowerCase()) {
      case 'total_konsumsi':
        return JenisPencapaian.totalKonsumsi;
      case 'streak_harian':
        return JenisPencapaian.streakHarian;
      case 'minggu_sempurna':
        return JenisPencapaian.mingguSempurna;
      case 'jumlah_harian':
        return JenisPencapaian.jumlahHarian;
      default:
        return JenisPencapaian.totalKonsumsi;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'judul': judul,
      'deskripsi': deskripsi,
      'nama_ikon': namaIkon,
      'nilai_target': nilaiTarget,
      'jenis_pencapaian': _jenisPencapaianToString(jenisPencapaian),
      'terbuka': terbuka,
      'progres': progres,
      'tanggal_terbuka': tanggalTerbuka?.toIso8601String(),
    };
  }

  static String _jenisPencapaianToString(JenisPencapaian jenis) {
    switch (jenis) {
      case JenisPencapaian.totalKonsumsi:
        return 'total_konsumsi';
      case JenisPencapaian.streakHarian:
        return 'streak_harian';
      case JenisPencapaian.mingguSempurna:
        return 'minggu_sempurna';
      case JenisPencapaian.jumlahHarian:
        return 'jumlah_harian';
    }
  }

  @override
  String toString() {
    return 'Pencapaian{id: $id, judul: $judul, terbuka: $terbuka, progres: $progres}';
  }
}

// Model untuk data streak
class StreakData {
  final int nilai;
  final String? terakhirUpdate;

  StreakData({
    required this.nilai,
    this.terakhirUpdate,
  });

  factory StreakData.fromJson(Map<String, dynamic> json) {
    return StreakData(
      nilai: json['nilai'] ?? 0,
      terakhirUpdate: json['terakhir_update'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nilai': nilai,
      'terakhir_update': terakhirUpdate,
    };
  }
}
