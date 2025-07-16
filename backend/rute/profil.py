from flask import Blueprint, request, jsonify
from utilitas.database import get_db_connection

profil_bp = Blueprint('profil', __name__)

@profil_bp.route('/simpan-profil', methods=['POST'])
def simpan_profil():

    try:
        data = request.get_json()
        user_id = data.get('user_id')
        nama = data.get('nama')
        usia = data.get('usia')
        berat_badan = data.get('berat_badan') 
        tinggi_badan = data.get('tinggi_badan')  
        jenis_kelamin = data.get('jenis_kelamin')

        if not user_id:
            return jsonify({'error': 'User ID diperlukan'}), 400

        conn = get_db_connection()
        cur = conn.cursor()
        

        cur.execute("SELECT user_id FROM detail_user WHERE user_id = %s", (user_id,))
        existing = cur.fetchone()
        
        if existing:

            cur.execute("""
                UPDATE detail_user 
                SET nama = %s, usia = %s, berat_badan = %s, tinggi_badan = %s, jenis_kelamin = %s
                WHERE user_id = %s
            """, (nama, usia, berat_badan, tinggi_badan, jenis_kelamin, user_id))
            message = 'Profil berhasil diperbarui'
        else:
            cur.execute("""
                INSERT INTO detail_user (user_id, nama, usia, berat_badan, tinggi_badan, jenis_kelamin)
                VALUES (%s, %s, %s, %s, %s, %s)
            """, (user_id, nama, usia, berat_badan, tinggi_badan, jenis_kelamin))
            message = 'Profil berhasil disimpan'
            
        conn.commit()
        cur.close()
        conn.close()
        return jsonify({'message': message}), 201
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@profil_bp.route('/dapatkan-profil/<int:user_id>', methods=['GET'])
def dapatkan_profil(user_id):
    try:
        conn = get_db_connection()
        cur = conn.cursor(dictionary=True)

        cur.execute("""
            SELECT u.id, u.email, d.nama, d.usia, d.berat_badan, d.tinggi_badan, d.jenis_kelamin
            FROM users u
            LEFT JOIN detail_user d ON u.id = d.user_id
            WHERE u.id = %s
        """, (user_id,))
        user = cur.fetchone()

        cur.close()
        conn.close()

        if not user:
            return jsonify({'error': 'User tidak ditemukan'}), 404

        # Format response konsisten
        response_data = {
            'user_id': user['id'],
            'email': user['email'],
            'nama': user['nama'],
            'usia': user['usia'],
            'berat_badan': user['berat_badan'],
            'tinggi_badan': user['tinggi_badan'],
            'jenis_kelamin': user['jenis_kelamin']
        }
        
        return jsonify(response_data), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@profil_bp.route('/perbarui-profil/<int:user_id>', methods=['PUT'])
def perbarui_profil(user_id):
    """Endpoint untuk memperbarui profil pengguna"""
    try:
        data = request.get_json()
        nama = data.get('nama')
        usia = data.get('usia')
        berat_badan = data.get('berat_badan')  # Konsisten
        tinggi_badan = data.get('tinggi_badan')  # Konsisten
        jenis_kelamin = data.get('jenis_kelamin')

        conn = get_db_connection()
        cur = conn.cursor()

        # Cek apakah detail_user sudah ada
        cur.execute("SELECT user_id FROM detail_user WHERE user_id = %s", (user_id,))
        existing = cur.fetchone()
        
        if existing:
            # Update existing profile
            cur.execute("""
                UPDATE detail_user
                SET nama = %s, usia = %s, berat_badan = %s, tinggi_badan = %s, jenis_kelamin = %s
                WHERE user_id = %s
            """, (nama, usia, berat_badan, tinggi_badan, jenis_kelamin, user_id))
        else:
            # Insert new profile if doesn't exist
            cur.execute("""
                INSERT INTO detail_user (user_id, nama, usia, berat_badan, tinggi_badan, jenis_kelamin)
                VALUES (%s, %s, %s, %s, %s, %s)
            """, (user_id, nama, usia, berat_badan, tinggi_badan, jenis_kelamin))

        conn.commit()
        cur.close()
        conn.close()

        return jsonify({'message': 'Profil berhasil diperbarui'}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500