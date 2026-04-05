import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiket_konser/admin/admin_layout.dart';
import 'package:tiket_konser/providers/concert_provider.dart';
import 'package:tiket_konser/models/concert_model.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:tiket_konser/core/constants.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminConcertsPage extends StatefulWidget {
  const AdminConcertsPage({super.key});

  @override
  State<AdminConcertsPage> createState() => _AdminConcertsPageState();
}

class _AdminConcertsPageState extends State<AdminConcertsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<ConcertProvider>().fetchConcerts());
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ConcertProvider>(context);

    return AdminLayout(
      currentPath: '/admin/concerts',
      title: 'CONCERTS',
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) => provider.setSearchQuery(value),
                    style: GoogleFonts.inter(),
                    decoration: InputDecoration(
                      hintText: 'Search concerts...',
                      prefixIcon: const Icon(Icons.search, color: AppColors.textPrimary),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: AppTheme.retroCard,
                  child: ElevatedButton(
                    onPressed: () => _showConcertDialog(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: AppColors.textPrimary,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                    child: const Icon(Icons.add, size: 24),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : (provider.concerts.isEmpty 
                    ? Center(child: Text('NO CONCERTS FOUND', style: GoogleFonts.pressStart2p(fontSize: 10, color: AppColors.textSecondary)))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                        itemCount: provider.concerts.length,
                        itemBuilder: (context, index) {
                          final concert = provider.concerts[index];
                          return _ConcertListItem(concert: concert, provider: provider);
                        },
                      )),
          ),
        ],
      ),
    );
  }

  void _showConcertDialog(BuildContext context, {ConcertModel? concert}) {
    final isEdit = concert != null;
    final nameController = TextEditingController(text: concert?.name);
    final locationController = TextEditingController(text: concert?.location);
    final priceController = TextEditingController(text: concert?.price.toInt().toString());
    final descController = TextEditingController(text: concert?.description);
    
    DateTime selectedDate = concert?.date ?? DateTime.now();
    final dateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(selectedDate),
    );

    PlatformFile? selectedImage;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            padding: const EdgeInsets.all(24),
            decoration: AppTheme.retroCard,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isEdit ? 'EDIT EVENT' : 'NEW EVENT',
                        style: GoogleFonts.pressStart2p(fontSize: 14, color: AppColors.textPrimary),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                  const Divider(color: AppColors.border, thickness: 2),
                  const SizedBox(height: 16),
                  _dialogField('CONCERT NAME', nameController),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('EVENT DATE', style: GoogleFonts.pressStart2p(fontSize: 8, color: AppColors.textSecondary)),
                            const SizedBox(height: 8),
                            TextField(
                              controller: dateController,
                              readOnly: true,
                              style: GoogleFonts.inter(),
                              decoration: const InputDecoration(
                                suffixIcon: Icon(Icons.calendar_today, size: 18, color: AppColors.primary),
                                isDense: true,
                              ),
                              onTap: () async {
                                final DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate: selectedDate,
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2101),
                                );
                                if (picked != null) {
                                  setDialogState(() {
                                    selectedDate = picked;
                                    dateController.text = DateFormat('yyyy-MM-dd').format(picked);
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _dialogField('TICKET PRICE', priceController, keyboardType: TextInputType.number),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _dialogField('LOCATION', locationController),
                  const SizedBox(height: 16),
                  _dialogField('DESCRIPTION', descController, maxLines: 3),
                  const SizedBox(height: 20),
                  Text('PROMO IMAGE', style: GoogleFonts.pressStart2p(fontSize: 8, color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final result = await FilePicker.platform.pickFiles(type: FileType.image);
                      if (result != null) setDialogState(() => selectedImage = result.files.first);
                    },
                    child: Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: AppColors.border, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: selectedImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.memory(selectedImage!.bytes!, fit: BoxFit.cover),
                            )
                          : (isEdit 
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Image.network(concert!.image, fit: BoxFit.cover),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.cloud_upload, size: 32, color: AppColors.textSecondary),
                                    const SizedBox(height: 4),
                                    Text('SELECT FILE', style: GoogleFonts.pressStart2p(fontSize: 8, color: AppColors.textSecondary)),
                                  ],
                                )),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        final data = {
                          'name': nameController.text,
                          'location': locationController.text,
                          'price': double.tryParse(priceController.text) ?? 0,
                          'description': descController.text,
                          'date': DateFormat('yyyy-MM-dd').format(selectedDate),
                        };
                        bool success = isEdit 
                          ? await context.read<ConcertProvider>().updateConcert(concert!.id, data, selectedImage)
                          : await context.read<ConcertProvider>().addConcert(data, selectedImage);
                        if (success && context.mounted) Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isEdit ? AppColors.approved : AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(isEdit ? 'UPDATE DATA' : 'CREATE CONCERT', style: GoogleFonts.pressStart2p(fontSize: 10)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _dialogField(String label, TextEditingController controller, {TextInputType? keyboardType, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.pressStart2p(fontSize: 8, color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        TextField(
          controller: controller, 
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: GoogleFonts.inter(),
          decoration: const InputDecoration(isDense: true),
        ),
      ],
    );
  }
}

class _ConcertListItem extends StatelessWidget {
  final ConcertModel concert;
  final ConcertProvider provider;

  const _ConcertListItem({required this.concert, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: AppTheme.retroCard,
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              border: const Border(right: BorderSide(color: AppColors.border, width: 2)),
              image: DecorationImage(
                image: NetworkImage(concert.image),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    concert.name.toUpperCase(),
                    style: GoogleFonts.pressStart2p(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DateFormat('dd MMM yyyy').format(concert.date).toUpperCase(),
                    style: GoogleFonts.pressStart2p(fontSize: 7, color: AppColors.primary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    concert.location.toUpperCase(),
                    style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: AppColors.textPrimary, size: 20),
                onPressed: () => (context.findAncestorStateOfType<_AdminConcertsPageState>())?._showConcertDialog(context, concert: concert),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: AppColors.rejected, size: 20),
                onPressed: () => _confirmDelete(context),
              ),
            ],
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: AppColors.border, width: 3),
          borderRadius: BorderRadius.circular(0),
        ),
        title: Text('DELETE?', style: GoogleFonts.pressStart2p(fontSize: 14)),
        content: Text('Remove this concert permanent?', style: GoogleFonts.inter()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('NO')),
          ElevatedButton(
            onPressed: () {
              provider.deleteConcert(concert.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.rejected),
            child: const Text('YES', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
