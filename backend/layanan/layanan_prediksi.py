import joblib
import numpy as np
from datetime import datetime
from utilitas.database import get_db_connection
from utilitas.cuaca import dapatkan_suhu_saat_ini, koreksi_suhu_berbasis_jurnal, dapatkan_tabel_koreksi_suhu

model = joblib.load('model/model.pkl')
le_gender = joblib.load('model/le_gender.pkl')
le_activity = joblib.load('model/le_activity.pkl')

class LayananPrediksi:
    @staticmethod
    def prediksi_konsumsi_air(id_pengguna, tingkat_aktivitas):
        try:
            conn = get_db_connection()
            cur = conn.cursor()
            
            cur.execute("""
                SELECT usia, berat_badan, tinggi_badan, jenis_kelamin
                FROM detail_user
                WHERE user_id = %s
                ORDER BY id DESC LIMIT 1
            """, (id_pengguna,))
            hasil = cur.fetchone()

            if not hasil:
                raise Exception('Data profil tidak ditemukan untuk pengguna ini')

            usia, berat, tinggi, jenis_kelamin = hasil

            try:
                jk_encoded = le_gender.transform([jenis_kelamin])[0]
                akt_encoded = le_activity.transform([tingkat_aktivitas])[0]
            except ValueError as e:
                raise Exception(f'Jenis kelamin atau tingkat aktivitas tidak valid: {str(e)}')

            data_input = np.array([[usia, berat, tinggi, akt_encoded, jk_encoded]])
            prediksi = model.predict(data_input)[0]
            rekomendasi = round(prediksi, 2)

            kota = "Padang"
            suhu = dapatkan_suhu_saat_ini(kota)

            if suhu is not None:
                koreksi = koreksi_suhu_berbasis_jurnal(suhu)
                rekomendasi += koreksi
            else:
                suhu = 'Data suhu tidak tersedia'
                koreksi = 0
            cur.execute("""
                INSERT INTO riwayat_prediksi 
                (user_id, usia, berat_badan, tinggi_badan, jenis_kelamin, tingkat_aktivitas, rekomendasi_air)
                VALUES (%s, %s, %s, %s, %s, %s, %s)
            """, (id_pengguna, usia, berat, tinggi, jenis_kelamin, tingkat_aktivitas, round(rekomendasi, 2)))

            conn.commit()
            cur.close()
            conn.close()

            return {
                'usia': usia,
                'berat_badan': berat,
                'tinggi_badan': tinggi,
                'jenis_kelamin': jenis_kelamin,
                'tingkat_aktivitas': tingkat_aktivitas,
                'suhu': suhu,
                'koreksi_suhu': koreksi,
                'rekomendasi_air': round(rekomendasi, 2),
                'satuan': 'liter/hari',
                'waktu': datetime.now().isoformat(),
                'tabel_koreksi_suhu': dapatkan_tabel_koreksi_suhu()
            }

        except Exception as e:
            raise Exception(f'Error prediksi: {str(e)}')