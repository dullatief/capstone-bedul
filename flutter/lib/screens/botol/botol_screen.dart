import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config/api_config.dart';
import '../../models/botol.dart';
import '../../services/botol_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/pencapaian_notifikasi.dart';
import '../../models/pencapaian.dart';

class BotolScreen extends StatefulWidget {
  const BotolScreen({Key? key}) : super(key: key);

  @override
  State<BotolScreen> createState() => _BotolScreenState();
}

class _BotolScreenState extends State<BotolScreen>
    with TickerProviderStateMixin {
  List<Botol> _botolDefault = [];
  List<Botol> _botolKustom = [];
  bool _isLoading = true;
  bool _isSubmitting = false;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadBotolData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadBotolData() async {
    setState(() => _isLoading = true);

    try {
      final botolDefault = await BotolService.getBotolDefault();
      final botolKustom = await BotolService.getBotolKustom();

      if (mounted) {
        setState(() {
          _botolDefault = botolDefault;
          _botolKustom = botolKustom;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showSnackBar('Gagal memuat data: $e');
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Botol & Gelas'),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primary, Colors.white],
            stops: [0.0, 0.3],
          ),
        ),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white))
            : Column(
                children: [
                  _buildHeader(),
                  _buildTabBar(),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildDefaultBotolGrid(),
                        _buildCustomBotolList(),
                      ],
                    ),
                  ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddBotolDialog(),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pilih Botol & Gelas',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pilih botol atau gelas yang Anda gunakan untuk mencatat konsumsi air dengan akurat',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(30),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        labelColor: AppColors.primary,
        unselectedLabelColor: Colors.white,
        tabs: const [
          Tab(text: 'Botol Standar'),
          Tab(text: 'Botol Kustom'),
        ],
      ),
    );
  }

  Widget _buildDefaultBotolGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _botolDefault.length,
      itemBuilder: (context, index) => _buildBotolCard(_botolDefault[index]),
    );
  }

  Widget _buildCustomBotolList() {
    if (_botolKustom.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.water_drop_outlined,
              size: 60,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'Belum ada botol kustom',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap tombol + untuk membuat botol kustom',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _botolKustom.length,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _buildBotolListItem(_botolKustom[index]),
      ),
    );
  }

  Widget _buildBotolCard(Botol botol) {
    final IconData iconData = _getIconForBotol(botol.jenis);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _showCatatKonsumsiDialog(botol),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              botol.gambar != null
                  ? Image.asset(
                      botol.gambar!,
                      height: 80,
                      fit: BoxFit.contain,
                    )
                  : Icon(
                      iconData,
                      size: 50,
                      color: botol.warna,
                    ),
              const SizedBox(height: 12),
              Text(
                botol.nama,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                _formatUkuran(botol.ukuran),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => _showCatatKonsumsiDialog(botol),
                style: ElevatedButton.styleFrom(
                  backgroundColor: botol.warna,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: EdgeInsets.zero,
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('Gunakan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBotolListItem(Botol botol) {
    final IconData iconData = _getIconForBotol(botol.jenis);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showCatatKonsumsiDialog(botol),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: botol.warna.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  iconData,
                  color: botol.warna,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      botol.nama,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatUkuran(botol.ukuran),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  botol.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: botol.isFavorite ? Colors.red : Colors.grey,
                ),
                onPressed: () => _toggleFavorite(botol),
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () => _showEditBotolDialog(botol),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _showDeleteConfirmDialog(botol),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatUkuran(double ukuran) {
    if (ukuran < 1.0) {
      // Convert to ml for values less than 1L
      int ml = (ukuran * 1000).round();
      return '$ml ml';
    } else {
      return '${ukuran.toStringAsFixed(1)} L';
    }
  }

  IconData _getIconForBotol(JenisBotol jenis) {
    switch (jenis) {
      case JenisBotol.gelas:
        return Icons.local_drink;
      case JenisBotol.mug:
        return Icons.coffee;
      case JenisBotol.lainnya:
        return Icons.water;
      default:
        return Icons.water_drop;
    }
  }

  Future<void> _toggleFavorite(Botol botol) async {
    try {
      final updatedBotol = botol.copyWith(isFavorite: !botol.isFavorite);
      await BotolService.updateBotolKustom(updatedBotol);

      setState(() {
        final index = _botolKustom.indexWhere((b) => b.id == botol.id);
        if (index != -1) {
          _botolKustom[index] = updatedBotol;
        }
      });
    } catch (e) {
      _showSnackBar('Gagal mengubah status favorit: $e');
    }
  }

  void _showAddBotolDialog() {
    final nameController = TextEditingController();
    final sizeController = TextEditingController();
    Color selectedColor = AppColors.primary;
    JenisBotol selectedJenis = JenisBotol.botol;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          title: const Text('Tambah Botol Kustom'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama',
                    hintText: 'Contoh: Tumbler Kantor',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: sizeController,
                  decoration: const InputDecoration(
                    labelText: 'Ukuran (Liter)',
                    hintText: 'Contoh: 0.5',
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<JenisBotol>(
                  value: selectedJenis,
                  onChanged: (JenisBotol? value) {
                    if (value != null) {
                      setState(() {
                        selectedJenis = value;
                      });
                    }
                  },
                  decoration: const InputDecoration(labelText: 'Jenis'),
                  items: JenisBotol.values.map((jenis) {
                    return DropdownMenuItem<JenisBotol>(
                      value: jenis,
                      child: Text(_jenisToString(jenis)),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                const Text('Warna'),
                const SizedBox(height: 8),
                BlockPicker(
                  pickerColor: selectedColor,
                  onColorChanged: (Color color) {
                    setState(() {
                      selectedColor = color;
                    });
                  },
                  availableColors: const [
                    Colors.red,
                    Colors.pink,
                    Colors.purple,
                    Colors.deepPurple,
                    Colors.indigo,
                    Colors.blue,
                    Colors.lightBlue,
                    Colors.cyan,
                    Colors.teal,
                    Colors.green,
                    Colors.lightGreen,
                    Colors.lime,
                    Colors.yellow,
                    Colors.amber,
                    Colors.orange,
                    Colors.deepOrange,
                    Colors.brown,
                    Colors.grey,
                    Colors.blueGrey,
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                // Validate
                if (nameController.text.isEmpty) {
                  _showSnackBar('Nama tidak boleh kosong');
                  return;
                }

                final ukuran = double.tryParse(sizeController.text);
                if (ukuran == null || ukuran <= 0) {
                  _showSnackBar('Ukuran tidak valid');
                  return;
                }

                Navigator.pop(context);
                _addNewBotol(
                  nameController.text,
                  ukuran,
                  selectedColor,
                  selectedJenis,
                );
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      }),
    );
  }

  String _jenisToString(JenisBotol jenis) {
    switch (jenis) {
      case JenisBotol.gelas:
        return 'Gelas';
      case JenisBotol.mug:
        return 'Mug';
      case JenisBotol.lainnya:
        return 'Lainnya';
      default:
        return 'Botol';
    }
  }

  Future<void> _addNewBotol(
      String nama, double ukuran, Color warna, JenisBotol jenis) async {
    try {
      setState(() => _isSubmitting = true);

      final newBotol =
          await BotolService.addBotolKustom(nama, ukuran, warna, jenis);

      setState(() {
        _botolKustom.add(newBotol);
        _isSubmitting = false;
        // Pindah ke tab botol kustom
        _tabController.animateTo(1);
      });

      _showSnackBar('Botol kustom berhasil ditambahkan');
    } catch (e) {
      setState(() => _isSubmitting = false);
      _showSnackBar('Gagal menambahkan botol: $e');
    }
  }

  void _showEditBotolDialog(Botol botol) {
    final nameController = TextEditingController(text: botol.nama);
    final sizeController = TextEditingController(text: botol.ukuran.toString());
    Color selectedColor = botol.warna;
    JenisBotol selectedJenis = botol.jenis;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          title: const Text('Edit Botol Kustom'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nama'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: sizeController,
                  decoration:
                      const InputDecoration(labelText: 'Ukuran (Liter)'),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<JenisBotol>(
                  value: selectedJenis,
                  onChanged: (JenisBotol? value) {
                    if (value != null) {
                      setState(() {
                        selectedJenis = value;
                      });
                    }
                  },
                  decoration: const InputDecoration(labelText: 'Jenis'),
                  items: JenisBotol.values.map((jenis) {
                    return DropdownMenuItem<JenisBotol>(
                      value: jenis,
                      child: Text(_jenisToString(jenis)),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                const Text('Warna'),
                const SizedBox(height: 8),
                BlockPicker(
                  pickerColor: selectedColor,
                  onColorChanged: (Color color) {
                    setState(() {
                      selectedColor = color;
                    });
                  },
                  availableColors: const [
                    Colors.red,
                    Colors.pink,
                    Colors.purple,
                    Colors.deepPurple,
                    Colors.indigo,
                    Colors.blue,
                    Colors.lightBlue,
                    Colors.cyan,
                    Colors.teal,
                    Colors.green,
                    Colors.lightGreen,
                    Colors.lime,
                    Colors.yellow,
                    Colors.amber,
                    Colors.orange,
                    Colors.deepOrange,
                    Colors.brown,
                    Colors.grey,
                    Colors.blueGrey,
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                // Validate
                if (nameController.text.isEmpty) {
                  _showSnackBar('Nama tidak boleh kosong');
                  return;
                }

                final ukuran = double.tryParse(sizeController.text);
                if (ukuran == null || ukuran <= 0) {
                  _showSnackBar('Ukuran tidak valid');
                  return;
                }

                Navigator.pop(context);
                _updateBotol(
                  botol,
                  nameController.text,
                  ukuran,
                  selectedColor,
                  selectedJenis,
                );
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      }),
    );
  }

  Future<void> _updateBotol(Botol botol, String nama, double ukuran,
      Color warna, JenisBotol jenis) async {
    try {
      setState(() => _isSubmitting = true);

      final updatedBotol = botol.copyWith(
        nama: nama,
        ukuran: ukuran,
        warna: warna,
        jenis: jenis,
      );

      await BotolService.updateBotolKustom(updatedBotol);

      setState(() {
        final index = _botolKustom.indexWhere((b) => b.id == botol.id);
        if (index != -1) {
          _botolKustom[index] = updatedBotol;
        }
        _isSubmitting = false;
      });

      _showSnackBar('Botol kustom berhasil diupdate');
    } catch (e) {
      setState(() => _isSubmitting = false);
      _showSnackBar('Gagal update botol: $e');
    }
  }

  void _showDeleteConfirmDialog(Botol botol) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Botol'),
        content: Text('Yakin ingin menghapus botol "${botol.nama}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteBotol(botol);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteBotol(Botol botol) async {
    try {
      setState(() => _isSubmitting = true);

      await BotolService.deleteBotolKustom(botol.id);

      setState(() {
        _botolKustom.removeWhere((b) => b.id == botol.id);
        _isSubmitting = false;
      });

      _showSnackBar('Botol kustom berhasil dihapus');
    } catch (e) {
      setState(() => _isSubmitting = false);
      _showSnackBar('Gagal menghapus botol: $e');
    }
  }

  void _showCatatKonsumsiDialog(Botol botol) {
    final ukuranController =
        TextEditingController(text: botol.ukuran.toString());
    bool useCustomSize = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          title: Text('Konsumsi dari ${botol.nama}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              botol.gambar != null
                  ? Center(
                      child: Image.asset(
                        botol.gambar!,
                        height: 100,
                        fit: BoxFit.contain,
                      ),
                    )
                  : Center(
                      child: Icon(
                        _getIconForBotol(botol.jenis),
                        size: 80,
                        color: botol.warna,
                      ),
                    ),
              const SizedBox(height: 16),
              Text(
                'Ukuran: ${_formatUkuran(botol.ukuran)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: useCustomSize,
                    onChanged: (value) {
                      setState(() {
                        useCustomSize = value ?? false;
                      });
                    },
                  ),
                  const Text('Gunakan ukuran kustom'),
                ],
              ),
              if (useCustomSize)
                TextField(
                  controller: ukuranController,
                  decoration: const InputDecoration(
                    labelText: 'Ukuran (Liter)',
                    hintText: 'Contoh: 0.5',
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
              const SizedBox(height: 16),
              const Text(
                'Catatan: Konsumsi ini akan direkam sebagai konsumsi hari ini',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (useCustomSize) {
                  final ukuran = double.tryParse(ukuranController.text);
                  if (ukuran == null || ukuran <= 0) {
                    _showSnackBar('Ukuran tidak valid');
                    return;
                  }
                }

                Navigator.pop(context);
                final ukuranFinal = useCustomSize
                    ? double.tryParse(ukuranController.text)
                    : null;
                _catatKonsumsi(botol, ukuranFinal);
              },
              child: const Text('Catat Konsumsi'),
            ),
          ],
        );
      }),
    );
  }

  Future<void> _catatKonsumsi(Botol botol, double? ukuranOverride) async {
    try {
      setState(() => _isSubmitting = true);

      final pencapaianBaru = await BotolService.catatKonsumsiDenganBotol(
        botol,
        ukuranOverride: ukuranOverride,
      );

      final String ukuranText = _formatUkuran(ukuranOverride ?? botol.ukuran);
      _showSnackBar('Konsumsi $ukuranText berhasil dicatat dari ${botol.nama}');

      // Tampilkan notifikasi pencapaian baru jika ada
      if (pencapaianBaru.isNotEmpty) {
        for (final pencapaian in pencapaianBaru) {
          _showPencapaianNotification(pencapaian);
        }
      }

      setState(() => _isSubmitting = false);
    } catch (e) {
      setState(() => _isSubmitting = false);
      _showSnackBar('Gagal mencatat konsumsi: $e');
    }
  }

  void _showPencapaianNotification(Pencapaian pencapaian) {
    // Overlay notification
    final overlayState = Overlay.of(context);

    if (overlayState == null) return; // Cek apakah overlay state tersedia

    // Deklarasi variabel terlebih dahulu
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

    // Insert entry ke overlay
    overlayState.insert(entry);
  }
}
