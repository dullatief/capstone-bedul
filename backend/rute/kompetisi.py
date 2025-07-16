from flask import Blueprint, request, jsonify
from utilitas.database import get_db_connection
from datetime import datetime, timedelta

kompetisi_bp = Blueprint('kompetisi', __name__)


@kompetisi_bp.route('/buat-kompetisi', methods=['POST'])
def create_competition():
    try:
        data = request.get_json()
        user_id = data.get('user_id')
        nama = data.get('nama')
        deskripsi = data.get('deskripsi', '')
        tanggal_mulai = data.get('tanggal_mulai')
        tanggal_selesai = data.get('tanggal_selesai')
        tipe = data.get('tipe')
        peserta_ids = data.get('peserta_ids', [])
        target_harian = data.get('target_harian')
        
        # Validasi input
        if not all([user_id, nama, tanggal_mulai, tanggal_selesai, tipe, target_harian]):
            return jsonify({'error': 'Data tidak lengkap'}), 400
        
        # Calculate status
        today = datetime.now().date()
        start_date = datetime.strptime(tanggal_mulai, '%Y-%m-%d').date()
        end_date = datetime.strptime(tanggal_selesai, '%Y-%m-%d').date()
        
        if start_date > today:
            status = 'upcoming'
        elif end_date < today:
            status = 'completed'
        else:
            status = 'ongoing'
        
        conn = get_db_connection()
        cursor = conn.cursor()
        

        cursor.execute("""
            INSERT INTO kompetisi (nama, deskripsi, tanggal_mulai, tanggal_selesai, status, tipe, created_by)
            VALUES (%s, %s, %s, %s, %s, %s, %s)
        """, (nama, deskripsi, tanggal_mulai, tanggal_selesai, status, tipe, user_id))
        
        competition_id = cursor.lastrowid
        print(f"Created competition with ID: {competition_id}")
        
        all_participants = peserta_ids + [int(user_id)]
        all_participants = list(set(all_participants))  # Remove duplicates
        
        for participant_id in all_participants:
            cursor.execute("""
                INSERT INTO kompetisi_peserta (kompetisi_id, user_id, target_harian)
                VALUES (%s, %s, %s)
            """, (competition_id, participant_id, target_harian))
        
        conn.commit()
        cursor.close()
        conn.close()
        
        return jsonify({'success': True, 'competition_id': competition_id})
    except Exception as e:
        print(f"Error creating competition: {e}")
        return jsonify({'error': str(e)}), 500

