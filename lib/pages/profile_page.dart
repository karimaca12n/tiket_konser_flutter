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
      appBar: AppBar(
        title: Text('MY PROFILE', style: GoogleFonts.orbitron(fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit, color: AppColors.secondary),
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
                      border: Border.all(color: AppColors.secondary, width: 2),
                      boxShadow: [
                        BoxShadow(color: AppColors.secondary.withOpacity(0.3), blurRadius: 15),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: AppColors.surface,
                      backgroundImage: _selectedImage != null 
                        ? MemoryImage(_selectedImage!.bytes!) 
                        : (user?.avatar != null ? NetworkImage(user!.avatar!) as ImageProvider : null),
                      child: (user?.avatar == null && _selectedImage == null) 
                        ? const Icon(Icons.person, size: 60, color: AppColors.primary) 
                        : null,
                    ),
                  ),
                  if (_isEditing)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        backgroundColor: AppColors.secondary,
                        radius: 18,
                        child: Icon(Icons.camera_alt, size: 18, color: AppColors.background),
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
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'FULL NAME',
                  prefixIcon: Icon(Icons.person_outline, color: AppColors.secondary),
                ),
              )
            else
              _buildProfileInfo('NAME', user?.name ?? 'Guest'),
            
            const SizedBox(height: 15),
            
            // Email (Non-Editable)
            _buildProfileInfo('EMAIL', user?.email ?? 'Not logged in'),
            
            const SizedBox(height: 40),
            
            if (_isEditing)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: authProvider.isLoading ? null : _handleUpdate,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.approved, foregroundColor: Colors.black),
                  child: authProvider.isLoading 
                    ? const CircularProgressIndicator() 
                    : const Text('SAVE CHANGES', style: TextStyle(fontWeight: FontWeight.bold)),
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
                    backgroundColor: AppColors.surface,
                    foregroundColor: AppColors.secondary,
                    side: BorderSide(color: AppColors.secondary.withOpacity(0.5)),
                  ),
                ),
              ),
              const SizedBox(height: 15),
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
                    backgroundColor: AppColors.rejected.withOpacity(0.1),
                    foregroundColor: AppColors.rejected,
                    side: const BorderSide(color: AppColors.rejected),
                  ),
                ),
              ),
            ],
          ],
        ),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(backgroundColor: AppColors.approved, content: Text('PROFILE UPDATED!')),
      );
    }
  }

  Widget _buildProfileInfo(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: AppTheme.neonCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text(value, style: GoogleFonts.orbitron(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
        ],
      ),
    );
  }
}
