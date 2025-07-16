import 'package:flutter/material.dart';
import '../../models/pencapaian.dart';
import '../../services/pencapaian_service.dart';
import '../../theme/app_colors.dart';

class PencapaianScreen extends StatefulWidget {
  const PencapaianScreen({Key? key}) : super(key: key);

  @override
  State<PencapaianScreen> createState() => _PencapaianScreenState();
}

class _PencapaianScreenState extends State<PencapaianScreen> {
  List<Pencapaian> _pencapaianList = [];
  bool _isLoading = true;
  int _streakHarian = 0;
  String? _lastUpdated;

  @override
  void initState() {
    super.initState();
    _loadPencapaian();
  }

  Future<void> _loadPencapaian() async {
    setState(() => _isLoading = true);
    try {
      final data = await PencapaianService.getPencapaian();

      final List<Pencapaian> pencapaianList = data['pencapaian'] ?? [];
      final Map<String, dynamic> streakData = data['streak'] ?? {};

      setState(() {
        _pencapaianList = pencapaianList;
        _streakHarian = streakData['nilai'] ?? 0;
        _lastUpdated = streakData['terakhir_update'];
      });

      print('Loaded ${_pencapaianList.length} pencapaian');
      print('Streak: $_streakHarian hari');
    } catch (e) {
      print('Error loading pencapaian: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pencapaian'),
        backgroundColor: AppColors.primary,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              )
            : RefreshIndicator(
                onRefresh: _loadPencapaian,
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: _buildHeader(),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.all(16.0),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          _buildStreakCard(),
                          const SizedBox(height: 24),
                          const Text(
                            'Pencapaian',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 16),
                        ]),
                      ),
                    ),
                    _pencapaianList.isEmpty
                        ? SliverToBoxAdapter(
                            child: Container(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.emoji_events_outlined,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Belum ada pencapaian',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Mulai catat konsumsi air untuk membuka pencapaian',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[500],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          )
                        : SliverPadding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            sliver: SliverGrid(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.8,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                              ),
                              delegate: SliverChildBuilderDelegate(
                                (context, index) => _buildPencapaianCard(
                                    _pencapaianList[index]),
                                childCount: _pencapaianList.length,
                              ),
                            ),
                          ),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 24),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildHeader() {
    int totalTerbuka = _pencapaianList.where((p) => p.terbuka).length;
    double persentase = _pencapaianList.isEmpty
        ? 0.0
        : totalTerbuka / _pencapaianList.length * 100;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.emoji_events,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pencapaian Anda',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '$totalTerbuka dari ${_pencapaianList.length} pencapaian terbuka',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: persentase / 100,
              backgroundColor: Colors.white30,
              color: Colors.white,
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${persentase.toStringAsFixed(1)}% selesai',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                Icons.local_fire_department,
                color: Colors.orange[700],
                size: 32,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Streak Saat Ini',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
                Text(
                  '$_streakHarian hari',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Pertahankan konsistensi untuk pembukaan badge!',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black45,
                  ),
                ),
                if (_lastUpdated != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Terakhir update: $_lastUpdated',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.black38,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPencapaianCard(Pencapaian pencapaian) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showPencapaianDetails(pencapaian),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: pencapaian.terbuka
                        ? AppColors.primary.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: pencapaian.terbuka
                        ? Icon(
                            _getIconForPencapaian(pencapaian),
                            color: AppColors.primary,
                            size: 32,
                          )
                        : Icon(
                            Icons.lock,
                            color: Colors.grey[400],
                            size: 28,
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  pencapaian.judul,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: pencapaian.terbuka ? Colors.black87 : Colors.black45,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: pencapaian.progres,
                    backgroundColor: Colors.grey[200],
                    color: pencapaian.terbuka
                        ? AppColors.primary
                        : Colors.grey[400],
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${(pencapaian.progres * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 12,
                    color: pencapaian.terbuka ? Colors.black54 : Colors.black38,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIconForPencapaian(Pencapaian pencapaian) {
    switch (pencapaian.jenisPencapaian) {
      case JenisPencapaian.totalKonsumsi:
        return Icons.water_drop;
      case JenisPencapaian.streakHarian:
        return Icons.local_fire_department;
      case JenisPencapaian.mingguSempurna:
        return Icons.calendar_today;
      case JenisPencapaian.jumlahHarian:
        return Icons.flash_on;
    }
  }

  void _showPencapaianDetails(Pencapaian pencapaian) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: pencapaian.terbuka
                    ? AppColors.primary.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: pencapaian.terbuka
                    ? Icon(
                        _getIconForPencapaian(pencapaian),
                        color: AppColors.primary,
                        size: 40,
                      )
                    : Icon(
                        Icons.lock,
                        color: Colors.grey[400],
                        size: 36,
                      ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              pencapaian.judul,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              pencapaian.deskripsi,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Target: ${pencapaian.nilaiTarget} ${_getUnitForPencapaian(pencapaian)}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              pencapaian.terbuka
                  ? 'Terbuka!'
                  : '${(pencapaian.progres * 100).toInt()}% selesai',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: pencapaian.terbuka ? AppColors.primary : Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: pencapaian.progres,
                backgroundColor: Colors.grey[200],
                color:
                    pencapaian.terbuka ? AppColors.primary : Colors.grey[400],
                minHeight: 8,
              ),
            ),
            if (pencapaian.tanggalTerbuka != null) ...[
              const SizedBox(height: 16),
              Text(
                'Terbuka pada: ${_formatDate(pencapaian.tanggalTerbuka!)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black45,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  String _getUnitForPencapaian(Pencapaian pencapaian) {
    switch (pencapaian.jenisPencapaian) {
      case JenisPencapaian.totalKonsumsi:
      case JenisPencapaian.jumlahHarian:
        return 'L';
      case JenisPencapaian.streakHarian:
        return 'hari';
      case JenisPencapaian.mingguSempurna:
        return 'minggu';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
