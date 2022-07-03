import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project_v1/screens/profile.dart';
import '../loading.dart';
import '../services/authentication_service.dart';
import '../theme.dart';
import '../buttons.dart';

class EdtiAddress extends StatefulWidget {
  const EdtiAddress({ Key? key }) : super(key: key);

  @override
  State<EdtiAddress> createState() => _EdtiAddressState();
}

class _EdtiAddressState extends State<EdtiAddress> {
  
  final CollectionReference userCollection = Firestore.instance.collection('users');
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  String city = '';
  String town = '';
  String neighbourhood = '';
  String street = '';
  String building = '';
  String door_number = '';

  void changePageTo(Widget page){
    
    Navigator.pushReplacement(
      context, 
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => page,
        transitionDuration: Duration(seconds: 0),
      ),
    ); 
  }

    void pushPageTo(Widget page){
    
    Navigator.push(
      context, 
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => page,
        transitionDuration: Duration(seconds: 0),
      ),
    ); 
  }

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
                child: Text('Close Alert'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              TextButton(
                child: Text('Return Back to Profile'),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                  //changePageTo(Profile());
                },
              ),
            ],
          );
        }
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      //resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Address'),
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
                SizedBox(height: 10),

                //* City
                TextFormField(
                  validator: (val) => val!.isEmpty ? 'Please enter city' : null,
                  decoration: InputDecoration(
                    hintText: 'City'
                  ),
                  onChanged: (val) {
                    setState(() {
                      city = val;
                    });
                  }, // val => paremeter of given function
                ),
            
                SizedBox(height: 20),
            
                //* Town
                TextFormField(
                  validator: (val) => val!.isEmpty ? 'Please enter town' : null,
                  decoration: InputDecoration(
                    hintText: 'Town'
                  ),
                  onChanged: (val) {
                    setState(() {
                      town = val;
                    });
                  }, // val => paremeter of given function
                ),
                SizedBox(height: 20),

                //* Neighbourhood
                TextFormField(
                  validator: (val) => val!.isEmpty ? 'Please enter neighbourhood' : null,
                  decoration: InputDecoration(
                    hintText: 'Neighbourhood'
                  ),
                  onChanged: (val) {
                    setState(() {
                      neighbourhood = val;
                    });
                  }, // val => paremeter of given function
                ),
                SizedBox(height: 20),

                //* Street
                TextFormField(
                  validator: (val) => val!.isEmpty ? 'Please enter street' : null,
                  decoration: InputDecoration(
                    hintText: 'Street'
                  ),
                  onChanged: (val) {
                    setState(() {
                      street = val;
                    });
                  }, // val => paremeter of given function
                ),
                SizedBox(height: 20),

                //* Building
                TextFormField(
                  validator: (val) => val!.isEmpty ? 'Please enter building' : null,
                  decoration: InputDecoration(
                    hintText: 'Building'
                  ),
                  onChanged: (val) {
                    setState(() {
                      building = val;
                    });
                  }, // val => paremeter of given function
                ),
                SizedBox(height: 20),

                //* Door Number
                TextFormField(
                  validator: (val) => val!.isEmpty ? 'Please enter your door number' : null,
                  decoration: InputDecoration(
                    hintText: 'Door Number'
                  ),
                  onChanged: (val) {
                    setState(() {
                      door_number = val;
                    });
                  }, // val => paremeter of given function
                ),
                SizedBox(height: 20),
                                
                
                ElevatedButton(
                  style: Buttons.elevated_button_mini,
                  onPressed: () async {
                    if(_formKey.currentState!.validate()) {
                      print(city);
                      print(town);
                      print(neighbourhood);
                      print(street);
                      print(building);
                      print(door_number);
                      showAlertDialog("Congratulations!", "Your address information was added to our system successfully");
                    }
                    final FirebaseUser user = await _auth.currentUser();
                    final userID = user.uid;
                    String final_address = city + "/" + town + "/" + neighbourhood + "/" + street + "/" + building + "/no:" + door_number;
                    await userCollection.document(userID).updateData({
                      'delivery_address': final_address
                    });

                    
                    //print(context.owner);
                  }, 
                  child: Text(
                    'Confirm',
                    style: TextStyle(
                      color: AppColors.low_white,
                      fontSize: 18,
                    ),
                  
                  ),
                ),

                SizedBox(height: 10,),
              ],
            ),
          ),
        ),
      ),
    );
  }
}