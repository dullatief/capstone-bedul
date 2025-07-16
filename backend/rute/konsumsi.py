from flask import Blueprint, request, jsonify
from datetime import datetime, timedelta
from utilitas.database import get_db_connection
from layanan.layanan_pencapaian import update_pencapaian_pengguna

konsumsi_bp = Blueprint('konsumsi', __name__)

@konsumsi_bp.route('/catat-konsumsi', methods=['POST'])
def catat_konsumsi_air():
    try:
        data = request.get_json()
        user_id = data.get('user_id')
        jumlah = data.get('jumlah')
        nama_botol = data.get('nama_botol', 'Botol')
        tanggal = data.get('tanggal', datetime.now().isoformat())
        
        if not user_id or not jumlah:
            return jsonify({'error': 'User ID dan jumlah konsumsi diperlukan'}), 400
        
        if isinstance(tanggal, str):
            tanggal = datetime.fromisoformat(tanggal.replace('Z', '+00:00'))
        
        conn = get_db_connection()
        cur = conn.cursor()
        
        # Removed 'nama_botol' field as it doesn't exist in the database schema
        cur.execute("""
            INSERT INTO riwayat_konsumsi (user_id, jumlah, tanggal)
            VALUES (%s, %s, %s)
        """, (user_id, jumlah, tanggal))
        
        konsumsi_id = cur.lastrowid
        conn.commit()
        
        pencapaian_baru = update_pencapaian_pengguna(user_id, jumlah)
        
        cur.close()
        conn.close()
        
        return jsonify({
            'success': True,
            'message': f'Berhasil mencatat konsumsi {jumlah} liter',
            'konsumsi_id': konsumsi_id,
            'pencapaian_baru': pencapaian_baru
        }), 201
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@konsumsi_bp.route('/riwayat-konsumsi/<int:user_id>', methods=['GET'])
def riwayat_konsumsi(user_id):
    try:
        hari = request.args.get('hari', 7)
        
        try:
            hari = int(hari)
        except ValueError:
            hari = 7
        
        conn = get_db_connection()
        cur = conn.cursor(dictionary=True)
        
        cur.execute("""
            SELECT id, jumlah, tanggal, nama_botol
            FROM riwayat_konsumsi 
            WHERE user_id = %s 
                AND tanggal >= DATE_SUB(CURDATE(), INTERVAL %s DAY)
            ORDER BY tanggal DESC
        """, (user_id, hari))
        
        riwayat = cur.fetchall()
        
        for r in riwayat:
            if r['tanggal']:
                r['tanggal'] = r['tanggal'].isoformat()
        
        cur.execute("""
            SELECT 
                COUNT(*) as total_catatan,
                COALESCE(SUM(jumlah), 0) as total_konsumsi,
                COALESCE(AVG(jumlah), 0) as rata_rata_harian
            FROM riwayat_konsumsi 
            WHERE user_id = %s 
                AND tanggal >= DATE_SUB(CURDATE(), INTERVAL %s DAY)
        """, (user_id, hari))
        
        statistik = cur.fetchone()
        
        cur.execute("""
            SELECT COALESCE(SUM(jumlah), 0) as konsumsi_hari_ini
            FROM riwayat_konsumsi 
            WHERE user_id = %s AND DATE(tanggal) = CURDATE()
        """, (user_id,))
        
        hari_ini = cur.fetchone()
        
        cur.close()
        conn.close()
        
        return jsonify({
            'riwayat': riwayat,
            'statistik': {
                'total_catatan': statistik['total_catatan'],
                'total_konsumsi': float(statistik['total_konsumsi']),
                'rata_rata_harian': float(statistik['rata_rata_harian']),
                'konsumsi_hari_ini': float(hari_ini['konsumsi_hari_ini'])
            }
        }), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@konsumsi_bp.route('/hapus-konsumsi/<int:konsumsi_id>', methods=['DELETE'])
def hapus_konsumsi(konsumsi_id):
    try:
        user_id = request.args.get('user_id')
        
        if not user_id:
            return jsonify({'error': 'User ID diperlukan'}), 400
        
        conn = get_db_connection()
        cur = conn.cursor()
        
        cur.execute("""
            SELECT user_id FROM riwayat_konsumsi WHERE id = %s
        """, (konsumsi_id,))
        
        result = cur.fetchone()
        if not result:
            cur.close()
            conn.close()
            return jsonify({'error': 'Konsumsi tidak ditemukan'}), 404
        
        if result[0] != int(user_id):
            cur.close()
            conn.close()
            return jsonify({'error': 'Tidak memiliki akses'}), 403
        
        # Hapus konsumsi
        cur.execute("DELETE FROM riwayat_konsumsi WHERE id = %s", (konsumsi_id,))
        conn.commit()
        
        cur.close()
        conn.close()
        
        return jsonify({'message': 'Konsumsi berhasil dihapus'}), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@konsumsi_bp.route('/edit-konsumsi/<int:konsumsi_id>', methods=['PUT'])
