import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/kompetisi.dart';
import '../../services/kompetisi_service.dart';
import '../../theme/app_colors.dart';
import '../../config/api_config.dart';
import 'detail_kompetisi_screen.dart';
import 'buat_kompetisi_screen.dart';
import 'teman_screen.dart';
import '../../services/firebase_service.dart';

class KompetisiScreen extends StatefulWidget {
  const KompetisiScreen({Key? key}) : super(key: key);

  @override
  State<KompetisiScreen> createState() => _KompetisiScreenState();
}

class _KompetisiScreenState extends State<KompetisiScreen> {
  bool _isLoading = false;
  String? _errorMessage;

  List<Kompetisi> _activeCompetitions = [];
  List<Kompetisi> _pastCompetitions = [];
  List<KompetisiUndangan> _invitations = [];

  @override
  void initState() {
    super.initState();
    _loadKompetisi();
  }

  Future<void> _loadKompetisi() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await KompetisiService.getKompetisi();

      if (mounted) {
        setState(() {
          _activeCompetitions = data['active_competitions'];
          _pastCompetitions = data['past_competitions'];
          _invitations = data['invitations'];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToTemanScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TemanScreen()),
    ).then((_) => _loadKompetisi());
  }

  void _jawabUndangan(KompetisiUndangan undangan, bool accept) async {
    try {
      await KompetisiService.responUndangan(undangan.id, accept);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(accept
              ? 'Anda bergabung dalam kompetisi ${undangan.namaKompetisi}!'
              : 'Undangan ditolak'),
          backgroundColor: accept ? Colors.green : Colors.orange,
        ),
      );
      _loadKompetisi(); // Refresh data
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  static Future<void> catatKonsumsiAir({
    required int kompetisiId,
    required double jumlah,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');
      final userName = prefs.getString('user_name') ?? 'User';

      if (userId == null) {
        throw Exception('User ID tidak ditemukan');
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/catat-konsumsi-kompetisi'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'kompetisi_id': kompetisiId,
          'jumlah_konsumsi': jumlah,
        }),
      );

      if (response.statusCode == 200) {
        // Send notification to chat
        final chatRoomId = 'comp_$kompetisiId';
        await FirebaseService.sendWaterIntakeUpdate(
          chatRoomId,
          userName,
          jumlah,
        );
      } else {
        final error = jsonDecode(response.body)['error'];
        throw Exception(error ?? 'Gagal mencatat konsumsi air');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kompetisi Air Minum'),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.people),
            tooltip: 'Kelola Teman',
            onPressed: _navigateToTemanScreen,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorScreen()
              : RefreshIndicator(
                  onRefresh: _loadKompetisi,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildFriendsNavigationCard(),

                      if (_invitations.isNotEmpty) ...[
                        const Text(
                          'Undangan Kompetisi',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ..._invitations
                            .map((undangan) => _buildInvitationCard(undangan)),
                        const SizedBox(height: 24),
                      ],

                      // Kompetisi Aktif
                      const Text(
                        'Kompetisi Aktif',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_activeCompetitions.isEmpty)
                        _buildEmptyCompetitionCard()
                      else
                        ..._activeCompetitions.map(
                            (kompetisi) => _buildCompetitionCard(kompetisi)),

                      const SizedBox(height: 24),

                      // Kompetisi Sebelumnya
                      if (_pastCompetitions.isNotEmpty) ...[
                        const Text(
                          'Kompetisi Sebelumnya',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ..._pastCompetitions.map((kompetisi) =>
                            _buildCompetitionCard(kompetisi, isActive: false)),
                      ],
                    ],
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const BuatKompetisiScreen()),
          ).then((_) => _loadKompetisi()); // Refresh data setelah kembali
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Error: $_errorMessage',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadKompetisi,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendsNavigationCard() {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: _navigateToTemanScreen,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.people,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kelola Teman',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Tambah teman baru atau lihat permintaan pertemanan',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.chevron_right,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyCompetitionCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(
              Icons.emoji_events_outlined,
              size: 48,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'Belum ada kompetisi aktif',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Buat kompetisi baru atau tunggu undangan dari teman',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _navigateToTemanScreen,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                  ),
                  icon: const Icon(Icons.people),
                  label: const Text('Lihat Teman'),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const BuatKompetisiScreen()),
                    ).then((_) => _loadKompetisi());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text('Buat Kompetisi'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompetitionCard(Kompetisi kompetisi, {bool isActive = true}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  DetailKompetisiScreen(kompetisiId: kompetisi.id),
            ),
          ).then((_) => _loadKompetisi());
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with status
              Row(
                children: [
                  Icon(
                    kompetisi.getTipeIcon(),
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      kompetisi.nama,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: kompetisi.getStatusColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: kompetisi.getStatusColor(),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      kompetisi.getStatusText(),
                      style: TextStyle(
                        fontSize: 12,
                        color: kompetisi.getStatusColor(),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              // Divider
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Divider(),
              ),

              // Info baris (tanggal dan pembuat)
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tanggal',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_formatDate(kompetisi.tanggalMulai)} - ${_formatDate(kompetisi.tanggalSelesai)}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dibuat oleh',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          kompetisi.creatorName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Progress bar (hanya untuk kompetisi aktif)
              if (isActive && kompetisi.status == 'ongoing') ...[
                const SizedBox(height: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Progres: ${(kompetisi.getProgress() * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: kompetisi.getProgress(),
                        backgroundColor: Colors.grey[200],
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.primary),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              ],

              // Durasi kompetisi
              const SizedBox(height: 12),
              Text(
                'Durasi: ${kompetisi.getDurationDays()} hari',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInvitationCard(KompetisiUndangan undangan) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.mail,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    undangan.namaKompetisi,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              undangan.pesan,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => _jawabUndangan(undangan, false),
                  child: const Text('Tolak'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () => _jawabUndangan(undangan, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child: const Text('Terima'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
