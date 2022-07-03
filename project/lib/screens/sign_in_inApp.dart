//* KULLANICI ANONIM KULLANIRKEN BI SEKILDE UYE OLMAYA VEYA GIRIS YAPMAYA YONLENDIRILIRSE BU SAYFA ACILIYOR.
// sign_in.dart la farki, anonim giris yok

import 'package:flutter/material.dart';
import 'package:project_v1/screens/login.dart';
import 'package:project_v1/screens/register.dart';
import 'package:project_v1/services/authentication_service.dart';
import '../loading.dart';
import '../theme.dart';
import '../buttons.dart';
import 'home.dart';

class SignIn_InApp extends StatefulWidget {
  const SignIn_InApp({ Key? key }) : super(key: key);

  @override
  State<SignIn_InApp> createState() => _SignIn_InAppState();
}

class _SignIn_InAppState extends State<SignIn_InApp> {

  final AuthService _auth = AuthService();
  bool loading = false;


  @override
  Widget build(BuildContext context) {
    return (loading) ? Loading() : Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0.0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Hi'),
            Icon(Icons.hail)
          ],
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          margin: EdgeInsets.all(20),
          //color: AppColors.dark_box,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                //padding: EdgeInsets.all(40),
                //color: AppColors.full_black,
                child: Column(
                  children: [
                    Text("Welcome back to",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 42,
                        fontStyle: FontStyle.italic,
                        color: AppColors.primary
                      ),
                    ),
                    //SizedBox(height: 10,),
                    Text("Get Fresh",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.bold,
                        color: AppColors.logo_color,
                      ),
                    ),
                    Icon(
                      Icons.eco_sharp , // grass_outlined
                      size: 84,
                      color: Colors.green,
                    ), 
                  ],
                ),
              ),
              SizedBox(height: 72,),
              ElevatedButton(
                style: Buttons.elevated_button,
                onPressed: () async {
                  await Navigator.push(context, MaterialPageRoute(builder: (context) => Register()),);
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context, 
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) => Home(),
                      transitionDuration: Duration(seconds: 0),
                    ),
                  ); 
                }, 
                child: Text(
                  'Register',
                  style: TextStyle(
                    color: AppColors.low_white,
                    fontSize: 18,
                  ),
                
                ),
              ),
              SizedBox(height: 20,),

              ElevatedButton(
                style: Buttons.elevated_button,
                onPressed: () async {
                  await Navigator.push(context, MaterialPageRoute(builder: (context) => Login()),);
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context, 
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) => Home(),
                      transitionDuration: Duration(seconds: 0),
                    ),
                  ); 
                }, 
                child: Text(
                  'Login',
                  style: TextStyle(
                    color: AppColors.low_white,
                    fontSize: 18,
                  ),
                
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}