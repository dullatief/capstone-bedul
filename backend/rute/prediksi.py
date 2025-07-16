from flask import Blueprint, request, jsonify
import numpy as np
import joblib
from datetime import datetime
from utilitas.database import get_db_connection
from utilitas.cuaca import get_current_temperature, koreksi_suhu_berbasis_jurnal, get_tabel_koreksi_suhu
from layanan.layanan_pencapaian import update_pencapaian_pengguna

prediksi_bp = Blueprint('prediksi', __name__)

try:
    model = joblib.load('model/model.pkl')
    le_gender = joblib.load('model/le_gender.pkl')
    le_activity = joblib.load('model/le_activity.pkl')
except FileNotFoundError:
    print("Model files not found. Some features may not work.")
    model = None
    le_gender = None
    le_activity = None

@prediksi_bp.route('/prediksi', methods=['POST'])
def prediksi():
    try:
        data = request.get_json()
        user_id = data.get('user_id')

        if not user_id:
            return jsonify({'error': 'user_id wajib disertakan'}), 400

        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute("""
            SELECT usia, berat_badan, tinggi_badan, jenis_kelamin
            FROM detail_user
            WHERE user_id = %s
            ORDER BY id DESC LIMIT 1
        """, (user_id,))
        result = cur.fetchone()

        if not result:
            cur.close()
            conn.close()
            return jsonify({'error': 'Data profil tidak ditemukan untuk user ini'}), 404

        usia, berat_badan, tinggi_badan, jenis_kelamin = result
        tingkat_aktivitas = data.get('tingkat_aktivitas')

        if not tingkat_aktivitas:
            cur.close()
            conn.close()
            return jsonify({'error': 'tingkat_aktivitas wajib diisi'}), 400

        try:
            jk_encoded = le_gender.transform([jenis_kelamin])[0]
            akt_encoded = le_activity.transform([tingkat_aktivitas])[0]
        except ValueError as e:
            cur.close()
            conn.close()
            return jsonify({'error': str(e)}), 400

        input_data = np.array([[usia, berat_badan, tinggi_badan, akt_encoded, jk_encoded]])
        prediksi = model.predict(input_data)[0]
        rekomendasi = round(prediksi, 2)

        city = "Padang"
        suhu = get_current_temperature(city)

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
        """, (user_id, usia, berat_badan, tinggi_badan, jenis_kelamin, tingkat_aktivitas, round(rekomendasi, 2)))

        conn.commit()
        
        try:
            cur.execute("""
                INSERT INTO riwayat_konsumsi (user_id, jumlah, tanggal)
                VALUES (%s, %s, %s)
            """, (user_id, round(rekomendasi, 2), datetime.now()))
            conn.commit()
            
            pencapaian_baru = update_pencapaian_pengguna(user_id, rekomendasi)
        except Exception as e:
            print(f"Error updating achievements: {e}")
            pencapaian_baru = []
        
        cur.close()
        conn.close()

        response_data = {
            'usia': usia,
            'berat_badan': berat_badan,
            'tinggi_badan': tinggi_badan,
            'jenis_kelamin': jenis_kelamin,
            'tingkat_aktivitas': tingkat_aktivitas,
            'suhu': suhu,
            'koreksi_suhu': koreksi,
            'rekomendasi_air': round(rekomendasi, 2),
            'satuan': 'liter/hari',
            'timestamp': datetime.now().isoformat(),
            'tabel_koreksi_suhu': get_tabel_koreksi_suhu()
        }
        
        if pencapaian_baru:
            response_data['pencapaian_baru'] = pencapaian_baru
        
        return jsonify(response_data), 200

    except Exception as e:
        return jsonify({'error': str(e)}), 500

@prediksi_bp.route('/riwayat-prediksi/<int:user_id>', methods=['GET'])
def riwayat_prediksi(user_id):
    try:
        conn = get_db_connection()
        cur = conn.cursor(dictionary=True)
        cur.execute("""
            SELECT tanggal, rekomendasi_air, tingkat_aktivitas
            FROM riwayat_prediksi
            WHERE user_id = %s
            ORDER BY tanggal DESC
            LIMIT 10
        """, (user_id,))
        rows = cur.fetchall()
        cur.close()
        conn.close()

        for row in rows:
            if isinstance(row['tanggal'], datetime):
                row['tanggal'] = row['tanggal'].strftime('%Y-%m-%dT%H:%M:%S')

        return jsonify(rows), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500