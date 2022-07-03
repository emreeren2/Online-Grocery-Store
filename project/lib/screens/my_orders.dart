import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:project_v1/cards/product_card.dart';
import 'package:project_v1/cards/refund_card.dart';

import '../loading.dart';
import '../theme.dart';

class MyOrders extends StatefulWidget {
  final List orderedItems;
  const MyOrders({ Key? key, required this.orderedItems }) : super(key: key);

  @override
  State<MyOrders> createState() => _MyOrdersState();
}

class _MyOrdersState extends State<MyOrders> {
  final CollectionReference userCollection = Firestore.instance.collection('users');
  final CollectionReference productCollection = Firestore.instance.collection('products');
  List ordered_items = [];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text("My Orders"),
        centerTitle: true,
        backgroundColor: AppColors.logo_color,
        elevation: 0.0,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height * 80 / 100,
        //color: AppColors.green,
        child: StreamBuilder(
          //stream: productCollection.where('category', isEqualTo: categoryNames[findCurrentIndex()]).snapshots(),
          stream: ((){
            return productCollection.where('product_id', whereIn: widget.orderedItems).snapshots();

          }()),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if(!snapshot.hasData){
              return Center(child: Text("You don't have any approved orders."));
            }
            else{
              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 20, crossAxisSpacing: 4 ,childAspectRatio: 0.70),
                itemCount: snapshot.data!.documents.length,
                itemBuilder: (context, index){
                  final doc = snapshot.data!.documents[index];
                  //return Loading();
                  // return Text(doc['product_name']),
                  //return Text('asd');
                  // ! databasede distibutor diye yanlis yazmisim onu duzeltince burayi da guncellemek lazim distributor olarak
                  return RefundCard(name: doc['product_name'], image: doc['product_photos'][0], price: doc['price'], productID: doc['product_id'], productDescription: doc['product_description'], productQuantity: doc['quantity'], productDistributor: doc['distributor'], productWarranty: doc['warranty'], document: doc);           
                }, 
              );
            }
          }
        
        ),
      ),
    );
  }
}