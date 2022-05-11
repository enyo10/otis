import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


import '../models/lodging.dart';
import '../models/sql_helper.dart';
import 'lodging_details.dart';

class LodgingList extends StatefulWidget {
  const LodgingList({Key? key}) : super(key: key);

  @override
  _LodgingListState createState() => _LodgingListState();
}

class _LodgingListState extends State<LodgingList> {
  // All journals
  List<Map<String, dynamic>> _apartments = [];

  bool _isLoading = true;
  // This function is used to fetch all data from the database
  void _refreshJournals() async {
    final data = await SQLHelper.getApartments();

    setState(() {
      _apartments = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshJournals(); // Loading the diary when the app starts
  }

  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _rentController = TextEditingController();

  // This function will be triggered when the floating button is pressed
  // It will also be triggered when you want to update an item
  void _showForm(int? id) async {
    if (id != null) {
      // id == null -> create new item
      // id != null -> update an existing item
      final existingJournal =
          _apartments.firstWhere((element) => element['id'] == id);
      _addressController.text = existingJournal['address'];
      _descriptionController.text = existingJournal['description'];
      _rentController.text = existingJournal['rent'].toString();
    }

    showModalBottomSheet(
        context: context,
        elevation: 5,
        isScrollControlled: true,
        builder: (_) => Container(
              padding: EdgeInsets.only(
                top: 15,
                left: 15,
                right: 15,
                // this will prevent the soft keyboard from covering the text fields
                bottom: MediaQuery.of(context).viewInsets.bottom + 120,
              ),
              decoration:  const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25.0),
                  topRight: Radius.circular(25.0),
                ),
              ),
              
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    TextField(
                      controller: _addressController,
                      decoration: const InputDecoration(hintText: 'Address'),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(hintText: 'Description'),
                    ),
                    TextField(
                      controller: _rentController,
                      // keyboardType: TextInputType.number,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'(^\d*\.?\d*)')),
                      ],
                      // Only numbers can be entered
                      decoration: const InputDecoration(hintText: 'rent'),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        // Save new journal
                        if (id == null) {
                          await _addApartment();
                        }

                        if (id != null) {
                          await _updateItem(id);
                        }

                        // Clear the text fields
                        _addressController.text = '';
                        _descriptionController.text = '';

                        // Close the bottom sheet
                        Navigator.of(context).pop();
                      },
                      child: Text(id == null ? 'Create New' : 'Update'),
                    )
                  ],
                ),
              ),
            ));
  }

// Insert a new journal to the database
  Future<void> _addApartment() async {
    await SQLHelper.insertApartment(1, _addressController.text,
        _descriptionController.text, double.parse(_rentController.text));
    _refreshJournals();
  }

  // Update an existing journal
  Future<void> _updateItem(int id) async {
    double rent = double.parse(_rentController.text);
    await SQLHelper.updateApartment(
        id, 1, rent, _addressController.text, _descriptionController.text);
    _refreshJournals();
  }

  // Delete an item
  void _deleteItem(int id) async {
    await SQLHelper.deleteApartment(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Successfully deleted a journal!'),
    ));
    _refreshJournals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ottis'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: _apartments.length,
              itemBuilder: (context, index) => GestureDetector(
                onDoubleTap: () {
                  Map<String, dynamic> data = _apartments[index];
                  Lodging lodging = Lodging(
                      id: data['id'],
                      address: data['address'],
                      description: data['description'],
                      rent: data['rent'],
                      type: data['type']);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => LodgingDetails(lodging: lodging)),
                  );
                },
                child: Card(
                  color: Colors.orange[200],
                  margin: const EdgeInsets.all(15),
                  child: ListTile(
                      title: Text(_apartments[index]['address']),
                      subtitle: Text(_apartments[index]['description']),
                      trailing: SizedBox(
                        width: 100,
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () =>
                                  _showForm(_apartments[index]['id']),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () =>
                                  _deleteItem(_apartments[index]['id']),
                            ),
                          ],
                        ),
                      )),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showForm(null),
      ),
    );
  }
}
