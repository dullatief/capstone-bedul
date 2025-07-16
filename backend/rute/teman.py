from flask import Blueprint, request, jsonify
from datetime import datetime
from utilitas.database import get_db_connection

teman_bp = Blueprint('teman', __name__)

@teman_bp.route('/cari-teman', methods=['GET'])
def cari_teman():
    try:
        query = request.args.get('query', '').strip()
        user_id = request.args.get('user_id')
        
        if not user_id:
            return jsonify({'error': 'User ID diperlukan'}), 400
            
        if not query:
            return jsonify({'error': 'Query pencarian diperlukan'}), 400
        
        conn = get_db_connection()
        cur = conn.cursor(dictionary=True)
        
        cur.execute("""
            SELECT u.id, u.email, d.nama, d.jenis_kelamin
            FROM users u
            LEFT JOIN detail_user d ON u.id = d.user_id
            WHERE (u.email LIKE %s OR d.nama LIKE %s) 
                AND u.id != %s
            LIMIT 20
        """, (f'%{query}%', f'%{query}%', user_id))
        
        users = cur.fetchall()
        
        for user in users:
            cur.execute("""
                SELECT status FROM pertemanan 
                WHERE (user_id = %s AND friend_id = %s) 
                   OR (user_id = %s AND friend_id = %s)
            """, (user_id, user['id'], user['id'], user_id))
            
            friendship = cur.fetchone()
            if friendship:
                user['status_pertemanan'] = friendship['status']
            else:
                user['status_pertemanan'] = 'none'
        
        cur.close()
        conn.close()
        
        return jsonify({'users': users}), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@teman_bp.route('/kirim-permintaan-teman', methods=['POST'])
def kirim_permintaan_teman():
    try:
        data = request.json
        user_id = data.get('user_id')
        friend_email = data.get('friend_email')
        
        conn = get_db_connection()
        cur = conn.cursor()
        
        cur.execute("SELECT id FROM users WHERE email = %s", (friend_email,))
        friend = cur.fetchone()
        
        if not friend:
            return jsonify({'error': 'Email tidak ditemukan'}), 404
            
        friend_id = friend[0]
        
        if user_id == friend_id:
            return jsonify({'error': 'Tidak bisa menambahkan diri sendiri'}), 400
            
        cur.execute(
            "SELECT * FROM pertemanan WHERE (user_id = %s AND friend_id = %s) OR (user_id = %s AND friend_id = %s)",
            (user_id, friend_id, friend_id, user_id)
        )
        existing = cur.fetchone()
        
        if existing:
            if existing[3] == 'accepted':
                return jsonify({'error': 'Sudah berteman'}), 400
            elif existing[3] == 'pending':
                return jsonify({'error': 'Permintaan pertemanan menunggu konfirmasi'}), 400
            elif existing[3] == 'blocked':
                return jsonify({'error': 'Tidak dapat menambahkan teman ini'}), 400
                
        cur.execute(
            "INSERT INTO pertemanan (user_id, friend_id, status) VALUES (%s, %s, 'pending')",
            (user_id, friend_id)
        )
        conn.commit()
        
        
        cur.close()
        conn.close()
        
        return jsonify({'success': True, 'message': 'Permintaan pertemanan terkirim'})
        
    except Exception as e:
        print(f"Error in add-friend: {e}")
        return jsonify({'error': str(e)}), 500

@teman_bp.route('/daftar-permintaan-teman/<int:user_id>', methods=['GET'])
def daftar_permintaan_teman(user_id):
    try:
        conn = get_db_connection()
        cur = conn.cursor(dictionary=True)
        
        cur.execute("""
            SELECT p.id, p.user_id, p.created_at, 
                   u.email, d.nama, d.jenis_kelamin
            FROM pertemanan p
            JOIN users u ON p.user_id = u.id
            LEFT JOIN detail_user d ON p.user_id = d.user_id
            WHERE p.friend_id = %s AND p.status = 'pending'
            ORDER BY p.created_at DESC
        """, (user_id,))
        
        permintaan = cur.fetchall()
        
        for p in permintaan:
            if p['created_at']:
                p['created_at'] = p['created_at'].isoformat()
        
        cur.close()
        conn.close()
        
        return jsonify({'permintaan': permintaan}), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@teman_bp.route('/tanggapi-permintaan-teman', methods=['POST'])
