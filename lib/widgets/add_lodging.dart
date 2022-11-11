import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:otis/helper/helper.dart';
import 'package:otis/models/building.dart';
import '../models/lodging.dart';
import '../models/rent_period.dart';
import '../models/sql_helper.dart';

class AddLodging extends StatefulWidget {
  final Building building;
  final Lodging? lodging;
  const AddLodging({Key? key, required this.building, this.lodging})
      : super(key: key);

  @override
  State<AddLodging> createState() => _AddLodgingState();
}

class _AddLodgingState extends State<AddLodging> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _rentController = TextEditingController();
  final TextEditingController _floorController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  late Rent? _actualRent;
  DateTime _rentModificationDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _setValue();
    if (widget.lodging != null) {
      _getLastRent(widget.lodging!.id).then((value) {
        _actualRent = value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      height: size.height * 0.6,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(40.0),
          topLeft: Radius.circular(40.0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            children: [
              //content of modal bottom
              // sheet
              const Padding(
                padding: EdgeInsets.only(top: 20, bottom: 8.0),
                child: Center(
                  child: Text(
                    'Appartement',
                    style: TextStyle(fontSize: 20.0),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 60),
                child: Divider(
                  thickness: 5, // thickness of the line
                  indent: 20, // empty space to the leading edge of divider.
                  endIndent:
                      20, // empty space to the trailing edge of the divider.
                  color: Colors.red, // The color to use when painting the line.
                  height: 20, // The divider's height extent.
                ),
              ),
              Visibility(
                visible: widget.lodging == null,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: _floorController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration: const InputDecoration(
                          hintText: 'Numéro d\'étage',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          hintText: 'Address',
                          labelText: 'Address',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          hintText: 'Description',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _rentController,
                  // keyboardType: TextInputType.number,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'(^\d*\.?\d*)')),
                  ],
                  // Only numbers can be entered
                  decoration: const InputDecoration(
                    hintText: 'rent',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        widget.lodging == null
                            ? await _selectRentalDate(context)
                            : await _selectRentModificationDate(context);
                      },
                      child: Text(widget.lodging == null
                          ? 'Mise en service'
                          : 'Date modification'),
                    ),
                    const SizedBox(
                      width: 40.0,
                    ),
                    Text(
                      stringValueOfDateTime(_selectedDate),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: ElevatedButton(
                  onPressed: () async {
                    widget.lodging != null
                        ? await _updateApartmentRent(widget.lodging!)
                        : await _addApartment();
                    _addressController.text = '';
                    _descriptionController.text = '';
                    // Close the bottom sheet
                    if (!mounted) return;
                    Navigator.of(context).pop();
                  },
                  child: Text(
                      widget.lodging == null ? 'Enrégistrer' : 'Actualiser'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _setValue() {
    if (widget.lodging != null) {
      _descriptionController.text = widget.lodging!.description;
      _addressController.text = widget.lodging!.address;
      _rentController.text = widget.lodging!.rent.toString();
      _floorController.text = widget.lodging!.floor.toString();
    }
  }

  void _clearController() {
    _rentController.clear();
    _descriptionController.clear();
    _addressController.clear();
    _floorController.clear();
  }

  Future<void> _selectRentalDate(BuildContext context) async {
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2040),
    );
    if (selected != null && selected != _selectedDate) {
      setState(() {
        _selectedDate = selected;
      });
    }
  }

  Future<void> _selectRentModificationDate(BuildContext context) async {
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: _actualRent!.startDate,
      firstDate: _actualRent!.startDate,
      lastDate: DateTime(2050),
    );
    if (selected != null && selected != _rentModificationDate) {
      setState(() {
        _rentModificationDate = selected;
      });
    }
  }

  bool _apartmentHasData() {
    if (_floorController.text.isNotEmpty &&
        _addressController.text.isNotEmpty &&
        _descriptionController.text.isNotEmpty &&
        _rentController.text.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  /// Insert a new apartment to the database
  Future<void> _addApartment() async {
    if (_apartmentHasData()) {
      await SQLHelper.insertApartment(
              int.parse(_floorController.text),
              widget.building.id,
              _addressController.text,
              _descriptionController.text,
              double.parse(_rentController.text))
          .then((lodgingId) async {
        print(" apartement with id $lodgingId inserted");
        await SQLHelper.insertRent(
                lodgingId, _selectedDate, double.parse(_rentController.text))
            .then((id) {
          showMessage(context, "Création réussie");
        });
      });
      _clearController();
      //_refreshJournals();
    }
  }

  Future<void> _updateApartmentRent(Lodging lodging) async {
    if (_actualRent != null) {
      if (_rentController.text.isNotEmpty) {
        double rentValue = double.parse(_rentController.text);
        await SQLHelper.insertRent(lodging.id, _selectedDate, rentValue)
            .then((value) async {
          _actualRent!.endDate = _selectedDate;
          await SQLHelper.updateRent(_actualRent!.id!, _actualRent!.toMap());
          await SQLHelper.updateApartment(lodging.id, lodging.floor, rentValue,
              lodging.address, lodging.description, lodging.occupantId);
        });
      }
    }
    var rents = await SQLHelper.getRents(lodging.id);

    List<Rent> rentList = rents.map((e) => Rent.formMap(e)).toList();

    // if (rentList.isNotEmpty) {
    for (int i = 0; i < rentList.length; i++) {
      if (rentList[i].endDate == null) {
        Rent actualRent = rentList[i];

        if (_rentController.text.isNotEmpty) {
          double rentValue = double.parse(_rentController.text);
          await SQLHelper.insertRent(lodging.id, _selectedDate, rentValue)
              .then((value) async {
            actualRent.endDate = _selectedDate;
            await SQLHelper.updateRent(actualRent.id!, actualRent.toMap());
            await SQLHelper.updateApartment(
                lodging.id,
                lodging.floor,
                rentValue,
                lodging.address,
                lodging.description,
                lodging.occupantId);
          });
        }
      }
      // }
      _clearController();
    }
  }

  Future<Rent?> _getLastRent(int lodgingId) async {
    var rents = await SQLHelper.getRents(lodgingId);
    List<Rent> rentList = rents.map((e) => Rent.formMap(e)).toList();
    if (rentList.isNotEmpty) {
      for (int i = 0; i < rentList.length; i++) {
        if (rentList[i].endDate == null) {
          Rent actualRent = rentList[i];
          print("actual ....${actualRent.toMap()}");
          return actualRent;
        }
      }
    }

    return null;
  }
}
