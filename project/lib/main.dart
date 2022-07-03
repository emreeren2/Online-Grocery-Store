// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:project_v1/models/UserObject.dart';
import 'package:project_v1/services/authentication_service.dart';
import 'package:project_v1/wrapper.dart';
import 'package:provider/provider.dart';

void main() {
  //WidgetsFlutterBinding.ensureInitialized();
  //await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StreamProvider<UserObject>.value(
      value: AuthService().user,
      child: MaterialApp(
        home: Wrapper(),
      ),
    );
  }
}

