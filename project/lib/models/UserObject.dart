import 'package:cloud_firestore/cloud_firestore.dart';

/*
class UserObject{
  String userID;
  String email;
  String password;

  String name;
  String surname;
  String type;

  //List<dynamic> basket = [];
  //List<dynamic> watchlist = [];
  //List<dynamic> products = [];

  Set basket = {};
  Set watchlist = {};
  Set products  = {};

  final CollectionReference userCollection = Firestore.instance.collection('users');

  UserObject({ required this.userID, 
              required this.email, required this.password,
              required this.name, required this.surname, required this.type,
              required this.basket, required this.watchlist, required this.products 
            });


  factory UserObject.fromSnapshot(DocumentSnapshot snapshot){
    return UserObject(
      userID: snapshot.documentID,
      email: snapshot["email"],
      password: snapshot["password"],
      name: snapshot["name"],
      surname: snapshot["surname"],
      type: snapshot["type"],
      basket: snapshot["basket"],
      watchlist: snapshot["watchlist"],
      products: snapshot["products"]
    );
  }

  Future<void> addUser(String name, String surname, String email, String password) async {
    return await userCollection.document(userID).setData({
      'name': name,
      'surname': surname,
      'email': email,
      'password': password
      
    });
  }
}
*/

class UserObject {
  String userID;

  UserObject({required this.userID});

  final CollectionReference userCollection = Firestore.instance.collection('users');

    Future<void> addUser(String email, String password, String name, String surname) async {
    return await userCollection.document(userID).setData({
      'email': email,
      'password': password,
      'name': name,
      'surname': surname,
      'basket': [],
      'wishlist': [], // burayi wishlist yapicaz sonradan
      'products': [],
      'ordered_items': [],
      'delivery_address': '',
      'CCV': '',
      
    });
  }
}