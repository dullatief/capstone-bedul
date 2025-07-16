from flask import Flask, jsonify
from utilitas.database import get_db_connection
from utilitas.cuaca import get_current_temperature, koreksi_suhu_berbasis_jurnal, get_tabel_koreksi_suhu
from layanan.layanan_pencapaian import inisialisasi_pencapaian_pengguna, update_pencapaian_pengguna

from rute.autentikasi import autentikasi_bp
from rute.profil import profil_bp
from rute.prediksi import prediksi_bp
from rute.botol import botol_bp
from rute.pencapaian import pencapaian_bp
from rute.kompetisi import kompetisi_bp
from rute.konsumsi import konsumsi_bp
from rute.teman import teman_bp
from rute.donasi import donasi_bp

app = Flask(__name__)

app.register_blueprint(autentikasi_bp)
app.register_blueprint(profil_bp)
app.register_blueprint(prediksi_bp)
app.register_blueprint(botol_bp)
app.register_blueprint(pencapaian_bp)
app.register_blueprint(kompetisi_bp)
app.register_blueprint(konsumsi_bp)
app.register_blueprint(teman_bp)
app.register_blueprint(donasi_bp)

@app.route('/', methods=['GET'])
def home():
    return jsonify({
        'message': 'Prediksi Air Minum API by BEDUL',
        'version': '1.0',
        'status': 'running'
    })

@app.errorhandler(400)
def bad_request(error):
    return jsonify({'error': 'Bad request', 'message': str(error)}), 400

@app.errorhandler(404)
def not_found(error):
    return jsonify({'error': 'Not found', 'message': str(error)}), 404

@app.errorhandler(500)
def server_error(error):
    return jsonify({'error': 'Server error', 'message': str(error)}), 500

@app.errorhandler(Exception)
def handle_exception(e):
    # Log the error
    app.logger.error(f"Unhandled exception: {e}")
    # Return JSON instead of HTML
    return jsonify({
        'error': 'Server error',
        'message': str(e),
        'type': e.__class__.__name__
    }), 500

@app.after_request
def add_cors_headers(response):
    response.headers['Access-Control-Allow-Origin'] = '*'  # Allow all origins
    response.headers['Access-Control-Allow-Headers'] = 'Content-Type,Authorization'
    response.headers['Access-Control-Allow-Methods'] = 'GET,PUT,POST,DELETE,OPTIONS'
    return response

import logging
from logging.handlers import RotatingFileHandler
import os

if not os.path.exists('logs'):
    os.mkdir('logs')
    
file_handler = RotatingFileHandler('logs/app.log', maxBytes=10240, backupCount=10)
file_handler.setFormatter(logging.Formatter(
    '%(asctime)s %(levelname)s: %(message)s [in %(pathname)s:%(lineno)d]'
))
file_handler.setLevel(logging.INFO)
app.logger.addHandler(file_handler)
app.logger.setLevel(logging.INFO)
app.logger.info('HydraTrack backend startup')

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)