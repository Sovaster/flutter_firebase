import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class EditNotePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _EditNotePageState();
}

class _EditNotePageState extends State<EditNotePage> {
  final user = FirebaseAuth.instance.currentUser!;
  GlobalKey<FormState> _key = GlobalKey();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  bool isObscure = true;
  bool _isValid = true;
  late Map<String, dynamic> imageData = {};
  String noteId = "";

  @override
  Widget build(BuildContext context) {
    var data = ModalRoute.of(context)!.settings.arguments;

    if (data != null) {
      Map<String, dynamic> values = data as Map<String, dynamic>;
      DocumentSnapshot note = values['NOTE'];

      _titleController.text = note['title'];
      _descriptionController.text = note['description'];
      imageData = note['preview_image'];
      noteId = note.id;
    }

    return Scaffold(
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Form(
            key: _key,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                //title
                Padding(
                  padding: EdgeInsets.only(left: 100, right: 100, top: 15),
                  child: TextFormField(
                    controller: _titleController,
                    validator: (value) {
                      if (!_isValid) {
                        return null;
                      }
                      if (value!.isEmpty) {
                        return 'Поле пустое';
                      }
                      if (value.length < 1) {
                        return 'Заголовок должнен содержать не менее 1 символа';
                      }
                      return null;
                    },
                    maxLength: 255,
                    decoration: const InputDecoration(
                      labelText: 'Заголовок',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),

                //description
                Padding(
                  padding: EdgeInsets.only(left: 100, right: 100, top: 15),
                  child: TextFormField(
                    controller: _descriptionController,
                    validator: (value) {
                      if (!_isValid) {
                        return null;
                      }
                      if (value!.isEmpty) {
                        return 'Поле пустое';
                      }
                      if (value.length < 1) {
                        return 'Описание должно содержать не менее 1 символа';
                      }
                      return null;
                    },
                    maxLength: 255,
                    decoration: const InputDecoration(
                      labelText: 'Описание',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
              padding: EdgeInsets.only(left: 350, right: 350, top: 5),
              child: Container(
                width: 150,
                child: ElevatedButton(
                  child: Text("Загрузить фото"),
                  onPressed: () => {_pickFile()},
                ),
              )),
          Padding(
              padding: EdgeInsets.only(left: 350, right: 350, top: 50),
              child: Container(
                width: 180,
                child: ElevatedButton(
                  child: Text("Сохранить изменения"),
                  onPressed: () => {
                    _isValid = true,
                    if (_key.currentState!.validate()) {editNote(noteId)}
                  },
                ),
              )),
          Padding(
              padding: EdgeInsets.only(left: 350, right: 350, top: 50),
              child: ElevatedButton(
                child: Text("Все заметки"),
                onPressed: () => {
                  _isValid = false,
                  _key.currentState!.validate(),
                  Navigator.pushNamed(context, 'notes'),
                },
              )),
        ],
      )),
    );
  }

  void _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      PlatformFile file = result.files.first;
      await FirebaseStorage.instance
          .ref('uploads/${file.name}')
          .putData(file.bytes!);

      imageData = {
        "size": file.size,
        "file_extensions": file.extension!,
        "name": file.name,
        'storage_path': 'uploads/${file.name}'
      };
    } else {}
  }

  Future editNote(String id) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('notes')
        .doc(id)
        .set({
          'title': _titleController.text.trim(),
          'description': _descriptionController.text.trim(),
          'preview_image': imageData
        })
        .then((value) => {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Запись изменена"),
                ),
              ),
              Navigator.pushNamed(context, 'notes'),
            })
        .onError((error, stackTrace) => {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Не удалось сохранить изменения"),
                ),
              )
            });
  }
}
