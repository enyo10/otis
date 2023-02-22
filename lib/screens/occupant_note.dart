import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:otis/helper/helper.dart';
import 'package:otis/models/note.dart';
import 'package:otis/models/occupant.dart';
import 'package:otis/models/sql_helper.dart';
import 'package:otis/widgets/add_comment.dart';
import 'package:otis/widgets/password_controller.dart';

class OccupantNote extends StatefulWidget {
  const OccupantNote({Key? key, required this.note, required this.occupant})
      : super(key: key);
  final Note note;
  final Occupant occupant;

  @override
  State<OccupantNote> createState() => _OccupantNoteState();
}

class _OccupantNoteState extends State<OccupantNote> {
  String comment = "";

  @override
  void initState() {
    comment = widget.note.comment;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var firstname = widget.occupant.firstname;
    var lastname = widget.occupant.lastname;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFEFFFFD),
          elevation: 0.0,
          iconTheme: const IconThemeData(
            color: Colors.red,
          ),
        ),
        body: FractionallySizedBox(
          heightFactor: 0.8,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Card(
                  elevation: 10,
                  margin: const EdgeInsets.all(8.0),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(firstname, style: const TextStyle(
                              fontSize: 20
                            ),),
                            const SizedBox(
                              width: 20,
                            ),
                            Text(lastname, style: const TextStyle(fontSize: 20),)
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                Card(
                  elevation: 5,
                  margin: const EdgeInsets.all(8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              "Commentaire: ",
                              // style: TextStyle(fontSize: 20),
                              style: GoogleFonts.courgette(
                                textStyle: const TextStyle(fontSize: 25),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Text(
                          comment,
                          style: const TextStyle(
                              fontSize: 20, fontStyle: FontStyle.italic),
                          /* style: GoogleFonts.courgette(
                              textStyle: const TextStyle(
                            fontSize: 20,
                          )),*/
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: TextButton(
                          onPressed: () async {
                            await _updateComment();
                            // .then((value) => Navigator.of(context).pop());
                          },
                          child: Text(
                            "Actualiser",
                            style: GoogleFonts.charm(
                                textStyle: const TextStyle(
                                    color: Colors.lightGreen, fontSize: 25)),
                          )),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: TextButton(
                        onPressed: () async {
                          await _deleteComment();
                          if (!mounted) return;
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          "Supprimer",
                          style: GoogleFonts.charm(
                            textStyle: const TextStyle(
                                color: Colors.redAccent, fontSize: 25),
                          ),
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  _deleteComment() async {
    var passwordController = const PasswordController(title: "Supprimer note");

    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return passwordController;
        }).then((value) async {
      if (value) {
        var id = widget.note.id;
        await SQLHelper.deleteComment(id).then((value) {
          showMessage(context, " Le Commentaire est supprimé");
        });
      } else {
        showMessage(context, "Saisir mot de passe correcte");
      }
    });
  }

  _loadComment() async {
    int ownerId = widget.occupant.id;
    var notes = await SQLHelper.getComments(ownerId)
        .then((value) => value.map((e) => Note.fromMap(e)).toList());

    if (notes.isNotEmpty) {
      comment = notes.first.comment;
    }
    setState(() {
      comment = notes.first.comment;
    });
  }

  Future<void> _updateComment() async {
    var passwordController = const PasswordController(title: "Actualiser note");

    await showDialog(
        context: context,
        builder: (context) {
          return passwordController;
        }).then((value) async {
      if (value!) {
        showModalBottomSheet(
            isScrollControlled: true,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(40.0),
            ),
            context: context,
            builder: (BuildContext ctx) {
              return AddComment(ownerId: widget.occupant.id, note: widget.note);
            }).then((value) => _loadComment());
      } else {
        showMessage(context, "Saisir mot de passe correcte");
      }
    });
  }
}
