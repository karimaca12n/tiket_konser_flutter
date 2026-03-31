import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiket_konser/providers/concert_provider.dart';
import 'package:tiket_konser/core/constants.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<ConcertProvider>().fetchConcerts());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Retro Header
            SliverAppBar(
              expandedHeight: 120,
              floating: true,
              backgroundColor: AppColors.background,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: false,
                titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                title: Text(
                  'SORAIFEST',
                  style: GoogleFonts.orbitron(
                    fontWeight: FontWeight.w900,
                    color: AppColors.secondary,
                    letterSpacing: 2,
                    fontSize: 20,
                    shadows: [
                      const Shadow(color: AppColors.secondary, blurRadius: 10),
                    ],
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_none, color: AppColors.secondary),
                  onPressed: () {},
                ),
                const SizedBox(width: 10),
              ],
            ),

            // Search Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "FIND YOUR VIBE",
                      style: GoogleFonts.orbitron(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      onChanged: (value) => context.read<ConcertProvider>().setSearchQuery(value),
                      decoration: InputDecoration(
                        hintText: 'Search concerts...',
                        prefixIcon: const Icon(Icons.search, color: AppColors.secondary),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Concert Grid
            Consumer<ConcertProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                  );
                }

                if (provider.concerts.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(child: Text('NO EVENTS FOUND')),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final concert = provider.concerts[index];
                        return _ConcertCard(concert: concert);
                      },
                      childCount: provider.concerts.length,
                    ),
                  ),
                );
              },
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}

class _ConcertCard extends StatelessWidget {
  final dynamic concert;
  const _ConcertCard({required this.concert});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: AppTheme.neonCard,
      child: InkWell(
        onTap: () => context.push('/concert/${concert.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.network(
                    concert.image,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 180,
                      color: Colors.white10,
                      child: const Icon(Icons.broken_image, color: Colors.white24),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.primary, width: 1),
                    ),
                    child: Text(
                      DateFormat('dd MMM').format(concert.date),
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    concert.name.toUpperCase(),
                    style: GoogleFonts.orbitron(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: AppColors.secondary),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          concert.location,
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0).format(concert.price),
                        style: const TextStyle(color: AppColors.approved, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: AppColors.retroGradient,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(color: AppColors.primary.withOpacity(0.5), blurRadius: 8),
                          ],
                        ),
                        child: const Text(
                          'GET TICKET',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
                        ),
                      ),
                    ],
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
