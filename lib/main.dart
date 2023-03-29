import 'package:flutter_firebase/create_note.dart';
import 'package:flutter_firebase/edit_note.dart';
import 'package:flutter_firebase/home.dart';
import 'package:flutter_firebase/index.dart';
import 'package:flutter_firebase/registration.dart';
import 'package:flutter_firebase/user_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'auth.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'firebaseApp',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: 'index',
      routes: {
        'index': (context) => IndexPage(),
        'auth': (context) => AuthPage(),
        'register': (context) => RegisterPage(),
        'home': (context) => HomePage(),
        'profile': (context) => UserProfile(),
        'notes': (context) => CreateNotePage(),
        'editNote': (context) => EditNotePage()
      },
    );
  }
}
