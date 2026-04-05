import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiket_konser/admin/admin_layout.dart';
import 'package:tiket_konser/providers/order_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tiket_konser/core/constants.dart';

class AdminOrdersPage extends StatefulWidget {
  const AdminOrdersPage({super.key});

  @override
  State<AdminOrdersPage> createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends State<AdminOrdersPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<OrderProvider>().fetchAllOrders());
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OrderProvider>(context);

    return AdminLayout(
      currentPath: '/admin/orders',
      title: 'ORDERS',
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: TextField(
              onChanged: (value) => provider.setSearchQuery(value),
              style: GoogleFonts.inter(),
              decoration: InputDecoration(
                hintText: 'Search by user or concert...',
                prefixIcon: const Icon(Icons.search, color: AppColors.textPrimary),
                isDense: true,
              ),
            ),
          ),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : (provider.orders.isEmpty
                    ? Center(child: Text('NO ORDERS FOUND', style: GoogleFonts.pressStart2p(fontSize: 10, color: AppColors.textSecondary)))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                        itemCount: provider.orders.length,
                        itemBuilder: (context, index) {
                          final order = provider.orders[index];
                          return _AdminOrderCard(order: order, provider: provider);
                        },
                      )),
          ),
        ],
      ),
    );
  }
}

class _AdminOrderCard extends StatelessWidget {
  final dynamic order;
  final OrderProvider provider;

  const _AdminOrderCard({required this.order, required this.provider});

  @override
  Widget build(BuildContext context) {
    final bool isPending = order.status.toLowerCase() == 'pending';
    final String displayId = order.id.length > 8 ? '#${order.id.substring(0, 8)}' : '#${order.id}';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: AppTheme.retroCard,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(displayId.toUpperCase(), style: GoogleFonts.pressStart2p(fontSize: 8, color: AppColors.textSecondary)),
                _StatusBadge(status: order.status),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              (order.concert?.name ?? 'UNKNOWN CONCERT').toUpperCase(),
              style: GoogleFonts.pressStart2p(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person, size: 14, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  order.user?.name ?? 'Unknown User',
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.mail_outline, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text(
                  order.user?.email ?? '-',
                  style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
            if (isPending) ...[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(color: AppColors.border, thickness: 1.5),
              ),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => provider.updateOrderStatus(order.id, 'approved'),
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('APPROVE'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.approved,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => provider.updateOrderStatus(order.id, 'rejected'),
                      icon: const Icon(Icons.close, size: 16),
                      label: const Text('REJECT'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.rejected,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
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
    String label = status.isEmpty ? 'PENDING' : status.toUpperCase();
    
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
      case '':
        color = AppColors.pending;
        break;
      default:
        color = AppColors.pending;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.border, width: 2),
        boxShadow: const [
          BoxShadow(color: AppColors.border, offset: Offset(2, 2)),
        ],
      ),
      child: Text(
        label,
        style: GoogleFonts.pressStart2p(
          color: color == AppColors.pending ? AppColors.textPrimary : Colors.white,
          fontSize: 7, 
          fontWeight: FontWeight.bold
        ),
      ),
    );
  }
}
