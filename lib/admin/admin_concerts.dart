import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiket_konser/admin/admin_layout.dart';
import 'package:tiket_konser/providers/concert_provider.dart';
import 'package:tiket_konser/models/concert_model.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';

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
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (value) => provider.setSearchQuery(value),
                  decoration: const InputDecoration(
                    hintText: 'Search concerts...',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () => _showConcertDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('Add Concert'),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Card(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : (provider.concerts.isEmpty 
                      ? const Center(child: Text('No concerts found.'))
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columnSpacing: 40,
                            columns: const [
                              DataColumn(label: Text('Image')),
                              DataColumn(label: Text('Concert Name')),
                              DataColumn(label: Text('Date')),
                              DataColumn(label: Text('Location')),
                              DataColumn(label: Text('Price')),
                              DataColumn(label: Text('Description')), // Tambahkan kolom Deskripsi
                              DataColumn(label: Text('Actions')),
                            ],
                            rows: provider.concerts.map((concert) {
                              return DataRow(cells: [
                                DataCell(
                                  Container(
                                    width: 80,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.grey[300]!),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        concert.image,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(Text(concert.name, style: const TextStyle(fontWeight: FontWeight.bold))),
                                DataCell(Text(DateFormat('dd MMM yyyy').format(concert.date))),
                                DataCell(Text(concert.location)),
                                DataCell(Text(NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0).format(concert.price))),
                                DataCell(
                                  SizedBox(
                                    width: 150,
                                    child: Text(
                                      concert.description ?? '-', 
                                      maxLines: 1, 
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                  ),
                                ),
                                DataCell(Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blue), 
                                      onPressed: () => _showConcertDialog(context, concert: concert),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => provider.deleteConcert(concert.id),
                                    ),
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
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEdit ? 'Edit Concert' : 'Add New Concert'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Concert Name')),
                const SizedBox(height: 12),
                TextField(
                  controller: dateController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (picked != null && picked != selectedDate) {
                      setDialogState(() {
                        selectedDate = picked;
                        dateController.text = DateFormat('yyyy-MM-dd').format(picked);
                      });
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(controller: locationController, decoration: const InputDecoration(labelText: 'Location')),
                const SizedBox(height: 12),
                TextField(controller: priceController, decoration: const InputDecoration(labelText: 'Price'), keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                TextField(
                  controller: descController, 
                  decoration: const InputDecoration(labelText: 'Description'), 
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final result = await FilePicker.platform.pickFiles(type: FileType.image);
                    if (result != null) {
                      setDialogState(() => selectedImage = result.files.first);
                    }
                  },
                  child: Container(
                    height: 100,
                    width: double.infinity,
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8)),
                    child: selectedImage != null
                        ? Image.memory(selectedImage!.bytes!, fit: BoxFit.cover)
                        : (isEdit 
                            ? Image.network(concert.image, fit: BoxFit.cover, errorBuilder: (_,__,___) => const Icon(Icons.image))
                            : const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.cloud_upload), Text('Upload Image')])),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final data = {
                  'name': nameController.text,
                  'location': locationController.text,
                  'price': double.tryParse(priceController.text) ?? 0,
                  'description': descController.text,
                  'date': DateFormat('yyyy-MM-dd').format(selectedDate),
                };

                bool success;
                if (isEdit) {
                  success = await context.read<ConcertProvider>().updateConcert(concert.id, data, selectedImage);
                } else {
                  success = await context.read<ConcertProvider>().addConcert(data, selectedImage);
                }

                if (success && context.mounted) Navigator.pop(context);
              },
              child: Text(isEdit ? 'Update Concert' : 'Save Concert'),
            ),
          ],
        ),
      ),
    );
  }
}
