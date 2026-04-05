import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiket_konser/providers/auth_provider.dart';
import 'package:tiket_konser/core/constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _nameController = TextEditingController();
  PlatformFile? _selectedImage;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _nameController.text = user?.name ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('MY PROFILE', 
          style: GoogleFonts.pressStart2p(
            fontSize: 16, 
            fontWeight: FontWeight.bold, 
            color: AppColors.textPrimary
          )
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit, color: AppColors.textPrimary),
              onPressed: () => setState(() => _isEditing = true),
            )
          else
            IconButton(
              icon: const Icon(Icons.close, color: AppColors.rejected),
              onPressed: () => setState(() => _isEditing = false),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // Profile Picture with Upload Function
            GestureDetector(
              onTap: _isEditing ? _pickImage : null,
              child: Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: AppColors.border, width: 3),
                      boxShadow: const [
                        BoxShadow(color: AppColors.border, offset: Offset(4, 4)),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: _selectedImage != null 
                        ? MemoryImage(_selectedImage!.bytes!) 
                        : (user?.avatar != null ? NetworkImage(user!.avatar!) as ImageProvider : null),
                      child: (user?.avatar == null && _selectedImage == null) 
                        ? const Icon(Icons.person, size: 60, color: AppColors.textPrimary) 
                        : null,
                    ),
                  ),
                  if (_isEditing)
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.border, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt, size: 18, color: AppColors.textPrimary),
                      ),
                    ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Name Field (Editable)
            if (_isEditing)
              TextField(
                controller: _nameController,
                style: GoogleFonts.inter(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'FULL NAME',
                  labelStyle: GoogleFonts.pressStart2p(fontSize: 10, color: AppColors.textSecondary),
                  prefixIcon: const Icon(Icons.person_outline, color: AppColors.textPrimary),
                ),
              )
            else
              _buildProfileInfo('NAME', user?.name ?? 'Guest'),
            
            const SizedBox(height: 20),
            
            // Email (Non-Editable)
            _buildProfileInfo('EMAIL', user?.email ?? 'Not logged in'),
            
            const SizedBox(height: 40),
            
            if (_isEditing)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: authProvider.isLoading ? null : _handleUpdate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.approved, 
                    foregroundColor: Colors.white,
                  ),
                  child: authProvider.isLoading 
                    ? const SizedBox(
                        height: 20, width: 20, 
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      ) 
                    : const Text('SAVE CHANGES'),
                ),
              )
            else ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => context.go('/orders'),
                  icon: const Icon(Icons.confirmation_num_outlined),
                  label: const Text('MY TICKETS'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildAboutSection(),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    authProvider.logout();
                    context.go('/login');
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('LOGOUT'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.rejected,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'ABOUT SORAIFEST',
                style: GoogleFonts.pressStart2p(fontSize: 8, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Support, Feedback, or Bug Reports:',
            style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          SelectableText(
            'SoraiFest@gmail.com',
            style: GoogleFonts.pressStart2p(
              fontSize: 10, 
              color: AppColors.textPrimary,
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      setState(() => _selectedImage = result.files.first);
    }
  }

  Future<void> _handleUpdate() async {
    final success = await context.read<AuthProvider>().updateProfile(
      name: _nameController.text,
      imageFile: _selectedImage,
    );

    if (success) {
      setState(() => _isEditing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.approved, 
            content: Text('PROFILE UPDATED!', style: GoogleFonts.pressStart2p(fontSize: 10, color: Colors.white)),
          ),
        );
      }
    }
  }

  Widget _buildProfileInfo(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.retroCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.pressStart2p(color: AppColors.textSecondary, fontSize: 8)),
          const SizedBox(height: 12),
          Text(value, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
