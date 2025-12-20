import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/profile_edit_provider.dart';
import '../providers/profile_provider.dart';
import '../../../../auth/presentation/providers/auth_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  File? _selectedImage;
  bool _isInitialized = false;
  String? _currentPhotoUrl;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _initializeFields() {
    if (_isInitialized) return;

    final authState = ref.read(authStateProvider);
    final userDataAsync = ref.read(userDataProvider);

    authState.whenData((state) {
      if (state is AuthStateAuthenticated) {
        // Load name from Auth
        _nameController.text = state.user.name;

        // Load phone and photo from database
        userDataAsync.whenData((userData) {
          if (userData != null) {
            if (userData.phone.isNotEmpty) {
              _phoneController.text = userData.phone;
            }
            if (userData.photoUrl.isNotEmpty) {
              _currentPhotoUrl = userData.photoUrl;
            }
            print(
                '✅ Loaded user data: phone=${userData.phone}, photo=${userData.photoUrl}');
          }
        });

        _isInitialized = true;
      }
    });
  }

  ImageProvider? _getBackgroundImage() {
    if (_selectedImage != null) {
      return FileImage(_selectedImage!);
    } else if (_currentPhotoUrl != null && _currentPhotoUrl!.isNotEmpty) {
      return CachedNetworkImageProvider(_currentPhotoUrl!);
    }
    return null;
  }

  Future<void> _pickImage() async {
    final image =
        await ref.read(profileEditProvider.notifier).pickProfileImage();
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    HapticFeedback.mediumImpact();

    final authState = ref.read(authStateProvider);
    String? userId;
    authState.whenData((state) {
      if (state is AuthStateAuthenticated) {
        userId = state.user.$id;
      }
    });

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User ID tidak ditemukan'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final success = await ref.read(profileEditProvider.notifier).updateProfile(
          userId: userId!,
          displayName: _nameController.text.trim(),
          phone: _phoneController.text.trim().isNotEmpty
              ? _phoneController.text.trim()
              : null,
          profileImage: _selectedImage,
        );

    if (mounted) {
      if (success) {
        // Refresh auth state to get updated user info
        ref.invalidate(authStateProvider);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile berhasil diupdate!'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      } else {
        final error = ref.read(profileEditProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Gagal mengupdate profile'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _initializeFields();

    final theme = Theme.of(context);
    final editState = ref.watch(profileEditProvider);
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        elevation: 0,
        actions: [
          TextButton.icon(
            onPressed: () {
              context.push('/customer/profile/change-password');
            },
            icon: const Icon(Icons.lock_outline),
            label: const Text('Ganti Password'),
          ),
        ],
      ),
      body: authState.when(
        data: (state) {
          if (state is! AuthStateAuthenticated) {
            return const Center(child: Text('Please login'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Profile Photo Section
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: theme.colorScheme.primaryContainer,
                          backgroundImage: _getBackgroundImage(),
                          child: (_selectedImage == null &&
                                  (_currentPhotoUrl == null ||
                                      _currentPhotoUrl!.isEmpty))
                              ? Icon(
                                  Icons.person,
                                  size: 60,
                                  color: theme.colorScheme.onPrimaryContainer,
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: theme.colorScheme.primary,
                            child: IconButton(
                              icon: const Icon(
                                Icons.camera_alt,
                                size: 20,
                                color: Colors.white,
                              ),
                              onPressed: _pickImage,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Display Name Field
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Nama Lengkap',
                      hintText: 'Masukkan nama lengkap',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Nama tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Phone Number Field
                  TextFormField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      labelText: 'Nomor Telepon',
                      hintText: 'Masukkan nomor telepon (opsional)',
                      prefixIcon: const Icon(Icons.phone_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),

                  // Email Field (Read-only)
                  TextFormField(
                    initialValue: state.user.email,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabled: false,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Email tidak dapat diubah',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Save Button
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: editState.isLoading ? null : _handleSave,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: editState.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Simpan Perubahan',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
