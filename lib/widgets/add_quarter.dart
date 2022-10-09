import 'package:flutter/material.dart';
import 'package:otis/models/sql_helper.dart';

import '../helper/helper.dart';

class AddQuarter extends StatefulWidget {
  const AddQuarter({Key? key}) : super(key: key);

  @override
  _AddQuarterState createState() => _AddQuarterState();
}

class _AddQuarterState extends State<AddQuarter> {
  var _selectedColorData = colorMap.entries.first;
  final quarterNameController = TextEditingController();
  final quarterDescriptionController = TextEditingController();
  bool isSaving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(" Ajouter un quartier"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          var name = quarterNameController.text;
          var desc = quarterDescriptionController.text;
          if (name.isNotEmpty && name.length > 1) {
            setState(() {
              isSaving = true;
            });
            SQLHelper.insertLivingQuarter(name, desc, _selectedColorData.key)
                .whenComplete(() => Navigator.pop(context, true));
          }
        },
        child: const Icon(Icons.save),
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 50,
          ),
          Padding(
            //padding: const EdgeInsets.only(left:15.0,right: 15.0,top:0,bottom: 0),
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: TextField(
              textAlign: TextAlign.center,
              controller: quarterNameController,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Le nom du quartier',
                  hintText: 'Enter le nom'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
                left: 15.0, right: 15.0, top: 15, bottom: 0),
            //padding: EdgeInsets.symmetric(horizontal: 15),
            child: TextField(
              controller: quarterDescriptionController,
              // Only numbers can be entered
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  // Only numbers can be entered
                  labelText: 'Description ',
                  hintText: 'Une petite description du quartier'),
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(50, 20, 50, 20),
            child: ListTile(
              // contentPadding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
              leading: Icon(
                Icons.lens,
                color: _selectedColorData.value,
              ),
              title: Text(_selectedColorData.key),
              onTap: () {
                showDialog<Widget>(
                  context: context,
                  barrierDismissible: true,
                  builder: (BuildContext context) {
                    return _pickColor();
                  },
                ).then((dynamic value) => setState(() {}));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _pickColor() {
    return AlertDialog(
      contentPadding: const EdgeInsets.all(20.0),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          padding: const EdgeInsets.all(0),
          itemCount: colorMap.length - 1,
          itemBuilder: (BuildContext context, int index) {
            var colorData = colorMap.entries.elementAt(index);

            return ListTile(
              contentPadding: const EdgeInsets.all(0),
              leading: Icon(
                // index == _selectedColorIndex ? Icons.lens : Icons.trip_origin,
                colorData == _selectedColorData
                    ? Icons.lens
                    : Icons.trip_origin,
                // color: _colorCollection[index],
                color: colorData.value,
              ),
              title: //Text(_colorNames[index]),
                  Text(colorData.key),
              onTap: () {
                setState(() {
                  // _selectedColorIndex = index;
                  _selectedColorData = colorData;
                });

                // ignore: always_specify_types
                Future.delayed(const Duration(milliseconds: 200), () {
                  // When task is over, close the dialog
                  Navigator.pop(context);
                });
              },
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    quarterDescriptionController.dispose();
    quarterNameController.dispose();
  }
}
