from flask import Blueprint, request, jsonify
from utilitas.database import get_db_connection

botol_bp = Blueprint('botol', __name__)

@botol_bp.route('/botol-default', methods=['GET'])
def botol_default():
    try:
        conn = get_db_connection()
        cur = conn.cursor(dictionary=True)
        
        cur.execute("SELECT * FROM botol_default")
        botol_list = cur.fetchall()
        
        cur.close()
        conn.close()
        
        return jsonify(botol_list), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@botol_bp.route('/botol-pengguna/<int:user_id>', methods=['GET'])
def botol_pengguna(user_id):
    try:
        conn = get_db_connection()
        cur = conn.cursor(dictionary=True)
        
        cur.execute("""
            SELECT * FROM botol_kustom 
            WHERE user_id = %s
            ORDER BY is_favorite DESC, created_at DESC
        """, (user_id,))
        botol_list = cur.fetchall()
        
        # Format datetime
        for botol in botol_list:
            if 'created_at' in botol and botol['created_at']:
                botol['created_at'] = botol['created_at'].isoformat()
        
        cur.close()
        conn.close()
        
        return jsonify(botol_list), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@botol_bp.route('/tambah-botol', methods=['POST'])
def tambah_botol():
    try:
        data = request.get_json()
        user_id = data.get('user_id')
        nama = data.get('nama')
        ukuran = data.get('ukuran')  # dalam liter
        warna = data.get('warna', '#2196F3')
        jenis = data.get('jenis', 'botol')
        
        if not all([user_id, nama, ukuran]):
            return jsonify({"error": "Data tidak lengkap"}), 400
        
        conn = get_db_connection()
        cur = conn.cursor()
        
        cur.execute("""
            INSERT INTO botol_kustom (user_id, nama, ukuran, warna, jenis)
            VALUES (%s, %s, %s, %s, %s)
        """, (user_id, nama, ukuran, warna, jenis))
        
        conn.commit()
        botol_id = cur.lastrowid
        
        cur.close()
        conn.close()
        
        return jsonify({
            "message": "Botol kustom berhasil ditambahkan",
            "id": botol_id
        }), 201
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@botol_bp.route('/edit-botol/<int:botol_id>', methods=['PUT'])
def edit_botol(botol_id):
    try:
        data = request.get_json()
        nama = data.get('nama')
        ukuran = data.get('ukuran')
        warna = data.get('warna')
        jenis = data.get('jenis')
        is_favorite = data.get('is_favorite')
        
        conn = get_db_connection()
        cur = conn.cursor()
        
        update_fields = []
        values = []
        
        if nama is not None:
            update_fields.append("nama = %s")
            values.append(nama)
        
        if ukuran is not None:
            update_fields.append("ukuran = %s")
            values.append(ukuran)
            
        if warna is not None:
            update_fields.append("warna = %s")
            values.append(warna)
            
        if jenis is not None:
            update_fields.append("jenis = %s")
            values.append(jenis)
            
        if is_favorite is not None:
            update_fields.append("is_favorite = %s")
            values.append(is_favorite)
        
        if not update_fields:
            return jsonify({"error": "Tidak ada data yang diupdate"}), 400
        
        values.append(botol_id)
        
        query = f"UPDATE botol_kustom SET {', '.join(update_fields)} WHERE id = %s"
        cur.execute(query, tuple(values))
        
        conn.commit()
        cur.close()
        conn.close()
        
        return jsonify({
            "message": "Botol kustom berhasil diupdate",
            "id": botol_id
        }), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@botol_bp.route('/hapus-botol/<int:botol_id>', methods=['DELETE'])
def hapus_botol(botol_id):
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        
        cur.execute("SELECT COUNT(*) FROM botol_kustom WHERE id = %s", (botol_id,))
        count = cur.fetchone()[0]
        
        if count == 0:
            cur.close()
            conn.close()
            return jsonify({"error": "Botol tidak ditemukan"}), 404
        
        cur.execute("DELETE FROM botol_kustom WHERE id = %s", (botol_id,))
        conn.commit()
        
        cur.close()
        conn.close()
        
        return jsonify({
            "message": "Botol kustom berhasil dihapus"
        }), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500
