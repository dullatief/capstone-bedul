import 'package:flutter/material.dart';

enum JenisBotol { botol, gelas, mug, lainnya }

class Botol {
  final int id;
  final String nama;
  final double ukuran;
  final Color warna;
  final JenisBotol jenis;
  final String? gambar;
  final bool isFavorite;
  final DateTime? createdAt;
  final bool isDefault;

  Botol({
    required this.id,
    required this.nama,
    required this.ukuran,
    required this.warna,
    required this.jenis,
    this.gambar,
    this.isFavorite = false,
    this.createdAt,
    required this.isDefault,
  });

  factory Botol.fromJsonDefault(Map<String, dynamic> json) {
    return Botol(
      id: json['id'],
      nama: json['nama'],
      ukuran: json['ukuran'].toDouble(),
      warna: _parseColor(json['warna']),
      jenis: _parseJenisBotol(json['jenis']),
      gambar: json['gambar'],
      isDefault: true,
    );
  }

  factory Botol.fromJsonKustom(Map<String, dynamic> json) {
    DateTime? createdAt;
    if (json['created_at'] != null) {
      try {
        createdAt = DateTime.parse(json['created_at']);
      } catch (_) {}
    }

    return Botol(
      id: json['id'],
      nama: json['nama'],
      ukuran: json['ukuran'].toDouble(),
      warna: _parseColor(json['warna']),
      jenis: _parseJenisBotol(json['jenis']),
      isFavorite: json['is_favorite'] == 1 || json['is_favorite'] == true,
      createdAt: createdAt,
      isDefault: false,
    );
  }

  static Color _parseColor(String? hexColor) {
    if (hexColor == null || !hexColor.startsWith('#')) {
      return Colors.blue;
    }

    try {
      return Color(int.parse(hexColor.substring(1, 7), radix: 16) + 0xFF000000);
    } catch (_) {
      return Colors.blue;
    }
  }

  static JenisBotol _parseJenisBotol(String? value) {
    if (value == 'gelas') return JenisBotol.gelas;
    if (value == 'mug') return JenisBotol.mug;
    if (value == 'lainnya') return JenisBotol.lainnya;
    return JenisBotol.botol;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'ukuran': ukuran,
      'warna': '#${warna.value.toRadixString(16).substring(2, 8)}',
      'jenis': _jenisBotolToString(jenis),
      'is_favorite': isFavorite,
    };
  }

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

  String get namaLengkap {
    String ukuranStr;
    if (ukuran < 1.0) {
      // Convert to ml for values less than 1L
      int ml = (ukuran * 1000).round();
      ukuranStr = '$ml ml';
    } else {
      ukuranStr = '${ukuran.toStringAsFixed(1)} L';
    }
    return '$nama ($ukuranStr)';
  }

  Botol copyWith({
    int? id,
    String? nama,
    double? ukuran,
    Color? warna,
    JenisBotol? jenis,
    String? gambar,
    bool? isFavorite,
    DateTime? createdAt,
    bool? isDefault,
  }) {
    return Botol(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      ukuran: ukuran ?? this.ukuran,
      warna: warna ?? this.warna,
      jenis: jenis ?? this.jenis,
      gambar: gambar ?? this.gambar,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
