import 'package:flutter/material.dart';
import 'package:project_v1/screens/register.dart';
import 'package:project_v1/services/authentication_service.dart';
import '../loading.dart';
import 'login.dart';
import '../theme.dart';
import '../buttons.dart';

class SignIn extends StatefulWidget {
  const SignIn({ Key? key }) : super(key: key);

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {

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
                    Text("Welcome to",
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
                  Navigator.push(context, MaterialPageRoute(builder: (context) => Register()),);
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
                  setState(() {loading = true;});
                  dynamic result = await _auth.signInAnon(); //* dynamic yazdik cunku sigInAnon farkli seyler return edebilir.
                  if(result == null) {
                    setState(() {loading = false;});
                    print("error signing in xxxx");
                  }
                  else {
                    print("signed in");
                    print(result.name);
                    // TODO burada anasayfaya gitmek lazim.
                  }
                }, 
                child: Text(
                  'Login Anonymously',
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
                  Navigator.push(context, MaterialPageRoute(builder: (context) => Login()),);
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