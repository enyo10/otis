import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:otis/helper/helper.dart';
import 'package:otis/models/sql_helper.dart';

import '../models/note.dart';

class AddComment extends StatefulWidget {
  const AddComment({Key? key, required this.ownerId, this.note})
      : super(key: key);

  final int ownerId;
  final Note? note;

  @override
  State<AddComment> createState() => _AddCommentState();
}

class _AddCommentState extends State<AddComment> {
  final TextEditingController _commentTextEditor = TextEditingController();

  @override
  void initState() {
    _initTextEditor();
    super.initState();
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
        padding: const EdgeInsets.only(left: 0.0),
        // padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Ajouter commentaire",
                style: GoogleFonts.charm(fontSize: 35, color: Colors.red),
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
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                    top: 20,
                    left: 8.0,
                    right: 8.0),
                child: TextField(
                  controller: _commentTextEditor,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Ajouter commentaire',
                      hintText: 'Commentaire'),
                  style: Theme.of(context).textTheme.labelLarge,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                  onPressed: () async {
                    await _addComment();
                    if (!mounted) return;
                    Navigator.of(context).pop();
                  },
                  child: const Text("Ajouter"))
            ],
          ),
        ),
      ),
    );
  }

  _addComment() async {
    var comment = _commentTextEditor.text;
    var ownerId = widget.ownerId;
    if (comment.isNotEmpty) {
      if (widget.note != null) {
        await SQLHelper.updateComment(widget.note!.id, comment)
            .then((value) => showMessage(context, "Commentaire actualisé"));
      } else {
        await SQLHelper.insertComment(ownerId, comment)
            .then((value) => showMessage(context, "Commentaire bien ajouté"));
      }
    } else {
      showMessage(context, "Vérifier le contenu");
    }
    _commentTextEditor.clear();
  }

  _initTextEditor() {
    if (widget.note != null) {
      _commentTextEditor.text = widget.note!.comment;
    }
  }
}