@kompetisi_bp.route('/kompetisis/<int:user_id>', methods=['GET'])
def get_competitions(user_id):
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        
        # Active Competitions
        cur.execute("""
            SELECT k.id, k.nama, k.deskripsi, k.tanggal_mulai, k.tanggal_selesai, 
                   k.status, k.tipe, k.created_by, du.nama as creator_name
            FROM kompetisi k
            JOIN kompetisi_peserta kp ON k.id = kp.kompetisi_id
            LEFT JOIN users u ON k.created_by = u.id
            LEFT JOIN detail_user du ON k.created_by = du.user_id
            WHERE kp.user_id = %s AND k.status != 'completed'
            ORDER BY k.tanggal_mulai ASC
        """, (user_id,))
        
        active_competitions = []
        for row in cur.fetchall():
            active_competitions.append({
                'id': row[0],
                'nama': row[1],
                'deskripsi': row[2],
                'tanggal_mulai': row[3],
                'tanggal_selesai': row[4],
                'status': row[5],
                'tipe': row[6],
                'created_by': row[7],
                'creator_name': row[8] or 'Unknown', # Handle null value
            })
        
        # Past Competitions
        cur.execute("""
            SELECT k.id, k.nama, k.deskripsi, k.tanggal_mulai, k.tanggal_selesai, 
                   k.status, k.tipe, k.created_by, du.nama as creator_name
            FROM kompetisi k
            JOIN kompetisi_peserta kp ON k.id = kp.kompetisi_id
            LEFT JOIN users u ON k.created_by = u.id
            LEFT JOIN detail_user du ON k.created_by = du.user_id
            WHERE kp.user_id = %s AND k.status = 'completed'
            ORDER BY k.tanggal_selesai DESC
            LIMIT 10
        """, (user_id,))
        
        past_competitions = []
        for row in cur.fetchall():
            past_competitions.append({
                'id': row[0],
                'nama': row[1],
                'deskripsi': row[2],
                'tanggal_mulai': row[3],
                'tanggal_selesai': row[4],
                'status': row[5],
                'tipe': row[6],
                'created_by': row[7],
                'creator_name': row[8] or 'Unknown', # Handle null value
            })
        
        cur.execute("""
            SELECT kn.id, kn.kompetisi_id, k.nama, kn.pesan
            FROM kompetisi_notifikasi kn
            JOIN kompetisi k ON kn.kompetisi_id = k.id
            WHERE kn.user_id = %s AND kn.tipe = 'invitation' AND kn.dibaca = FALSE
        """, (user_id,))
        
        invitations = []
        for row in cur.fetchall():
            invitations.append({
                'id': row[0],
                'kompetisi_id': row[1],
                'nama_kompetisi': row[2],
                'pesan': row[3],
            })
        
        cur.close()
        conn.close()
        
        return jsonify({
            'active_competitions': active_competitions,
            'past_competitions': past_competitions,
            'invitations': invitations
        })
    except Exception as e:
        print(f"Error in get-competitions: {e}")
        return jsonify({'error': str(e)}), 500

