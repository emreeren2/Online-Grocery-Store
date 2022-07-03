import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project_v1/models/CategoryObject.dart';
import 'package:project_v1/screens/my_orders.dart';
import 'package:project_v1/screens/products.dart';
import 'package:project_v1/screens/sign_in.dart';
import 'package:project_v1/screens/sign_in_inapp.dart';
import 'package:project_v1/services/authentication_service.dart';
import 'package:project_v1/theme.dart';
import '../buttons.dart';
import 'package:project_v1/screens/products_information.dart';

class RefundCard extends StatefulWidget {
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

  RefundCard({required this.name, required this.image, required this.price, required this.productID, required this.productDescription, required this.productQuantity, required this.productWarranty, required this.productDistributor, this.document});

  @override
  _RefundCardState createState() => _RefundCardState();
}

class _RefundCardState extends State<RefundCard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference userCollection = Firestore.instance.collection('users');
  final CollectionReference cartsCollection = Firestore.instance.collection('Carts');
  final CollectionReference refundCollection = Firestore.instance.collection('refunds');
  final CollectionReference productCollection = Firestore.instance.collection('products');
  final CollectionReference myOrdersCollection = Firestore.instance.collection('myorders');


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
                Navigator.push(context, MaterialPageRoute(builder: (context) => ProductsInfo(name: widget.name, image: widget.image, price: widget.price, productID: widget.productID, productDescription: widget.productDescription, productQuantity: widget.productQuantity, productDistributor: widget.productDistributor, productWarranty: widget.productWarranty, document: widget.document,)));
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
            Container(
              width: 80,
              height: 40,
              //color: AppColors.box,
              child: ElevatedButton(
                onPressed: () async {  

                  

                  final FirebaseUser user = await FirebaseAuth.instance.currentUser();
                  final userID = user.uid;

                  var orderedItems = [];
                  var concreteOrderedItems = [];
                  //! GETTING BASKET FROM PRODUCT COLLECTION
                  var docSnapshotProducts = await userCollection.document(userID).get();
                  if (docSnapshotProducts.exists) {
                    Map<String, dynamic> data = docSnapshotProducts.data;
                    // You can then retrieve the value from the Map like this:
                    orderedItems = List.of(data['ordered_items'].cast<String>()); //! Burdaki sacma sey olmayinca basket listesi otamatikman fixedlength list oluyo bu yuzden eleman ekleyince exception throwluyo.
                  }
                  concreteOrderedItems = orderedItems;
                  orderedItems.remove(widget.productID);
                  await userCollection.document(userID).updateData({
                    'ordered_items': orderedItems,
                  });

                  //! start: putting all the items to "orders" collection for web team
                  var timestamp = DateTime.now();
                  var hour = timestamp.hour.toString();
                  var minute = timestamp.minute.toString();
                  var second = timestamp.second.toString();
                  var day = timestamp.day.toString();
                  var month = timestamp.month.toString();
                  var year = timestamp.year.toString();
                  //cartsCollection.document(userID).collection('Products').
                  var userSnapshot = await userCollection.document(userID).get();
                  Map<String, dynamic> user_data = userSnapshot.data; 
                  var address = user_data['delivery_address'];
                  var delivery_name = user_data['name'] + " " + user_data['surname'];
                  var delivery_id = userID + hour + ":" + minute + ":" + second;
                  var order_status = "pending_approval";
                  var placement_date = day + "-" + month + "-" + year;
                  var user_id = userID;
                  Map cart_products = {};

                  var docSnapshot = await productCollection.document(widget.productID).get();
                  
                  Map<String, dynamic> data = docSnapshot.data;   
                  print("ashdhjksf;gafgasndanksjdnajsbfj");
                  print(data['category']);
                  data['qty'] = 1;
                  data['ID'] = widget.productID;
                  data['TotalProductPrice'] = widget.price;
                  cart_products.addAll(data);
                  //cart_products.add(widget.document);
                  //for(int j = 0; j < concreteOrderedItems.length; j++){
                  //  var product_name;
                  //  var docSnapshotProducts = await cartsCollection.document(userID).collection('Products').document(concreteOrderedItems[j]).get();
                  //  if (docSnapshotProducts.exists) {
                  //    Map<String, dynamic> data = docSnapshotProducts.data;   
                  //    int q =  data['qty'];
                  //    int tp = data['TotalProductPrice'];
                  //    total_qty += q;
                  //    total_price += tp;                           
                  //    cart_products.add(data);
                  //  }
                  //} 
                  refundCollection.document(delivery_id).setData({
                    'Address': address,
                    'delivery_id': delivery_id,
                    'delivery_name': delivery_name,
                    'order_status': order_status,
                    'product': cart_products,
                    'used_id': user_id
                  });

                  Navigator.pop(context);
                  //for(int j = 0; j < basket_product_ids.length; j++){
                  //  cartsCollection.document(userID).collection('Products').document(basket_product_ids[j]).delete();
                  //} 
                  //! end

                },
                child: (widget.productQuantity > 0) ? Text("refund", style: TextStyle(fontSize: 16),) : Text("0"),
                style: ElevatedButton.styleFrom(
                  enableFeedback: true, // ne oldugunu bilmiyorum bunun.
                  elevation: (widget.productQuantity > 0) ? 22 : 5,
                  primary: (widget.productQuantity > 0) ? AppColors.logo_color: AppColors.red,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
              ),
            ),

          ],
        ),
      );
  }
}
