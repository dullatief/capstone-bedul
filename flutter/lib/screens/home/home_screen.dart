import 'package:flutter/material.dart';
import 'dart:async';
import '../../theme/app_colors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/notification_helper.dart';
import '../main_navigation_screen.dart';
import '../statistics/statistics_screen.dart';
import '../../services/pencapaian_service.dart';
import '../../models/pencapaian.dart';
import '../../widgets/pencapaian_notifikasi.dart';
import '../../models/botol.dart';
import '../../services/botol_service.dart';
import '../../screens/botol/botol_screen.dart';
import '../../config/api_config.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainNavigationScreen(initialIndex: 0);
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent>
    with TickerProviderStateMixin {
  String? _aktivitas;
  Map<String, dynamic>? _userData;
  double? _rekomendasiAir;
  String? _suhu;
  bool _isLoading = false;
  bool _isLoadingProfile = true;

  List<Botol> _botolList = [];
  Botol? _selectedBottle;
  bool _isLoadingBottles = false;

  final List<String> _aktivitasList = ['rendah', 'sedang', 'tinggi'];

  late AnimationController _pulseController;
  late AnimationController _slideController;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initializeApp();
    _loadBotol();
  }

  void _initAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _slideController.forward();
  }

  Future<void> _initializeApp() async {
    await initializeNotification();
    _scheduleDailyReminders();
    await _loadUserProfile();
  }

  void _scheduleDailyReminders() {
    final reminders = [
      {
        'id': 0,
        'hour': 9,
        'title': 'Minum Pagi',
        'body': 'Selamat pagi! Jangan lupa minum air untuk memulai harimu!'
      },
      {
        'id': 1,
        'hour': 12,
        'title': 'Minum Siang',
        'body': 'Sudah waktunya makan siang. Minum air dulu yuk!'
      },
      {
        'id': 2,
        'hour': 15,
        'title': 'Minum Sore',
        'body': 'Jangan ngantuk! Segelas air bisa bantu kamu tetap fokus.'
      },
      {
        'id': 3,
        'hour': 18,
        'title': 'Minum Petang',
        'body': 'Waktunya relaks sore hari. Jangan lupa minum air.'
      },
      {
        'id': 4,
        'hour': 21,
        'title': 'Minum Malam',
        'body': 'Sebelum tidur, minum air secukupnya ya.'
      },
    ];

    for (var reminder in reminders) {
      scheduleDailyReminder(
        id: reminder['id'] as int,
        hour: reminder['hour'] as int,
        minute: 0,
        title: reminder['title'] as String,
        body: reminder['body'] as String,
      );
    }
  }

  Future<void> _loadUserProfile() async {
    setState(() => _isLoadingProfile = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId == null) {
        setState(() => _isLoadingProfile = false);
        return;
      }

      final response = await http.get(
        Uri.parse(
            '${ApiConfig.baseUrl}${ApiConfig.dapatkanProfil}/$userId'), // Ubah endpoint
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _userData = data;
        });
      }
    } catch (e) {
      debugPrint('Gagal mengambil profil: $e');
    } finally {
      setState(() => _isLoadingProfile = false);
    }
  }

  Future<void> _prediksiAir() async {
    if (_aktivitas == null) {
      _showSnackBar('Pilih tingkat aktivitas terlebih dahulu.', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId == null) {
        throw Exception('User ID tidak ditemukan');
      }

      final response = await http.post(
        Uri.parse(
            '${ApiConfig.baseUrl}${ApiConfig.prediksi}'), // Ubah dari '/predict' ke ApiConfig.prediksi
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'tingkat_aktivitas': _aktivitas,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          _rekomendasiAir = data['rekomendasi_air'];
          _suhu = data['suhu'].toString();
        });
        _showSnackBar('Prediksi berhasil!', isError: false);

        // await _updatePencapaian(_rekomendasiAir!);
      } else {
        _showSnackBar(data['error'] ?? 'Prediksi gagal', isError: true);
      }
    } catch (e) {
      _showSnackBar('Terjadi kesalahan: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updatePencapaian(double jumlahKonsumsi) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId == null) {
        throw Exception('User ID tidak ditemukan');
      }

      final List<Pencapaian> pencapaianBaru =
          await PencapaianService.updatePencapaian(userId, jumlahKonsumsi);

      if (pencapaianBaru.isNotEmpty && mounted) {
        for (final pencapaian in pencapaianBaru) {
          _showPencapaianNotification(pencapaian);
        }
      }
    } catch (e) {
      debugPrint('Error updating achievements: $e');
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    await prefs.remove('token');
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _loadBotol() async {
    if (mounted) {
      setState(() => _isLoadingBottles = true);
    }

    try {
      final botolDefault = await BotolService.getBotolDefault();
      final botolKustom = await BotolService.getBotolKustom();

      final List<Botol> allBotol = [...botolDefault, ...botolKustom];

      if (mounted) {
        setState(() {
          _botolList = allBotol;

          if (allBotol.isNotEmpty) {
            // Cari botol default
            final defaultBottle =
                allBotol.where((botol) => botol.isDefault).toList();

            _selectedBottle =
                defaultBottle.isNotEmpty ? defaultBottle.first : allBotol.first;
          } else {
            _selectedBottle = null;
          }

          _isLoadingBottles = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading bottles: $e');
      if (mounted) {
        setState(() => _isLoadingBottles = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    // App Bar
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Prediksi Kebutuhan\nAir Minum',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                            ),
                          ),

                          // Tombol Statistik
                          Container(
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.bar_chart,
                                  color: Colors.white),
                              tooltip: 'Statistik',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const StatisticsScreen(),
                                  ),
                                );
                              },
                            ),
                          ),

                          // Tombol Logout
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              icon:
                                  const Icon(Icons.logout, color: Colors.white),
                              tooltip: 'Logout',
                              onPressed: () async {
                                final confirm = await showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    title: const Text('Konfirmasi Logout'),
                                    content: const Text(
                                        'Apakah Anda yakin ingin logout?'),
                                    actions: [
                                      TextButton(
                                        child: const Text('Batal'),
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.error,
                                        ),
                                        child: const Text('Logout'),
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  logout(context);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Tip Card
                    Container(
                      margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          AnimatedBuilder(
                            animation: _pulseAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _pulseAnimation.value,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.water_drop,
                                    size: 24,
                                    color: Colors.white,
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "💡 Tahukah kamu?",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "Minum cukup air bisa meningkatkan konsentrasi dan menjaga energi sepanjang hari.",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Content Section
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // User Profile Card
                      if (_isLoadingProfile)
                        _buildProfileLoadingCard()
                      else if (_userData != null)
                        _buildProfileCard(),

                      const SizedBox(height: 16),

                      // Prediction Card
                      _buildPredictionCard(),

                      // Result Card
                      if (_rekomendasiAir != null) ...[
                        const SizedBox(height: 16),
                        _buildResultCard(),
                        const SizedBox(height: 16),
                        _buildConsumptionTracker(),
                      ],

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileLoadingCard() {
    return Card(
      elevation: 4,
      shadowColor: AppColors.cardShadow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.person,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Memuat Profil...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Mengambil data profil Anda',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Card(
      elevation: 4,
      shadowColor: AppColors.cardShadow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withOpacity(0.1),
              AppColors.surface,
            ],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    "Profil Anda",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildProfileItem("Nama", _userData!['nama'] ?? 'N/A'),
                ),
                Expanded(
                  child: _buildProfileItem(
                      "Usia", "${_userData!['usia'] ?? 'N/A'} th"),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildProfileItem(
                      "Berat", "${_userData!['berat_badan'] ?? 'N/A'} kg"),
                ),
                Expanded(
                  child: _buildProfileItem(
                      "Tinggi", "${_userData!['tinggi_badan'] ?? 'N/A'} cm"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildPredictionCard() {
    return Card(
      elevation: 4,
      shadowColor: AppColors.cardShadow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.analytics,
                    color: AppColors.secondary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Prediksi Kebutuhan Air',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: DropdownButtonFormField<String>(
                value: _aktivitas,
                decoration: const InputDecoration(
                  labelText: 'Tingkat Aktivitas Hari Ini',
                  prefixIcon: Icon(Icons.directions_run),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                items: _aktivitasList
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(
                            e.substring(0, 1).toUpperCase() + e.substring(1),
                          ),
                        ))
                    .toList(),
                onChanged: (val) => setState(() => _aktivitas = val),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _prediksiAir,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.psychology),
                label: Text(
                  _isLoading ? 'Memproses...' : 'Prediksi Sekarang',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    return Card(
      elevation: 4,
      shadowColor: AppColors.cardShadow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              AppColors.success.withOpacity(0.1),
              AppColors.surface,
            ],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.water_drop,
                    color: AppColors.success,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Hasil Prediksi',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.water_drop,
                    size: 40,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Rekomendasi Air Minum Anda:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_rekomendasiAir!.toStringAsFixed(2)} liter/hari',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  if (_suhu != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '🌡️ Suhu: $_suhu°C',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],

                  // Tombol konfirmasi konsumsi air
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _konfirmasiKonsumsiAir(),
                      icon: const Icon(Icons.check_circle),
                      label: const Text(
                        'Saya sudah minum sesuai rekomendasi',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _konfirmasiKonsumsiAir() async {
    try {
      if (_selectedBottle != null) {
        setState(() => _isLoading = true);

        final ukuranLiter = _selectedBottle!.ukuran < 1.0
            ? _selectedBottle!.ukuran
            : _selectedBottle!.ukuran / 1000.0;

        final pencapaianBaru =
            await PencapaianService.catatKonsumsi(ukuranLiter);

        if (pencapaianBaru.isNotEmpty && mounted) {
          for (final pencapaian in pencapaianBaru) {
            _showPencapaianNotification(pencapaian);
          }
        }

        setState(() => _isLoading = false);
        _showSnackBar(
            'Konsumsi air berhasil dicatat menggunakan ${_selectedBottle!.nama}!',
            isError: false);
      } else if (_rekomendasiAir != null) {
        setState(() => _isLoading = true);

        final List<Pencapaian> pencapaianBaru =
            await PencapaianService.catatKonsumsi(_rekomendasiAir!);

        if (pencapaianBaru.isNotEmpty && mounted) {
          for (final pencapaian in pencapaianBaru) {
            _showPencapaianNotification(pencapaian);
          }
        }

        setState(() => _isLoading = false);
        _showSnackBar('Konsumsi air berhasil dicatat sesuai rekomendasi!',
            isError: false);
      } else {
        _showSnackBar(
            'Pilih botol atau dapatkan rekomendasi air terlebih dahulu',
            isError: true);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Gagal mencatat konsumsi: $e', isError: true);
    }
  }

  void _showPencapaianNotification(Pencapaian pencapaian) {
    final overlayState = Overlay.of(context);

    if (overlayState == null) return;

    late final OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 16,
        left: 0,
        right: 0,
        child: PencapaianNotifikasi(
          pencapaian: pencapaian,
          onDismiss: () {
            entry.remove();
          },
        ),
      ),
    );

    overlayState.insert(entry);
  }

  String _getGreetingMessage() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Selamat pagi! Jangan lupa minum air ya.';
    } else if (hour < 15) {
      return 'Selamat siang! Tetap terhidrasi di tengah hari.';
    } else if (hour < 18) {
      return 'Selamat sore! Sudah cukup minum air hari ini?';
    } else {
      return 'Selamat malam! Jangan lupa hidrasi sebelum tidur.';
    }
  }

  Future<Map<String, dynamic>> _getUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId == null) {
        return {'nama': 'Pengguna'};
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.dapatkanProfil}/$userId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return {
          'user_id': data['user_id'],
          'email': data['email'],
          'nama': data['nama'] ?? 'Pengguna',
          'usia': data['usia'],
          'berat_badan': data['berat_badan'],
          'tinggi_badan': data['tinggi_badan'],
          'jenis_kelamin': data['jenis_kelamin'],
        };
      } else {
        return {'nama': 'Pengguna'};
      }
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
      return {'nama': 'Pengguna'};
    }
  }

  Widget _buildConsumptionTracker() {
    return Card(
      elevation: 4,
      shadowColor: AppColors.cardShadow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Catat Konsumsi Air',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Pilih botol atau gelas yang Anda gunakan:',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            _isLoadingBottles
                ? const Center(child: CircularProgressIndicator())
                : _buildBottleSelector(),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _botolList.isEmpty || _selectedBottle == null
                    ? null
                    : _konfirmasiKonsumsiAir,
                icon: const Icon(Icons.add),
                label: const Text('Catat Konsumsi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BotolScreen(),
                    ),
                  ).then((_) => _loadBotol());
                },
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('Kustomisasi Botol/Gelas'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottleSelector() {
    if (_botolList.isEmpty) {
      return Center(
        child: Column(
          children: [
            const Icon(
              Icons.water_drop_outlined,
              size: 48,
              color: Colors.grey,
            ),
            const SizedBox(height: 8),
            const Text(
              'Belum ada botol atau gelas',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BotolScreen(),
                  ),
                ).then((_) => _loadBotol());
              },
              child: const Text('Tambah Botol/Gelas'),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _botolList.length,
        itemBuilder: (context, index) {
          final botol = _botolList[index];
          final isSelected = _selectedBottle?.id == botol.id;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedBottle = botol;
              });
            },
            child: Container(
              width: 100,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isSelected ? botol.warna : botol.warna.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _getBottleIcon(botol.jenis),
                    size: 40,
                    color: isSelected ? Colors.white : Colors.black54,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    botol.nama,
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    botol.ukuran < 1.0
                        ? '${(botol.ukuran * 1000).toInt()} ml'
                        : '${botol.ukuran.toStringAsFixed(1)} L',
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Mengambil icon untuk jenis botol
  IconData _getBottleIcon(JenisBotol jenis) {
    switch (jenis) {
      case JenisBotol.gelas:
        return Icons.local_drink;
      case JenisBotol.mug:
        return Icons.coffee;
      case JenisBotol.lainnya:
        return Icons.water;
      case JenisBotol.botol:
      default:
        return Icons.water_drop;
    }
  }
}