@kompetisi_bp.route('/kompetisi/<int:competition_id>', methods=['GET'])
def get_competition_details(competition_id):
    """
    Get competition details including leaderboard.
    """
    print(f"API: Getting competition details for ID {competition_id}")
    
    try:
        # 1. Check user ID
        user_id = request.args.get('user_id')
        if not user_id:
            return jsonify({
                'error': 'User ID diperlukan',
                'success': False
            }), 400
            
        user_id = int(user_id)
        print(f"API: User ID {user_id} is requesting competition {competition_id}")
            
        # 2. Connect to database
        conn = get_db_connection()
        if not conn:
            return jsonify({
                'error': 'Database connection failed',
                'success': False,
                'kompetisi': None,
                'peserta': [],
                'is_participant': False
            }), 500
            
        cur = conn.cursor()
        
        try:
            cur.execute("""
                SELECT k.id, k.nama, k.deskripsi, k.tanggal_mulai, k.tanggal_selesai, 
                       k.status, k.tipe, k.created_by, du.nama as creator_name
                FROM kompetisi k
                LEFT JOIN users u ON k.created_by = u.id
                LEFT JOIN detail_user du ON k.created_by = du.user_id
                WHERE k.id = %s
            """, (competition_id,))
        
            result = cur.fetchone()
            
            if not result:
                return jsonify({
                    'error': 'Kompetisi tidak ditemukan',
                    'success': False,
                    'kompetisi': None,
                    'peserta': [],
                    'is_participant': False
                }), 404
                
            
            print(f"API: Raw competition query result: {result}")
        except Exception as db_error:
            print(f"API: Database error fetching competition: {db_error}")
            return jsonify({
                'error': f'Database error: {str(db_error)}',
                'success': False,
                'kompetisi': None,
                'peserta': [],
                'is_participant': False
            }), 500
            
        
        print(f"Raw competition result: {result}")
        
        def simple_format_date(date_val):
            if date_val is None:
                return ''
                
            # If it's already a string, return it
            if isinstance(date_val, str):
                return date_val
                
           
            try:
                if hasattr(date_val, 'strftime'):
                    return date_val.strftime('%Y-%m-%d')
                elif isinstance(date_val, (int, float)):
                   
                    from datetime import datetime
                    return datetime.fromtimestamp(date_val).strftime('%Y-%m-%d')
                else:
                  
                    return str(date_val)
            except Exception as e:
                print(f"Date formatting error: {e}, value: {date_val}, type: {type(date_val)}")
                return str(date_val)
        
        try:
            competition = {
                'id': int(result[0]) if result[0] is not None else 0,
                'nama': str(result[1]) if result[1] is not None else '',
                'deskripsi': str(result[2]) if result[2] is not None else '',
                'tanggal_mulai': simple_format_date(result[3]),
                'tanggal_selesai': simple_format_date(result[4]),
                'status': str(result[5]) if result[5] is not None else 'unknown',
                'tipe': str(result[6]) if result[6] is not None else 'unknown',
                'created_by': int(result[7]) if result[7] is not None else 0,
                'creator_name': str(result[8]) if result[8] is not None else 'Unknown',
            }
            print(f"Formatted competition data: {competition}")
        except Exception as e:
            print(f"Error formatting competition data: {e}")
            # Provide default values in case of error
            competition = {
                'id': 0,
                'nama': 'Error loading competition',
                'deskripsi': f'Error: {str(e)}',
                'tanggal_mulai': datetime.now().strftime('%Y-%m-%d'),
                'tanggal_selesai': datetime.now().strftime('%Y-%m-%d'),
                'status': 'error',
                'tipe': 'unknown',
                'created_by': 0,
                'creator_name': 'System',
            }
        cur.execute("""
            SELECT 1 FROM kompetisi_peserta WHERE kompetisi_id = %s AND user_id = %s
        """, (competition_id, user_id))
        is_participant = bool(cur.fetchone())
        
        cur.execute("""
            SELECT kp.user_id, du.nama, kp.total_konsumsi, kp.target_harian, 
                   kp.streak_current, kp.streak_best, kp.peringkat
            FROM kompetisi_peserta kp
            JOIN users u ON kp.user_id = u.id
            LEFT JOIN detail_user du ON kp.user_id = du.user_id
            WHERE kp.kompetisi_id = %s
            ORDER BY kp.total_konsumsi DESC
        """, (competition_id,))
        
        leaderboard = []
        for row in cur.fetchall():
            leaderboard.append({
                'user_id': row[0],
                'nama': row[1] if row[1] else 'User',
                'total_konsumsi': float(row[2]) if row[2] is not None else 0.0,
                'target_harian': float(row[3]) if row[3] is not None else 0.0,
                'streak_current': row[4] if row[4] is not None else 0,
                'streak_best': row[5] if row[5] is not None else 0,
                'peringkat': row[6] if row[6] is not None else 0,
                'is_current_user': row[0] == int(user_id),
                # Default nilai untuk foto_profil
                'foto_profil': None
            })
        
        print(f"Returning competition details: {competition}")
        print(f"Leaderboard has {len(leaderboard)} participants")
        
        
        return jsonify({
            'competition': competition,
            'is_participant': is_participant,
            'leaderboard': leaderboard,
           
            'kompetisi': competition,
            'peserta': leaderboard
        })
        
    except Exception as e:
        print(f"Error getting competition details: {e}")
        return jsonify({'error': str(e)}), 500
        
