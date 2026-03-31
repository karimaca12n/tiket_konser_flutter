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
      title: 'DASHBOARD OVERVIEW',
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _StatCard(
            title: 'TOTAL SALES',
            value: NumberFormat.compactCurrency(locale: 'id_ID', symbol: 'Rp').format(totalSales),
            icon: Icons.payments,
            color: AppColors.secondary,
          ),
          const SizedBox(height: 15),
          _StatCard(
            title: 'TICKETS SOLD',
            value: ticketsSold.toString(),
            icon: Icons.confirmation_number,
            color: AppColors.approved,
          ),
          const SizedBox(height: 15),
          _StatCard(
            title: 'ACTIVE EVENTS',
            value: concertProvider.concerts.length.toString(),
            icon: Icons.music_note,
            color: AppColors.primary,
          ),
          const SizedBox(height: 15),
          _StatCard(
            title: 'PENDING',
            value: pendingApprovals.toString(),
            icon: Icons.pending_actions,
            color: AppColors.pending,
          ),
          const SizedBox(height: 30),
          Text(
            "QUICK STATS",
            style: GoogleFonts.orbitron(fontSize: 14, color: AppColors.secondary, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          Container(
            height: 250,
            padding: const EdgeInsets.all(20),
            decoration: AppTheme.neonCard,
            child: orderProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : (orderProvider.orders.isEmpty
                    ? const Center(child: Text("NO DATA AVAILABLE", style: TextStyle(color: Colors.white24)))
                    : PieChart(
                        PieChartData(
                          sectionsSpace: 5,
                          centerSpaceRadius: 40,
                          sections: [
                            PieChartSectionData(
                              value: approvedCount.toDouble(),
                              title: 'PAID',
                              color: AppColors.approved,
                              radius: 50,
                              titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                            PieChartSectionData(
                              value: pendingApprovals.toDouble(),
                              title: 'WAIT',
                              color: AppColors.pending,
                              radius: 50,
                              titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                            PieChartSectionData(
                              value: rejectedCount.toDouble(),
                              title: 'FAIL',
                              color: AppColors.rejected,
                              radius: 50,
                              titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                          ],
                        ),
                      )),
          ),
          const SizedBox(height: 100),
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
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.neonCard,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
              Text(value, style: GoogleFonts.orbitron(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }
}
