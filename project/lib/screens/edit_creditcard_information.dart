import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project_v1/screens/profile.dart';
import '../loading.dart';
import '../services/authentication_service.dart';
import '../theme.dart';
import '../buttons.dart';

class EdtiCreditCard extends StatefulWidget {
  const EdtiCreditCard({ Key? key }) : super(key: key);

  @override
  State<EdtiCreditCard> createState() => _EdtiCreditCardState();
}

class _EdtiCreditCardState extends State<EdtiCreditCard> {
  
  final CollectionReference userCollection = Firestore.instance.collection('users');
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  String cardNumber = '';
  String CCV = '';

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
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('Return Back to Profile'),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
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
        title: Text('Credit Card'),
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
                TextFormField(
                  validator: (val) => val!.isEmpty ? 'Please enter your card number.' : null,
                  decoration: InputDecoration(
                    hintText: 'Card Number'
                  ),
                  onChanged: (val) {
                    setState(() {
                      cardNumber = val;
                    });
                  }, // val => paremeter of given function
                ),
            
                SizedBox(height: 20),
            
                TextFormField(
                  validator: (val) => val!.isEmpty ? 'Please enter CCV of your credit card.' : null,
                  decoration: InputDecoration(
                    hintText: 'CCV'
                  ),
                  onChanged: (val) {
                    setState(() {
                      CCV = val;
                    });
                  }, // val => paremeter of given function
                ),
                SizedBox(height: 20),
                                
                
                ElevatedButton(
                  style: Buttons.elevated_button_mini,
                  onPressed: () async {
                    if(_formKey.currentState!.validate()) {
                      print(cardNumber);
                      print(CCV);
                      showAlertDialog("Congratulations!", "Your card information was added to our system successfully");
                    }
                    final FirebaseUser user = await _auth.currentUser();
                    final userID = user.uid;
                    await userCollection.document(userID).updateData({
                      'credit_card_number': cardNumber,
                      'CCV': CCV
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