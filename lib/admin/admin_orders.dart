import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiket_konser/admin/admin_layout.dart';
import 'package:tiket_konser/providers/order_provider.dart';
import 'package:intl/intl.dart';
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
      title: 'ORDER REQUESTS',
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: TextField(
              onChanged: (value) => provider.setSearchQuery(value),
              decoration: const InputDecoration(
                hintText: 'Search by user or concert...',
                prefixIcon: Icon(Icons.search, color: Colors.cyan),
                isDense: true,
              ),
            ),
          ),
          Expanded(
            child: Scrollbar(
              thumbVisibility: true,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  if (provider.isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (provider.orders.isEmpty)
                    const Center(child: Text('No orders found.'))
                  else
                    Center( // Tambahkan Center di sini agar tabel berada di tengah
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columnSpacing: 20,
                          columns: const [
                            DataColumn(label: Center(child: Text('ID'))),
                            DataColumn(label: Center(child: Text('USER'))),
                            DataColumn(label: Center(child: Text('CONCERT'))),
                            DataColumn(label: Center(child: Text('STATUS'))),
                            DataColumn(label: Center(child: Text('ACTIONS'))),
                          ],
                          rows: provider.orders.map((order) {
                            String displayId = order.id.length > 5 ? '#${order.id.substring(0, 5)}' : '#${order.id}';
                            return DataRow(cells: [
                              DataCell(Center(child: Text(displayId, style: const TextStyle(fontSize: 10)))),
                              DataCell(Center(child: Text(order.user?.name ?? 'Unknown', style: const TextStyle(fontSize: 11)))),
                              DataCell(Center(child: Text(order.concert?.name ?? 'Unknown', style: const TextStyle(fontSize: 11)))),
                              DataCell(Center(child: _StatusBadge(status: order.status))),
                              DataCell(Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (order.status.toLowerCase() == 'pending') ...[
                                      IconButton(
                                        icon: const Icon(Icons.check_circle, color: Colors.green, size: 20),
                                        onPressed: () => provider.updateOrderStatus(order.id, 'approved'),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.cancel, color: Colors.red, size: 20),
                                        onPressed: () => provider.updateOrderStatus(order.id, 'rejected'),
                                      ),
                                    ] else
                                      const Text('-', style: TextStyle(color: Colors.white24)),
                                  ],
                                ),
                              )),
                            ]);
                          }).toList(),
                        ),
                      ),
                    ),
                ],
              ),
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
      case 'paid': color = AppColors.approved; break;
      case 'rejected': color = AppColors.rejected; break;
      default: color = AppColors.pending;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(status.toUpperCase(), style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold)),
    );
  }
}
