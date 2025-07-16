import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/midtrans_config.dart';
import '../models/donasi.dart';

class DonasiService {
  static String _generateOrderId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(9999);
    return 'DONASI-$timestamp-$random';
  }

  static Future<Map<String, dynamic>> createDonation({
    required int amount,
    required String donorName,
    String? message,
    String? email,
  }) async {
    try {
      final orderId = _generateOrderId();
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (amount < 1000) {
        throw Exception('Minimum donasi adalah Rp 1.000');
      }

      final requestBody = {
        'transaction_details': {
          'order_id': orderId,
          'gross_amount': amount,
        },
        'customer_details': {
          'first_name': donorName.isNotEmpty ? donorName : 'Donatur',
          'email': email?.isNotEmpty == true ? email : 'donor@example.com',
          'phone': '08123456789',
        },
        'item_details': [
          {
            'id': 'donation',
            'price': amount,
            'quantity': 1,
            'name': 'Donasi untuk Developer Prediksi Air Minum',
            'brand': 'Bedull',
            'category': 'Donation',
          }
        ],
        'custom_field1': message ?? '',
        'custom_field2': userId?.toString() ?? '',
        'custom_field3': 'donation_support',
      };

      print(
          'Creating donation transaction with body: ${jsonEncode(requestBody)}');

      final response = await http.post(
        Uri.parse('${MidtransConfig.snapUrl}/transactions'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization':
              'Basic ${base64Encode(utf8.encode('${MidtransConfig.serverKey}:'))}',
        },
        body: jsonEncode(requestBody),
      );

      print('Midtrans response status: ${response.statusCode}');
      print('Midtrans response body: ${response.body}');

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        await _saveTransactionLocally(orderId, amount, donorName, message);

        return {
          'success': true,
          'order_id': orderId,
          'snap_token': responseData['token'],
          'redirect_url': responseData['redirect_url'],
        };
      } else {
        final errorData = jsonDecode(response.body);
        print('Midtrans error: $errorData');
        throw Exception(errorData['error_messages']?.join(', ') ??
            'Gagal membuat transaksi donasi');
      }
    } catch (e) {
      print('Error creating donation: $e');
      throw Exception('Gagal membuat donasi: $e');
    }
  }

  static Future<void> _saveTransactionLocally(
      String orderId, int amount, String donorName, String? message) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final transactions = prefs.getStringList('donation_transactions') ?? [];

      final transaction = {
        'order_id': orderId,
        'amount': amount,
        'donor_name': donorName,
        'message': message,
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      };

      transactions.add(jsonEncode(transaction));
      await prefs.setStringList('donation_transactions', transactions);
    } catch (e) {
      print('Error saving transaction locally: $e');
    }
  }

  static Future<Map<String, dynamic>> checkTransactionStatus(
      String orderId) async {
    try {
      final response = await http.get(
        Uri.parse('${MidtransConfig.baseUrl}/$orderId/status'),
        headers: {
          'Accept': 'application/json',
          'Authorization':
              'Basic ${base64Encode(utf8.encode('${MidtransConfig.serverKey}:'))}',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        await _updateLocalTransactionStatus(
            orderId, responseData['transaction_status']);

        return {
          'success': true,
          'order_id': responseData['order_id'],
          'transaction_status': responseData['transaction_status'],
          'payment_type': responseData['payment_type'],
          'transaction_id': responseData['transaction_id'],
          'gross_amount': responseData['gross_amount'],
        };
      } else {
        throw Exception('Gagal mengecek status transaksi');
      }
    } catch (e) {
      print('Error checking transaction status: $e');
      throw Exception('Error: $e');
    }
  }

  static Future<void> _updateLocalTransactionStatus(
      String orderId, String status) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final transactions = prefs.getStringList('donation_transactions') ?? [];

      final updatedTransactions = transactions.map((transactionStr) {
        final transaction = jsonDecode(transactionStr);
        if (transaction['order_id'] == orderId) {
          transaction['status'] = status;
          transaction['updated_at'] = DateTime.now().toIso8601String();
        }
        return jsonEncode(transaction);
      }).toList();

      await prefs.setStringList('donation_transactions', updatedTransactions);
    } catch (e) {
      print('Error updating local transaction status: $e');
    }
  }

  static Future<List<Donasi>> getRiwayatDonasi() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final transactions = prefs.getStringList('donation_transactions') ?? [];

      return transactions.map((transactionStr) {
        final transaction = jsonDecode(transactionStr);
        return Donasi(
          id: transaction['order_id'],
          orderId: transaction['order_id'],
          amount: transaction['amount'],
          status: transaction['status'] ?? 'pending',
          createdAt: DateTime.parse(transaction['created_at']),
          donorName: transaction['donor_name'],
          message: transaction['message'],
        );
      }).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      print('Error getting donation history: $e');
      return [];
    }
  }

  static Future<bool> cancelTransaction(String orderId) async {
    try {
      final response = await http.post(
        Uri.parse('${MidtransConfig.baseUrl}/$orderId/cancel'),
        headers: {
          'Accept': 'application/json',
          'Authorization':
              'Basic ${base64Encode(utf8.encode('${MidtransConfig.serverKey}:'))}',
        },
      );

      if (response.statusCode == 200) {
        await _updateLocalTransactionStatus(orderId, 'cancel');
        return true;
      }
      return false;
    } catch (e) {
      print('Error canceling transaction: $e');
      return false;
    }
  }
}
