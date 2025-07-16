import 'package:flutter/material.dart';
import '../../models/pertemanan.dart';
import '../../services/pertemanan_service.dart';
import '../../theme/app_colors.dart';

class TemanScreen extends StatefulWidget {
  const TemanScreen({Key? key}) : super(key: key);

  @override
  State<TemanScreen> createState() => _TemanScreenState();
}

class _TemanScreenState extends State<TemanScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String? _errorMessage;

  List<Teman> _daftarTeman = [];
  List<Teman> _permintaanTeman = [];

  final TextEditingController _emailController = TextEditingController();
  bool _isAddingFriend = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadTeman();
  }

  Future<void> _loadTeman() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      List<Teman> daftarTeman = [];
      try {
        daftarTeman = await PertemananService.getDaftarTeman();
      } catch (e) {
        debugPrint('Error loading friends: $e');
      }

      List<Teman> permintaanTeman = [];
      try {
        permintaanTeman = await PertemananService.getPermintaanPertemanan();
      } catch (e) {
        debugPrint('Error loading friend requests: $e');
      }

      if (mounted) {
        setState(() {
          _daftarTeman = daftarTeman;
          _permintaanTeman = permintaanTeman;
          _isLoading = false;

          if (daftarTeman.isEmpty && permintaanTeman.isEmpty) {
            _errorMessage = 'Gagal memuat data pertemanan';
          }
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

  Future<void> _tambahTeman() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email tidak boleh kosong'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isAddingFriend = true);

    try {
      final success = await PertemananService.tambahTeman(email);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permintaan pertemanan berhasil dikirim'),
            backgroundColor: Colors.green,
          ),
        );
        _emailController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal mengirim permintaan pertemanan'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isAddingFriend = false);
      }
    }
  }

  Future<void> _responPermintaanPertemanan(Teman teman, bool accept) async {
    final bool? konfirmasi = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(accept ? 'Terima Permintaan' : 'Tolak Permintaan'),
        content: Text(
          accept
              ? 'Apakah Anda yakin ingin menerima permintaan pertemanan dari ${teman.nama}?'
              : 'Apakah Anda yakin ingin menolak permintaan pertemanan dari ${teman.nama}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: accept ? Colors.green : Colors.red,
            ),
            child: Text(accept ? 'Terima' : 'Tolak'),
          ),
        ],
      ),
    );

    if (konfirmasi != true) return;

    try {
      setState(() {
        teman.isProcessing = true;
      });

      final success =
          await PertemananService.responPermintaanPertemanan(teman.id, accept);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              accept
                  ? 'Anda telah menerima permintaan pertemanan dari ${teman.nama}'
                  : 'Anda telah menolak permintaan pertemanan dari ${teman.nama}',
            ),
            backgroundColor: accept ? Colors.green : Colors.orange,
          ),
        );

        // Refresh data
        _loadTeman();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal merespons permintaan pertemanan'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          if (teman.isProcessing) teman.isProcessing = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        if (teman.isProcessing) teman.isProcessing = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, true);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Teman'),
          backgroundColor: AppColors.primary,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context, true);
            },
          ),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Teman Saya'),
              Tab(text: 'Permintaan'),
            ],
            indicatorColor: Colors.white,
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? _buildErrorScreen()
                : TabBarView(
                    controller: _tabController,
                    children: [
                      // Tab Daftar Teman
                      _buildDaftarTemanTab(),

                      // Tab Permintaan Pertemanan
                      _buildPermintaanTab(),
                    ],
                  ),
        // FAB untuk menambahkan teman
        floatingActionButton: FloatingActionButton(
          onPressed: _showAddFriendDialog,
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.person_add),
        ),
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
            onPressed: _loadTeman,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildDaftarTemanTab() {
    if (_daftarTeman.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.people_outline,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'Belum ada teman',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tambahkan teman untuk mengundang mereka berpartisipasi dalam kompetisi',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _showAddFriendDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              icon: const Icon(Icons.person_add),
              label: const Text('Tambah Teman'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTeman,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _daftarTeman.length,
        itemBuilder: (context, index) {
          final teman = _daftarTeman[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primary.withOpacity(0.2),
                child: Text(
                  teman.nama.isNotEmpty ? teman.nama[0].toUpperCase() : '?',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(teman.nama),
              subtitle: Text(teman.email),
            ),
          );
        },
      ),
    );
  }

  // Update metode _buildPermintaanTab
  Widget _buildPermintaanTab() {
    if (_permintaanTeman.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.mark_email_unread_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Tidak ada permintaan pertemanan',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTeman,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _permintaanTeman.length,
        itemBuilder: (context, index) {
          final teman = _permintaanTeman[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.orange.withOpacity(0.2),
                child: Text(
                  teman.nama.isNotEmpty ? teman.nama[0].toUpperCase() : '?',
                  style: const TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(teman.nama),
              subtitle: Text(teman.email),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.green),
                    onPressed: () => _responPermintaanPertemanan(teman, true),
                    tooltip: 'Terima permintaan',
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () => _responPermintaanPertemanan(teman, false),
                    tooltip: 'Tolak permintaan',
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAddFriendDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Teman'),
        content: TextField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'Email Teman',
            hintText: 'contoh@email.com',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: _isAddingFriend
                ? null
                : () {
                    Navigator.pop(context);
                    _tambahTeman();
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: _isAddingFriend
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Tambah'),
          ),
        ],
      ),
    );
  }
}
