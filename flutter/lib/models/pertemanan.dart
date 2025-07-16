class Teman {
  final int id;
  final String nama;
  final String email;
  final String? fotoProfil;
  bool isProcessing;

  Teman({
    required this.id,
    required this.nama,
    required this.email,
    this.fotoProfil,
    this.isProcessing = false,
  });

  factory Teman.fromJson(Map<String, dynamic> json) {
    return Teman(
      id: json['id'],
      nama: json['nama'] ?? 'Tidak diketahui',
      email: json['email'] ?? '',
      fotoProfil: json['foto_profil'],
    );
  }
}

class Kompetisi {
  final int id;
  final String nama;
  final String deskripsi;
  final DateTime tanggalMulai;
  final DateTime tanggalSelesai;
  final String status; // 'upcoming', 'ongoing', 'completed'
  final String tipe; // 'harian', 'mingguan', 'bulanan', 'kustom'
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
    return Kompetisi(
      id: json['id'],
      nama: json['nama'],
      deskripsi: json['deskripsi'],
      tanggalMulai: DateTime.parse(json['tanggal_mulai']),
      tanggalSelesai: DateTime.parse(json['tanggal_selesai']),
      status: json['status'],
      tipe: json['tipe'],
      createdBy: json['created_by'],
      creatorName: json['creator_name'],
    );
  }
}

class KompetisiPeserta {
  final int userId;
  final String nama;
  final String? fotoProfil;
  final double totalKonsumsi;
  final double targetHarian;
  final int streakCurrent;
  final int streakBest;
  final int peringkat;
  final bool isCurrentUser;

  KompetisiPeserta({
    required this.userId,
    required this.nama,
    this.fotoProfil,
    required this.totalKonsumsi,
    required this.targetHarian,
    required this.streakCurrent,
    required this.streakBest,
    required this.peringkat,
    required this.isCurrentUser,
  });

  factory KompetisiPeserta.fromJson(Map<String, dynamic> json) {
    return KompetisiPeserta(
      userId: json['user_id'],
      nama: json['nama'],
      fotoProfil: json['foto_profil'],
      totalKonsumsi: json['total_konsumsi']?.toDouble() ?? 0.0,
      targetHarian: json['target_harian']?.toDouble() ?? 0.0,
      streakCurrent: json['streak_current'] ?? 0,
      streakBest: json['streak_best'] ?? 0,
      peringkat: json['peringkat'] ?? 0,
      isCurrentUser: json['is_current_user'] ?? false,
    );
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
