import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiket_konser/admin/admin_layout.dart';
import 'package:tiket_konser/providers/order_provider.dart';
import 'package:tiket_konser/providers/concert_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

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

    // LOGIKA PERHITUNGAN STATISTIK REALTIME
    double totalSales = 0;
    int ticketsSold = 0;
    int pendingApprovals = 0;

    for (var order in orderProvider.orders) {
      if (order.status.toLowerCase() == 'approved' || order.status.toLowerCase() == 'paid') {
        totalSales += order.totalHarga;
        ticketsSold += order.jumlahTiket;
      }
      if (order.status.toLowerCase() == 'pending') {
        pendingApprovals++;
      }
    }

    return AdminLayout(
      currentPath: '/admin/dashboard',
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats Cards
            Row(
              children: [
                _StatCard(
                  title: 'Total Sales', 
                  value: NumberFormat.compactCurrency(locale: 'id_ID', symbol: 'Rp').format(totalSales), 
                  icon: Icons.payments, 
                  color: Colors.blue
                ),
                _StatCard(
                  title: 'Tickets Sold', 
                  value: ticketsSold.toString(), 
                  icon: Icons.confirmation_number, 
                  color: Colors.green
                ),
                _StatCard(
                  title: 'Active Concerts', 
                  value: concertProvider.concerts.length.toString(), 
                  icon: Icons.music_note, 
                  color: Colors.purple
                ),
                _StatCard(
                  title: 'Pending Approvals', 
                  value: pendingApprovals.toString(), 
                  icon: Icons.pending_actions, 
                  color: Colors.orange
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            // Charts Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: _ChartContainer(
                    title: 'Sales Overview (Last 6 Months)',
                    child: SizedBox(
                      height: 300,
                      child: LineChart(
                        LineChartData(
                          gridData: const FlGridData(show: false),
                          titlesData: const FlTitlesData(show: false),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: [
                                const FlSpot(0, 3),
                                const FlSpot(2, 5),
                                const FlSpot(4, 4),
                                const FlSpot(6, 8),
                                const FlSpot(8, 6),
                                const FlSpot(10, 7),
                              ],
                              isCurved: true,
                              color: Theme.of(context).primaryColor,
                              barWidth: 4,
                              belowBarData: BarAreaData(
                                show: true,
                                color: Theme.of(context).primaryColor.withOpacity(0.1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 1,
                  child: _ChartContainer(
                    title: 'Orders by Status',
                    child: SizedBox(
                      height: 300,
                      child: PieChart(
                        PieChartData(
                          sections: [
                            PieChartSectionData(
                              value: (orderProvider.orders.where((o) => o.status.toLowerCase() == 'approved' || o.status.toLowerCase() == 'paid').length).toDouble(), 
                              color: Colors.green, title: 'Paid', radius: 50
                            ),
                            PieChartSectionData(
                              value: pendingApprovals.toDouble(), 
                              color: Colors.orange, title: 'Pending', radius: 50
                            ),
                            PieChartSectionData(
                              value: (orderProvider.orders.where((o) => o.status.toLowerCase() == 'rejected' || o.status.toLowerCase() == 'cancelled').length).toDouble(), 
                              color: Colors.red, title: 'Reject', radius: 50
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
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
    return Expanded(
      child: Card(
        margin: const EdgeInsets.only(right: 16),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                    FittedBox(child: Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChartContainer extends StatelessWidget {
  final String title;
  final Widget child;

  const _ChartContainer({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            child,
          ],
        ),
      ),
    );
  }
}
