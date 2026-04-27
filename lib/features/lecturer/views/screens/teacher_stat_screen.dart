import 'package:flutter/material.dart';
import '../../models/teacher_stat_model.dart';
import '../../services/teacher_stat_service.dart';

class TeacherStatScreen extends StatefulWidget {
  const TeacherStatScreen({super.key});

  @override
  State<TeacherStatScreen> createState() => _TeacherStatScreenState();
}

class _TeacherStatScreenState extends State<TeacherStatScreen> {
  late Future<List<TeacherStat>> futureStats;

  String selectedSemester = "2";
  String selectedYear = "2024-2025";

  final List<String> semesters = ["1", "2", "3"];
  final List<String> years = ["2023-2024", "2024-2025", "2025-2026"];

  @override
  void initState() {
    super.initState();
    futureStats = TeacherStatService().getStats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<TeacherStat>>(
        future: futureStats,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Lỗi: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Không có dữ liệu"));
          }

          final stat = snapshot.data!.first;
          final completionRate =
          ((stat.taughtHours + stat.makeUpHours) / stat.totalHours * 100)
              .toStringAsFixed(0);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Header dính sát trên cùng
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
                      // 🔹 Bộ lọc học kỳ & năm học
                      Row(
                        children: [
                          const Text("Chọn học kỳ thống kê: "),
                          const SizedBox(width: 8),
                          DropdownButton<String>(
                            value: selectedSemester,
                            items: semesters
                                .map((s) =>
                                DropdownMenuItem(value: s, child: Text(s)))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedSemester = value!;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Text("Chọn năm học: "),
                          const SizedBox(width: 8),
                          DropdownButton<String>(
                            value: selectedYear,
                            items: years
                                .map((y) =>
                                DropdownMenuItem(value: y, child: Text(y)))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedYear = value!;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // 🔹 Card thống kê
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue[400],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              "Học kỳ: $selectedSemester - Năm học: $selectedYear",
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
                                    "${stat.taughtHours}", "Giờ đã dạy"),
                                _buildStatCard(
                                    "${stat.makeUpHours}", "Giờ dạy bù"),
                                _buildStatCard(
                                    "${stat.notTaughtHours}", "Giờ nghỉ"),
                                _buildStatCard(
                                    "$completionRate%", "Tỷ lệ hoàn thành"),
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
    );
  }

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
