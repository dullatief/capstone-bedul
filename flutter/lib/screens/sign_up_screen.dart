import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config/api_config.dart';
import '../theme/app_colors.dart';
import '../widgets/auth/auth_header.dart';
import '../widgets/auth/auth_text_field.dart';
import '../widgets/auth/auth_button.dart';
import '../widgets/auth/auth_container.dart';
import '../widgets/auth/auth_footer.dart';
import 'sign_in_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentStep = 0;
  bool _isLoading = false;

  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _usiaController = TextEditingController();
  final TextEditingController _beratController = TextEditingController();
  final TextEditingController _tinggiController = TextEditingController();

  String? _jenisKelamin;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
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
    _pageController.dispose();
    _namaController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _usiaController.dispose();
    _beratController.dispose();
    _tinggiController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (_jenisKelamin == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih jenis kelamin')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final registerResponse = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.daftar}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text.trim(),
          'password': _passwordController.text.trim(),
          'nama': _namaController.text.trim(),
          'usia': int.parse(_usiaController.text.trim()),
          'berat_badan': double.parse(_beratController.text.trim()),
          'tinggi_badan': double.parse(_tinggiController.text.trim()),
          'jenis_kelamin': _jenisKelamin,
        }),
      );

      final registerData = jsonDecode(registerResponse.body);

      if (registerResponse.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(registerData['message'] ?? 'Registrasi berhasil'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );

          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const SignInScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(registerData['error'] ?? 'Registrasi gagal.'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _nextStep() {
    if (_currentStep == 0) {
      // Validate step 1
      if (_namaController.text.isEmpty ||
          _emailController.text.isEmpty ||
          _passwordController.text.isEmpty ||
          _confirmPasswordController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mohon lengkapi semua field pada langkah ini'),
            backgroundColor: AppColors.warning,
          ),
        );
        return;
      }

      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Konfirmasi password tidak sama'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
    }

    if (_currentStep < 1) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _register();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 16), // Kurangi padding
                  child: const AuthHeader(title: 'DAFTAR AKUN BARU'),
                ),
              ),

              // Progress indicator
              Container(
                margin: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 8), // Kurangi margin
                child: Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: (_currentStep + 1) / 2,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(Colors.white),
                        minHeight: 4,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${_currentStep + 1}/2',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0), // Kurangi padding
                      child: AuthContainer(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _currentStep == 0
                                    ? 'Informasi Akun'
                                    : 'Data Pribadi',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                              ),

                              const SizedBox(height: 8),

                              Text(
                                _currentStep == 0
                                    ? 'Masukkan email dan password untuk akun Anda'
                                    : 'Lengkapi data pribadi untuk prediksi yang akurat',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                textAlign: TextAlign.center,
                              ),

                              const SizedBox(height: 24), // Kurangi spacing

                              SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    0.4, // Set height berdasarkan screen
                                child: PageView(
                                  controller: _pageController,
                                  physics: const NeverScrollableScrollPhysics(),
                                  children: [
                                    _buildStep1(),
                                    _buildStep2(),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 16), // Kurangi spacing

                              Row(
                                children: [
                                  if (_currentStep > 0)
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: _previousStep,
                                        style: OutlinedButton.styleFrom(
                                          side: const BorderSide(
                                              color: AppColors.primary),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 14), // Kurangi padding
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: const Text(
                                          'Kembali',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  if (_currentStep > 0)
                                    const SizedBox(width: 16),
                                  Expanded(
                                    flex: _currentStep == 0 ? 1 : 1,
                                    child: AuthButton(
                                      text: _currentStep == 1
                                          ? 'Daftar'
                                          : 'Lanjutkan',
                                      isLoading: _isLoading,
                                      onPressed: _isLoading ? null : _nextStep,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16), // Kurangi spacing

                              // Sign in link
                              AuthFooter(
                                text: 'Sudah punya akun?',
                                linkText: 'Masuk Sekarang',
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation,
                                              secondaryAnimation) =>
                                          const SignInScreen(),
                                      transitionsBuilder: (context, animation,
                                          secondaryAnimation, child) {
                                        return SlideTransition(
                                          position: Tween<Offset>(
                                            begin: const Offset(-1.0, 0.0),
                                            end: Offset.zero,
                                          ).animate(animation),
                                          child: child,
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      child: Column(
        children: [
          AuthTextField(
            label: 'Nama Lengkap',
            hintText: 'Masukkan nama lengkap Anda',
            controller: _namaController,
            prefixIcon:
                const Icon(Icons.person_outline, color: AppColors.textHint),
          ),
          const SizedBox(height: 16),
          AuthTextField(
            label: 'Email',
            hintText: 'Masukkan email Anda',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            prefixIcon:
                const Icon(Icons.email_outlined, color: AppColors.textHint),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Email tidak boleh kosong';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                  .hasMatch(value)) {
                return 'Format email tidak valid';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          AuthTextField(
            label: 'Kata Sandi',
            hintText: 'Masukkan kata sandi',
            isPassword: true,
            controller: _passwordController,
            prefixIcon:
                const Icon(Icons.lock_outline, color: AppColors.textHint),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Kata sandi tidak boleh kosong';
              }
              if (value.length < 6) {
                return 'Kata sandi minimal 6 karakter';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          AuthTextField(
            label: 'Konfirmasi Kata Sandi',
            hintText: 'Masukkan ulang kata sandi',
            isPassword: true,
            controller: _confirmPasswordController,
            prefixIcon:
                const Icon(Icons.lock_outline, color: AppColors.textHint),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Konfirmasi kata sandi tidak boleh kosong';
              }
              if (value != _passwordController.text) {
                return 'Konfirmasi kata sandi tidak sama';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Row untuk Usia dan Jenis Kelamin
          Row(
            children: [
              Expanded(
                child: AuthTextField(
                  label: 'Usia',
                  hintText: 'Tahun',
                  controller: _usiaController,
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.cake_outlined,
                      color: AppColors.textHint),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Usia tidak boleh kosong';
                    }
                    final usia = int.tryParse(value);
                    if (usia == null || usia < 1 || usia > 120) {
                      return 'Usia tidak valid';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Jenis Kelamin',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.divider),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: _jenisKelamin,
                        decoration: const InputDecoration(
                          hintText: 'Pilih',
                          prefixIcon: Icon(Icons.wc_outlined,
                              color: AppColors.textHint),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                        ),
                        items: const [
                          DropdownMenuItem(
                              value: 'L', child: Text('Laki-laki')),
                          DropdownMenuItem(
                              value: 'P', child: Text('Perempuan')),
                        ],
                        onChanged: (value) =>
                            setState(() => _jenisKelamin = value),
                        validator: (value) {
                          if (value == null) {
                            return 'Jenis kelamin harus dipilih';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Row untuk Berat dan Tinggi
          Row(
            children: [
              Expanded(
                child: AuthTextField(
                  label: 'Berat Badan',
                  hintText: 'kg',
                  controller: _beratController,
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.monitor_weight_outlined,
                      color: AppColors.textHint),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Berat badan tidak boleh kosong';
                    }
                    final berat = double.tryParse(value);
                    if (berat == null || berat < 1 || berat > 500) {
                      return 'Berat badan tidak valid';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AuthTextField(
                  label: 'Tinggi Badan',
                  hintText: 'cm',
                  controller: _tinggiController,
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.height_outlined,
                      color: AppColors.textHint),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Tinggi badan tidak boleh kosong';
                    }
                    final tinggi = double.tryParse(value);
                    if (tinggi == null || tinggi < 50 || tinggi > 300) {
                      return 'Tinggi badan tidak valid';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Info card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: AppColors.primary,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Data ini akan digunakan untuk menghitung kebutuhan air minum yang sesuai dengan kondisi tubuh Anda.',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.primary.withOpacity(0.8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
