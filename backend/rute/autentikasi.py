from flask import Blueprint, request, jsonify
from werkzeug.security import generate_password_hash, check_password_hash
from utilitas.database import get_db_connection
from layanan.layanan_pencapaian import inisialisasi_pencapaian_pengguna

autentikasi_bp = Blueprint('autentikasi', __name__)

@autentikasi_bp.route('/daftar', methods=['POST'])
def daftar():
    try:
        data = request.get_json()
        email = data.get('email')
        password = data.get('password')
        nama = data.get('nama')
        usia = data.get('usia')
        berat_badan = data.get('berat_badan')  
        tinggi_badan = data.get('tinggi_badan') 
        jenis_kelamin = data.get('jenis_kelamin')

        if not email or not password:
            return jsonify({'error': 'Email dan password wajib diisi'}), 400

        hashed = generate_password_hash(password)

        conn = get_db_connection()
        cur = conn.cursor()
        
        cur.execute("SELECT id FROM users WHERE email = %s", (email,))
        if cur.fetchone():
            cur.close()
            conn.close()
            return jsonify({'error': 'Email sudah terdaftar'}), 400
        
        cur.execute("INSERT INTO users (email, password) VALUES (%s, %s)", (email, hashed))
        user_id = cur.lastrowid
        
        if all([nama, usia, berat_badan, tinggi_badan, jenis_kelamin]):
            cur.execute("""
                INSERT INTO detail_user (user_id, nama, usia, berat_badan, tinggi_badan, jenis_kelamin)
                VALUES (%s, %s, %s, %s, %s, %s)
            """, (user_id, nama, usia, berat_badan, tinggi_badan, jenis_kelamin))
        
        conn.commit()
        cur.close()
        conn.close()
        
        inisialisasi_pencapaian_pengguna(user_id)
        
        return jsonify({'message': 'Registrasi berhasil', 'user_id': user_id}), 201
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@autentikasi_bp.route('/masuk', methods=['POST'])
def masuk():
    try:
        data = request.get_json()
        email = data.get('email')
        password = data.get('password')

        if not email or not password:
            return jsonify({'error': 'Email dan password wajib diisi'}), 400

        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute("SELECT id, password FROM users WHERE email = %s", (email,))
        result = cur.fetchone()
        cur.close()
        conn.close()

        if result and check_password_hash(result[1], password):
            return jsonify({'message': 'Login berhasil', 'user_id': result[0]}), 200
        return jsonify({'error': 'Email atau password salah'}), 401
    except Exception as e:
        return jsonify({'error': str(e)}), 500