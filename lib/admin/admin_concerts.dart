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
      title: 'MANAGE CONCERTS',
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) => provider.setSearchQuery(value),
                    decoration: const InputDecoration(
                      hintText: 'Search concerts...',
                      prefixIcon: Icon(Icons.search, color: Colors.cyan),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => _showConcertDialog(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                  ),
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          ),
          Expanded(
            child: Scrollbar(
              thumbVisibility: true,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : (provider.concerts.isEmpty 
                        ? const Center(child: Text('No concerts found.'))
                        : SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columnSpacing: 30,
                              columns: const [
                                DataColumn(label: Text('IMAGE')),
                                DataColumn(label: Text('NAME')),
                                DataColumn(label: Text('DATE')),
                                DataColumn(label: Text('LOCATION')),
                                DataColumn(label: Text('PRICE')),
                                DataColumn(label: Text('ACTIONS')),
                              ],
                              rows: provider.concerts.map((concert) {
                                return DataRow(cells: [
                                  DataCell(
                                    Image.network(
                                      concert.image,
                                      width: 50,
                                      height: 30,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_,__,___) => const Icon(Icons.broken_image, size: 20),
                                    ),
                                  ),
                                  DataCell(Text(concert.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                                  DataCell(Text(DateFormat('dd MMM yy').format(concert.date), style: const TextStyle(fontSize: 11))),
                                  DataCell(Text(concert.location, style: const TextStyle(fontSize: 11))),
                                  DataCell(Text(NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0).format(concert.price), style: const TextStyle(fontSize: 11))),
                                  DataCell(Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.blue, size: 18), 
                                        onPressed: () => _showConcertDialog(context, concert: concert),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red, size: 18),
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
          title: Text(isEdit ? 'EDIT CONCERT' : 'ADD CONCERT'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'NAME')),
                const SizedBox(height: 12),
                TextField(
                  controller: dateController,
                  readOnly: true,
                  decoration: const InputDecoration(labelText: 'DATE', suffixIcon: Icon(Icons.calendar_today)),
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
                const SizedBox(height: 12),
                TextField(controller: locationController, decoration: const InputDecoration(labelText: 'LOCATION')),
                const SizedBox(height: 12),
                TextField(controller: priceController, decoration: const InputDecoration(labelText: 'PRICE'), keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                TextField(controller: descController, decoration: const InputDecoration(labelText: 'DESCRIPTION'), maxLines: 3),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final result = await FilePicker.platform.pickFiles(type: FileType.image);
                    if (result != null) setDialogState(() => selectedImage = result.files.first);
                  },
                  child: Container(
                    height: 100,
                    width: double.infinity,
                    decoration: BoxDecoration(border: Border.all(color: Colors.white24), borderRadius: BorderRadius.circular(8)),
                    child: selectedImage != null
                        ? Image.memory(selectedImage!.bytes!, fit: BoxFit.cover)
                        : (isEdit ? Image.network(concert.image, fit: BoxFit.cover) : const Icon(Icons.cloud_upload)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
            ElevatedButton(
              onPressed: () async {
                final data = {
                  'name': nameController.text,
                  'location': locationController.text,
                  'price': double.tryParse(priceController.text) ?? 0,
                  'description': descController.text,
                  'date': DateFormat('yyyy-MM-dd').format(selectedDate),
                };
                bool success = isEdit 
                  ? await context.read<ConcertProvider>().updateConcert(concert.id, data, selectedImage)
                  : await context.read<ConcertProvider>().addConcert(data, selectedImage);
                if (success && context.mounted) Navigator.pop(context);
              },
              child: Text(isEdit ? 'UPDATE' : 'SAVE'),
            ),
          ],
        ),
      ),
    );
  }
}
