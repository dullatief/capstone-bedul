import 'dart:convert';

class MidtransConfig {
  static const String merchantId = 'G391936868';
  static const String clientKey = 'SB-Mid-client-o9ExlmgCwvOmmzm4';
  static const String serverKey = 'SB-Mid-server-9nxoT7b-jZx8sb04rkJf4ilT';

  static const String baseUrl = 'https://api.sandbox.midtrans.com/v2';
  static const String snapUrl = 'https://app.sandbox.midtrans.com/snap/v1';

  static const String localBackendUrl = 'http://api.bedoel.me';

  static Map<String, String> get headers => {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Basic ${_getEncodedServerKey()}',
      };

  static String _getEncodedServerKey() {
    final bytes = utf8.encode('$serverKey:');
    return base64Encode(bytes);
  }

  static Map<String, String> get callbackUrls => {
        'finish': '$localBackendUrl/payment/finish',
        'error': '$localBackendUrl/payment/error',
        'pending': '$localBackendUrl/payment/pending',
      };
}
