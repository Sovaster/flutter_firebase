
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  GlobalKey<FormState> _key = GlobalKey();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  TextEditingController _loginController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _middleNameController = TextEditingController();
  late Map<String, dynamic> imageData = {};

  late FirebaseAuth _auth;
  bool isObscure = true;
  bool _isValid = true;

  @override
  Widget build(BuildContext context) {
    _auth = FirebaseAuth.instance;

    return Scaffold(
      body: SingleChildScrollView(
          child: Padding(
        padding: EdgeInsets.all(30),
        child: Form(
          key: _key,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Регистрация",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24),
              ),

              //login
              Padding(
                padding: EdgeInsets.only(left: 100, right: 100, top: 15),
                child: TextFormField(
                  controller: _loginController,
                  validator: (value) {
                    if (!_isValid) {
                      return null;
                    }
                    if (value!.isEmpty) {
                      return 'Поле логин пустое';
                    }
                    if (value.length < 2) {
                      return 'Логин должен содержать не менее 2 символов';
                    }

                    return null;
                  },
                  maxLength: 255,
                  decoration: const InputDecoration(
                    labelText: 'Логин',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),

              //password
              Padding(
                padding: EdgeInsets.only(left: 100, right: 100, top: 15),
                child: TextFormField(
                  controller: _passwordController,
                  validator: (value) {
                    if (!_isValid) {
                      return null;
                    }
                    if (value!.isEmpty) {
                      return 'Поле пароль пустое';
                    }
                    if (value.length < 2) {
                      return 'Пароль должен содержать не менее 2 символов';
                    }
                    return null;
                  },
                  maxLength: 255,
                  decoration: const InputDecoration(
                    labelText: 'Пароль',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              //last name
              Padding(
                padding: EdgeInsets.only(left: 100, right: 100, top: 15),
                child: TextFormField(
                  controller: _lastNameController,
                  validator: (value) {
                    if (!_isValid) {
                      return null;
                    }
                    if (value!.isEmpty) {
                      return 'Поле пустое';
                    }
                    if (value.length < 1) {
                      return 'Фамилия должна содержать не менее 1 символа';
                    }
                    return null;
                  },
                  maxLength: 255,
                  decoration: const InputDecoration(
                    labelText: 'Фамилия',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),

              //first name
              Padding(
                padding: EdgeInsets.only(left: 100, right: 100, top: 15),
                child: TextFormField(
                  controller: _firstNameController,
                  validator: (value) {
                    if (!_isValid) {
                      return null;
                    }
                    if (value!.isEmpty) {
                      return 'Поле пустое';
                    }
                    if (value.length < 1) {
                      return 'Имя должно содержать не менее 1 символа';
                    }
                    return null;
                  },
                  maxLength: 255,
                  decoration: const InputDecoration(
                    labelText: 'Имя',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              //middle name
              Padding(
                padding: EdgeInsets.only(left: 100, right: 100, top: 15),
                child: TextFormField(
                  controller: _middleNameController,
                  validator: (value) {
                    if (!_isValid) {
                      return null;
                    }
                    if (value!.isEmpty) {
                      return 'Поле пустое';
                    }
                    if (value.length < 1) {
                      return 'Отчество должно содержать не менее 1 символа';
                    }
                    return null;
                  },
                  maxLength: 255,
                  decoration: const InputDecoration(
                    labelText: 'Отчество',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Padding(
                  padding: EdgeInsets.only(left: 350, right: 350, top: 50),
                  child: Container(
                    width: 50,
                    child: ElevatedButton(
                      child: Text("Загрузить фото профиля"),
                      onPressed: () => {_pickFile()},
                    ),
                  )),
              Padding(
                  padding: EdgeInsets.only(left: 350, right: 350, top: 50),
                  child: Container(
                    width: 50,
                    child: ElevatedButton(
                      child: Text("Зарегистрироваться"),
                      onPressed: () => {
                        _isValid = true,
                        if (_key.currentState!.validate()) {register()}
                      },
                    ),
                  )),
              Padding(
                  padding: EdgeInsets.only(left: 350, right: 350, top: 50),
                  child: ElevatedButton(
                    child: Text("Авторизация"),
                    onPressed: () => {
                      _loginController.clear(),
                      _passwordController.clear(),
                      _isValid = false,
                      _key.currentState!.validate(),
                      Navigator.pushNamed(context, 'auth'),
                    },
                  ))
            ],
          ),
        ),
      )),
    );
  }

  Future addUserDetails(String id) async {
    await FirebaseFirestore.instance.collection('users').doc(id).set({
      'first_name': _lastNameController.text.trim(),
      'last_name': _lastNameController.text.trim(),
      'middle_name': _middleNameController.text.trim(),
      'email': _loginController.text.trim(),
      'profile_image': imageData
    });
  }

  register() async {
    try {
      UserCredential user = await _auth.createUserWithEmailAndPassword(
          email: _loginController.text, password: _passwordController.text);

      addUserDetails(FirebaseAuth.instance.currentUser!.uid);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Успешная регистрация"),
        ),
      );
      Navigator.pushNamed(context, 'auth');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Пароль слишком слабый"),
          ),
        );
      }
    } catch (e) {
      print(e);
    }
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
    } else {
    }
  }
}
