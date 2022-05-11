import 'package:flutter/material.dart';
import 'helper.dart';

/*
List<Color> _colorCollection = colorCollection;
List<String> _colorNames = colorNames;
int _selectedColorIndex = 0;
*/


/*
class ColorPicker extends StatefulWidget {
  const ColorPicker({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ColorPickerState();
  }
}

class ColorPickerState extends State<ColorPicker> {
  final List<Color>_colorCollection = colorCollection;
  final List<String>_colorNames = colorNames;
  int _selectedColorIndex = 0;

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
                leading: Icon(
                  index == _selectedColorIndex ? Icons.lens : Icons.trip_origin,
                  color: _colorCollection[index],
                ),
                title: Text(_colorNames[index]),
                onTap: () {
                  setState(() {
                    _selectedColorIndex = index;
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
*/
