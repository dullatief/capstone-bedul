from flask import Blueprint, request, jsonify
from datetime import datetime
import json
import os

donasi_bp = Blueprint('donasi', __name__)

DONATION_FILE = 'donations.json'

def load_donations():
    if os.path.exists(DONATION_FILE):
        with open(DONATION_FILE, 'r') as f:
            return json.load(f)
    return []

def save_donations(donations):
    with open(DONATION_FILE, 'w') as f:
        json.dump(donations, f, indent=2)

@donasi_bp.route('/donasi/webhook', methods=['POST'])
def webhook_handler():
    try:
        data = request.get_json()
        
        
        donations = load_donations()
        
        donation_record = {
            'order_id': data.get('order_id'),
            'transaction_status': data.get('transaction_status'),
            'payment_type': data.get('payment_type'),
            'transaction_id': data.get('transaction_id'),
            'gross_amount': data.get('gross_amount'),
            'transaction_time': data.get('transaction_time'),
            'updated_at': datetime.now().isoformat()
        }
        
        existing_index = next((i for i, d in enumerate(donations) 
                             if d['order_id'] == data.get('order_id')), None)
        
        if existing_index is not None:
            donations[existing_index].update(donation_record)
        else:
            donations.append(donation_record)
        
        save_donations(donations)
        
        return jsonify({'status': 'ok'}), 200
        
    except Exception as e:
        print(f"Webhook error: {e}")
        return jsonify({'error': str(e)}), 500

@donasi_bp.route('/donasi/status/<order_id>', methods=['GET'])
def get_donation_status(order_id):
    try:
        donations = load_donations()
        donation = next((d for d in donations if d['order_id'] == order_id), None)
        
        if donation:
            return jsonify({
                'success': True,
                'donation': donation
            }), 200
        else:
            return jsonify({
                'success': False,
                'message': 'Donation not found'
            }), 404
            
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@donasi_bp.route('/donasi/history/<user_id>', methods=['GET'])
def get_donation_history(user_id):
    try:
        donations = load_donations()
        
        return jsonify({
            'success': True,
            'donations': donations
        }), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500