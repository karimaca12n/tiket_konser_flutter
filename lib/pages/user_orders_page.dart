import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiket_konser/providers/order_provider.dart';
import 'package:tiket_konser/providers/auth_provider.dart';
import 'package:tiket_konser/core/constants.dart';
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('MY TICKETS', 
          style: GoogleFonts.pressStart2p(
            fontSize: 16, 
            fontWeight: FontWeight.bold, 
            color: AppColors.textPrimary
          )
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextField(
              onChanged: (value) => context.read<OrderProvider>().setSearchQuery(value),
              style: GoogleFonts.inter(),
              decoration: InputDecoration(
                hintText: 'Search tickets...',
                prefixIcon: const Icon(Icons.search, color: AppColors.textPrimary),
                hintStyle: GoogleFonts.inter(color: AppColors.textSecondary),
              ),
            ),
          ),
          Expanded(
            child: Consumer<OrderProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                if (provider.orders.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.confirmation_number_outlined, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          'NO TICKETS FOUND',
                          style: GoogleFonts.pressStart2p(fontSize: 10, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  );
                }

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
    final bool isRejected = order.status.toLowerCase() == 'rejected' || order.status.toLowerCase() == 'cancelled';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: AppTheme.retroCard,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: isPaid ? () => _showTicket(context, order) : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border, width: 1.5),
                  image: order.concert?.image != null && order.concert!.image.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(order.concert!.image),
                        fit: BoxFit.cover,
                      )
                    : null,
                ),
                child: order.concert?.image == null || order.concert!.image.isEmpty 
                    ? const Icon(Icons.music_note, color: Colors.grey) 
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.concert?.name.toUpperCase() ?? 'CONCERT',
                      style: GoogleFonts.pressStart2p(
                        fontWeight: FontWeight.bold, 
                        color: AppColors.textPrimary, 
                        fontSize: 10
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    _StatusBadge(status: order.status),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isPaid 
                      ? AppColors.approved 
                      : (isRejected ? AppColors.rejected : Colors.grey[200]),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border, width: 2),
                ),
                child: Icon(
                  isPaid 
                      ? Icons.qr_code_scanner 
                      : (isRejected ? Icons.close : Icons.hourglass_empty),
                  color: (isPaid || isRejected) ? Colors.white : AppColors.textSecondary,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
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
            return Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: AppTheme.retroCard,
                child: const CircularProgressIndicator(color: AppColors.primary),
              ),
            );
          }

          final data = snapshot.data;

          return Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: AppTheme.retroCard,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "VIRTUAL TICKET", 
                      style: GoogleFonts.pressStart2p(fontSize: 14, color: AppColors.textPrimary)
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border, width: 2),
                      ),
                      child: const Icon(Icons.qr_code_2, size: 180, color: Colors.black),
                    ),
                    const SizedBox(height: 24),
                    if (data != null) ...[
                      Text(
                        (data['name_konser'] ?? 'CONCERT NAME').toString().toUpperCase(), 
                        textAlign: TextAlign.center,
                        style: GoogleFonts.pressStart2p(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 12)
                      ),
                      const SizedBox(height: 20),
                      _ticketInfo("BUYER", data['nama_user'] ?? '-'),
                      _ticketInfo("LOCATION", data['lokasi'] ?? '-'),
                      _ticketInfo("DATE", data['tanggal'] ?? '-'),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(color: AppColors.border, thickness: 1.5),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("TOTAL", style: GoogleFonts.pressStart2p(fontSize: 8, color: AppColors.textSecondary)),
                          Text(
                            "Rp ${data['total_harga']}", 
                            style: GoogleFonts.inter(color: AppColors.accent, fontWeight: FontWeight.w900, fontSize: 18)
                          ),
                        ],
                      ),
                    ] else ...[
                      const Icon(Icons.error_outline, color: AppColors.rejected, size: 40),
                      const SizedBox(height: 10),
                      Text("FAILED TO LOAD DATA", style: GoogleFonts.pressStart2p(fontSize: 8, color: AppColors.rejected)),
                    ],
                    
                    const SizedBox(height: 32),
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
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => Navigator.pop(context), 
                      child: Text(
                        'CLOSE', 
                        style: GoogleFonts.pressStart2p(fontSize: 8, color: AppColors.textSecondary)
                      )
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _ticketInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.pressStart2p(color: AppColors.textSecondary, fontSize: 7)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value, 
              textAlign: TextAlign.right,
              style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
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
    String label = status.toUpperCase();

    switch (status.toLowerCase()) {
      case 'approved':
      case 'paid':
        color = AppColors.approved;
        break;
      case 'rejected':
      case 'cancelled':
        color = AppColors.rejected;
        break;
      case 'pending':
        color = AppColors.pending;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border, width: 1.5),
        boxShadow: const [
          BoxShadow(color: AppColors.border, offset: Offset(2, 2)),
        ],
      ),
      child: Text(
        label,
        style: GoogleFonts.pressStart2p(
          color: color == AppColors.pending ? AppColors.textPrimary : Colors.white,
          fontSize: 7,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
