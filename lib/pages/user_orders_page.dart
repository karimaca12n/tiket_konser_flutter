import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiket_konser/providers/order_provider.dart';
import 'package:tiket_konser/providers/auth_provider.dart';
import 'package:tiket_konser/widgets/navbar.dart';
import 'package:intl/intl.dart';

class UserOrdersPage extends StatefulWidget {
  const UserOrdersPage({super.key});

  @override
  State<UserOrdersPage> createState() => _UserOrdersPageState();
}

class _UserOrdersPageState extends State<UserOrdersPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.isAuthenticated) {
        context.read<OrderProvider>().fetchUserOrders(authProvider.user!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Navbar(),
      body: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('My Orders', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            TextField(
              onChanged: (value) => context.read<OrderProvider>().setSearchQuery(value),
              decoration: const InputDecoration(
                hintText: 'Search orders...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Consumer<OrderProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) return const Center(child: CircularProgressIndicator());
                  if (provider.orders.isEmpty) return const Center(child: Text('No orders found.'));

                  return ListView.builder(
                    itemCount: provider.orders.length,
                    itemBuilder: (context, index) {
                      final order = provider.orders[index];
                      final isApproved = order.status == 'approved' || order.status == 'paid';

                      // Handle image URL
                      String imageUrl = order.concert?.image ?? '';
                      if (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
                        imageUrl = 'http://localhost:8081/uploads/gambar/$imageUrl';
                      }

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: imageUrl.isNotEmpty 
                                ? DecorationImage(
                                    image: NetworkImage(imageUrl),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                            ),
                            child: imageUrl.isEmpty ? const Icon(Icons.music_note) : null,
                          ),
                          title: Text(order.concert?.name ?? 'Unknown Concert', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Ordered on: ${DateFormat('dd MMM yyyy').format(order.createdAt)}'),
                              const SizedBox(height: 4),
                              _StatusBadge(status: order.status),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isApproved)
                                ElevatedButton.icon(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Downloading ticket...')));
                                  },
                                  icon: const Icon(Icons.download),
                                  label: const Text('Download Ticket'),
                                )
                              else
                                const Text('Status: Processing', style: TextStyle(color: Colors.grey, fontSize: 12)),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.qr_code),
                                onPressed: isApproved ? () {
                                  _showTicketDialog(context, order);
                                } : null,
                                tooltip: 'View Ticket',
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTicketDialog(BuildContext context, dynamic order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Your Ticket'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 200,
              height: 200,
              color: Colors.white,
              child: const Icon(Icons.qr_code_2, size: 180),
            ),
            const SizedBox(height: 16),
            Text(order.concert?.name ?? 'Concert Ticket', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('Booking ID: ${order.id}'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status.toLowerCase()) {
      case 'approved':
      case 'paid': 
        color = Colors.green; break;
      case 'rejected':
      case 'cancelled': 
        color = Colors.red; break;
      default: color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
