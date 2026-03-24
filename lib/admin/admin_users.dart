import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiket_konser/admin/admin_layout.dart';
import 'package:tiket_konser/providers/auth_provider.dart';

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Registered Users', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              Container(
                constraints: const BoxConstraints(maxWidth: 300),
                child: TextField(
                  onChanged: (value) => authProvider.setSearchQuery(value),
                  decoration: InputDecoration(
                    hintText: 'Search by name or email...',
                    prefixIcon: const Icon(Icons.search),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Card(
              child: authProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : (authProvider.filteredUsers.isEmpty 
                      ? const Center(child: Text('No users found matching your search.'))
                      : ListView.separated(
                          itemCount: authProvider.filteredUsers.length,
                          separatorBuilder: (context, index) => const Divider(),
                          itemBuilder: (context, index) {
                            final user = authProvider.filteredUsers[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                                child: Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : '?'),
                              ),
                              title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(user.email),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: user.role == 'admin' ? Colors.purple.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: user.role == 'admin' ? Colors.purple : Colors.blue),
                                ),
                                child: Text(
                                  user.role.toUpperCase(),
                                  style: TextStyle(
                                    color: user.role == 'admin' ? Colors.purple : Colors.blue,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
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
