import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../notifiers/teacher_service_locator.dart';
import '../../notifiers/teacher_stats_notifier.dart';

class TeacherStatScreen extends StatefulWidget {
  const TeacherStatScreen({super.key});

  @override
  State<TeacherStatScreen> createState() => _TeacherStatScreenState();
}

class _TeacherStatScreenState extends State<TeacherStatScreen> {
  late final Map<String, dynamic> _notifiers;

  @override
  void initState() {
    super.initState();
    _initializeNotifiers();
  }

  Future<void> _initializeNotifiers() async {
    final prefs = await SharedPreferences.getInstance();
    _notifiers = await TeacherServiceLocator.setup(prefs);
    final statsNotifier = _notifiers['statsNotifier'] as TeacherStatsNotifier;
    await statsNotifier.load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChangeNotifierProvider.value(
        value:
            _notifiers['statsNotifier'] as TeacherStatsNotifier? ??
            TeacherStatsNotifier(fetchStatsUseCase: _mockUseCase),
        child: Consumer<TeacherStatsNotifier>(
          builder: (context, notifier, child) {
            if (notifier.loading) return const Center(child: CircularProgressIndicator());
            if (notifier.error != null) return Center(child: Text("Lỗi: ${notifier.error}"));
            final stat = notifier.stats;
            if (stat == null) return const Center(child: Text("Không có dữ liệu"));
            final completionRate = ((stat.taughtHours + stat.makeUpHours) / stat.totalHours * 100).toStringAsFixed(0);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  color: Colors.blue[600],
                  child: const Center(
                    child: Text(
                      "Thống kê lịch dạy",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue[400],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Text(
                                "${stat.semesterName} - ${stat.teacherName}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              GridView.count(
                                crossAxisCount: 2,
                                shrinkWrap: true,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                physics: const NeverScrollableScrollPhysics(),
                                children: [
                                  _buildStatCard(
                                    "${stat.taughtHours}",
                                    "Giờ đã dạy",
                                  ),
                                  _buildStatCard(
                                    "${stat.makeUpHours}",
                                    "Giờ dạy bù",
                                  ),
                                  _buildStatCard(
                                    "${stat.notTaughtHours}",
                                    "Giờ nghỉ",
                                  ),
                                  _buildStatCard(
                                    "$completionRate%",
                                    "Tỷ lệ hoàn thành",
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // Mock use case for fallback
  dynamic get _mockUseCase => null;

  Widget _buildStatCard(String value, String label) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}
