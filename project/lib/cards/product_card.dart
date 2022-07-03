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

class ProductCard extends StatefulWidget {
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

  ProductCard({required this.name, required this.image, required this.price, required this.productID, required this.productDescription, required this.productQuantity, required this.productWarranty, required this.productDistributor, this.document});

  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
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
              width: 40,
              height: 40,
              //color: AppColors.box,
              child: ElevatedButton(
                onPressed: () async {  // TODO kullanicinin anonim olup olmadigini kontrol etmek lazim, eger anonimse signin sayfasina gondermek lazim.
                if(widget.productQuantity > 0){
                  // ! GETTING USERNAME FROM USER COLLECTION:
                    final FirebaseUser user = await _auth.currentUser();
                    final userID = user.uid;
                    String userName = "";
                    var docSnapshotUsers = await userCollection.document(userID).get();
                    if (docSnapshotUsers.exists) {
                      Map<String, dynamic> data = docSnapshotUsers.data;
                      // You can then retrieve the value from the Map like this:
                      userName = data['name'];
                    }

                    var basket = [];

                    //! GETTING BASKET FROM USER COLLECTION
                    // docSnapshotProducts degil docSnapshotUsers olucak
                    //var docSnapshotUsers = await userCollection.document(userID).get();
                    if (docSnapshotUsers.exists) {
                      Map<String, dynamic> data = docSnapshotUsers.data;
                      // You can then retrieve the value from the Map like this:
                      basket = List.of(data['basket'].cast<String>()); //! Burdaki sacma sey olmayinca basket listesi otamatikman fixedlength list oluyo bu yuzden eleman ekleyince exception throwluyo.
                      print("QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQ");
                      print(basket);
                    }

                    if(userName.isEmpty){
                      showAlertDialog("Item cannot be added", "You have not been registered. Do you want to register or login?");
                    }
                    else{
                      basket.add(widget.productID);
                      print("TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT");
                      print(basket);
                      await userCollection.document(userID).updateData({
                        'basket': basket,
                      });

                      //! adding product to the Carts collection for web team
                      var qty = 1;
                      var total_price = qty * widget.price;
                      var price = widget.price;
                      var docSnapshotCarts = await cartsCollection.document(userID).collection('Products').document(widget.productID).get();
                      if(docSnapshotCarts.exists){
                        Map<String, dynamic> product_data = docSnapshotCarts.data;
                        qty = product_data['qty'];
                        price = product_data['price'];
                        print("QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQ");
                        print(qty);
                        
                        if(qty != null){
                          qty = qty + 1;
                        }
                        else{
                          qty = 1;
                        }
                        total_price = qty * price;//widget.price;
                      }
                      else{
                        Map<String, dynamic> data = widget.document.data;
                        cartsCollection.document(userID).collection('Products').document(widget.productID).setData(data);
                      }
                      
                      //cartsCollection.document(userID).collection('Products').document(widget.productID).setData(data);

                      cartsCollection.document(userID).collection('Products').document(widget.productID).updateData({
                        'ID': widget.productID,
                        'qty': qty,
                        'TotalProductPrice': total_price
                      });
                      //! addition end
                    }
                  }
                  setState(() {
                    counter++;
                  });
                },
                child: (widget.productQuantity > 0) ? Text("+", style: TextStyle(fontSize: 20),) : Text("0"),
                //child: 
                //(() {
                //  if((widget.productQuantity > 0)){
                //    if(counter > 0){
                //      return Text(counter.toString(), style: TextStyle(fontSize: 20),);
                //      
                //    }
                //    else{
                //      return Text("+", style: TextStyle(fontSize: 20),);
                //    }
                //  }
                //  else{
                //    return Text("0");
                //  }
                //}()),
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
