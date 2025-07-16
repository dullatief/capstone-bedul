import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../../services/donasi_service.dart';
import '../../theme/app_colors.dart';
import 'payment_webview.dart';
import 'riwayat_donasi_screen.dart';

class DonasiScreen extends StatefulWidget {
  const DonasiScreen({Key? key}) : super(key: key);

  @override
  State<DonasiScreen> createState() => _DonasiScreenState();
}

class _DonasiScreenState extends State<DonasiScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  final _customAmountController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isLoading = false;
  int? _selectedAmount;

  final List<Map<String, dynamic>> _predefinedAmounts = [
    {
      'amount': 5000,
      'label': 'Rp 5.000',
      'emoji': '☕',
      'description': 'Secangkir kopi'
    },
    {
      'amount': 10000,
      'label': 'Rp 10.000',
      'emoji': '🍔',
      'description': 'Burger kecil'
    },
    {
      'amount': 25000,
      'label': 'Rp 25.000',
      'emoji': '🍕',
      'description': 'Sepotong pizza'
    },
    {
      'amount': 50000,
      'label': 'Rp 50.000',
      'emoji': '🍽️',
      'description': 'Makan siang'
    },
    {
      'amount': 100000,
      'label': 'Rp 100.000',
      'emoji': '🎉',
      'description': 'Support besar'
    },
    {
      'amount': 0,
      'label': 'Custom',
      'emoji': '💝',
      'description': 'Jumlah sendiri'
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    _customAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Dukung Developer'),
        backgroundColor: AppColors.primary,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(12), // Reduced from 16
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 16), // Reduced from 24
                _buildDonationForm(),
                const SizedBox(height: 16), // Reduced from 24
                _buildHistorySection(),
                const SizedBox(height: 20), // Bottom padding for safe area
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20), // Reduced padding
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10), // Reduced padding
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10), // Reduced radius
                ),
                child: const Icon(
                  Icons.favorite,
                  color: Colors.white,
                  size: 24, // Reduced size
                ),
              ),
              const SizedBox(width: 12), // Reduced spacing
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dukung Pengembangan',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18, // Reduced font size
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Prediksi Air Minum App',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14, // Reduced font size
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12), // Reduced spacing
          const Text(
            'Aplikasi ini gratis dan akan terus dikembangkan. Dukungan Anda sangat berarti!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13, // Reduced font size
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonationForm() {
    return Container(
      padding: const EdgeInsets.all(16), // Reduced from 24
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
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pilih Jumlah Donasi',
              style: TextStyle(
                fontSize: 16, // Reduced from 18
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12), // Reduced from 16
            _buildAmountSelector(),
            const SizedBox(height: 16), // Reduced from 24
            _buildDonorInfo(),
            const SizedBox(height: 16), // Reduced from 24
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountSelector() {
    return Column(
      children: [
        // Grid dengan layout yang lebih compact
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 3.8, // Increased ratio untuk mengurangi tinggi
          ),
          itemCount: _predefinedAmounts.length,
          itemBuilder: (context, index) {
            final item = _predefinedAmounts[index];
            final isSelected = _selectedAmount == item['amount'];

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedAmount = item['amount'];
                  if (item['amount'] == 0) {
                    _customAmountController.clear();
                  }
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                    horizontal: 6, vertical: 4), // Reduced padding
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.grey[50],
                  borderRadius: BorderRadius.circular(8), // Reduced radius
                  border: Border.all(
                    color: isSelected ? AppColors.primary : Colors.grey[300]!,
                    width: 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  // Ubah dari Column ke Row untuk lebih compact
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item['emoji'],
                      style: const TextStyle(fontSize: 14), // Reduced font size
                    ),
                    const SizedBox(width: 6), // Horizontal spacing
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['label'],
                            style: TextStyle(
                              fontSize: 11, // Reduced font size
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : Colors.black87,
                            ),
                          ),
                          Text(
                            item['description'],
                            style: TextStyle(
                              fontSize: 8, // Very small font for description
                              color: isSelected
                                  ? Colors.white70
                                  : Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        // Custom amount input
        if (_selectedAmount == 0) ...[
          const SizedBox(height: 12), // Reduced spacing
          Container(
            padding: const EdgeInsets.all(12), // Reduced padding
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10), // Reduced radius
              border: Border.all(
                color: AppColors.primary.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.edit_outlined,
                      size: 14, // Reduced icon size
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Masukkan Jumlah Custom',
                      style: TextStyle(
                        fontSize: 12, // Reduced font size
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8), // Reduced spacing
                TextFormField(
                  controller: _customAmountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: InputDecoration(
                    labelText: 'Jumlah (Rupiah)',
                    hintText: 'Contoh: 15000',
                    prefixText: 'Rp ',
                    prefixStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      fontSize: 12, // Reduced font size
                    ),
                    labelStyle:
                        const TextStyle(fontSize: 12), // Reduced label size
                    hintStyle:
                        const TextStyle(fontSize: 12), // Reduced hint size
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6), // Reduced radius
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 8, // Reduced vertical padding
                      horizontal: 12,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    isDense: true, // Make field more compact
                  ),
                  style:
                      const TextStyle(fontSize: 12), // Reduced input text size
                  validator: (value) {
                    if (_selectedAmount == 0) {
                      if (value == null || value.isEmpty) {
                        return 'Masukkan jumlah donasi';
                      }
                      final amount = int.tryParse(value);
                      if (amount == null || amount < 1000) {
                        return 'Minimal donasi Rp 1.000';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 6), // Reduced spacing
                Text(
                  '💡 Minimum donasi Rp 1.000',
                  style: TextStyle(
                    fontSize: 10, // Reduced font size
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDonorInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Informasi Donatur (Opsional)',
          style: TextStyle(
            fontSize: 14, // Reduced from 16
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8), // Reduced from 12
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Nama',
            hintText: 'Nama Anda',
            border: OutlineInputBorder(),
            prefixIcon:
                Icon(Icons.person_outline, size: 20), // Reduced icon size
            contentPadding: EdgeInsets.symmetric(
                vertical: 8, horizontal: 12), // Reduced padding
            isDense: true, // Make field more compact
          ),
          style: const TextStyle(fontSize: 13), // Reduced font size
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Nama tidak boleh kosong';
            }
            return null;
          },
        ),
        const SizedBox(height: 10), // Reduced from 16
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Email (Opsional)',
            hintText: 'email@example.com',
            border: OutlineInputBorder(),
            prefixIcon:
                Icon(Icons.email_outlined, size: 20), // Reduced icon size
            contentPadding: EdgeInsets.symmetric(
                vertical: 8, horizontal: 12), // Reduced padding
            isDense: true, // Make field more compact
          ),
          style: const TextStyle(fontSize: 13), // Reduced font size
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                  .hasMatch(value)) {
                return 'Format email tidak valid';
              }
            }
            return null;
          },
        ),
        const SizedBox(height: 10), // Reduced from 16
        TextFormField(
          controller: _messageController,
          maxLines: 2, // Reduced from 3
          decoration: const InputDecoration(
            labelText: 'Pesan untuk Developer (Opsional)',
            hintText: 'Tulis pesan dukungan Anda...',
            border: OutlineInputBorder(),
            prefixIcon:
                Icon(Icons.message_outlined, size: 20), // Reduced icon size
            contentPadding: EdgeInsets.symmetric(
                vertical: 8, horizontal: 12), // Reduced padding
            isDense: true, // Make field more compact
          ),
          style: const TextStyle(fontSize: 13), // Reduced font size
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _processDonation,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.payment),
                  SizedBox(width: 8),
                  Text(
                    'Lanjutkan Pembayaran',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildHistorySection() {
    return Container(
      padding: const EdgeInsets.all(24),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.history, color: AppColors.primary),
              const SizedBox(width: 8),
              const Text(
                'Riwayat Donasi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: _showDonationHistory,
                child: const Text('Lihat Semua'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Terima kasih untuk semua dukungan yang telah diberikan!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _processDonation() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedAmount == null) {
      _showSnackBar('Pilih jumlah donasi terlebih dahulu', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      int finalAmount = _selectedAmount!;
      if (_selectedAmount == 0) {
        finalAmount = int.parse(_customAmountController.text);
      }

      final result = await DonasiService.createDonation(
        amount: finalAmount,
        donorName: _nameController.text.trim(),
        message: _messageController.text.trim(),
        email: _emailController.text.trim(),
      );

      if (result['success'] && mounted) {
        // Navigate to payment webview
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentWebView(
              paymentUrl: result['redirect_url'],
              orderId: result['order_id'],
            ),
          ),
        ).then((paymentResult) {
          if (paymentResult == true) {
            _showSnackBar('Terima kasih atas donasi Anda!', isError: false);
            _resetForm();
          }
        });
      }
    } catch (e) {
      _showSnackBar('Error: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _resetForm() {
    setState(() {
      _selectedAmount = null;
    });
    _nameController.clear();
    _emailController.clear();
    _messageController.clear();
    _customAmountController.clear();
  }

  void _showDonationHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RiwayatDonasiScreen(),
      ),
    );
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
