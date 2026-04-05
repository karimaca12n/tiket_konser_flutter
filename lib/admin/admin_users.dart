import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiket_konser/admin/admin_layout.dart';
import 'package:tiket_konser/providers/auth_provider.dart';
import 'package:tiket_konser/core/constants.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<AuthProvider>().fetchAllUsers());
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return AdminLayout(
      currentPath: '/admin/users',
      title: 'SYSTEM USERS',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: TextField(
              onChanged: (value) => authProvider.setSearchQuery(value),
              style: GoogleFonts.inter(),
              decoration: InputDecoration(
                hintText: 'Search by name or email...',
                prefixIcon: const Icon(Icons.search, color: AppColors.textPrimary),
                isDense: true,
              ),
            ),
          ),
          Expanded(
            child: authProvider.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : (authProvider.filteredUsers.isEmpty 
                    ? Center(
                        child: Text(
                          'NO USERS FOUND', 
                          style: GoogleFonts.pressStart2p(fontSize: 10, color: AppColors.textSecondary)
                        )
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 5, 20, 20),
                        itemCount: authProvider.filteredUsers.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final user = authProvider.filteredUsers[index];
                          return Container(
                            decoration: AppTheme.retroCard,
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              leading: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.border, width: 2),
                                ),
                                child: CircleAvatar(
                                  backgroundColor: Colors.white,
                                  backgroundImage: user.avatar != null 
                                      ? NetworkImage(user.avatar!) 
                                      : null,
                                  child: user.avatar == null 
                                      ? Text(
                                          user.name.isNotEmpty ? user.name[0].toUpperCase() : '?', 
                                          style: GoogleFonts.pressStart2p(fontSize: 14, color: AppColors.textPrimary)
                                        )
                                      : null,
                                ),
                              ),
                              title: Text(
                                user.name.toUpperCase(), 
                                style: GoogleFonts.pressStart2p(
                                  fontWeight: FontWeight.bold, 
                                  fontSize: 10, 
                                  color: AppColors.textPrimary
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  user.email, 
                                  style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12)
                                ),
                              ),
                              trailing: _RoleBadge(role: user.role),
                            ),
                          );
                        },
                      )),
          ),
        ],
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final String role;
  const _RoleBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    bool isAdmin = role.toLowerCase() == 'admin';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isAdmin ? AppColors.primary : AppColors.secondary,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.border, width: 2),
        boxShadow: const [
          BoxShadow(color: AppColors.border, offset: Offset(2, 2)),
        ],
      ),
      child: Text(
        role.toUpperCase(),
        style: GoogleFonts.pressStart2p(
          color: isAdmin ? Colors.white : AppColors.textPrimary,
          fontSize: 7,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
