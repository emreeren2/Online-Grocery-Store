import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project_v1/models/CategoryObject.dart';
import 'package:project_v1/screens/products.dart';
import 'package:project_v1/screens/sign_in.dart';
import 'package:project_v1/screens/sign_in_inapp.dart';
import 'package:project_v1/services/authentication_service.dart';
import 'package:project_v1/theme.dart';
import '../buttons.dart';
import 'package:project_v1/screens/products_information.dart';

class ProductCardDiscount extends StatefulWidget {
  //const CategoryCard({ Key? key, required this.categoty}) : super(key: key);

  final String productID;
  final String name;
  final String image;
  final int price;
  final String productDescription;
  final int productQuantity;
  final String productWarranty;
  final String productDistributor;
  final document;

  ProductCardDiscount({required this.name, required this.image, required this.price, required this.productID, required this.productDescription, required this.productQuantity, required this.productWarranty, required this.productDistributor, this.document});

  @override
  _ProductCardDiscountState createState() => _ProductCardDiscountState();
}

class _ProductCardDiscountState extends State<ProductCardDiscount> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference userCollection = Firestore.instance.collection('users');
  final CollectionReference cartsCollection = Firestore.instance.collection('Carts');
  int counter = 0;

  void changePageTo(Widget page){
    
    Navigator.pushReplacement(
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
                child: Text('No'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('Yes'),
                onPressed: () {
                  changePageTo(SignIn_InApp());
                },
              ),
            ],
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
      return Container(
        //color: AppColors.green,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Container(
              width: 130,
              height: 130,
              //color: AppColors.red,
              child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                enableFeedback: true, // ne oldugunu bilmiyorum bunun.
                elevation: 18,
                primary: AppColors.full_white,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
              onPressed: () {
                //Navigator.push(context, MaterialPageRoute(builder: (context) => ProductsInfo(name: widget.name, image: widget.image, price: widget.price, productID: widget.productID, productDescription: widget.productDescription, productQuantity: widget.productQuantity, productDistributor: widget.productDistributor, productWarranty: widget.productWarranty, document: widget.document,)));
                print(widget.name); // TODO basildiginda products sayfasina gidilicek. Products sayfasinda geri donme tusu olucak ve basildiginda bu sayfaya geri donulecek. Product sayfasi basilan category kartinin ismini arguman olarak alicak ve firebase querysinde o ismi kullanicak. 
              },
              child: Container(
                height: 150,
                //color: AppColors.red,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Stack(
                      children: [
                      Image(image: NetworkImage(widget.image),),
                      //Text(counter.toString(), style: TextStyle(fontSize: 20, color: AppColors.full_black),)
                      ]
                    ),
                    Text(widget.name, style: TextStyle(color: AppColors.full_black),),
                    Text(widget.price.toString() + " TL", style: TextStyle(color: AppColors.full_black),),

                  ],
                ),
              ),
            ),
            ),
          ],
        ),
      );
  }
}