def edit_konsumsi(konsumsi_id):
    try:
        data = request.get_json()
        user_id = data.get('user_id')
        jumlah = data.get('jumlah')
        nama_botol = data.get('nama_botol')
        tanggal = data.get('tanggal')
        
        if not user_id:
            return jsonify({'error': 'User ID diperlukan'}), 400
        
        conn = get_db_connection()
        cur = conn.cursor()
        
        cur.execute("""
            SELECT user_id FROM riwayat_konsumsi WHERE id = %s
        """, (konsumsi_id,))
        
        result = cur.fetchone()
        if not result:
            cur.close()
            conn.close()
            return jsonify({'error': 'Konsumsi tidak ditemukan'}), 404
        
        if result[0] != int(user_id):
            cur.close()
            conn.close()
            return jsonify({'error': 'Tidak memiliki akses'}), 403
        
        # Update fields yang diberikan
        update_fields = []
        values = []
        
        if jumlah is not None:
            update_fields.append("jumlah = %s")
            values.append(jumlah)
        
        # Removed 'nama_botol' update as this field doesn't exist in the database schema
        # if nama_botol is not None:
        #     update_fields.append("nama_botol = %s")
        #     values.append(nama_botol)
        
        if tanggal is not None:
            if isinstance(tanggal, str):
                tanggal = datetime.fromisoformat(tanggal.replace('Z', '+00:00'))
            update_fields.append("tanggal = %s")
            values.append(tanggal)
        
        if not update_fields:
            cur.close()
            conn.close()
            return jsonify({'error': 'Tidak ada data yang diupdate'}), 400
        
        values.append(konsumsi_id)
        
        query = f"UPDATE riwayat_konsumsi SET {', '.join(update_fields)} WHERE id = %s"
        cur.execute(query, tuple(values))
        
        conn.commit()
        cur.close()
        conn.close()
        
        return jsonify({'message': 'Konsumsi berhasil diupdate'}), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@konsumsi_bp.route('/statistik-konsumsi/<int:user_id>', methods=['GET'])
def grafik_konsumsi(user_id):
    try:
        periode = request.args.get('periode', 'minggu')  # minggu, bulan, tahun
        
        conn = get_db_connection()
        cur = conn.cursor(dictionary=True)
        
        if periode == 'minggu':
            # Data 7 hari terakhir
            cur.execute("""
                SELECT 
                    DATE(tanggal) as tanggal,
                    COALESCE(SUM(jumlah), 0) as total_konsumsi
                FROM riwayat_konsumsi 
                WHERE user_id = %s 
                    AND tanggal >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
                GROUP BY DATE(tanggal)
                ORDER BY tanggal
            """, (user_id,))
        elif periode == 'bulan':
            # Data 30 hari terakhir per minggu
            cur.execute("""
                SELECT 
                    YEARWEEK(tanggal) as periode,
                    COALESCE(SUM(jumlah), 0) as total_konsumsi,
                    MIN(DATE(tanggal)) as tanggal_mulai,
                    MAX(DATE(tanggal)) as tanggal_akhir
                FROM riwayat_konsumsi 
                WHERE user_id = %s 
                    AND tanggal >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
                GROUP BY YEARWEEK(tanggal)
                ORDER BY periode
            """, (user_id,))
        else:  # tahun
            # Data 12 bulan terakhir
            cur.execute("""
                SELECT 
                    DATE_FORMAT(tanggal, '%%Y-%%m') as periode,
                    COALESCE(SUM(jumlah), 0) as total_konsumsi,
                    MIN(DATE(tanggal)) as tanggal_mulai,
                    MAX(DATE(tanggal)) as tanggal_akhir
                FROM riwayat_konsumsi 
                WHERE user_id = %s 
                    AND tanggal >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
                GROUP BY DATE_FORMAT(tanggal, '%%Y-%%m')
                ORDER BY periode
            """, (user_id,))
        
        data_grafik = cur.fetchall()
        
        # Format tanggal
        for item in data_grafik:
            if 'tanggal' in item and item['tanggal']:
                item['tanggal'] = item['tanggal'].isoformat()
            if 'tanggal_mulai' in item and item['tanggal_mulai']:
                item['tanggal_mulai'] = item['tanggal_mulai'].isoformat()
            if 'tanggal_akhir' in item and item['tanggal_akhir']:
                item['tanggal_akhir'] = item['tanggal_akhir'].isoformat()
            
            # Convert Decimal to float
            if 'total_konsumsi' in item:
                item['total_konsumsi'] = float(item['total_konsumsi'])
        
        cur.close()
        conn.close()
        
        return jsonify({
            'periode': periode,
            'data': data_grafik
        }), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500