from datetime import datetime
from utilitas.database import get_db_connection

def inisialisasi_pencapaian_pengguna(user_id):
    """Inisialisasi pencapaian untuk pengguna baru"""
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        
        # Periksa apakah pengguna sudah memiliki data pencapaian
        cur.execute("SELECT COUNT(*) FROM pencapaian_pengguna WHERE user_id = %s", (user_id,))
        count = cur.fetchone()[0]
        
        if count == 0:
            # Ambil semua ID pencapaian
            cur.execute("SELECT id FROM pencapaian")
            pencapaian_ids = cur.fetchall()
            
            # Inisialisasi data untuk setiap pencapaian
            for pencapaian_id in pencapaian_ids:
                cur.execute(
                    "INSERT INTO pencapaian_pengguna (user_id, pencapaian_id, terbuka, progres, tanggal_terbuka) "
                    "VALUES (%s, %s, FALSE, 0.0, NULL)",
                    (user_id, pencapaian_id[0])
                )
            
            # Inisialisasi streak pengguna
            cur.execute(
                "INSERT INTO streak_pengguna (user_id, nilai_streak, terakhir_update) "
                "VALUES (%s, 1, CURRENT_DATE)",
                (user_id,)
            )
            
            conn.commit()
            cur.close()
            conn.close()
            return True
        
        cur.close()
        conn.close()
        return False
        
    except Exception as e:
        print(f"Error inisialisasi pencapaian pengguna: {e}")
        return False

