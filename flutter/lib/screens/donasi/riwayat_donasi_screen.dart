import 'package:flutter/material.dart';
import '../../services/donasi_service.dart';
import '../../models/donasi.dart';
import '../../theme/app_colors.dart';

class RiwayatDonasiScreen extends StatefulWidget {
  const RiwayatDonasiScreen({Key? key}) : super(key: key);

  @override
  State<RiwayatDonasiScreen> createState() => _RiwayatDonasiScreenState();
}

class _RiwayatDonasiScreenState extends State<RiwayatDonasiScreen> {
  List<Donasi> _riwayatDonasi = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRiwayatDonasi();
  }

  Future<void> _loadRiwayatDonasi() async {
    setState(() => _isLoading = true);

    try {
      final riwayat = await DonasiService.getRiwayatDonasi();
      setState(() {
        _riwayatDonasi = riwayat;
      });
    } catch (e) {
      _showSnackBar('Error memuat riwayat donasi: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Donasi'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _riwayatDonasi.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadRiwayatDonasi,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _riwayatDonasi.length,
                    itemBuilder: (context, index) {
                      final donasi = _riwayatDonasi[index];
                      return _buildDonasiCard(donasi);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.volunteer_activism_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada riwayat donasi',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Donasi Anda akan muncul di sini',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonasiCard(Donasi donasi) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getStatusColor(donasi.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getStatusIcon(donasi.status),
                  color: _getStatusColor(donasi.status),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rp ${_formatCurrency(donasi.amount)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      _getStatusText(donasi.status),
                      style: TextStyle(
                        fontSize: 12,
                        color: _getStatusColor(donasi.status),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                _formatDate(donasi.createdAt),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          if (donasi.donorName != null && donasi.donorName!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.person_outline, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  donasi.donorName!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ],
          if (donasi.message != null && donasi.message!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.message_outlined,
                      size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '"${donasi.message}"',
                      style: TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                'Order ID: ${donasi.orderId}',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[500],
                  fontFamily: 'monospace',
                ),
              ),
              const Spacer(),
              if (donasi.status == 'pending')
                TextButton(
                  onPressed: () => _checkTransactionStatus(donasi),
                  style: TextButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                  child: const Text(
                    'Cek Status',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'settlement':
      case 'capture':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'deny':
      case 'cancel':
      case 'expire':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'settlement':
      case 'capture':
        return Icons.check_circle;
      case 'pending':
        return Icons.hourglass_empty;
      case 'deny':
      case 'cancel':
      case 'expire':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  String _getStatusText(String status) {
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

  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _checkTransactionStatus(Donasi donasi) async {
    try {
      final result = await DonasiService.checkTransactionStatus(donasi.orderId);

      if (result['success']) {
        _showSnackBar(
            'Status diperbarui: ${_getStatusText(result['transaction_status'])}');
        _loadRiwayatDonasi();
      }
    } catch (e) {
      _showSnackBar('Error mengecek status: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
