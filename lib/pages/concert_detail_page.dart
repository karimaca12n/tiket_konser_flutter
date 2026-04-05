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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => context.pop(),
            ),
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
                  child: Container(
                    height: 400,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: const Border(bottom: BorderSide(color: AppColors.border, width: 3)),
                      image: DecorationImage(
                        image: NetworkImage(concert.image),
                        fit: BoxFit.cover,
                      ),
                    ),
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
                          AppColors.background.withValues(alpha: 0.1),
                          AppColors.background.withValues(alpha: 0.9),
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
                    style: GoogleFonts.pressStart2p(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        concert.location.toUpperCase(), 
                        style: GoogleFonts.pressStart2p(fontSize: 10, color: AppColors.textSecondary)
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: AppTheme.retroCard,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildInfoItem(Icons.calendar_today, DateFormat('dd MMM yyyy').format(concert.date)),
                        _buildInfoItem(Icons.access_time, '19:00'),
                        _buildInfoItem(
                          Icons.confirmation_num, 
                          isExpired ? 'EXPIRED' : 'ACTIVE',
                          color: isExpired ? AppColors.rejected : AppColors.approved,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    "DESCRIPTION",
                    style: GoogleFonts.pressStart2p(fontSize: 12, color: AppColors.primary),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    concert.description ?? "Experience an unforgettable night of music and lights. Don't miss this retro modern concert experience.",
                    style: GoogleFonts.inter(color: AppColors.textPrimary, height: 1.6, fontSize: 14),
                  ),
                  const SizedBox(height: 140),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(top: BorderSide(color: AppColors.border, width: 3)),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, -5))
          ]
        ),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("PRICE", style: GoogleFonts.pressStart2p(color: AppColors.textSecondary, fontSize: 8)),
                const SizedBox(height: 4),
                Text(
                  NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0).format(concert.price),
                  style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w900, fontSize: 20),
                ),
              ],
            ),
            const SizedBox(width: 24),
            Expanded(
              child: SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: isExpired ? null : () async {
                    if (!authProvider.isAuthenticated) {
                      context.push('/login');
                      return;
                    }
                    context.push('/payment', extra: concert);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isExpired ? Colors.grey[400] : AppColors.secondary,
                    foregroundColor: AppColors.textPrimary,
                  ),
                  child: Text(
                    isExpired ? "EXPIRED" : "BOOK NOW", 
                    style: GoogleFonts.pressStart2p(fontSize: 10),
                  ),
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
          Icon(icon, color: color ?? AppColors.primary, size: 24),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              text.toUpperCase(), 
              textAlign: TextAlign.center,
              style: GoogleFonts.pressStart2p(
                fontSize: 8, 
                color: color ?? AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
