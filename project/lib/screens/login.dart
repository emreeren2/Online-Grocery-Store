import 'package:flutter/material.dart';
import 'package:project_v1/loading.dart';
import '../services/authentication_service.dart';
import '../theme.dart';
import '../buttons.dart';

class Login extends StatefulWidget {
  const Login({ Key? key }) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {

  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  String email = '';
  String password = '';
  String error = '';

  Future<void> showAlertDialog(String title, String message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, //User must tap button
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text(message),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return (loading) ? Loading() : Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Login'),
        backgroundColor: AppColors.logo_color,
        centerTitle: true,
        elevation: 0.0,
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 20),


              TextFormField(
                validator: (val) => val!.isEmpty ? 'Please enter your e-mail.' : null,
                decoration: InputDecoration(
                  hintText: 'E-mail'
                ),
                onChanged: (val) {
                  setState(() {
                    email = val;
                  });
                }, // val => paremeter of given function
              ),
              SizedBox(height: 20),

              
              TextFormField(
                validator: (val) {
                  if(val!.isEmpty){
                    return 'Please enter a password';
                  }
                  else if(val.length < 6){ // TODO the minimum length of the password can be increased
                    return 'Passwords have to be at least 6 characters';
                  }
                  else{
                    return null;
                  }
                },                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Password'
                ),
                onChanged: (val) {
                  setState(() {
                    password = val;
                  });
                },
              ),


              SizedBox(height: 60),
              
              
              ElevatedButton(
                style: Buttons.elevated_button_mini,
                onPressed: () async {
                  print(email);
                  print(password);
                  //print(context.owner);
                  if(_formKey.currentState!.validate()) {
                    setState(() {
                      loading = true;
                    });
                    dynamic result = await _auth.signInWithEmailAndPassword(email, password);
                    if(result == null) {
                      setState(() {
                        loading = false;
                        error = 'Couldn\'t sign in with these credentials';
                      });
                    }
                    else {
                      Navigator.pop(context); // register yaptigimizda home page gecmesi icin bi onceki sayfaya gelmek gerekiyo cunku authentication olaylari orada ve wrapper da ayarlaniyo.
                    }
                  }
                }, 
                child: Text(
                  'Login',
                  style: TextStyle(
                    color: AppColors.low_white,
                    fontSize: 18,
                  ),
                
                ),
              ),
              SizedBox(height: 10,),
              Text(
                error,
                style: TextStyle(color: AppColors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }
}