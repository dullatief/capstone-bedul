import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../models/botol.dart';
import '../../services/botol_service.dart';
import '../../theme/app_colors.dart';

class BotelCustomizeScreen extends StatefulWidget {
  const BotelCustomizeScreen({Key? key}) : super(key: key);

  @override
  State<BotelCustomizeScreen> createState() => _BotelCustomizeScreenState();
}

class _BotelCustomizeScreenState extends State<BotelCustomizeScreen> {
  List<Botol> _botolList = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadBotol();
  }

  Future<void> _loadBotol() async {
    setState(() => _isLoading = true);

    try {
      final botolList = await BotolService.getBotol();
      setState(() {
        _botolList = botolList;
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kustomisasi Botol/Gelas'),
        backgroundColor: AppColors.primary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _botolList.isEmpty
              ? _buildEmptyState()
              : _buildBotolList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditBotolDialog(),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.water_drop_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          const Text(
            'Belum ada botol atau gelas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tambahkan botol atau gelas kustom Anda',
            style: TextStyle(color: Colors.black45),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddEditBotolDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Tambah Botol/Gelas'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBotolList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _botolList.length,
      itemBuilder: (context, index) {
        final botol = _botolList[index];
        return _buildBotolCard(botol);
      },
    );
  }

  Widget _buildBotolCard(Botol botol) {
    final color = Color(int.parse('0xFF${botol.warna.substring(1)}'));
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getBottleIcon(botol.iconType),
            color: color,
            size: 30,
          ),
        ),
        title: Text(
          botol.nama,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('${botol.ukuran.toInt()} ml'),
            if (botol.isDefault) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Default',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _showAddEditBotolDialog(botol: botol),
            ),
            if (!botol.isDefault)
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _showDeleteConfirmation(botol),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getBottleIcon(String iconType) {
    switch (iconType) {
      case 'bottle':
        return Icons.local_drink;
      case 'bottle_small':
        return Icons.water_drop;
      case 'cup':
        return Icons.free_breakfast;
      case 'glass':
        return Icons.local_bar;
      default:
        return Icons.water;
    }
  }

  void _showAddEditBotolDialog({Botol? botol}) {
    final isEditing = botol != null;
    final formKey = GlobalKey<FormState>();
    final namaController = TextEditingController(text: botol?.nama ?? '');
    final ukuranController = TextEditingController(
      text: botol?.ukuran != null ? botol!.ukuran.toInt().toString() : '',
    );
    
    String selectedIconType = botol?.iconType ?? 'bottle';
    Color selectedColor = botol != null
        ? Color(int.parse('0xFF${botol.warna.substring(1)}'))
        : Colors.blue;
    bool isDefault = botol?.isDefault ?? false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: Text(isEditing ? 'Edit Botol/Gelas' : 'Tambah Botol/Gelas'),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: namaController,
                      decoration: const InputDecoration(
                        labelText: 'Nama',
                        hintText: 'Contoh: Botol Kesayangan',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: ukuranController,
                      decoration: const InputDecoration(
                        labelText: 'Ukuran (ml)',
                        hintText: 'Contoh: 500',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ukuran tidak boleh kosong';
                        }
                        final ukuran = int.tryParse(value);
                        if (ukuran == null || ukuran <= 0) {
                          return 'Ukuran harus berupa angka positif';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text('Pilih Jenis Ikon:'),
                    const SizedBox(height: 8),
                    _buildIconTypeSelector(selectedIconType, (newType) {
                      setStateDialog(() {
                        selectedIconType = newType;
                      });
                    }),
                    const SizedBox(height: 16),
                    const Text('Pilih Warna:'),
                    const SizedBox(height: 8),
                    BlockPicker(
                      pickerColor: selectedColor,
                      onColorChanged: (color) {
                        setStateDialog(() {
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
                    const SizedBox(height: 16),
                    CheckboxListTile(
                      title: const Text('Jadikan Default'),
                      value: isDefault,
                      onChanged: (value) {
                        setStateDialog(() {
                          isDefault = value ?? false;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    final nama = namaController.text;
                    final ukuran = double.parse(ukuranController.text);
                    final warna = '#${selectedColor.value.toRadixString(16).substring(2)}';
                    
                    Navigator.of(context).pop();
                    
                    setState(() => _isLoading = true);
                    
                    try {
                      if (isEditing) {
                        await BotolService.updateBotol(
                          botol!.id,
                          nama,
                          ukuran,
                          warna,
                          selectedIconType,
                          isDefault,
                        );
                      } else {
                        await BotolService.addBotol(
                          nama,
                          ukuran,
                          warna,
                          selectedIconType,
                          isDefault,
                        );
                      }
                      
                      await _loadBotol();
                      
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isEditing
                                  ? 'Botol berhasil diperbarui'
                                  : 'Botol berhasil ditambahkan',
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                      setState(() => _isLoading = false);
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: Text(isEditing ? 'Simpan' : 'Tambah'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildIconTypeSelector(String selectedType, Function(String) onSelect) {
    final iconTypes = [
      {'type': 'bottle', 'icon': Icons.local_drink, 'label': 'Botol'},
      {'type': 'bottle_small', 'icon': Icons.water_drop, 'label': 'Botol Kecil'},
      {'type': 'cup', 'icon': Icons.free_breakfast, 'label': 'Cangkir'},
      {'type': 'glass', 'icon': Icons.local_bar, 'label': 'Gelas'},
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: iconTypes.map((type) {
        final isSelected = type['type'] == selectedType;
        return InkWell(
          onTap: () => onSelect(type['type'] as String),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 64,
            height: 80,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.grey.shade300,
                width: 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  type['icon'] as IconData,
                  color: isSelected ? AppColors.primary : Colors.grey.shade600,
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  type['label'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? AppColors.primary : Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showDeleteConfirmation(Botol botol) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Botol/Gelas'),
        content: Text(
          'Apakah Anda yakin ingin menghapus ${botol.nama}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              setState(() => _isLoading = true);
              
              try {
                await BotolService.deleteBotol(botol.id);
                await _loadBotol();
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Botol berhasil dihapus'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
                setState(() => _isLoading = false);
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}