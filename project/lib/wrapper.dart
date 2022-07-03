import 'package:flutter/material.dart';
import 'package:project_v1/models/UserObject.dart';
import 'package:provider/provider.dart';
import 'authenticate.dart';
import 'screens/home.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final user = Provider.of<UserObject>(context);
    print("XXXXXXXXXXXXXXXX");
    print(user);
    print("XXXXXXXXXXXXXXXX");

    if(user == null){
      print("XXXXXX OUTSIDE THE APP XXXXXX");
      return Authenticate();
    }
    else{
      print("XXXXXX INSIDE THE APP XXXXXX");
      return Home();
    }
  }
}