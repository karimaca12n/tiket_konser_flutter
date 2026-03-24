import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiket_konser/providers/auth_provider.dart';
import 'package:tiket_konser/providers/concert_provider.dart';
import 'package:tiket_konser/providers/order_provider.dart';
import 'package:tiket_konser/widgets/navbar.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

class ConcertDetailPage extends StatefulWidget {
  final String id;
  const ConcertDetailPage({super.key, required this.id});

  @override
  State<ConcertDetailPage> createState() => _ConcertDetailPageState();
}

class _ConcertDetailPageState extends State<ConcertDetailPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final provider = context.read<ConcertProvider>();
      if (provider.concerts.isEmpty) {
        provider.fetchConcerts();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final concertProvider = Provider.of<ConcertProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context);

    final concerts = concertProvider.concerts;
    
    if (concertProvider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (concerts.isEmpty) {
      return const Scaffold(
        appBar: Navbar(),
        body: Center(child: Text('Concert not found or loading...')),
      );
    }

    final concert = concerts.firstWhere(
      (c) => c.id == widget.id, 
      orElse: () => concerts.first,
    );

    return Scaffold(
      appBar: const Navbar(), // PERBAIKAN: app_bar -> appBar
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: 400,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(concert.image),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
                  height: 400,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 40,
                  left: 40,
                  right: 40,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        concert.name,
                        style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.white70),
                          const SizedBox(width: 8),
                          Text(concert.location, style: const TextStyle(color: Colors.white70, fontSize: 18)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('About this Concert', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        Text(
                          concert.description ?? 'No description available.', 
                          style: const TextStyle(fontSize: 16, height: 1.6),
                        ),
                        const SizedBox(height: 32),
                        const Text('Date & Time', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        ListTile(
                          leading: const Icon(Icons.calendar_month),
                          title: Text(DateFormat('EEEE, dd MMMM yyyy').format(concert.date)),
                          subtitle: const Text('Doors open at 18:00'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 40),
                  Expanded(
                    flex: 1,
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Ticket Price', style: TextStyle(color: Colors.grey)),
                            const SizedBox(height: 8),
                            Text(
                              NumberFormat.currency(locale: 'id_ID', symbol: 'IDR ', decimalDigits: 0).format(concert.price),
                              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
                            ),
                            const SizedBox(height: 24),
                            const Divider(),
                            const SizedBox(height: 16),
                            const Text('• Single Entry Ticket\n• General Admission\n• Tax Included', style: TextStyle(height: 1.8)),
                            const SizedBox(height: 32),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (!authProvider.isAuthenticated) {
                                    context.push('/login');
                                    return;
                                  }
                                  
                                  final success = await orderProvider.createOrder(
                                    concert, 
                                    authProvider.user!.id
                                  );
                                  
                                  if (success) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Order placed successfully!')),
                                    );
                                    context.go('/orders');
                                  }
                                },
                                child: Text(authProvider.isAuthenticated ? 'Buy Ticket Now' : 'Login to Buy'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
