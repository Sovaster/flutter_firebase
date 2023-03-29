import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  GlobalKey<FormState> _key = GlobalKey();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  TextEditingController _loginController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  bool isObscure = true;
  bool _isValid = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Padding(
        padding: EdgeInsets.all(30),
        child: Form(
          key: _key,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Авторизация",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24),
              ),
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
                  maxLength: 100,
                  decoration: const InputDecoration(
                    labelText: 'Логин',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
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
                  maxLength: 100,
                  decoration: const InputDecoration(
                    labelText: 'Пароль',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Padding(
                  padding: EdgeInsets.only(left: 350, right: 350, top: 50),
                  child: Container(
                    width: 50,
                    child: ElevatedButton(
                      child: Text("Войти"),
                      onPressed: () => {
                        _isValid = true,
                        if (_key.currentState!.validate()) {authorize()}
                      },
                    ),
                  )),
              Padding(
                  padding: EdgeInsets.only(left: 350, right: 350, top: 50),
                  child: Container(
                    width: 50,
                    child: ElevatedButton(
                      child: Text("Войти анонимно"),
                      onPressed: () => {authorizeAnonymus()},
                    ),
                  )),
              Padding(
                  padding: EdgeInsets.only(left: 350, right: 350, top: 50),
                  child: Container(
                    width: 50,
                    child: ElevatedButton(
                      child: Text("Войти по ссылке"),
                      onPressed: () => {sendLink()},
                    ),
                  )),
              Padding(
                  padding: EdgeInsets.only(left: 350, right: 350, top: 50),
                  child: ElevatedButton(
                    child: Text("Регистрация"),
                    onPressed: () => {
                      _loginController.clear(),
                      _passwordController.clear(),
                      _isValid = false,
                      _key.currentState!.validate(),
                      Navigator.pushNamed(context, 'register'),
                    },
                  ))
            ],
          ),
        ),
      )),
    );
  }

  authorize() async {
    final auth = FirebaseAuth.instance;
    try {
      UserCredential user = await auth.signInWithEmailAndPassword(
          email: _loginController.text, password: _passwordController.text);

      Navigator.pushNamed(context, 'home');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Пользователь не найден"),
          ),
        );
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Не правильный пароль"),
          ),
        );
      }
    }
  }

  authorizeAnonymus() async {
    final auth = FirebaseAuth.instance;
    try {
      final userCredential = await auth.signInAnonymously();

      Navigator.pushNamed(context, 'home');
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Не удалось авторизоваться"),
        ),
      );
    }
  }

  sendLink() {
    var acs = ActionCodeSettings(
      url: 'http://localhost:4000/#home',
      handleCodeInApp: true,
    );

    FirebaseAuth.instance
        .sendSignInLinkToEmail(email: _loginController.text, actionCodeSettings: acs)
        .catchError((onError) => {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Что-то пошло не так"),
                ),
              )
            })
        .then((value) => {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      "Ссылка отправлена на почту ${_loginController.text}"),
                ),
              )
            });
  }
}
