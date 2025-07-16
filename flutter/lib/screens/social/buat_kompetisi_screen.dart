import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/pertemanan.dart';
import '../../services/pertemanan_service.dart';
import '../../services/kompetisi_service.dart';
import '../../theme/app_colors.dart';
import 'teman_screen.dart';

class BuatKompetisiScreen extends StatefulWidget {
  const BuatKompetisiScreen({Key? key}) : super(key: key);

  @override
  State<BuatKompetisiScreen> createState() => _BuatKompetisiScreenState();
}

class _BuatKompetisiScreenState extends State<BuatKompetisiScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _deskripsiController = TextEditingController();

  DateTime _tanggalMulai = DateTime.now();
  DateTime _tanggalSelesai = DateTime.now().add(const Duration(days: 7));

  String _tipeKompetisi = 'harian';
  double _targetHarian = 2.0;

  bool _isLoadingFriends = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  List<Teman> _daftarTeman = [];
  List<Teman> _temanDipilih = [];

  @override
  void initState() {
    super.initState();
    _loadTeman();
  }

  void _navigateToTemanScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TemanScreen()),
    ).then((_) => _loadTeman());
  }

  Future<void> _loadTeman() async {
    setState(() {
      _isLoadingFriends = true;
      _errorMessage = null;
    });

    try {
      final daftarTeman = await PertemananService.getDaftarTeman();

      setState(() {
        _daftarTeman = daftarTeman;
        _isLoadingFriends = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat daftar teman: ${e.toString()}';
        _isLoadingFriends = false;
      });
    }
  }

  Future<void> _pilihTanggal(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _tanggalMulai : _tanggalSelesai,
      firstDate: isStartDate ? DateTime.now() : _tanggalMulai,
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _tanggalMulai = picked;
          // Ensure end date is not before start date
          if (_tanggalSelesai.isBefore(_tanggalMulai)) {
            _tanggalSelesai = _tanggalMulai.add(const Duration(days: 1));
          }
        } else {
          _tanggalSelesai = picked;
        }
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_temanDipilih.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih minimal satu teman untuk berkompetisi'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await KompetisiService.buatKompetisi(
        nama: _namaController.text,
        deskripsi: _deskripsiController.text,
        tanggalMulai: _tanggalMulai,
        tanggalSelesai: _tanggalSelesai,
        tipe: _tipeKompetisi,
        pesertaIds: _temanDipilih.map((teman) => teman.id).toList(),
        targetHarian: _targetHarian,
      );

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Kompetisi "${_namaController.text}" berhasil dibuat!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal membuat kompetisi: ${e.toString()}';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $_errorMessage'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _toggleTemanSelection(Teman teman) {
    setState(() {
      if (_temanDipilih.any((item) => item.id == teman.id)) {
        _temanDipilih.removeWhere((item) => item.id == teman.id);
      } else {
        _temanDipilih.add(teman);
      }
    });
  }

  @override
  void dispose() {
    _namaController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Kompetisi'),
        backgroundColor: AppColors.primary,
        actions: [
          // Tambahkan tombol navigasi ke TemanScreen di AppBar
          IconButton(
            icon: const Icon(Icons.people),
            tooltip: 'Kelola Teman',
            onPressed: _navigateToTemanScreen,
          ),
        ],
      ),
      body: _isLoadingFriends && _daftarTeman.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null && _daftarTeman.isEmpty
              ? _buildErrorScreen()
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Info Kompetisi Card
                          Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Informasi Kompetisi',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // Nama Kompetisi, Deskripsi, Tanggal, dll.
                                  TextFormField(
                                    controller: _namaController,
                                    decoration: const InputDecoration(
                                      labelText: 'Nama Kompetisi',
                                      hintText:
                                          'Misal: Challenge Minum Air 30 Hari',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.emoji_events),
                                    ),
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Nama kompetisi tidak boleh kosong';
                                      }
                                      return null;
                                    },
                                  ),

                                  const SizedBox(height: 16),

                                  // Deskripsi
                                  TextFormField(
                                    controller: _deskripsiController,
                                    decoration: const InputDecoration(
                                      labelText: 'Deskripsi (Opsional)',
                                      hintText:
                                          'Jelaskan tentang kompetisi ini',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.description),
                                    ),
                                    maxLines: 3,
                                  ),

                                  const SizedBox(height: 16),

                                  // Tanggal Mulai
                                  InkWell(
                                    onTap: () => _pilihTanggal(context, true),
                                    child: InputDecorator(
                                      decoration: const InputDecoration(
                                        labelText: 'Tanggal Mulai',
                                        border: OutlineInputBorder(),
                                        prefixIcon: Icon(Icons.calendar_today),
                                      ),
                                      child: Text(
                                        DateFormat('dd MMMM yyyy')
                                            .format(_tanggalMulai),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 16),

                                  // Tanggal Selesai
                                  InkWell(
                                    onTap: () => _pilihTanggal(context, false),
                                    child: InputDecorator(
                                      decoration: const InputDecoration(
                                        labelText: 'Tanggal Selesai',
                                        border: OutlineInputBorder(),
                                        prefixIcon: Icon(Icons.calendar_today),
                                      ),
                                      child: Text(
                                        DateFormat('dd MMMM yyyy')
                                            .format(_tanggalSelesai),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 16),

                                  // Tipe Kompetisi
                                  InputDecorator(
                                    decoration: const InputDecoration(
                                      labelText: 'Tipe Kompetisi',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.category),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: _tipeKompetisi,
                                        isExpanded: true,
                                        items: const [
                                          DropdownMenuItem(
                                              value: 'harian',
                                              child: Text('Harian')),
                                          DropdownMenuItem(
                                              value: 'mingguan',
                                              child: Text('Mingguan')),
                                          DropdownMenuItem(
                                              value: 'bulanan',
                                              child: Text('Bulanan')),
                                          DropdownMenuItem(
                                              value: 'kustom',
                                              child: Text('Kustom')),
                                        ],
                                        onChanged: (value) {
                                          if (value != null) {
                                            setState(() {
                                              _tipeKompetisi = value;
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 16),

                                  // Target Harian
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Target Harian: ${_targetHarian.toStringAsFixed(1)} liter',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Slider(
                                        min: 0.5,
                                        max: 5.0,
                                        divisions: 9,
                                        label:
                                            '${_targetHarian.toStringAsFixed(1)} L',
                                        value: _targetHarian,
                                        activeColor: AppColors.primary,
                                        onChanged: (value) {
                                          setState(() {
                                            _targetHarian = value;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Peserta Kompetisi Card dengan navigasi ke TemanScreen
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Pilih Peserta',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      // Tambahkan badge dengan jumlah teman yang dipilih
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color: AppColors.primary,
                                            width: 1,
                                          ),
                                        ),
                                        child: Text(
                                          'Dipilih: ${_temanDipilih.length}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),

                                  // Jika belum ada teman, tampilkan UI yang mengarahkan untuk menambahkan teman
                                  if (_daftarTeman.isEmpty)
                                    Column(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.amber.withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                              color: Colors.amber,
                                              width: 1,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(Icons.info_outline,
                                                  color: Colors.amber[800]),
                                              const SizedBox(width: 8),
                                              const Expanded(
                                                child: Text(
                                                  'Anda perlu menambahkan teman terlebih dahulu untuk mengundang mereka ke kompetisi.',
                                                  style: TextStyle(
                                                      color: Colors.black87),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Center(
                                          child: ElevatedButton.icon(
                                            onPressed: _navigateToTemanScreen,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  AppColors.primary,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 10),
                                            ),
                                            icon: const Icon(Icons.person_add),
                                            label:
                                                const Text('Tambahkan Teman'),
                                          ),
                                        ),
                                      ],
                                    )
                                  else
                                    Column(
                                      children: [
                                        ...List.generate(_daftarTeman.length,
                                            (index) {
                                          final teman = _daftarTeman[index];
                                          final isSelected = _temanDipilih
                                              .any((t) => t.id == teman.id);

                                          return CheckboxListTile(
                                            value: isSelected,
                                            onChanged: (_) =>
                                                _toggleTemanSelection(teman),
                                            title: Text(teman.nama),
                                            subtitle: Text(teman.email),
                                            secondary: CircleAvatar(
                                              backgroundColor: isSelected
                                                  ? AppColors.primary
                                                  : Colors.grey,
                                              child: teman.fotoProfil != null
                                                  ? null
                                                  : Text(teman.nama[0]
                                                      .toUpperCase()),
                                            ),
                                            activeColor: AppColors.primary,
                                            checkColor: Colors.white,
                                          );
                                        }),

                                        // Tambahkan tombol untuk menambah teman di akhir daftar
                                        Center(
                                          child: TextButton.icon(
                                            onPressed: _navigateToTemanScreen,
                                            icon: const Icon(Icons.person_add),
                                            label:
                                                const Text('Tambah Teman Baru'),
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Tombol Buat Kompetisi
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isSubmitting ? null : _submitForm,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: _isSubmitting
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    )
                                  : const Text(
                                      'Buat Kompetisi',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }

  // UI untuk menampilkan error
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
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadTeman,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            icon: const Icon(Icons.refresh),
            label: const Text('Coba Lagi'),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: _navigateToTemanScreen,
            icon: const Icon(Icons.people),
            label: const Text('Buka Halaman Teman'),
          ),
        ],
      ),
    );
  }
}