def respon_permintaan_teman():
 
    try:
        data = request.json
        user_id = data.get('user_id')  
        requester_id = data.get('requester_id') 
        response = data.get('response') 
        
        conn = get_db_connection()
        cur = conn.cursor()
        
        if response == 'accept':
            cur.execute(
                "UPDATE pertemanan SET status = 'accepted' WHERE user_id = %s AND friend_id = %s AND status = 'pending'",
                (requester_id, user_id)
            )
            
            if cur.rowcount == 0:
                return jsonify({'error': 'Permintaan pertemanan tidak ditemukan'}), 404
                
            conn.commit()
            return jsonify({'success': True, 'message': 'Permintaan pertemanan diterima'})
            
        elif response == 'reject':
            # Update status menjadi rejected
            cur.execute(
                "UPDATE pertemanan SET status = 'rejected' WHERE user_id = %s AND friend_id = %s AND status = 'pending'",
                (requester_id, user_id)
            )
            
            if cur.rowcount == 0:
                return jsonify({'error': 'Permintaan pertemanan tidak ditemukan'}), 404
                
            conn.commit()
            return jsonify({'success': True, 'message': 'Permintaan pertemanan ditolak'})
        else:
            return jsonify({'error': 'Response tidak valid'}), 400
            
    except Exception as e:
        print(f"Error in respond-friend-request: {e}")
        return jsonify({'error': str(e)}), 500

@teman_bp.route('/daftar-teman/<int:user_id>', methods=['GET'])
def daftar_teman(user_id):
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        
        # Remove foto_profil from the query
        cur.execute("""
            SELECT u.id, du.nama, u.email
            FROM users u
            JOIN pertemanan p ON (u.id = p.friend_id OR u.id = p.user_id)
            LEFT JOIN detail_user du ON u.id = du.user_id
            WHERE ((p.user_id = %s OR p.friend_id = %s) AND p.status = 'accepted')
            AND u.id != %s
        """, (user_id, user_id, user_id))
        
        friends = []
        for row in cur.fetchall():
            friends.append({
                'id': row[0],
                'nama': row[1],
                'email': row[2],
                'foto_profil': None  # Add null foto_profil
            })
        

        cur.execute("""
            SELECT u.id, du.nama, u.email
            FROM users u
            JOIN pertemanan p ON u.id = p.user_id
            LEFT JOIN detail_user du ON u.id = du.user_id
            WHERE p.friend_id = %s AND p.status = 'pending'
        """, (user_id,))
        
        requests = []
        for row in cur.fetchall():
            requests.append({
                'id': row[0],
                'nama': row[1],
                'email': row[2],
                # Remove foto_profil from response
            })
            
        return jsonify({
            'friends': friends,
            'requests': requests
        })
    except Exception as e:
        print(f"Error getting friends: {e}")
        return jsonify({'error': str(e)}), 500

@teman_bp.route('/hapus-teman', methods=['DELETE'])
def hapus_teman():
    """Endpoint untuk menghapus pertemanan"""
    try:
        data = request.get_json()
        user_id = data.get('user_id')
        friend_id = data.get('friend_id')
        
        if not user_id or not friend_id:
            return jsonify({'error': 'User ID dan Teman ID diperlukan'}), 400
        
        conn = get_db_connection()
        cur = conn.cursor()
        
        # Hapus semua record pertemanan antara kedua user
        cur.execute("""
            DELETE FROM pertemanan 
            WHERE (user_id = %s AND friend_id = %s) 
               OR (user_id = %s AND friend_id = %s)
        """, (user_id, friend_id, friend_id, user_id))
        
        if cur.rowcount == 0:
            cur.close()
            conn.close()
            return jsonify({'error': 'Pertemanan tidak ditemukan'}), 404
        
        conn.commit()
        cur.close()
        conn.close()
        
        return jsonify({'message': 'Pertemanan berhasil dihapus'}), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@teman_bp.route('/notifikasi-pertemanan/<int:user_id>', methods=['GET'])
