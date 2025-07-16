import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../theme/app_colors.dart';
import '../../widgets/auth/auth_header.dart';
import '../../widgets/auth/auth_text_field.dart';
import '../../widgets/auth/auth_button.dart';
import '../../widgets/auth/auth_container.dart';
import '../../config/api_config.dart';

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _usiaController = TextEditingController();
  final TextEditingController _beratController = TextEditingController();
  final TextEditingController _tinggiController = TextEditingController();
  String? _jenisKelamin;
  bool _isLoading = false;

  Future<void> _submitProfile() async {
    if (!_formKey.currentState!.validate() || _jenisKelamin == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap lengkapi semua kolom')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId == null) throw Exception('User ID tidak ditemukan');

      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.simpanProfil}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'nama': _namaController.text,
          'usia': int.parse(_usiaController.text),
          'berat_badan': double.parse(_beratController.text),
          'tinggi_badan': double.parse(_tinggiController.text),
          'jenis_kelamin': _jenisKelamin,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'])),
        );
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['error'] ?? 'Gagal menyimpan profil')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    }

    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _namaController.dispose();
    _usiaController.dispose();
    _beratController.dispose();
    _tinggiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Container(
            height: 300,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const AuthHeader(title: 'PROFIL PENGGUNA'),
                  Transform.translate(
                    offset: const Offset(0, 20),
                    child: AuthContainer(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Lengkapi Data Anda',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Digunakan untuk menghitung kebutuhan air harian.',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 32),
                            AuthTextField(
                              controller: _namaController,
                              label: 'Nama',
                              hintText: 'Masukkan nama Anda',
                            ),
                            const SizedBox(height: 16),
                            AuthTextField(
                              controller: _usiaController,
                              label: 'Usia',
                              hintText: 'Masukkan usia Anda',
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 16),
                            AuthTextField(
                              controller: _beratController,
                              label: 'Berat Badan (kg)',
                              hintText: 'Masukkan berat badan',
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 16),
                            AuthTextField(
                              controller: _tinggiController,
                              label: 'Tinggi Badan (cm)',
                              hintText: 'Masukkan tinggi badan',
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: 'Jenis Kelamin',
                                border: OutlineInputBorder(),
                              ),
                              value: _jenisKelamin,
                              items: const [
                                DropdownMenuItem(
                                    value: 'L', child: Text('Laki-laki')),
                                DropdownMenuItem(
                                    value: 'P', child: Text('Perempuan')),
                              ],
                              onChanged: (val) =>
                                  setState(() => _jenisKelamin = val),
                              validator: (val) =>
                                  val == null ? 'Wajib dipilih' : null,
                            ),
                            const SizedBox(height: 32),
                            AuthButton(
                              text:
                                  _isLoading ? 'Menyimpan...' : 'Simpan Profil',
                              onPressed: _isLoading ? null : _submitProfile,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
