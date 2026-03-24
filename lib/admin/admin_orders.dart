import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiket_konser/admin/admin_layout.dart';
import 'package:tiket_konser/providers/order_provider.dart';
import 'package:intl/intl.dart';

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
      child: Column(
        children: [
          TextField(
            onChanged: (value) => provider.setSearchQuery(value),
            decoration: const InputDecoration(
              hintText: 'Search by user or concert name...',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Card(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : (provider.orders.isEmpty 
                      ? const Center(child: Text('No orders found.'))
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('Order ID')),
                              DataColumn(label: Text('User')),
                              DataColumn(label: Text('Concert')),
                              DataColumn(label: Text('Date')),
                              DataColumn(label: Text('Status')),
                              DataColumn(label: Text('Actions')),
                            ],
                            rows: provider.orders.map((order) {
                              // Safely get ID substring
                              String displayId = order.id.length > 8 
                                  ? '#${order.id.substring(0, 8)}' 
                                  : '#${order.id}';

                              return DataRow(cells: [
                                DataCell(Text(displayId)),
                                DataCell(Text(order.user?.name ?? 'Unknown')),
                                DataCell(Text(order.concert?.name ?? 'Unknown')),
                                DataCell(Text(DateFormat('dd MMM yyyy HH:mm').format(order.createdAt))),
                                DataCell(_StatusBadge(status: order.status)),
                                DataCell(Row(
                                  children: [
                                    if (order.status.toLowerCase() == 'pending') ...[
                                      IconButton(
                                        icon: const Icon(Icons.check_circle, color: Colors.green),
                                        onPressed: () => provider.updateOrderStatus(order.id, 'approved'),
                                        tooltip: 'Approve',
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.cancel, color: Colors.red),
                                        onPressed: () => provider.updateOrderStatus(order.id, 'rejected'),
                                        tooltip: 'Reject',
                                      ),
                                    ] else
                                      const Text('-', style: TextStyle(color: Colors.grey)),
                                  ],
                                )),
                              ]);
                            }).toList(),
                          ),
                        )),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}
