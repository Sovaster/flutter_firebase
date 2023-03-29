import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser!;
  late final userData;
  late final imageUrl;

  Future<String> loadImage() async {
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    var filePath = documentSnapshot['profile_image']['storage_path'];

    Reference ref = FirebaseStorage.instance.ref().child(filePath);

    var url = await ref.getDownloadURL();
    print('url: ' + url);
    return url;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: SingleChildScrollView(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FutureBuilder<String>(
            future: loadImage(),
            builder: (BuildContext context, AsyncSnapshot<String> image) {
              if (image.hasData) {
                return Container(
                    width: 200,
                    child: Image.network(
                      image.data.toString(),
                      fit: BoxFit.scaleDown,
                    ));
              } else {
                return new Container(); // placeholder
              }
            },
          ),
          Text("Добро пожаловать"),
          ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, 'profile');
              },
              child: Text("Профиль")),
          SizedBox(
            height: 15,
          ),
          ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, 'notes');
              },
              child: Text("Мои заметки"))
        ],
      )),
    ));
  }
}