def update_pencapaian_pengguna(user_id, jumlah_konsumsi=0):
    """Update pencapaian pengguna berdasarkan data konsumsi air terbaru"""
    try:
        conn = get_db_connection()
        cur = conn.cursor(dictionary=True)
        
        pencapaian_baru = []  # Untuk menyimpan pencapaian yang baru terbuka
        
        # 1. Update total konsumsi
        cur.execute("""
            SELECT COALESCE(SUM(jumlah), 0) as total 
            FROM riwayat_konsumsi 
            WHERE user_id = %s
        """, (user_id,))
        hasil = cur.fetchone()
        total_konsumsi = hasil['total'] if hasil['total'] else jumlah_konsumsi
        
        # 2. Update streak harian
        # Cek apakah pengguna memiliki streak
        cur.execute(
            "SELECT nilai_streak, terakhir_update FROM streak_pengguna WHERE user_id = %s",
            (user_id,)
        )
        streak_data = cur.fetchone()
        
        nilai_streak = 1  # Default
        if streak_data:
            # Ada data streak
            terakhir_update = streak_data['terakhir_update']
            hari_ini = datetime.now().date()
            selisih_hari = (hari_ini - terakhir_update).days
            
            if selisih_hari == 0:
                # Sama hari, tidak perlu update
                nilai_streak = streak_data['nilai_streak']
            elif selisih_hari == 1:
                # Hari berurutan, tambah streak
                nilai_streak = streak_data['nilai_streak'] + 1
                cur.execute(
                    "UPDATE streak_pengguna SET nilai_streak = %s, terakhir_update = %s WHERE user_id = %s",
                    (nilai_streak, hari_ini, user_id)
                )
            else:
                # Gap lebih dari 1 hari, reset streak
                nilai_streak = 1
                cur.execute(
                    "UPDATE streak_pengguna SET nilai_streak = 1, terakhir_update = %s WHERE user_id = %s",
                    (hari_ini, user_id)
                )
        else:
            # Belum ada streak, buat baru
            cur.execute(
                "INSERT INTO streak_pengguna (user_id, nilai_streak, terakhir_update) VALUES (%s, 1, %s)",
                (user_id, datetime.now().date())
            )
        
        conn.commit()
        
        # 3. Update pencapaian total_konsumsi
        cur.execute("""
            SELECT p.id, p.judul, p.nilai_target, pp.terbuka, pp.progres 
            FROM pencapaian p
            JOIN pencapaian_pengguna pp ON p.id = pp.pencapaian_id
            WHERE pp.user_id = %s AND p.jenis_pencapaian = 'total_konsumsi' AND pp.terbuka = FALSE
        """, (user_id,))
        
        pencapaian_total = cur.fetchall()
        for p in pencapaian_total:
            progres = min(1.0, total_konsumsi / p['nilai_target'])
            terbuka = total_konsumsi >= p['nilai_target']
            
            if progres > p['progres'] or terbuka:
                tanggal_terbuka = datetime.now() if terbuka else None
                cur.execute(
                    "UPDATE pencapaian_pengguna SET progres = %s, terbuka = %s, tanggal_terbuka = %s "
                    "WHERE user_id = %s AND pencapaian_id = %s",
                    (progres, terbuka, tanggal_terbuka, user_id, p['id'])
                )
                
                if terbuka:
                    pencapaian_baru.append({
                        "id": p['id'],
                        "judul": p['judul']
                    })
        
        # 4. Update pencapaian streak_harian
        cur.execute("""
            SELECT p.id, p.judul, p.nilai_target, pp.terbuka, pp.progres 
            FROM pencapaian p
            JOIN pencapaian_pengguna pp ON p.id = pp.pencapaian_id
            WHERE pp.user_id = %s AND p.jenis_pencapaian = 'streak_harian' AND pp.terbuka = FALSE
        """, (user_id,))
        
        pencapaian_streak = cur.fetchall()
        for p in pencapaian_streak:
            progres = min(1.0, nilai_streak / p['nilai_target'])
            terbuka = nilai_streak >= p['nilai_target']
            
            if progres > p['progres'] or terbuka:
                tanggal_terbuka = datetime.now() if terbuka else None
                cur.execute(
                    "UPDATE pencapaian_pengguna SET progres = %s, terbuka = %s, tanggal_terbuka = %s "
                    "WHERE user_id = %s AND pencapaian_id = %s",
                    (progres, terbuka, tanggal_terbuka, user_id, p['id'])
                )
                
                if terbuka:
                    pencapaian_baru.append({
                        "id": p['id'],
                        "judul": p['judul']
                    })
        
        # 5. Update pencapaian jumlah_harian
        cur.execute("""
            SELECT p.id, p.judul, p.nilai_target, pp.terbuka, pp.progres 
            FROM pencapaian p
            JOIN pencapaian_pengguna pp ON p.id = pp.pencapaian_id
            WHERE pp.user_id = %s AND p.jenis_pencapaian = 'jumlah_harian' AND pp.terbuka = FALSE
        """, (user_id,))
        
        pencapaian_harian = cur.fetchall()
        
        # Hitung total konsumsi hari ini
        cur.execute("""
            SELECT COALESCE(SUM(jumlah), 0) as total_hari_ini 
            FROM riwayat_konsumsi 
            WHERE user_id = %s AND DATE(tanggal) = CURDATE()
        """, (user_id,))
        hasil_hari_ini = cur.fetchone()
        total_hari_ini = hasil_hari_ini['total_hari_ini'] if hasil_hari_ini['total_hari_ini'] else jumlah_konsumsi
        
        for p in pencapaian_harian:
            progres = min(1.0, total_hari_ini / p['nilai_target'])
            terbuka = total_hari_ini >= p['nilai_target']
            
            if progres > p['progres'] or terbuka:
                tanggal_terbuka = datetime.now() if terbuka else None
                cur.execute(
                    "UPDATE pencapaian_pengguna SET progres = %s, terbuka = %s, tanggal_terbuka = %s "
                    "WHERE user_id = %s AND pencapaian_id = %s",
                    (progres, terbuka, tanggal_terbuka, user_id, p['id'])
                )
                
                if terbuka:
                    pencapaian_baru.append({
                        "id": p['id'],
                        "judul": p['judul']
                    })
        
        conn.commit()
        cur.close()
        conn.close()
        
        return pencapaian_baru
        
    except Exception as e:
        print(f"Error updating achievements: {e}")
        return []

def update_streak_pengguna(user_id):
    """Update streak pengguna"""
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        
        # Cek streak terbaru
        cur.execute(
            "SELECT nilai_streak, terakhir_update FROM streak_pengguna WHERE user_id = %s",
            (user_id,)
        )
        streak_data = cur.fetchone()
        
        if streak_data:
            terakhir_update = streak_data[1]
            hari_ini = datetime.now().date()
            selisih_hari = (hari_ini - terakhir_update).days
            
            if selisih_hari == 1:
                # Hari berurutan, tambah streak
                nilai_streak = streak_data[0] + 1
                cur.execute(
                    "UPDATE streak_pengguna SET nilai_streak = %s, terakhir_update = %s WHERE user_id = %s",
                    (nilai_streak, hari_ini, user_id)
                )
            elif selisih_hari > 1:
                # Reset streak
                cur.execute(
                    "UPDATE streak_pengguna SET nilai_streak = 1, terakhir_update = %s WHERE user_id = %s",
                    (hari_ini, user_id)
                )
                
        conn.commit()
        cur.close()
        conn.close()
        
    except Exception as e:
        print(f"Error updating streak: {e}")