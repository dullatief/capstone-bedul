import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import 'dart:math' as math;
import '../../config/api_config.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _riwayat = [];
  String _selectedTimeRange = 'Minggu';
  final List<String> _timeRanges = ['Minggu', 'Bulan', 'Tahun'];

  @override
  void initState() {
    super.initState();
    _loadRiwayat();
  }

  Future<void> _loadRiwayat() async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId == null) {
        throw Exception('User ID tidak ditemukan');
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.riwayatPrediksi}/$userId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          if (data is List) {
            _riwayat = List<Map<String, dynamic>>.from(data);
          } else if (data is Map && data.containsKey('riwayat')) {
            _riwayat = List<Map<String, dynamic>>.from(data['riwayat'] ?? []);
          } else {
            _riwayat = [];
          }

          // Sort by date ascending
          _riwayat.sort((a, b) {
            try {
              final dateA = DateTime.parse(a['tanggal'].toString());
              final dateB = DateTime.parse(b['tanggal'].toString());
              return dateA.compareTo(dateB);
            } catch (e) {
              return 0;
            }
          });
        });
      } else {
        throw Exception('Gagal memuat data statistik');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Parse double safely from various types
  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        return 0.0;
      }
    }
    return 0.0;
  }

  List<Map<String, dynamic>> _getFilteredData() {
    if (_riwayat.isEmpty) return [];

    final now = DateTime.now();
    DateTime cutoffDate;

    switch (_selectedTimeRange) {
      case 'Minggu':
        cutoffDate = DateTime(now.year, now.month, now.day - 7);
        break;
      case 'Bulan':
        cutoffDate = DateTime(now.year, now.month - 1, now.day);
        break;
      case 'Tahun':
        cutoffDate = DateTime(now.year - 1, now.month, now.day);
        break;
      default:
        cutoffDate = DateTime(now.year, now.month, now.day - 7);
    }

    return _riwayat.where((item) {
      try {
        final date = DateTime.parse(item['tanggal'].toString());
        return date.isAfter(cutoffDate) &&
            date.isBefore(now.add(const Duration(days: 1)));
      } catch (e) {
        return false;
      }
    }).toList();
  }

  // Get chart data points
  List<FlSpot> _getChartPoints() {
    final filteredData = _getFilteredData();
    if (filteredData.isEmpty) return [];

    final List<FlSpot> spots = [];
    for (int i = 0; i < filteredData.length; i++) {
      final rekomendasi = _parseDouble(filteredData[i]['rekomendasi_air']);
      spots.add(FlSpot(i.toDouble(), rekomendasi));
    }
    return spots;
  }

  // Calculate stats
  Map<String, double> _calculateStats() {
    final filteredData = _getFilteredData();
    if (filteredData.isEmpty) {
      return {
        'average': 0.0,
        'max': 0.0,
        'min': 0.0,
        'total': 0.0,
      };
    }

    double total = 0.0;
    double max = double.negativeInfinity;
    double min = double.infinity;

    for (final item in filteredData) {
      final rekomendasi = _parseDouble(item['rekomendasi_air']);
      total += rekomendasi;
      max = math.max(max, rekomendasi);
      min = math.min(min, rekomendasi);
    }

    return {
      'average': total / filteredData.length,
      'max': max,
      'min': min,
      'total': total,
    };
  }

  @override
  Widget build(BuildContext context) {
    final stats = _calculateStats();
    final filteredData = _getFilteredData();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistik Konsumsi Air'),
        backgroundColor: AppColors.primary,
        elevation: 0,
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
                onRefresh: _loadRiwayat,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Time range selector
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Text(
                              'Tampilkan data: ',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: DropdownButton<String>(
                                value: _selectedTimeRange,
                                isExpanded: true,
                                underline: Container(),
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    setState(() {
                                      _selectedTimeRange = newValue;
                                    });
                                  }
                                },
                                items: _timeRanges
                                    .map<DropdownMenuItem<String>>(
                                        (String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Stats cards
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 1.5,
                        children: [
                          _buildStatCard(
                            title: 'Rata-rata Harian',
                            value: '${stats['average']?.toStringAsFixed(1)} L',
                            icon: Icons.show_chart,
                            color: Colors.blue,
                          ),
                          _buildStatCard(
                            title: 'Total Konsumsi',
                            value: '${stats['total']?.toStringAsFixed(1)} L',
                            icon: Icons.water_drop,
                            color: AppColors.primary,
                          ),
                          _buildStatCard(
                            title: 'Konsumsi Tertinggi',
                            value: '${stats['max']?.toStringAsFixed(1)} L',
                            icon: Icons.arrow_upward,
                            color: Colors.green,
                          ),
                          _buildStatCard(
                            title: 'Konsumsi Terendah',
                            value: '${stats['min']?.toStringAsFixed(1)} L',
                            icon: Icons.arrow_downward,
                            color: Colors.orange,
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      if (filteredData.isEmpty)
                        _buildEmptyState()
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Chart
                            _buildChartSection(),

                            const SizedBox(height: 20),

                            // Data table
                            _buildDataTable(),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection() {
    final chartData = _getChartPoints();
    final filteredData = _getFilteredData();

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Grafik Konsumsi Air',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= filteredData.length ||
                            value.toInt() < 0) {
                          return const SizedBox.shrink();
                        }

                        try {
                          final date = DateTime.parse(
                              filteredData[value.toInt()]['tanggal']
                                  .toString());
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              DateFormat('dd/MM').format(date),
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        } catch (e) {
                          return const SizedBox.shrink();
                        }
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: true),
                minX: 0,
                maxX:
                    chartData.isEmpty ? 10 : (chartData.length - 1).toDouble(),
                minY: 0,
                maxY: chartData.isEmpty
                    ? 5
                    : (chartData
                            .map((e) => e.y)
                            .reduce((a, b) => a > b ? a : b) *
                        1.2),
                lineBarsData: [
                  LineChartBarData(
                    spots: chartData,
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.primary.withOpacity(0.2),
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

  Widget _buildDataTable() {
    final filteredData = _getFilteredData();

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Riwayat Detail',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Tanggal')),
                DataColumn(label: Text('Rekomendasi')),
                DataColumn(label: Text('Aktivitas')),
              ],
              rows: filteredData.map((item) {
                try {
                  final date = DateTime.parse(item['tanggal'].toString());
                  final formattedDate = DateFormat('dd/MM/yyyy').format(date);
                  final rekomendasi =
                      _parseDouble(item['rekomendasi_air']).toStringAsFixed(1);
                  final aktivitas =
                      item['tingkat_aktivitas']?.toString() ?? '-';

                  return DataRow(cells: [
                    DataCell(Text(formattedDate)),
                    DataCell(Text('$rekomendasi L')),
                    DataCell(Text(aktivitas)),
                  ]);
                } catch (e) {
                  return const DataRow(cells: [
                    DataCell(Text('-')),
                    DataCell(Text('-')),
                    DataCell(Text('-')),
                  ]);
                }
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.bar_chart,
              size: 64,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Belum Ada Data',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Lakukan prediksi konsumsi air untuk melihat statistik',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
