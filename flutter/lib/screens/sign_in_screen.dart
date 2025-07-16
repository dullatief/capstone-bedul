import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import '../widgets/auth/auth_text_field.dart';
import '../widgets/auth/auth_button.dart';
import 'sign_up_screen.dart';
import 'home/home_screen.dart';
import '../../config/api_config.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.masuk}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final userId = data['user_id'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('user_id', userId);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message']),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );

          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const HomeScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
              transitionDuration: const Duration(milliseconds: 500),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['error'] ?? 'Login gagal.'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.all(16),
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions and safe area
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;
    final safeAreaTop = mediaQuery.padding.top;
    final safeAreaBottom = mediaQuery.padding.bottom;
    final keyboardHeight = mediaQuery.viewInsets.bottom;

    // Calculate responsive dimensions
    final isSmallScreen = screenHeight < 700;
    final isTablet = screenWidth > 600;

    // Responsive padding and sizing
    final horizontalPadding =
        isTablet ? screenWidth * 0.15 : screenWidth * 0.06;
    final logoSize = isSmallScreen ? 40.0 : 48.0;
    final titleFontSize = isSmallScreen ? 20.0 : 24.0;
    final headerPadding = isSmallScreen ? 20.0 : 30.0;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final availableHeight = constraints.maxHeight;

              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: availableHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        // Header Section - Flexible height based on screen
                        Flexible(
                          flex: isSmallScreen ? 2 : 3,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                vertical: headerPadding,
                                horizontal: horizontalPadding,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Logo/Icon with responsive size
                                  Container(
                                    padding:
                                        EdgeInsets.all(isSmallScreen ? 16 : 20),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(
                                          isSmallScreen ? 16 : 20),
                                    ),
                                    child: Icon(
                                      Icons.water_drop,
                                      size: logoSize,
                                      color: Colors.white,
                                    ),
                                  ),

                                  SizedBox(height: isSmallScreen ? 12 : 16),

                                  // Title with responsive font size
                                  Text(
                                    'PREDIKSI AIR MINUM',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: titleFontSize,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.2,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Form Section - Expanded to fill remaining space
                        Expanded(
                          flex: isSmallScreen ? 5 : 4,
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: FadeTransition(
                              opacity: _fadeAnimation,
                              child: Container(
                                width: double.infinity,
                                margin: EdgeInsets.symmetric(
                                  horizontal: horizontalPadding,
                                ),
                                child: Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(isTablet ? 32 : 24),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: Form(
                                    key: _formKey,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Welcome text
                                        Text(
                                          'Selamat Datang!',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textPrimary,
                                            fontSize: isTablet ? 28 : 24,
                                          ),
                                        ),
                                        SizedBox(height: isSmallScreen ? 6 : 8),
                                        Text(
                                          'Masuk untuk melanjutkan ke aplikasi prediksi air minum',
                                          style: TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: isTablet ? 16 : 14,
                                          ),
                                        ),

                                        SizedBox(
                                            height: isSmallScreen ? 24 : 32),

                                        // Email field
                                        AuthTextField(
                                          label: 'Email',
                                          hintText: 'Masukkan email Anda',
                                          controller: _emailController,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          prefixIcon: const Icon(
                                            Icons.email_outlined,
                                            color: AppColors.textHint,
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Email tidak boleh kosong';
                                            }
                                            if (!RegExp(
                                                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                                .hasMatch(value)) {
                                              return 'Format email tidak valid';
                                            }
                                            return null;
                                          },
                                        ),

                                        SizedBox(
                                            height: isSmallScreen ? 16 : 20),

                                        // Password field
                                        AuthTextField(
                                          label: 'Kata Sandi',
                                          hintText: 'Masukkan kata sandi Anda',
                                          isPassword: true,
                                          controller: _passwordController,
                                          prefixIcon: const Icon(
                                            Icons.lock_outline,
                                            color: AppColors.textHint,
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Kata sandi tidak boleh kosong';
                                            }
                                            if (value.length < 6) {
                                              return 'Kata sandi minimal 6 karakter';
                                            }
                                            return null;
                                          },
                                        ),

                                        // Forgot password
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: TextButton(
                                            onPressed: () {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                      'Fitur dalam pengembangan'),
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                ),
                                              );
                                            },
                                            child: Text(
                                              'Lupa Kata Sandi?',
                                              style: TextStyle(
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.w500,
                                                fontSize: isTablet ? 16 : 14,
                                              ),
                                            ),
                                          ),
                                        ),

                                        SizedBox(
                                            height: isSmallScreen ? 20 : 24),

                                        // Login button - Full width
                                        SizedBox(
                                          width: double.infinity,
                                          child: AuthButton(
                                            text: 'Masuk',
                                            isLoading: _isLoading,
                                            onPressed: _isLoading
                                                ? null
                                                : () => _login(context),
                                          ),
                                        ),

                                        SizedBox(
                                            height: isSmallScreen ? 16 : 20),

                                        // Sign up link
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Belum punya akun?',
                                              style: TextStyle(
                                                fontSize: isTablet ? 16 : 14,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  PageRouteBuilder(
                                                    pageBuilder: (context,
                                                            animation,
                                                            secondaryAnimation) =>
                                                        const SignUpScreen(),
                                                    transitionsBuilder:
                                                        (context,
                                                            animation,
                                                            secondaryAnimation,
                                                            child) {
                                                      return SlideTransition(
                                                        position: Tween<Offset>(
                                                          begin: const Offset(
                                                              1.0, 0.0),
                                                          end: Offset.zero,
                                                        ).animate(animation),
                                                        child: child,
                                                      );
                                                    },
                                                  ),
                                                );
                                              },
                                              style: TextButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8),
                                              ),
                                              child: Text(
                                                'Daftar Sekarang',
                                                style: TextStyle(
                                                  fontSize: isTablet ? 16 : 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.primary,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Bottom spacing - Flexible for keyboard
                        if (keyboardHeight == 0)
                          Flexible(
                            flex: 1,
                            child: SizedBox(
                              height: isSmallScreen ? 16 : 24,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
