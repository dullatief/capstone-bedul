from flask import Blueprint, request, jsonify
from datetime import datetime
from utilitas.database import get_db_connection
from layanan.layanan_pencapaian import (
    inisialisasi_pencapaian_pengguna, 
    update_pencapaian_pengguna,
    update_streak_pengguna
)

pencapaian_bp = Blueprint('pencapaian', __name__)

@pencapaian_bp.route('/daftar-pencapaian/<int:user_id>', methods=['GET'])
def daftar_pencapaian(user_id):
    try:
        conn = get_db_connection()
        cur = conn.cursor(dictionary=True)
        
        cur.execute("SELECT COUNT(*) as jumlah FROM pencapaian_pengguna WHERE user_id = %s", (user_id,))
        hasil = cur.fetchone()
        
        if hasil['jumlah'] == 0:
            inisialisasi_pencapaian_pengguna(user_id)
        
        cur.execute("""
            SELECT 
                p.id, 
                p.judul, 
                p.deskripsi, 
                p.nama_ikon, 
                p.nilai_target, 
                p.jenis_pencapaian,
                pp.terbuka, 
                pp.progres, 
                pp.tanggal_terbuka
            FROM 
                pencapaian p
            JOIN 
                pencapaian_pengguna pp ON p.id = pp.pencapaian_id
            WHERE 
                pp.user_id = %s
            ORDER BY 
                p.jenis_pencapaian, p.nilai_target
        """, (user_id,))
        
        pencapaian = cur.fetchall()
        
        cur.execute(
            "SELECT nilai_streak, terakhir_update FROM streak_pengguna WHERE user_id = %s",
            (user_id,)
        )
        streak_data = cur.fetchone()
        
        for p in pencapaian:
            p['terbuka'] = bool(p['terbuka'])
            if p['tanggal_terbuka']:
                p['tanggal_terbuka'] = p['tanggal_terbuka'].isoformat()
        
        cur.close()
        conn.close()
        
        return jsonify({
            "pencapaian": pencapaian,
            "streak": {
                "nilai": streak_data['nilai_streak'] if streak_data else 0,
                "terakhir_update": streak_data['terakhir_update'].isoformat() if streak_data and streak_data['terakhir_update'] else None
            }
        }), 200
        
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@pencapaian_bp.route('/catat-konsumsi', methods=['POST'])
def catat_konsumsi():
    """Endpoint untuk mencatat konsumsi air dan update pencapaian"""
    try:
        data = request.get_json()
        user_id = data.get('user_id')
        jumlah_konsumsi = data.get('jumlah_konsumsi', 0)
        nama_botol = data.get('nama_botol', 'Botol')
        
        if not user_id:
            return jsonify({'error': 'User ID diperlukan'}), 400
            
        # Catat konsumsi di database
        conn = get_db_connection()
        cur = conn.cursor()
        
        cur.execute("""
            INSERT INTO riwayat_konsumsi (user_id, jumlah, tanggal)
            VALUES (%s, %s, %s)
        """, (user_id, jumlah_konsumsi, datetime.now()))
        
        conn.commit()
        
        # Update pencapaian
        pencapaian_baru = update_pencapaian_pengguna(user_id, jumlah_konsumsi)
        
        # Update streak pengguna
        update_streak_pengguna(user_id)
        
        cur.close()
        conn.close()
        
        return jsonify({
            'success': True,
            'message': f'Berhasil mencatat konsumsi {jumlah_konsumsi} liter menggunakan {nama_botol}',
            'pencapaian_baru': pencapaian_baru
        }), 200
        
    except Exception as e:
        print(f"Error in catat-konsumsi: {e}")
        return jsonify({'error': str(e)}), 500

@pencapaian_bp.route('/inisialisasi-pencapaian', methods=['POST'])
def inisialisasi_pencapaian():
    """Endpoint untuk inisialisasi daftar pencapaian di database"""
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        
        # Periksa apakah tabel pencapaian sudah memiliki data
        cur.execute("SELECT COUNT(*) FROM pencapaian")
        count = cur.fetchone()[0]
        
        if count == 0:
            # Daftar pencapaian default
            default_pencapaian = [
                # Pencapaian Total Konsumsi
                ('Tetes Pertama', 'Melakukan pencatatan konsumsi air pertama', 'water_drop', 1, 'total_konsumsi'),
                ('Pemula Hidrasi', 'Konsumsi total 10L air', 'water_glass', 10, 'total_konsumsi'),
                ('Hidrasi Reguler', 'Konsumsi total 25L air', 'water_bottle', 25, 'total_konsumsi'),
                ('Ahli Hidrasi', 'Konsumsi total 50L air', 'water_bottle_full', 50, 'total_konsumsi'),
                ('Master Hidrasi', 'Konsumsi total 100L air', 'water_waves', 100, 'total_konsumsi'),
                ('Hydration Expert', 'Konsumsi total 250L air', 'water_trophy', 250, 'total_konsumsi'),

                # Pencapaian Streak Harian
                ('Pemula Konsisten', 'Mencatat konsumsi air 3 hari berturut-turut', 'streak3', 3, 'streak_harian'),
                ('Konsisten Mingguan', 'Mencatat konsumsi air 7 hari berturut-turut', 'streak7', 7, 'streak_harian'),
                ('Konsisten 2 Minggu', 'Mencatat konsumsi air 14 hari berturut-turut', 'streak14', 14, 'streak_harian'),
                ('Konsisten Bulanan', 'Mencatat konsumsi air 30 hari berturut-turut', 'streak30', 30, 'streak_harian'),
                ('Konsistensi Tingkat Dewa', 'Mencatat konsumsi air 90 hari berturut-turut', 'streak90', 90, 'streak_harian'),

                # Pencapaian Minggu Sempurna
                ('Minggu Pertama', 'Menyelesaikan satu minggu dengan konsumsi air sesuai target setiap hari', 'perfect_week1', 1, 'minggu_sempurna'),
                ('Bulan Sempurna', 'Menyelesaikan empat minggu dengan konsumsi air sesuai target setiap hari', 'perfect_month', 4, 'minggu_sempurna'),

                # Pencapaian Jumlah Harian
                ('Tetesan Awal', 'Konsumsi 1L air dalam satu hari', 'drop_small', 1, 'jumlah_harian'),
                ('Hidrasi Standar', 'Konsumsi 2L air dalam satu hari', 'drop_medium', 2, 'jumlah_harian'),
                ('Hidrasi Plus', 'Konsumsi 3L air dalam satu hari', 'drop_large', 3, 'jumlah_harian'),
                ('Super Hidrasi', 'Konsumsi 4L air dalam satu hari', 'drop_xlarge', 4, 'jumlah_harian'),
                ('Hidrasi Ultra', 'Konsumsi 5L air dalam satu hari', 'waterfall', 5, 'jumlah_harian')
            ]
            
            # Insert into pencapaian table
            cur.executemany(
                "INSERT INTO pencapaian (judul, deskripsi, nama_ikon, nilai_target, jenis_pencapaian) VALUES (%s, %s, %s, %s, %s)",
                default_pencapaian
            )
            conn.commit()
            
        cur.close()
        conn.close()
        
        return jsonify({"pesan": "Pencapaian berhasil diinisialisasi"}), 200
        
    except Exception as e:
        return jsonify({"error": str(e)}), 500