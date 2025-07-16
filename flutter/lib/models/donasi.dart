class Donasi {
  final String id;
  final String orderId;
  final int amount;
  final String currency;
  final String status;
  final String? paymentType;
  final String? transactionId;
  final DateTime createdAt;
  final String? donorName;
  final String? message;

  Donasi({
    required this.id,
    required this.orderId,
    required this.amount,
    this.currency = 'IDR',
    required this.status,
    this.paymentType,
    this.transactionId,
    required this.createdAt,
    this.donorName,
    this.message,
  });

  factory Donasi.fromJson(Map<String, dynamic> json) {
    DateTime createdAt;
    try {
      if (json['created_at'] is String) {
        createdAt = DateTime.parse(json['created_at']);
      } else {
        createdAt = DateTime.now();
      }
    } catch (e) {
      print(
          'Error parsing created_at: ${json['created_at']}, using current time');
      createdAt = DateTime.now();
    }

    return Donasi(
      id: json['id']?.toString() ?? '',
      orderId: json['order_id']?.toString() ?? '',
      amount: _parseAmount(json['amount']),
      currency: json['currency']?.toString() ?? 'IDR',
      status: json['status']?.toString() ?? 'pending',
      paymentType: json['payment_type']?.toString(),
      transactionId: json['transaction_id']?.toString(),
      createdAt: createdAt,
      donorName: json['donor_name']?.toString(),
      message: json['message']?.toString(),
    );
  }

  static int _parseAmount(dynamic amount) {
    if (amount is int) return amount;
    if (amount is double) return amount.toInt();
    if (amount is String) {
      return int.tryParse(amount) ?? 0;
    }
    return 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'amount': amount,
      'currency': currency,
      'status': status,
      'payment_type': paymentType,
      'transaction_id': transactionId,
      'created_at': createdAt.toIso8601String(),
      'donor_name': donorName,
      'message': message,
    };
  }

  // Format untuk display
  String get formattedAmount {
    return 'Rp ${amount.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}';
  }

  String get formattedDate {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year} ${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}';
  }

  String get statusText {
    switch (status.toLowerCase()) {
      case 'settlement':
      case 'capture':
        return 'Berhasil';
      case 'pending':
        return 'Tertunda';
      case 'deny':
        return 'Ditolak';
      case 'cancel':
        return 'Dibatalkan';
      case 'expire':
        return 'Kedaluwarsa';
      default:
        return status.toUpperCase();
    }
  }
}

class DonasiRequest {
  final int amount;
  final String donorName;
  final String? message;
  final String? email;

  DonasiRequest({
    required this.amount,
    required this.donorName,
    this.message,
    this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'donor_name': donorName.isNotEmpty ? donorName : 'Donatur Anonim',
      'message': message?.isNotEmpty == true ? message : null,
      'email': email?.isNotEmpty == true ? email : null,
    };
  }
}
