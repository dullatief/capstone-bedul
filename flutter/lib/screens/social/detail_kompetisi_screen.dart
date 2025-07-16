import 'package:flutter/material.dart';
import 'package:klinik_bedul/models/kompetisi.dart';
import 'package:klinik_bedul/services/kompetisi_service.dart';
import '../../theme/app_colors.dart';
import 'package:intl/intl.dart';
import 'chat_kompetisi_screen.dart';
import '../../services/firebase_service.dart';

class DetailKompetisiScreen extends StatefulWidget {
  final int kompetisiId;

  const DetailKompetisiScreen({Key? key, required this.kompetisiId})
      : super(key: key);

  @override
  _DetailKompetisiScreenState createState() => _DetailKompetisiScreenState();
}

class _DetailKompetisiScreenState extends State<DetailKompetisiScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  String? _errorMessage;
  Kompetisi? _kompetisi;
  List<KompetisiPeserta> _peserta = [];
  bool _isParticipant = false;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);
    _loadKompetisiDetail();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadKompetisiDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      debugPrint('Loading competition detail for ID: ${widget.kompetisiId}');

      // Wrap in a try-catch with more detailed error handling
      Map<String, dynamic> result;
      try {
        result = await KompetisiService.getDetailKompetisi(widget.kompetisiId);
      } catch (e) {
        debugPrint('Error in API call: $e');
        if (mounted) {
          setState(() {
            _errorMessage = 'Gagal memuat detail kompetisi: ${e.toString()}';
            _isLoading = false;
          });
        }
        return; // Exit early
      }

      if (mounted) {
        setState(() {
          try {
            _kompetisi = result['kompetisi'] as Kompetisi?;

            _peserta = (result['peserta'] as List<KompetisiPeserta>? ?? [])
              ..sort((a, b) => b.totalKonsumsi.compareTo(a.totalKonsumsi));

            for (int i = 0; i < _peserta.length; i++) {
              final peserta = _peserta[i];
              _peserta[i] = KompetisiPeserta(
                userId: peserta.userId,
                nama: peserta.nama,
                totalKonsumsi: peserta.totalKonsumsi,
                targetHarian: peserta.targetHarian,
                streakCurrent: peserta.streakCurrent,
                streakBest: peserta.streakBest,
                peringkat: i + 1,
                isCurrentUser: peserta.isCurrentUser,
                fotoProfil: peserta.fotoProfil,
              );
            }

            debugPrint('Loaded ${_peserta.length} participants');
            _isParticipant = result['is_participant'] as bool? ?? false;
          } catch (e) {
            _errorMessage = 'Format data tidak valid: ${e.toString()}';
            _peserta = [];
            debugPrint('Error parsing competition details: $e');
          } finally {
            _isLoading = false;
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading competition detail: $e');
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
          _peserta = [];
        });
      }
    }
  }

  Future<void> _showCatatKonsumsiDialog() async {
    final TextEditingController jumlahController = TextEditingController();
    double? jumlah;

    final currentUser = _peserta.firstWhere(
      (p) => p.isCurrentUser,
      orElse: () => _peserta.first,
    );

    final double remainingTarget =
        currentUser.targetHarian > currentUser.totalKonsumsi
            ? (currentUser.targetHarian - currentUser.totalKonsumsi)
            : 0.5;

    jumlahController.text = remainingTarget.toStringAsFixed(1);

    bool? result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Catat Konsumsi Air'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Target harian: ${currentUser.targetHarian.toStringAsFixed(1)} L\n'
              'Sudah diminum: ${currentUser.totalKonsumsi.toStringAsFixed(1)} L\n'
              'Sisa: ${(currentUser.targetHarian - currentUser.totalKonsumsi).toStringAsFixed(1)} L',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: jumlahController,
              decoration: const InputDecoration(
                labelText: 'Jumlah (Liter)',
                hintText: 'Misalnya: 0.5',
                border: OutlineInputBorder(),
                suffixText: 'L',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              onChanged: (value) {
                // Validasi jumlah
                try {
                  jumlah = double.parse(value);
                } catch (e) {
                  jumlah = null;
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              // Try parse once more if needed
              if (jumlah == null) {
                try {
                  jumlah = double.parse(jumlahController.text);
                } catch (e) {
                  // Still null, will be handled later
                }
              }

              Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (result == true && jumlah != null && jumlah! > 0) {
      setState(() {
        _isLoading = true; // Show loading indicator
      });

      try {
        final result = await KompetisiService.catatKonsumsiKompetisiEnhanced(
          kompetisiId: widget.kompetisiId,
          jumlahKonsumsi: jumlah!,
        );

        // Reload data to show updated progress
        await _loadKompetisiDetail();

        if (mounted) {
          // Show success message with additional details
          final peringkat = result['peringkat'];
          final persentase = result['persentase'].toInt();
          final streakCurrent = result['streak_current'];

          String peringkatText = '';
          if (peringkat == 1)
            peringkatText = '🏆 Peringkat #1!';
          else if (peringkat == 2)
            peringkatText = '🥈 Peringkat #2!';
          else if (peringkat == 3)
            peringkatText = '🥉 Peringkat #3!';
          else
            peringkatText = '📊 Peringkat #$peringkat';

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      'Berhasil mencatat ${jumlah!.toStringAsFixed(1)} L konsumsi air'),
                  const SizedBox(height: 4),
                  Text(
                      '$peringkatText · $persentase% tercapai · Streak: $streakCurrent hari',
                      style: const TextStyle(fontSize: 12)),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );

          // Check if there are any achievements
          final pencapaianBaru = result['pencapaian_baru'] as List?;
          if (pencapaianBaru != null && pencapaianBaru.isNotEmpty) {
            for (final pencapaian in pencapaianBaru) {
              // Wait a moment before showing achievement notification
              await Future.delayed(const Duration(milliseconds: 500));
              _showPencapaianNotification(pencapaian['judul']);
            }
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal mencatat konsumsi: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _openChat() {
    if (_kompetisi == null) return;

    final participantIds = _peserta.map((p) => p.userId).toList();

    final currentUser = _peserta.firstWhere(
      (p) => p.isCurrentUser,
      orElse: () => KompetisiPeserta(
        userId: 0,
        nama: 'Unknown User',
        totalKonsumsi: 0,
        targetHarian: 0,
        streakCurrent: 0,
        streakBest: 0,
        peringkat: 0,
        isCurrentUser: false,
      ),
    );

    debugPrint(
        'Current user for chat: ${currentUser.nama} (ID: ${currentUser.userId})');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatKompetisiScreen(
          kompetisi: _kompetisi!,
          participantIds: participantIds,
          currentUserName: currentUser.nama,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _kompetisi != null
            ? Text(_kompetisi!.nama)
            : const Text('Detail Kompetisi'),
        backgroundColor: AppColors.primary,
        bottom: _isLoading || _errorMessage != null || _kompetisi == null
            ? null
            : TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Informasi'),
                  Tab(text: 'Peringkat'),
                ],
              ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorScreen()
              : _kompetisi == null
                  ? const Center(child: Text('Data kompetisi tidak tersedia'))
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildInfoTab(),
                        _buildLeaderboardTab(),
                      ],
                    ),
      floatingActionButton: _isParticipant &&
              !_isLoading &&
              _errorMessage == null &&
              _kompetisi != null
          ? FloatingActionButton(
              onPressed: _showCatatKonsumsiDialog,
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.local_drink),
            )
          : null,
    );
  }

  Widget _buildErrorScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 64,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Terjadi Kesalahan',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Tidak dapat memuat detail kompetisi',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadKompetisiDetail,
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Kembali'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCompetitionInfoCard(),
          const SizedBox(height: 16),
          // Tambahkan widget lain untuk tab Informasi di sini
        ],
      ),
    );
  }

  Widget _buildLeaderboardTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Peringkat Peserta',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (_peserta.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: Text(
                    'Belum ada data peserta',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            )
          else
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: _peserta.length,
              itemBuilder: (context, index) {
                final peserta = _peserta[index];
                return _buildLeaderboardItem(peserta, index + 1);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildCompetitionInfoCard() {
    if (_kompetisi == null) return const SizedBox();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _kompetisi!.nama,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (_kompetisi!.deskripsi.isNotEmpty) ...[
              Text(
                _kompetisi!.deskripsi,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
            ],
            Row(
              children: [
                const Icon(Icons.calendar_month, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${_formatDate(_kompetisi!.tanggalMulai)} - ${_formatDate(_kompetisi!.tanggalSelesai)}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.person, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  'Dibuat oleh ${_kompetisi!.creatorName}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildStatusChip(),
            const SizedBox(height: 16),

            // TAMBAHAN: Tombol-tombol aksi
            if (_isParticipant) ...[
              // TAMBAH: Chat Group Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _openChat, // Menggunakan method yang sudah ada
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text('Chat Grup'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    minimumSize: const Size(double.infinity, 40),
                  ),
                ),
              ),
              const SizedBox(height: 8), // Spacing

              // Button yang sudah ada - TIDAK DIUBAH
              ElevatedButton.icon(
                onPressed: _showCatatKonsumsiDialog,
                icon: const Icon(Icons.local_drink),
                label: const Text('Catat Konsumsi Air'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 40),
                ),
              ),
            ] else ...[
              // Button yang sudah ada - TIDAK DIUBAH
              OutlinedButton.icon(
                onPressed: () {
                  // Handler untuk bergabung
                },
                icon: const Icon(Icons.person_add),
                label: const Text('Gabung Kompetisi'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 40),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    if (_kompetisi == null) return const SizedBox();

    Color chipColor;
    String statusText;

    switch (_kompetisi!.status) {
      case 'upcoming':
        chipColor = Colors.blue;
        statusText = 'Akan Datang';
        break;
      case 'ongoing':
        chipColor = Colors.green;
        statusText = 'Sedang Berjalan';
        break;
      case 'completed':
        chipColor = Colors.orange;
        statusText = 'Selesai';
        break;
      default:
        chipColor = Colors.grey;
        statusText = _kompetisi!.status;
    }

    return Chip(
      label: Text(
        statusText,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
      ),
      backgroundColor: chipColor,
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildLeaderboardItem(KompetisiPeserta peserta, int rank) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      color: peserta.isCurrentUser ? Colors.blue.shade50 : null,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: rank <= 3
              ? [
                  Colors.amber,
                  Colors.grey.shade400,
                  Colors.brown.shade300
                ][rank - 1]
              : Colors.blue.shade100,
          child: Text(
            rank <= 3 ? ['🥇', '🥈', '🥉'][rank - 1] : rank.toString(),
            style: TextStyle(
              color: rank <= 3 ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                peserta.nama,
                style: TextStyle(
                  fontWeight: peserta.isCurrentUser
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ),
            Text(
              '${peserta.totalKonsumsi.toStringAsFixed(1)} L',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: peserta.getTargetPercentage() / 100,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                peserta.isCurrentUser ? AppColors.primary : Colors.blue,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${peserta.getTargetPercentage().toStringAsFixed(1)}% dari target',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final formatter = DateFormat('dd MMM yyyy');
    return formatter.format(date);
  }

  void _showPencapaianNotification(String title) {
    if (!mounted) return;

    final overlayState = Overlay.of(context);
    late final OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 16,
        left: 0,
        right: 0,
        child: Center(
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.amber, Colors.orange],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  const Icon(
                    Icons.emoji_events,
                    size: 40,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Pencapaian Baru!',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      entry.remove();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.amber,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('Luar Biasa!'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    overlayState.insert(entry);

    // Auto-dismiss after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (entry.mounted) {
        entry.remove();
      }
    });
  }
}