def notifikasi_pertemanan(user_id):
    """Endpoint untuk mendapatkan notifikasi pertemanan"""
    try:
        conn = get_db_connection()
        cur = conn.cursor(dictionary=True)
        
        # Ambil notifikasi yang belum dibaca
        cur.execute("""
            SELECT n.id, n.dari_user_id, n.pesan, n.created_at,
                   u.email, d.nama
            FROM notifikasi_pertemanan n
            JOIN users u ON n.dari_user_id = u.id
            LEFT JOIN detail_user d ON n.dari_user_id = d.user_id
            WHERE n.user_id = %s AND n.dibaca = FALSE
            ORDER BY n.created_at DESC
        """, (user_id,))
        
        notifikasi = cur.fetchall()
        
        # Format tanggal
        for n in notifikasi:
            if n['created_at']:
                n['created_at'] = n['created_at'].isoformat()
        
        cur.close()
        conn.close()
        
        return jsonify({'notifikasi': notifikasi}), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@teman_bp.route('/tandai-notifikasi-dibaca', methods=['POST'])
def tandai_notifikasi_dibaca():
    """Endpoint untuk menandai notifikasi sebagai sudah dibaca"""
    try:
        data = request.get_json()
        notifikasi_id = data.get('notifikasi_id')
        
        if not notifikasi_id:
            return jsonify({'error': 'Notifikasi ID diperlukan'}), 400
        
        conn = get_db_connection()
        cur = conn.cursor()
        
        cur.execute("""
            UPDATE notifikasi_pertemanan 
            SET dibaca = TRUE 
            WHERE id = %s
        """, (notifikasi_id,))
        
        conn.commit()
        cur.close()
        conn.close()
        
        return jsonify({'message': 'Notifikasi ditandai sebagai dibaca'}), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@teman_bp.route('/leaderboard-teman/<int:user_id>', methods=['GET'])
def leaderboard_teman(user_id):
    """Endpoint untuk mendapatkan leaderboard konsumsi air di antara teman"""
    try:
        conn = get_db_connection()
        cur = conn.cursor(dictionary=True)
        
        # Ambil daftar teman dan konsumsi mereka hari ini
        cur.execute("""
            SELECT DISTINCT
                CASE 
                    WHEN p.user_id = %s THEN p.friend_id 
                    ELSE p.user_id 
                END as friend_id,
                d.nama,
                d.jenis_kelamin
            FROM pertemanan p
            LEFT JOIN detail_user d ON (
                CASE 
                    WHEN p.user_id = %s THEN p.friend_id 
                    ELSE p.user_id 
                END = d.user_id
            )
            WHERE (p.user_id = %s OR p.friend_id = %s) 
                AND p.status = 'accepted'
        """, (user_id, user_id, user_id, user_id))
        
        teman_list = cur.fetchall()
        
        # Tambahkan user sendiri ke dalam list
        cur.execute("""
            SELECT nama, jenis_kelamin FROM detail_user WHERE user_id = %s
        """, (user_id,))
        user_data = cur.fetchone()
        
        if user_data:
            teman_list.append({
                'friend_id': user_id,
                'nama': user_data['nama'],
                'jenis_kelamin': user_data['jenis_kelamin']
            })
        
        # Ambil konsumsi hari ini untuk setiap teman
        leaderboard = []
        for teman in teman_list:
            cur.execute("""
                SELECT COALESCE(SUM(jumlah), 0) as konsumsi_hari_ini
                FROM riwayat_konsumsi 
                WHERE user_id = %s AND DATE(tanggal) = CURDATE()
            """, (teman['friend_id'],))
            
            konsumsi_result = cur.fetchone()
            konsumsi = float(konsumsi_result['konsumsi_hari_ini']) if konsumsi_result else 0.0
            
            # Ambil streak
            cur.execute("""
                SELECT nilai_streak FROM streak_pengguna WHERE user_id = %s
            """, (teman['friend_id'],))
            
            streak_result = cur.fetchone()
            streak = streak_result['nilai_streak'] if streak_result else 0
            
            leaderboard.append({
                'user_id': teman['friend_id'],
                'nama': teman['nama'] or 'User',
                'jenis_kelamin': teman['jenis_kelamin'],
                'konsumsi_hari_ini': konsumsi,
                'streak': streak,
                'is_current_user': teman['friend_id'] == user_id
            })
        
        # Sort berdasarkan konsumsi hari ini
        leaderboard.sort(key=lambda x: x['konsumsi_hari_ini'], reverse=True)
        
        # Tambahkan ranking
        for i, item in enumerate(leaderboard):
            item['ranking'] = i + 1
        
        cur.close()
        conn.close()
        
        return jsonify({'leaderboard': leaderboard}), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500