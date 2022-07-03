import 'package:flutter/material.dart';
import '../loading.dart';
import '../services/authentication_service.dart';
import '../theme.dart';
import '../buttons.dart';

class Register extends StatefulWidget {
  const Register({ Key? key }) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  

  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  String email = '';
  String password = '';
  String password_2 = '';
  String name = '';
  String surname = '';
  String user_type = 'Buyer';
  var items =  ['Buyer', 'Seller'];
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
      //resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Register'),
        backgroundColor: AppColors.logo_color,
        centerTitle: true,
        elevation: 0.0,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: 20),
                TextFormField(
                  validator: (val) => val!.isEmpty ? 'Please enter your name.' : null,
                  decoration: InputDecoration(
                    hintText: 'Name'
                  ),
                  onChanged: (val) {
                    setState(() {
                      name = val;
                    });
                  }, // val => paremeter of given function
                ),
            
                SizedBox(height: 20),
            
                TextFormField(
                  validator: (val) => val!.isEmpty ? 'Please enter your surname.' : null,
                  decoration: InputDecoration(
                    hintText: 'Surname'
                  ),
                  onChanged: (val) {
                    setState(() {
                      surname = val;
                    });
                  }, // val => paremeter of given function
                ),
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
                  },
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Password'
                  ),
                  onChanged: (val) {
                    setState(() {
                      password = val;
                    });
                  },
                  
                ),
                SizedBox(height: 20),
                TextFormField(
                  validator: (val) {
                    if(val!.isEmpty){
                      return 'Please repeat your password.';
                    }
                    else if(password != password_2){ 
                      return 'Your passwords don\'t match';
                    }
                    else{
                      return null;
                    }
                  },
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Password Repeat',
                  ),
                  onChanged: (val) {
                    setState(() {
                      password_2 = val;
                    });
                  },
                ),
                
            
            
                SizedBox(height: 60),
                
                
                ElevatedButton(
                  style: Buttons.elevated_button_mini,
                  onPressed: () async {
                    // if(password != password_2){ // bunu validator olarak password repeatde yapiyoruz
                    //   showAlertDialog('Error', 'Passwords do not match.');
                    // } 
                    if(_formKey.currentState!.validate()) {
                      print(email);
                      print(password);
                      setState(() {
                        loading = true;
                      });
                      dynamic result = await _auth.registerWithEmailAndPassword(email, password, name, surname, user_type);
                      if(result == null) {
                        setState(() {
                          loading = false;
                          error = 'Please enter a valid email';
                        });
                        //showAlertDialog('Error', 'Please enter a valid email');
                      }
                      else {

                        Navigator.pop(context); // register yaptigimizda home page gecmesi icin bi onceki sayfaya gelmek gerekiyo cunku authentication olaylari orada ve wrapper da ayarlaniyo.
                      }
                    }
                    //print(context.owner);
                  }, 
                  
                  child: Text(
                    'Register',
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
      ),
    );
  }
}