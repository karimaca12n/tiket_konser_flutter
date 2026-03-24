import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiket_konser/providers/concert_provider.dart';
import 'package:tiket_konser/widgets/navbar.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<ConcertProvider>().fetchConcerts();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: const Navbar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Section
            Container(
              width: double.infinity,
              height: 400,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: const NetworkImage('https://images.unsplash.com/photo-1470225620780-dba8ba36b745'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.darken),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'FIND YOUR NEXT FAVORITE CONCERT',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 600),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: TextField(
                        onChanged: (value) => context.read<ConcertProvider>().setSearchQuery(value),
                        decoration: const InputDecoration(
                          hintText: 'Search concerts, artists, venues...',
                          prefixIcon: Icon(Icons.search),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Concert List
            Padding(
              padding: const EdgeInsets.all(40.0),
              child: Consumer<ConcertProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(child: Padding(
                      padding: EdgeInsets.all(50.0),
                      child: CircularProgressIndicator(),
                    ));
                  }

                  if (provider.concerts.isEmpty) {
                    return const Center(child: Padding(
                      padding: EdgeInsets.all(50.0),
                      child: Text('No concerts found.'),
                    ));
                  }

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 4 : (MediaQuery.of(context).size.width > 800 ? 3 : 1),
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: provider.concerts.length,
                    itemBuilder: (context, index) {
                      final concert = provider.concerts[index];
                      return Card(
                        clipBehavior: Clip.antiAlias,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 4,
                        child: InkWell(
                          onTap: () => context.go('/concert/${concert.id}'),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 3,
                                child: Image.network(
                                  concert.image,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.image, size: 50, color: Colors.grey),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            concert.name,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Icon(Icons.calendar_today, size: 12, color: Colors.grey),
                                              const SizedBox(width: 4),
                                              Text(DateFormat('dd MMM yyyy').format(concert.date), style: const TextStyle(color: Colors.grey, fontSize: 11)),
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          Row(
                                            children: [
                                              const Icon(Icons.location_on, size: 12, color: Colors.grey),
                                              const SizedBox(width: 4),
                                              Expanded(child: Text(concert.location, style: const TextStyle(color: Colors.grey, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis)),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Text(
                                        NumberFormat.currency(locale: 'id_ID', symbol: 'IDR ', decimalDigits: 0).format(concert.price),
                                        style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold, fontSize: 15),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
