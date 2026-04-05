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
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Retro Header
            SliverAppBar(
              expandedHeight: 100,
              floating: true,
              backgroundColor: AppColors.background,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: false,
                titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                title: Text(
                  'SORAIFEST',
                  style: GoogleFonts.pressStart2p(
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                    fontSize: 18,
                  ),
                ),
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.only(right: 20, top: 10, bottom: 10),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    border: Border.all(color: AppColors.border, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.notifications_none, color: AppColors.textPrimary, size: 20),
                    onPressed: () {},
                  ),
                ),
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
                      style: GoogleFonts.pressStart2p(
                        fontSize: 10,
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      onChanged: (value) => context.read<ConcertProvider>().setSearchQuery(value),
                      style: GoogleFonts.inter(),
                      decoration: InputDecoration(
                        hintText: 'Search concerts...',
                        prefixIcon: const Icon(Icons.search, color: AppColors.textPrimary),
                        hintStyle: GoogleFonts.inter(color: AppColors.textSecondary),
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
                  return SliverFillRemaining(
                    child: Center(
                      child: Text(
                        'NO EVENTS FOUND',
                        style: GoogleFonts.pressStart2p(fontSize: 10, color: AppColors.textSecondary),
                      ),
                    ),
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
      margin: const EdgeInsets.only(bottom: 24),
      decoration: AppTheme.retroCard,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/concert/${concert.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.network(
                  concert.image,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 200,
                    color: Colors.grey[200],
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      border: Border.all(color: AppColors.border, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      DateFormat('dd MMM').format(concert.date),
                      style: GoogleFonts.pressStart2p(
                        color: AppColors.textPrimary, 
                        fontWeight: FontWeight.bold, 
                        fontSize: 8
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Container(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.border, width: 2)),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    concert.name.toUpperCase(),
                    style: GoogleFonts.pressStart2p(
                      fontSize: 12, 
                      fontWeight: FontWeight.bold, 
                      color: AppColors.textPrimary
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          concert.location,
                          style: GoogleFonts.inter(
                            color: AppColors.textSecondary, 
                            fontSize: 13,
                            fontWeight: FontWeight.w500
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "START FROM",
                            style: GoogleFonts.pressStart2p(fontSize: 7, color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0).format(concert.price),
                            style: GoogleFonts.inter(
                              color: AppColors.textPrimary, 
                              fontWeight: FontWeight.w900, 
                              fontSize: 18
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border, width: 2),
                          boxShadow: const [
                            BoxShadow(color: AppColors.border, offset: Offset(3, 3)),
                          ],
                        ),
                        child: Text(
                          'GET TICKET',
                          style: GoogleFonts.pressStart2p(
                            color: Colors.white, 
                            fontWeight: FontWeight.bold, 
                            fontSize: 8
                          ),
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
