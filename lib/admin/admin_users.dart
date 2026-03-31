import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiket_konser/admin/admin_layout.dart';
import 'package:tiket_konser/providers/auth_provider.dart';
import 'package:tiket_konser/core/constants.dart';

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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: TextField(
              onChanged: (value) => authProvider.setSearchQuery(value),
              decoration: InputDecoration(
                hintText: 'Search by name or email...',
                prefixIcon: const Icon(Icons.search, color: AppColors.secondary),
                isDense: true,
              ),
            ),
          ),
          Expanded(
            child: Scrollbar(
              thumbVisibility: true,
              child: authProvider.isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : (authProvider.filteredUsers.isEmpty 
                      ? const Center(child: Text('NO USERS FOUND'))
                      : ListView.separated(
                          padding: const EdgeInsets.all(20),
                          itemCount: authProvider.filteredUsers.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 15),
                          itemBuilder: (context, index) {
                            final user = authProvider.filteredUsers[index];
                            return Container(
                              decoration: AppTheme.neonCard,
                              child: ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppColors.secondary, width: 1),
                                  ),
                                  child: CircleAvatar(
                                    backgroundColor: AppColors.surface,
                                    backgroundImage: user.avatar != null 
                                        ? NetworkImage(user.avatar!) 
                                        : null,
                                    child: user.avatar == null 
                                        ? Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : '?', 
                                            style: const TextStyle(color: AppColors.secondary))
                                        : null,
                                  ),
                                ),
                                title: Text(user.name.toUpperCase(), 
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                                subtitle: Text(user.email, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                                trailing: _RoleBadge(role: user.role),
                              ),
                            );
                          },
                        )),
            ),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isAdmin ? AppColors.primary.withOpacity(0.1) : AppColors.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isAdmin ? AppColors.primary : AppColors.secondary, width: 1),
      ),
      child: Text(
        role.toUpperCase(),
        style: TextStyle(
          color: isAdmin ? AppColors.primary : AppColors.secondary,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
