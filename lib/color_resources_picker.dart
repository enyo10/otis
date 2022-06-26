import 'package:flutter/material.dart';

import 'helper/helper.dart';


class ResourcePicker extends StatefulWidget {
  const ResourcePicker({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ResourcePickerState();
  }
}

class _ResourcePickerState extends State<ResourcePicker> {
  int selectedResourceIndex = 0;
  final List<Color>_colorCollection =  colorCollection;
  final List<String>_nameCollection = colorNames;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            padding: const EdgeInsets.all(0),
            itemCount: _colorCollection.length - 1,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                contentPadding: const EdgeInsets.all(0),
                title: Text(_nameCollection.isEmpty
                    ? "Empty list"
                    : _nameCollection[index]),
                onTap: () {
                  setState(() {
                    selectedResourceIndex = index;
                  });

                  // ignore: always_specify_types
                  Future.delayed(const Duration(milliseconds: 200), () {
                    // When task is over, close the dialog
                    Navigator.pop(context);
                  });
                },
              );
            },
          )),
    );
  }
}
