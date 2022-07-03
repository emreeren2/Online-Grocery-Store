import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:project_v1/models/ProductObject.dart';
import 'package:project_v1/screens/edit_address_information.dart';
import 'package:project_v1/screens/edit_creditcard_information.dart';
import 'package:project_v1/screens/favorites.dart';
import 'package:project_v1/screens/search.dart';
import 'package:project_v1/screens/shopping_cart.dart';
import 'package:project_v1/screens/sign_in_inApp.dart';
import 'package:project_v1/services/authentication_service.dart';
import 'package:project_v1/theme.dart';
import '../buttons.dart';
import '../loading.dart';
import '../wrapper.dart';
import 'home.dart';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';

import 'my_orders.dart';
import 'notifications.dart';

class Profile extends StatefulWidget {
  const Profile({ Key? key }) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {

  bool is_signed_out = false;
  String userName = "";
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference productCollection = Firestore.instance.collection('products');
  final CollectionReference userCollection = Firestore.instance.collection('users');

  Future<String> getUserID() async {
    final FirebaseUser user = await _auth.currentUser();
    final userID = user.uid;
    return userID;
  }

  Future<String> getUserName() async{
    String name = "";
    final FirebaseUser user = await _auth.currentUser();
    final userID = user.uid;
    var docSnapshotUsers = await userCollection.document(userID).get();
    if (docSnapshotUsers.exists) {
      Map<String, dynamic> data = docSnapshotUsers.data;
      // You can then retrieve the value from the Map like this:
      name = data['name'];
    }
    return name;
  }

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

  int _selectedIndex = 4;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if(index == 0){
        changePageTo(Home());
      }
      else if(index == 1){
        changePageTo(Search()); 
      }
      else if(index == 2){
        changePageTo(ShoppingCart());
      }
      else if(index == 3){
        changePageTo(Favorites());
      }
      else if(index == 4){
        print("XXXXXXXXXXX");
        print("IN PROFILE PAGE");
        print("XXXXXXXXXXX");
      }
    });
  }

  @override
  void initState () {
    super.initState();
    getUserName().then((value){
      setState(() {
        userName = value;
      });
    });
  }
  @override
  Widget build(BuildContext context) {

    final AuthService _auth = AuthService();

    return (is_signed_out) ? Wrapper() : Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text("Profile"),
        centerTitle: true,
        backgroundColor: AppColors.logo_color,
        elevation: 0.0,
        actions: <Widget>[
          /*
          FlatButton.icon(
            icon: Icon(Icons.logout),
            label: Text('logout'),
            onPressed: () async {
              setState(() {
                is_signed_out = true;
              });
              await _auth.signOut();
            },
          ),
          */
        ],
      ),
      body: Container(
        child: FutureBuilder(
          future: getUserName(),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot){
            if(!snapshot.hasData){
              return Center(child: Loading()); 
            }
            if (ConnectionState.done != null && snapshot.hasError) {
              return Center(child: Text(snapshot.error.toString()));
              //return Center(child: Loading());
            }
            if(snapshot.data.isEmpty){
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width/1.2,
                      child: ElevatedButton(
                        onPressed: () async { 
                          Navigator.push(
                            context, 
                            PageRouteBuilder(
                              pageBuilder: (context, animation1, animation2) => SignIn_InApp(),
                              transitionDuration: Duration(seconds: 0),
                            ),
                          ); 
                        },
                        child: Center(child: Text("Login or Register")),
                        style: ElevatedButton.styleFrom(
                          enableFeedback: true, // ne oldugunu bilmiyorum bunun.
                          elevation: 12,
                          primary: AppColors.logo_color,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20,),
                    Material(
                      elevation: 12,
                      color: AppColors.red,
                      borderRadius: BorderRadius.all(Radius.circular(30)),
                      child: Container(
                        height: 50,
                        width: MediaQuery.of(context).size.width/2,
                        child:  FlatButton.icon(
                            icon: Icon(Icons.logout, color: AppColors.full_white,),
                            label: Text('logout', style: TextStyle(color: AppColors.full_white),),
                            onPressed: () async {
                              setState(() {
                                is_signed_out = true;
                              });
                              await _auth.signOut();
                            },
                          ),
                      ),
                    ),

                  ],
                ),
              );
            }
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text( "Hi " + snapshot.data.toString() + "!"),
                  SizedBox(height: MediaQuery.of(context).size.height/10,),
                  Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width/1.2,
                    child: ElevatedButton(
                      onPressed: () async { 
                        pushPageTo(Notifications());
                      },
                      child: Center(child: Text("Discounts")),
                      style: ElevatedButton.styleFrom(
                        enableFeedback: true, // ne oldugunu bilmiyorum bunun.
                        elevation: 12,
                        primary: AppColors.logo_color,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20,),
                  Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width/1.2,
                    child: ElevatedButton(
                      onPressed: () async {

                        final FirebaseUser user = await FirebaseAuth.instance.currentUser();
                        final userID = user.uid;

                        var docSnapshotUsers = await userCollection.document(userID).get();
                        var myOrders = [];
                        if (docSnapshotUsers.exists) {
                          Map<String, dynamic> data = docSnapshotUsers.data;
                          // You can then retrieve the value from the Map like this:
                          myOrders = List.of(data['ordered_items'].cast<String>()); //! Burdaki sacma sey olmayinca basket listesi otamatikman fixedlength list oluyo bu yuzden eleman ekleyince exception throwluyo.
                          print("QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQ");
                          print(myOrders);
                        };

                        print(userID);


                        pushPageTo(MyOrders(orderedItems: myOrders,));
                      },
                      child: Center(child: Text("My Orders")),
                      style: ElevatedButton.styleFrom(
                        enableFeedback: true, // ne oldugunu bilmiyorum bunun.
                        elevation: 12,
                        primary: AppColors.logo_color,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20,),
                  Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width/1.2,
                    child: ElevatedButton(
                      onPressed: () async { 
                        pushPageTo(EdtiCreditCard());
                      },
                      child: Center(child: Text("Edit Card Information")),
                      style: ElevatedButton.styleFrom(
                        enableFeedback: true, // ne oldugunu bilmiyorum bunun.
                        elevation: 12,
                        primary: AppColors.logo_color,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20,),
                  Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width/1.2,
                    child: ElevatedButton(
                      onPressed: () async { 
                        pushPageTo(EdtiAddress());
                      },
                      child: Center(child: Text("Edit Address Information")),
                      style: ElevatedButton.styleFrom(
                        enableFeedback: true, // ne oldugunu bilmiyorum bunun.
                        elevation: 12,
                        primary: AppColors.logo_color,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20,),
                  Material(
                    elevation: 12,
                    color: AppColors.red,
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                    child: Container(
                      height: 50,
                      width: MediaQuery.of(context).size.width/2,
                      child:  FlatButton.icon(
                          icon: Icon(Icons.logout, color: AppColors.full_white,),
                          label: Text('logout', style: TextStyle(color: AppColors.full_white),),
                          onPressed: () async {
                            setState(() {
                              is_signed_out = true;
                            });
                            await _auth.signOut();
                          },
                        ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Seach',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Basket',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.logo_color,
        unselectedItemColor: AppColors.dark_box,
        showSelectedLabels: true,
        //enableFeedback: true,
        elevation: 8,
        iconSize: 24,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
      ),
    );
  }
}