@kompetisi_bp.route('/lacak-kompetisi', methods=['POST'])
def track_competition_consumption():
    try:
        data = request.json
        user_id = data.get('user_id')
        kompetisi_id = data.get('kompetisi_id')
        jumlah_konsumsi = data.get('jumlah_konsumsi') 
        
        conn = get_db_connection()
        cur = conn.cursor()
        
        cur.execute("""
            SELECT k.status, kp.user_id FROM kompetisi k
            JOIN kompetisi_peserta kp ON k.id = kp.kompetisi_id
            WHERE k.id = %s AND kp.user_id = %s
        """, (kompetisi_id, user_id))
        
        result = cur.fetchone()
        if not result:
            return jsonify({'error': 'Peserta tidak terdaftar dalam kompetisi ini'}), 404
            
        if result[0] != 'ongoing':
            return jsonify({'error': f'Kompetisi tidak sedang berlangsung (status: {result[0]})'}), 400
            
       
        cur.execute("""
            INSERT INTO kompetisi_konsumsi (kompetisi_id, user_id, jumlah, tanggal)
            VALUES (%s, %s, %s, %s)
        """, (kompetisi_id, user_id, jumlah_konsumsi, datetime.now()))
        
        
        cur.execute("""
            UPDATE kompetisi_peserta 
            SET total_konsumsi = total_konsumsi + %s
            WHERE kompetisi_id = %s AND user_id = %s
        """, (jumlah_konsumsi, kompetisi_id, user_id))
        
        
        conn.commit()
        
        
        cur.execute("""
            SELECT total_konsumsi, streak_current, streak_best
            FROM kompetisi_peserta
            WHERE kompetisi_id = %s AND user_id = %s
        """, (kompetisi_id, user_id))
        
        user_data = cur.fetchone()
        
        cur.close()
        conn.close()
        
        return jsonify({
            'success': True,
            'message': 'Konsumsi air berhasil dicatat untuk kompetisi',
            'total_konsumsi': user_data[0],
            'streak_current': user_data[1],
            'streak_best': user_data[2]
        })
        
    except Exception as e:
        print(f"Error in track-competition-consumption: {e}")
        return jsonify({'error': str(e)}), 500
@kompetisi_bp.route('/catat-konsum', methods=['POST'])
def record_water_intake():
    try:
        data = request.get_json()
        user_id = data.get('user_id')
        competition_id = data.get('competition_id')
        amount = float(data.get('amount', 0))
        recorded_at = data.get('recorded_at')
        
        # Validasi input
        if not all([user_id, competition_id, amount]) or amount <= 0:
            return jsonify({'error': 'Data tidak lengkap atau tidak valid'}), 400
        
        
        try:
            if recorded_at:
                recorded_datetime = datetime.fromisoformat(recorded_at.replace('Z', '+00:00'))
            else:
                recorded_datetime = datetime.now()
        except:
            recorded_datetime = datetime.now()
            
        recorded_date = recorded_datetime.date()
            
        conn = get_db_connection()
        cursor = conn.cursor()
        
        
        cursor.execute("""
            SELECT 1 FROM kompetisi_peserta 
            WHERE kompetisi_id = %s AND user_id = %s
        """, (competition_id, user_id))
        
        if not cursor.fetchone():
            return jsonify({'error': 'User bukan peserta kompetisi ini'}), 403
        
       
        cursor.execute("""
            INSERT INTO konsumsi_air (user_id, kompetisi_id, jumlah, tanggal)
            VALUES (%s, %s, %s, %s)
        """, (user_id, competition_id, amount, recorded_date))
        
        
        cursor.execute("""
            UPDATE kompetisi_peserta 
            SET total_konsumsi = total_konsumsi + %s
            WHERE kompetisi_id = %s AND user_id = %s
        """, (amount, competition_id, user_id))
        
        
        cursor.execute("""
            SELECT user_id, total_konsumsi 
            FROM kompetisi_peserta
            WHERE kompetisi_id = %s
            ORDER BY total_konsumsi DESC
        """, (competition_id,))
        
        
        rank = 1
        for row in cursor.fetchall():
            participant_id = row[0]
            cursor.execute("""
                UPDATE kompetisi_peserta
                SET peringkat = %s
                WHERE kompetisi_id = %s AND user_id = %s
            """, (rank, competition_id, participant_id))
            rank += 1
            
       
        conn.commit()
        cursor.close()
        conn.close()
        
        return jsonify({
            'success': True, 
            'message': f'Berhasil mencatat {amount} L konsumsi air'
        })
        
    except Exception as e:
        print(f"Error recording water intake: {e}")
        return jsonify({'error': str(e)}), 500

