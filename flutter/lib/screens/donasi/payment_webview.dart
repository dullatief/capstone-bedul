import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../services/donasi_service.dart';
import '../../theme/app_colors.dart';

class PaymentWebView extends StatefulWidget {
  final String paymentUrl;
  final String orderId;

  const PaymentWebView({
    Key? key,
    required this.paymentUrl,
    required this.orderId,
  }) : super(key: key);

  @override
  State<PaymentWebView> createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends State<PaymentWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String _pageTitle = 'Pembayaran';

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {},
          onPageStarted: (String url) {
            setState(() => _isLoading = true);
            _handleUrlChange(url);
          },
          onPageFinished: (String url) {
            setState(() => _isLoading = false);
            _handleUrlChange(url);
          },
          onWebResourceError: (WebResourceError error) {
            _showErrorDialog(
                'Silahkan Klik Tombol OK, big thanks from bedul :)');
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  void _handleUrlChange(String url) {
    if (url.contains('/donation/success') || url.contains('status=success')) {
      _handlePaymentSuccess();
    } else if (url.contains('/donation/error') ||
        url.contains('status=error')) {
      _handlePaymentError();
    } else if (url.contains('/donation/pending') ||
        url.contains('status=pending')) {
      _handlePaymentPending();
    }

    if (url.contains('sandbox.midtrans.com')) {
      setState(() => _pageTitle = 'Pilih Metode Pembayaran');
    }
  }

  void _handlePaymentSuccess() {
    _checkTransactionStatus(true);
  }

  void _handlePaymentError() {
    _checkTransactionStatus(false);
  }

  void _handlePaymentPending() {
    _showPendingDialog();
  }

  Future<void> _checkTransactionStatus(bool expectSuccess) async {
    try {
      final result = await DonasiService.checkTransactionStatus(widget.orderId);

      if (result['success']) {
        final status = result['transaction_status'];

        if (status == 'settlement' || status == 'capture') {
          _showSuccessDialog();
        } else if (status == 'pending') {
          _showPendingDialog();
        } else if (status == 'deny' ||
            status == 'cancel' ||
            status == 'expire') {
          _showErrorDialog(
              'Pembayaran ${status == 'cancel' ? 'dibatalkan' : status}');
        } else {
          _showErrorDialog('Status pembayaran: $status');
        }
      } else {
        _showErrorDialog('Gagal mengecek status pembayaran');
      }
    } catch (e) {
      if (expectSuccess) {
        _showSuccessDialog();
      } else {
        _showErrorDialog('Error: $e');
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 8),
            Text('Pembayaran Berhasil!'),
          ],
        ),
        content: const Text(
          'Terima kasih atas donasi Anda! Dukungan Anda sangat berarti untuk pengembangan aplikasi ini.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(true);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showPendingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.hourglass_empty, color: Colors.orange, size: 28),
            SizedBox(width: 8),
            Text('Pembayaran Tertunda'),
          ],
        ),
        content: const Text(
          'Pembayaran Anda sedang diproses. Kami akan menginformasikan status pembayaran melalui notifikasi.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(false);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 8),
            Text('Pembayaran Berhasil!'),
          ],
        ),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(false);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_pageTitle),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            _showConfirmCloseDialog();
          },
        ),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Memuat halaman pembayaran...'),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _showConfirmCloseDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Batalkan Pembayaran?'),
        content: const Text(
          'Apakah Anda yakin ingin menutup halaman pembayaran? Transaksi yang sedang berlangsung akan dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tidak'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(false);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );
  }
}
