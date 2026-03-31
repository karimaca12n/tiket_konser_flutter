import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiket_konser/providers/order_provider.dart';
import 'package:tiket_konser/providers/auth_provider.dart';
import 'package:tiket_konser/core/constants.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

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
      appBar: AppBar(
        title: Text('MY TICKETS', style: GoogleFonts.orbitron(fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextField(
              onChanged: (value) => context.read<OrderProvider>().setSearchQuery(value),
              decoration: const InputDecoration(
                hintText: 'Search tickets...',
                prefixIcon: Icon(Icons.search, color: AppColors.secondary),
              ),
            ),
          ),
          Expanded(
            child: Consumer<OrderProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                if (provider.orders.isEmpty) return const Center(child: Text('NO TICKETS FOUND'));

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: provider.orders.length,
                  itemBuilder: (context, index) {
                    final order = provider.orders[index];
                    return _OrderCard(order: order);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final dynamic order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final bool isPaid = order.status.toLowerCase() == 'approved' || order.status.toLowerCase() == 'paid';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: AppTheme.neonCard,
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: order.concert?.image != null && order.concert!.image.isNotEmpty
                ? DecorationImage(
                    image: NetworkImage(order.concert!.image),
                    fit: BoxFit.cover,
                  )
                : null,
            ),
            child: order.concert?.image == null || order.concert!.image.isEmpty 
                ? const Icon(Icons.music_note, color: Colors.white24) 
                : null,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.concert?.name.toUpperCase() ?? 'CONCERT',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                _StatusBadge(status: order.status),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              isPaid ? Icons.qr_code_scanner : Icons.hourglass_empty,
              color: isPaid ? AppColors.approved : AppColors.pending,
            ),
            onPressed: isPaid ? () => _showTicket(context, order) : null,
          ),
        ],
      ),
    );
  }

  void _showTicket(BuildContext context, dynamic order) {
    showDialog(
      context: context,
      builder: (context) => FutureBuilder<Map<String, dynamic>?>(
        future: context.read<OrderProvider>().getTicketDetails(order.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AlertDialog(
              backgroundColor: AppColors.background,
              content: SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
              ),
            );
          }

          final data = snapshot.data;

          return AlertDialog(
            backgroundColor: AppColors.surface,
            title: Text("VIRTUAL TICKET", style: GoogleFonts.orbitron(fontSize: 16, color: AppColors.secondary)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.qr_code_2, size: 180, color: Colors.black),
                  ),
                  const SizedBox(height: 20),
                  if (data != null) ...[
                    Text(data['name_konser'] ?? 'CONCERT NAME', 
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
                    const SizedBox(height: 10),
                    _ticketInfo("Buyer", data['nama_user'] ?? '-'),
                    _ticketInfo("Location", data['lokasi'] ?? '-'),
                    _ticketInfo("Date", data['tanggal'] ?? '-'),
                    const Divider(color: Colors.white10, height: 20),
                    Text("Rp ${data['total_harga']}", 
                        style: const TextStyle(color: AppColors.approved, fontWeight: FontWeight.bold, fontSize: 18)),
                  ] else ...[
                    const Icon(Icons.error_outline, color: AppColors.rejected, size: 40),
                    const SizedBox(height: 10),
                    const Text("Failed to load ticket data.", style: TextStyle(color: Colors.white70)),
                    const Text("(Server Error 501)", style: TextStyle(color: Colors.white38, fontSize: 10)),
                  ],
                  
                  const SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: data == null ? null : () {
                        context.read<OrderProvider>().downloadTicket(order.id);
                      },
                      icon: const Icon(Icons.download),
                      label: const Text("DOWNLOAD PDF"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary, 
                        foregroundColor: Colors.black,
                        disabledBackgroundColor: Colors.white10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context), 
                child: const Text('CLOSE', style: TextStyle(color: Colors.white54))
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _ticketInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("$label:", style: const TextStyle(color: Colors.white38, fontSize: 11)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500)),
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
      case 'paid': color = AppColors.approved; break;
      case 'rejected':
      case 'cancelled': color = AppColors.rejected; break;
      default: color = AppColors.pending;
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
