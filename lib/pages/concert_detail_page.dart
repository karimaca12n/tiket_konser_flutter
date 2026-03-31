import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiket_konser/providers/auth_provider.dart';
import 'package:tiket_konser/providers/concert_provider.dart';
import 'package:tiket_konser/providers/order_provider.dart';
import 'package:tiket_konser/core/constants.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

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

    if (concertProvider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.primary)));
    }

    final concerts = concertProvider.concerts;
    
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

    // Logic Expired: Cek apakah tanggal hari ini sudah melewati tanggal konser
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final bool isExpired = concert.date.isBefore(today);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: CircleAvatar(
          backgroundColor: Colors.black45,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.pop(),
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Image
            Stack(
              children: [
                Hero(
                  tag: 'concert-${concert.id}',
                  child: Image.network(
                    concert.image,
                    height: 350,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppColors.background.withOpacity(0.8),
                          AppColors.background,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    concert.name.toUpperCase(),
                    style: GoogleFonts.orbitron(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: AppColors.primary, size: 18),
                      const SizedBox(width: 5),
                      Text(concert.location, style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                    decoration: AppTheme.neonCard,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildInfoItem(Icons.calendar_today, DateFormat('dd MMM yyyy').format(concert.date)),
                        _buildInfoItem(Icons.access_time, '19:00'),
                        _buildInfoItem(
                          Icons.confirmation_num, 
                          isExpired ? 'EXPIRED' : 'AVAILABLE',
                          color: isExpired ? AppColors.rejected : AppColors.secondary,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    "DESCRIPTION",
                    style: GoogleFonts.orbitron(fontSize: 14, color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    concert.description ?? "Experience an unforgettable night of music and lights. Don't miss this retro modern concert experience.",
                    style: const TextStyle(color: Colors.white70, height: 1.6),
                  ),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.secondary.withOpacity(0.3))),
        ),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("PRICE", style: TextStyle(color: Colors.white54, fontSize: 10)),
                Text(
                  NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0).format(concert.price),
                  style: const TextStyle(color: AppColors.approved, fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: ElevatedButton(
                onPressed: isExpired ? null : () async {
                  if (!authProvider.isAuthenticated) {
                    context.push('/login');
                    return;
                  }
                  final success = await orderProvider.createOrder(concert, authProvider.user!.id);
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('BOOKING SUCCESSFUL!')),
                    );
                    context.go('/orders');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isExpired ? Colors.grey.withOpacity(0.3) : AppColors.secondary,
                  foregroundColor: isExpired ? Colors.white38 : Colors.black,
                ),
                child: Text(
                  isExpired ? "EXPIRED" : "BOOK NOW", 
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text, {Color? color}) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color ?? AppColors.secondary, size: 20),
          const SizedBox(height: 5),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              text, 
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11, 
                fontWeight: FontWeight.bold,
                color: color ?? Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Navbar extends StatelessWidget implements PreferredSizeWidget {
  const Navbar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
    );
  }
}
