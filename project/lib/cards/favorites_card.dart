import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project_v1/models/CategoryObject.dart';
import 'package:project_v1/screens/products.dart';
import 'package:project_v1/screens/shopping_cart.dart';
import 'package:project_v1/theme.dart';
import '../buttons.dart';
import 'package:project_v1/globals.dart' as globals;

class FavoritesCard extends StatefulWidget {

  final String productID;

  const FavoritesCard({required this.productID});

  @override
  State<FavoritesCard> createState() => _FavoritesCardState();
}

class _FavoritesCardState extends State<FavoritesCard> {
  final CollectionReference productCollection = Firestore.instance.collection('products');
  final CollectionReference userCollection = Firestore.instance.collection('users');
  final FirebaseAuth _auth = FirebaseAuth.instance;

  var productName;
  var productPrice;
  var productImage;

  Future<List> getProductImages() async{
    var productImages = [];
    var docSnapshotUsers = await productCollection.document(widget.productID).get();
    Map<String, dynamic> data = docSnapshotUsers.data;
    String mainImage = data['product_photos'][0];
    productImages.add(mainImage);
    return productImages;
  }

  Future<List> getProductPrices() async{
    var productPrices = [];
    var docSnapshotUsers = await productCollection.document(widget.productID).get();
    Map<String, dynamic> data = docSnapshotUsers.data;
    productPrices.add(data['price']);
    return productPrices;
  }

  Future<List> getProductNames() async{
    var productNames = [];
    var docSnapshotUsers = await productCollection.document(widget.productID).get();
    Map<String, dynamic> data = docSnapshotUsers.data;
    productNames.add(data['product_name']);
    return productNames;
  }

  @override
  void initState(){
    super.initState();
    // NOTE: Calling this function here would crash the app.
    productName =  getProductNames();
    productPrice =  getProductPrices();
    productImage =  getProductImages();
    
  }

  @override
  Widget build(BuildContext context){
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        elevation: 10,
        borderRadius: BorderRadius.circular(20),  
        color: AppColors.full_white,
        child: Container(

          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height / 5,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: MediaQuery.of(context).size.width / 5,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Image(
                        image: NetworkImage(productImage.toString())
                      ),
                      SizedBox(height: 5,),
                      Text(productName.toString()),
                      SizedBox(height: 5,),
                      Text(productPrice.toString() + " TL")
                    ],
                  ),
                ),
              ),
      
              Container(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(
                        children: <Widget>[
                          Container(
                            width: 38,
                            height: 38,
                            child: ElevatedButton(
                              onPressed: () async{print(productName);},
                              child: Center(child: Text("-")),
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
      
                          SizedBox(width: 8,),
                          SizedBox(width: 8,),
                          Container(
                            width: 38,
                            height: 38,
                            child: ElevatedButton(
                              onPressed: () async { },
                              child: Center(child: Text("+")),
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
                        ],
                      ),
                    ],
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
