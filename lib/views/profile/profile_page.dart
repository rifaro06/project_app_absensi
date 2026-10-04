import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/constants/app_colors.dart';
import '../../core/storage/storage_service.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../core/widgets/app_text_field.dart';
import '../../models/user_model.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../services/profile_service.dart';
import '../../main.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _profileService = ProfileService();
  final _authService = AuthService();
  final _picker = ImagePicker();

  UserModel? _user;
  String? _photoPath;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);

    // Ambil data offline terlebih dahulu
    final id = await StorageService.getUserId() ?? 0;
    final name = await StorageService.getUserName() ?? '';
    final email = await StorageService.getUserEmail() ?? '';
    final photo = id > 0 ? await StorageService.getUserPhoto(id) : null;

    if (mounted && name.isNotEmpty) {
      setState(() {
        _user = UserModel(id: id, name: name, email: email);
        _photoPath = photo;
      });
    }

    try {
      final remoteUser = await _profileService.getProfile();
      final freshPhoto = await StorageService.getUserPhoto(remoteUser.id);
      if (mounted) {
        setState(() {
          _user = remoteUser;
          _photoPath = freshPhoto;
        });
      }
    } catch (_) {
      // Jika offline, tetap gunakan data dari storage
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Pilih foto dari Kamera atau Galeri
  Future<void> _pickPhoto(ImageSource source) async {
    if (_user == null || _user!.id <= 0) {
      AppSnackbar.showError(context, 'Data pengguna belum siap.');
      return;
    }

    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 600,
        maxHeight: 600,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      await StorageService.saveUserPhoto(_user!.id, pickedFile.path);

      if (mounted) {
        setState(() => _photoPath = pickedFile.path);
        AppSnackbar.showSuccess(context, 'Foto profil berhasil diperbarui!');
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.showError(context, 'Gagal memilih foto: $e');
      }
    }
  }

  // Hapus foto profil
  Future<void> _removePhoto() async {
    if (_user == null || _user!.id <= 0) return;

    await StorageService.removeUserPhoto(_user!.id);
    if (mounted) {
      setState(() => _photoPath = null);
      AppSnackbar.showSuccess(context, 'Foto profil dihapus.');
    }
  }

  // Modal pilihan sumber foto
  void _showPhotoOptions() {
    final hasPhoto =
        _photoPath != null &&
        _photoPath!.isNotEmpty &&
        File(_photoPath!).existsSync();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Text(
                  'Foto Profil',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(
                    Icons.camera_alt_rounded,
                    color: AppColors.primary,
                  ),
                  title: const Text('Ambil dari Kamera'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickPhoto(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.photo_library_rounded,
                    color: AppColors.primary,
                  ),
                  title: const Text('Pilih dari Galeri'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickPhoto(ImageSource.gallery);
                  },
                ),
                if (hasPhoto)
                  ListTile(
                    leading: const Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.red,
                    ),
                    title: const Text(
                      'Hapus Foto Profil',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _removePhoto();
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showEditNameDialog() async {
    final nameController = TextEditingController(text: _user?.name ?? '');
    final formKey = GlobalKey<FormState>();

    final updated = await showDialog<bool>(
      context: context,
      builder: (context) {
        bool isSubmitting = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                'Ubah Nama Profil',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: AppTextField(
                    label: 'Nama Lengkap',
                    hint: 'Masukkan nama baru',
                    controller: nameController,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Nama tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              actions: [
                TextButton(
                  onPressed: isSubmitting ? null : () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;

                          setDialogState(() => isSubmitting = true);

                          try {
                            final updatedUser = await _profileService
                                .updateProfileName(nameController.text);
                            if (context.mounted) {
                              setState(() => _user = updatedUser);
                              Navigator.pop(context, true);
                            }
                          } catch (e) {
                            if (context.mounted) {
                              AppSnackbar.showError(context, e.toString());
                            }
                          } finally {
                            if (context.mounted) {
                              setDialogState(() => isSubmitting = false);
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );

    if (updated == true && mounted) {
      AppSnackbar.showSuccess(context, 'Nama profil berhasil diperbarui!');
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar dari akun Anda?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentCoral,
              foregroundColor: Colors.white,
            ),
            child: const Text('Ya, Keluar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await _authService.logout();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasPhoto =
        _photoPath != null &&
        _photoPath!.isNotEmpty &&
        File(_photoPath!).existsSync();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Pengguna'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadProfile,
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              // Avatar & Nama
              Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        GestureDetector(
                          onTap: _showPhotoOptions,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primary,
                                width: 2.5,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 46,
                              backgroundColor: AppColors.primary.withAlpha(40),
                              backgroundImage: hasPhoto
                                  ? FileImage(File(_photoPath!))
                                  : const AssetImage(
                                      "assets/images/default_avatar.png",
                                    ) as ImageProvider,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 2,
                          right: 2,
                          child: GestureDetector(
                            onTap: _showPhotoOptions,
                            child: Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Theme.of(context)
                                      .scaffoldBackgroundColor,
                                  width: 2.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(40),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                size: 15,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _user?.name ?? 'Memuat nama...',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _user?.email ?? 'Memuat email...',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Kartu Detail Informasi
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? Colors.white10 : Colors.grey.shade200,
                  ),
                ),
                child: Column(
                  children: [
                    _buildInfoRow(
                      icon: Icons.badge_outlined,
                      label: 'Peran Akun',
                      value: 'Peserta Pelatihan PPKD',
                    ),
                    const Divider(height: 20),
                    _buildInfoRow(
                      icon: Icons.verified_user_outlined,
                      label: 'Status Akun',
                      value: 'Aktif Terverifikasi',
                      valueColor: AppColors.primary,
                    ),
                    const Divider(height: 20),
                    _buildInfoRow(
                      icon: Icons.edit_note_rounded,
                      label: 'Edit Nama',
                      value: 'Ketuk untuk ubah',
                      onTap: _showEditNameDialog,
                    ),
                    const Divider(height: 20),
                    ValueListenableBuilder<ThemeMode>(
                      valueListenable: themeNotifier,
                      builder: (context, mode, _) {
                        final isDarkMode = mode == ThemeMode.dark;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            children: [
                              Icon(
                                isDarkMode
                                    ? Icons.dark_mode_outlined
                                    : Icons.light_mode_outlined,
                                size: 20,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  isDarkMode
                                      ? 'Tema: Mode Gelap'
                                      : 'Tema: Mode Terang',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textGrey,
                                  ),
                                ),
                              ),
                              Switch(
                                value: isDarkMode,
                                activeThumbColor: AppColors.primary,
                                onChanged: (val) => toggleAppTheme(),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Tombol Keluar / Logout
              AppButton(
                text: 'Keluar dari Akun',
                isLoading: false,
                onPressed: _handleLogout,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 13, color: AppColors.textGrey),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: valueColor,
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 6),
              const Icon(
                Icons.arrow_forward_ios,
                size: 12,
                color: AppColors.textGrey,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
