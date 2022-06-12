import 'package:flutter/material.dart';

class ModalBottomSheet {
  static void _moreModalBottomSheet(context) {
    Size size = MediaQuery.of(context).size;
    showModalBottomSheet(
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40.0),
        ),
        context: context,
        builder: (BuildContext bc) {
          return Container(
            height: size.height * 0.5,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(40.0),
                topLeft: Radius.circular(40.0),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: ListView(
                physics: const ClampingScrollPhysics(),
                children: const [
                  //content of modal bottom
                  // sheet
                  Center(
                    child: Text("Hello"),
                  )
                ],
              ),
            ),
          );
        });
  }
}

class Test extends StatelessWidget {
  const Test({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ElevatedButton(
            onPressed: () =>
                ModalBottomSheet._moreModalBottomSheet(context),
            child: const Text('open modal'),
          ),
        ),
      ),
    );
  }
}