@kompetisi_bp.route('/lacak-konsumsi-kompetisi', methods=['POST'])
def lacak_konsumsi_kompetisi():
    """
    Enhanced endpoint untuk mencatat konsumsi air untuk kompetisi.
    Fitur:
    - Validasi data input
    - Verifikasi status kompetisi
    - Mencatat konsumsi di tabel khusus
    - Update total konsumsi peserta
    - Update peringkat semua peserta
    - Update streak peserta
    - Tambahkan ke riwayat konsumsi umum pengguna
    - Cek pencapaian
    """
    try:
        data = request.get_json()
        
        # Validasi input data
        user_id = data.get('user_id')
        kompetisi_id = data.get('kompetisi_id')
        jumlah_konsumsi = data.get('jumlah_konsumsi')
        catatan = data.get('catatan', '')
        
        if not all([user_id, kompetisi_id, jumlah_konsumsi]):
            return jsonify({
                'success': False,
                'error': 'Data tidak lengkap. Diperlukan: user_id, kompetisi_id, dan jumlah_konsumsi'
            }), 400
            
        if not isinstance(jumlah_konsumsi, (int, float)) or jumlah_konsumsi <= 0:
            return jsonify({
                'success': False,
                'error': 'Jumlah konsumsi harus berupa angka positif'
            }), 400
        
        # Waktu sekarang
        timestamp = datetime.now()
        
        conn = get_db_connection()
        cur = conn.cursor(dictionary=True)
        
        # 1. Verifikasi status kompetisi dan peserta
        cur.execute("""
            SELECT k.id, k.status, k.tanggal_mulai, k.tanggal_selesai, kp.user_id, 
                   kp.total_konsumsi, kp.streak_current, kp.streak_best, kp.target_harian
            FROM kompetisi k
            JOIN kompetisi_peserta kp ON k.id = kp.kompetisi_id
            WHERE k.id = %s AND kp.user_id = %s
        """, (kompetisi_id, user_id))
        
        # Log raw database results for debugging
        print(f"SQL query results for competition check: {cur.fetchall()}")
        
        # Reset cursor position
        cur.execute("""
            SELECT k.id, k.status, k.tanggal_mulai, k.tanggal_selesai, kp.user_id, 
                   kp.total_konsumsi, kp.streak_current, kp.streak_best, kp.target_harian
            FROM kompetisi k
            JOIN kompetisi_peserta kp ON k.id = kp.kompetisi_id
            WHERE k.id = %s AND kp.user_id = %s
        """, (kompetisi_id, user_id))
        
        result = cur.fetchone()
        if not result:
            return jsonify({
                'success': False,
                'error': 'Peserta tidak terdaftar dalam kompetisi ini'
            }), 404
            
        if result['status'] != 'ongoing':
            return jsonify({
                'success': False,
                'error': f'Kompetisi tidak sedang berlangsung (status: {result["status"]})'
            }), 400
        
        # 2. Catat konsumsi dalam tabel kompetisi_konsumsi
        cur.execute("""
            INSERT INTO kompetisi_konsumsi 
                (kompetisi_id, user_id, jumlah, tanggal) 
            VALUES (%s, %s, %s, %s)
        """, (kompetisi_id, user_id, jumlah_konsumsi, timestamp))
        
        konsumsi_id = cur.lastrowid
        
        # 3. Update total konsumsi peserta
        try:
            new_total = float(result['total_konsumsi']) + float(jumlah_konsumsi)
        except (TypeError, ValueError) as e:
            print(f"Error calculating new total: {e}, using default")
            new_total = float(jumlah_konsumsi)  # Default to just this consumption
        
        # 4. Update streak jika perlu
        try:
            today = timestamp.date()
            yesterday = today - timedelta(days=1)
        except Exception as e:
            print(f"Error with date calculation: {e}, using current date")
            from datetime import date
            today = date.today()
            yesterday = today - timedelta(days=1)
        
        cur.execute("""
            SELECT MAX(DATE(tanggal)) as last_activity
            FROM kompetisi_konsumsi
            WHERE kompetisi_id = %s AND user_id = %s AND DATE(tanggal) != %s
        """, (kompetisi_id, user_id, today))
        
        last_activity = cur.fetchone()
        
        streak_current = result['streak_current']
        streak_best = result['streak_best']
        
        # Jika belum ada aktivitas hari ini
        if last_activity and last_activity['last_activity']:
            last_date = last_activity['last_activity']
            
            if last_date == yesterday:
                # Streak berlanjut
                streak_current += 1
                if streak_current > streak_best:
                    streak_best = streak_current
            elif last_date != today:
                # Streak terputus
                streak_current = 1
        else:
            # Aktivitas pertama
            streak_current = 1
        
        # 5. Update data peserta dengan nilai baru
        cur.execute("""
            UPDATE kompetisi_peserta 
            SET total_konsumsi = %s, streak_current = %s, streak_best = %s
            WHERE kompetisi_id = %s AND user_id = %s
        """, (new_total, streak_current, streak_best, kompetisi_id, user_id))
        
        # 6. Update peringkat semua peserta
        cur.execute("""
            SELECT user_id FROM kompetisi_peserta
            WHERE kompetisi_id = %s
            ORDER BY total_konsumsi DESC
        """, (kompetisi_id,))
        
        participants = cur.fetchall()
        for i, participant in enumerate(participants):
            rank = i + 1
            cur.execute("""
                UPDATE kompetisi_peserta
                SET peringkat = %s
                WHERE kompetisi_id = %s AND user_id = %s
            """, (rank, kompetisi_id, participant['user_id']))
        
        # 7. Tambahkan ke riwayat konsumsi umum pengguna
        
        cur.execute("""
            INSERT INTO riwayat_konsumsi 
                (user_id, jumlah, tanggal)
            VALUES (%s, %s, %s)
        """, (user_id, jumlah_konsumsi, timestamp))
        
        riwayat_id = cur.lastrowid
        
        # 8. Update pencapaian pengguna
        from layanan.layanan_pencapaian import update_pencapaian_pengguna
        pencapaian_baru = update_pencapaian_pengguna(user_id, jumlah_konsumsi)
        
        # 9. Commit perubahan
        conn.commit()
        
        # 10. Ambil data terbaru untuk respons
        cur.execute("""
            SELECT total_konsumsi, target_harian, streak_current, streak_best, peringkat
            FROM kompetisi_peserta
            WHERE kompetisi_id = %s AND user_id = %s
        """, (kompetisi_id, user_id))
        
        updated_data = cur.fetchone()
        
        # 11. Tutup koneksi
        cur.close()
        conn.close()
        
        # Calculate percentage safely
        persentase = 0
        if updated_data and updated_data.get('target_harian', 0) > 0:
            persentase = min(100, (updated_data.get('total_konsumsi', 0) / updated_data.get('target_harian', 1)) * 100)
        
        # 12. Return success response - ensuring all values are of the expected type
        response_data = {
            'success': True,
            'message': 'Konsumsi air berhasil dicatat untuk kompetisi',
            'data': {
                'konsumsi_id': konsumsi_id or 0,
                'riwayat_id': riwayat_id or 0,
                'jumlah_konsumsi': float(jumlah_konsumsi),
                'total_konsumsi': float(updated_data.get('total_konsumsi', 0)) if updated_data else 0,
                'target_harian': float(updated_data.get('target_harian', 0)) if updated_data else 0,
                'persentase': float(persentase),
                'streak_current': int(updated_data.get('streak_current', 0)) if updated_data else 0,
                'streak_best': int(updated_data.get('streak_best', 0)) if updated_data else 0,
                'peringkat': int(updated_data.get('peringkat', 0)) if updated_data else 0,
                'pencapaian_baru': pencapaian_baru or []
            }
        }
        
        # Log the response for debugging
        print(f"Response data for competition consumption: {response_data}")
        
        return jsonify(response_data), 200
        
    except Exception as e:
        print(f"Error in lacak_konsumsi_kompetisi: {e}")
        import traceback
        traceback.print_exc()
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500