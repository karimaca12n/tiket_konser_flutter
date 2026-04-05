import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiket_konser/admin/admin_layout.dart';
import 'package:tiket_konser/providers/order_provider.dart';
import 'package:tiket_konser/providers/concert_provider.dart';
import 'package:tiket_konser/core/constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<OrderProvider>().fetchAllOrders();
      context.read<ConcertProvider>().fetchConcerts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final concertProvider = Provider.of<ConcertProvider>(context);

    double totalSales = 0;
    int ticketsSold = 0;
    int pendingApprovals = 0;
    int approvedCount = 0;
    int rejectedCount = 0;

    for (var order in orderProvider.orders) {
      if (order.status.toLowerCase() == 'approved' || order.status.toLowerCase() == 'paid') {
        totalSales += order.totalHarga;
        ticketsSold += order.jumlahTiket;
        approvedCount++;
      } else if (order.status.toLowerCase() == 'pending') {
        pendingApprovals++;
      } else if (order.status.toLowerCase() == 'rejected' || order.status.toLowerCase() == 'cancelled') {
        rejectedCount++;
      }
    }

    return AdminLayout(
      currentPath: '/admin/dashboard',
      title: 'DASHBOARD',
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'SALES',
                  value: NumberFormat.compactCurrency(locale: 'id_ID', symbol: 'Rp').format(totalSales),
                  icon: Icons.payments,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StatCard(
                  title: 'SOLD',
                  value: ticketsSold.toString(),
                  icon: Icons.confirmation_number,
                  color: AppColors.approved,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'EVENTS',
                  value: concertProvider.concerts.length.toString(),
                  icon: Icons.music_note,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StatCard(
                  title: 'PENDING',
                  value: pendingApprovals.toString(),
                  icon: Icons.pending_actions,
                  color: AppColors.pending,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            "ORDER STATUS",
            style: GoogleFonts.pressStart2p(fontSize: 12, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          Container(
            height: 280,
            padding: const EdgeInsets.all(24),
            decoration: AppTheme.retroCard,
            child: orderProvider.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : (orderProvider.orders.isEmpty
                    ? Center(child: Text("NO DATA", style: GoogleFonts.pressStart2p(fontSize: 10, color: AppColors.textSecondary)))
                    : PieChart(
                        PieChartData(
                          sectionsSpace: 4,
                          centerSpaceRadius: 40,
                          sections: [
                            PieChartSectionData(
                              value: approvedCount.toDouble(),
                              title: 'PAID',
                              color: AppColors.approved,
                              radius: 60,
                              titleStyle: GoogleFonts.pressStart2p(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.white),
                              borderSide: const BorderSide(color: AppColors.border, width: 2),
                            ),
                            PieChartSectionData(
                              value: pendingApprovals.toDouble(),
                              title: 'WAIT',
                              color: AppColors.pending,
                              radius: 60,
                              titleStyle: GoogleFonts.pressStart2p(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.white),
                              borderSide: const BorderSide(color: AppColors.border, width: 2),
                            ),
                            PieChartSectionData(
                              value: rejectedCount.toDouble(),
                              title: 'FAIL',
                              color: AppColors.rejected,
                              radius: 60,
                              titleStyle: GoogleFonts.pressStart2p(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.white),
                              borderSide: const BorderSide(color: AppColors.border, width: 2),
                            ),
                          ],
                        ),
                      )),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.retroCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color, 
              border: Border.all(color: AppColors.border, width: 2),
              borderRadius: BorderRadius.circular(8)
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 12),
          Text(title, style: GoogleFonts.pressStart2p(color: AppColors.textSecondary, fontSize: 7)),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
          ),
        ],
      ),
    );
  }
}
