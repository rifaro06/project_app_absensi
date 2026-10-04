import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';

class IzinDialog extends StatefulWidget {
  final Future<void> Function(String reason) onSubmit;

  const IzinDialog({super.key, required this.onSubmit});

  static Future<void> show(
    BuildContext context, {
    required Future<void> Function(String reason) onSubmit,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => IzinDialog(onSubmit: onSubmit),
    );
  }

  @override
  State<IzinDialog> createState() => _IzinDialogState();
}

class _IzinDialogState extends State<IzinDialog> {
  final _reasonController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await widget.onSubmit(_reasonController.text.trim());
      if (mounted) {
        Navigator.pop(context);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: bottomInset + 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Formulir Pengajuan Izin',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Silakan tuliskan alasan ketidakhadiran Anda secara jelas.',
              style: TextStyle(fontSize: 13, color: AppColors.textGrey),
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Alasan Izin',
              hint: 'Contoh: Izin Sakit Demam, Keperluan Keluarga',
              controller: _reasonController,
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Alasan izin wajib diisi';
                }
                if (val.trim().length < 4) {
                  return 'Alasan izin terlalu singkat';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            AppButton(
              text: 'Kirim Pengajuan Izin',
              isLoading: _isLoading,
              onPressed: _handleSubmit,
            ),
          ],
        ),
      ),
    );
  }
}
