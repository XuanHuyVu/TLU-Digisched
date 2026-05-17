import 'package:flutter/material.dart';
import '../../../domain/entities/schedule_entity.dart';

const _purpleColor = Color(0xFF6A1B9A);

class MakeupAttendanceScreen extends StatefulWidget {
  final ScheduleEntity item;
  final Future<void> Function(String reason, String? fileUrl) onSubmit;

  const MakeupAttendanceScreen({
    super.key,
    required this.item,
    required this.onSubmit,
  });

  @override
  State<MakeupAttendanceScreen> createState() => _MakeupAttendanceScreenState();
}

class _MakeupAttendanceScreenState extends State<MakeupAttendanceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  final _fileUrlController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _reasonController.dispose();
    _fileUrlController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final reason = _reasonController.text.trim();
      final fileUrl = _fileUrlController.text.trim();
      
      await widget.onSubmit(
        reason,
        fileUrl.isEmpty ? null : fileUrl,
      );

      if (!mounted) return;
      Navigator.of(context).pop(true); // Return success
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: _purpleColor,
        foregroundColor: Colors.white,
        title: const Text(
          'Điểm danh bù',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Thông tin buổi học
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _purpleColor.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: _purpleColor, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Thông tin buổi học',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  _buildInfoRow('Môn học:', widget.item.subjectName),
                  const SizedBox(height: 8),
                  _buildInfoRow('Lớp:', widget.item.classCode),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    'Ngày:',
                    widget.item.sessionDate != null
                        ? '${widget.item.sessionDate!.day}/${widget.item.sessionDate!.month}/${widget.item.sessionDate!.year}'
                        : 'N/A',
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow('Tiết:', widget.item.periodText),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Lý do điểm danh bù
            const Text(
              'Lý do điểm danh bù *',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _reasonController,
              maxLines: 5,
              maxLength: 500,
              decoration: InputDecoration(
                hintText: 'Nhập lý do điểm danh bù (tối thiểu 10 ký tự)...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _purpleColor, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.red),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập lý do';
                }
                if (value.trim().length < 10) {
                  return 'Lý do phải có ít nhất 10 ký tự';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // File đính kèm (optional)
            const Text(
              'File đính kèm (tùy chọn)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _fileUrlController,
              decoration: InputDecoration(
                hintText: 'Nhập URL file đính kèm (nếu có)...',
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.attach_file),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _purpleColor, width: 2),
                ),
              ),
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final uri = Uri.tryParse(value);
                  if (uri == null || !uri.hasScheme) {
                    return 'URL không hợp lệ';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            Text(
              'Ví dụ: https://drive.google.com/file/...',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 32),

            // Nút submit
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _purpleColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Gửi điểm danh bù',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),

            // Lưu ý
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning_amber, color: Colors.orange.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Lưu ý: Điểm danh bù cần có lý do chính đáng. Thông tin sẽ được ghi nhận và có thể được xem xét bởi quản lý.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.orange.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
