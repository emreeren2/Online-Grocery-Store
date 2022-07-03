import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project_v1/models/CategoryObject.dart';
import 'package:project_v1/screens/products.dart';
import 'package:project_v1/screens/shopping_cart.dart';
import 'package:project_v1/theme.dart';
import '../buttons.dart';
import 'package:project_v1/globals.dart' as globals;


class BasketCard extends StatefulWidget {

  final String productID;
  final String productImage;
  final String productName;
  final int productPrice;
  final int productAmount;

  const BasketCard({required this.productImage, required this.productPrice, required this.productAmount, required this.productID, required this.productName});

  @override
  State<BasketCard> createState() => _BasketCardState();
}

class _BasketCardState extends State<BasketCard> {

  final CollectionReference productCollection = Firestore.instance.collection('products');
  final CollectionReference userCollection = Firestore.instance.collection('users');
  final CollectionReference cartsCollection = Firestore.instance.collection('Carts');

  final FirebaseAuth _auth = FirebaseAuth.instance;
  late int dynamicProductAmount;
  late int dynamicTotalPrice;

  int getProductAmount(){
    return widget.productAmount;
  }

  Future<Map<String, dynamic>> getProductDocument(String docID) async{
    // ! GETTING USERNAME FROM USER COLLECTION:
    var docSnapshotProducts = await productCollection.document(docID).get();
    Map<String, dynamic> data = docSnapshotProducts.data;
    return data;
  }

  Future<String> getUserID() async {
    final FirebaseUser user = await _auth.currentUser();
    final userID = user.uid;
    return userID;
  }

  int getTotalPrice(){
    int totalPrice = 0;
    for(int i = 0; i < globals.totalItemPrices.length; i++){
      totalPrice += globals.totalItemPrices[i];
    }

    return totalPrice;
  }

  // this will executed when page is build. Yani sayfa yuklendiginde getPRoductAmount() fonkisyonunu cagiriyoruz
  @override
  void initState() {
    super.initState();
    // NOTE: Calling this function here would crash the app.
    dynamicProductAmount = getProductAmount();
    dynamicTotalPrice = getTotalPrice();
  }

  @override
  Widget build(BuildContext context) {
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
                        image: NetworkImage(widget.productImage)
                      ),
                      SizedBox(height: 5,),
                      Text(widget.productName),
                      SizedBox(height: 5,),
                      Text(widget.productPrice.toString() + " TL")
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
                              onPressed: () async{ 
                                //print(widget.productImage); 
                                String userID = await getUserID();
                                var basket = [];
                                //! GETTING BASKET FROM PRODUCT COLLECTION
                                var docSnapshotProducts = await userCollection.document(userID).get();
                                if (docSnapshotProducts.exists) {
                                  Map<String, dynamic> data = docSnapshotProducts.data;
                                  // You can then retrieve the value from the Map like this:
                                  basket = List.of(data['basket'].cast<String>()); //! Burdaki sacma sey olmayinca basket listesi otamatikman fixedlength list oluyo bu yuzden eleman ekleyince exception throwluyo.
                                }
                                basket.remove(widget.productID);
                                await userCollection.document(userID).updateData({
                                  'basket': basket,
                                });
                                //! deleting product in carts collection for web team;
                                
                                var document = await productCollection.document(widget.productID).get();
                                var qty = 1;
                                var total_price = qty * 0;
                                var price = 0;
                                var docSnapshotCarts = await cartsCollection.document(userID).collection('Products').document(widget.productID).get();
                                if(docSnapshotCarts.exists){
                                  Map<String, dynamic> product_data = docSnapshotCarts.data;
                                  qty = product_data['qty'];
                                  price = product_data['price'];
                                  print("QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQ");
                                  print(qty);
                                  
                                  if(qty > 0){
                                    qty = qty - 1;
                                    total_price = qty * price;//widget.price;

                                    if(qty == 0){
                                      cartsCollection.document(userID).collection('Products').document(widget.productID).delete();
                                    }
                                    else{
                                      cartsCollection.document(userID).collection('Products').document(widget.productID).updateData({
                                        'qty': qty,
                                        'TotalProductPrice': total_price
                                      });                               
                                    }
                                  }
                                }


                                setState(() {
                                  if(dynamicProductAmount > 0){
                                    dynamicProductAmount--;
                                  }
                                });
                                if(dynamicProductAmount == 0){
                                  //Navigator.pop(context);
                                  //Navigator.push(context,  MaterialPageRoute(builder: (context) => const ShoppingCart()),);
                                }
                              },
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
                        
                          Material( // containera elevation verebilmek icin
                            elevation: 20,
                            borderRadius: BorderRadius.circular(100),
                            child: Container(
                              width: 53,
                              height: 53,
                              child: Center(child: Text(dynamicProductAmount.toString())),
                            ),
                          ),
                          SizedBox(width: 8,),
                          
                          Container(
                            width: 38,
                            height: 38,
                            child: ElevatedButton(
                              onPressed: () async { 
                                //print(widget.productID);
                                String userID = await getUserID();
                                var basket = [];
                                //! GETTING BASKET FROM USER COLLECTION
                                var docSnapshotUsers = await userCollection.document(userID).get();
                                if (docSnapshotUsers.exists) {
                                  Map<String, dynamic> data = docSnapshotUsers.data;
                                  // You can then retrieve the value from the Map like this:
                                  basket = List.of(data['basket'].cast<String>()); //! Burdaki sacma sey olmayinca basket listesi otamatikman fixedlength list oluyo bu yuzden eleman ekleyince exception throwluyo.
                                }
                                basket.add(widget.productID);
                                await userCollection.document(userID).updateData({
                                  'basket': basket,
                                });
                                setState(() {
                                  dynamicProductAmount++;
                                });

                                //! adding product to the Carts collection for web team
                                var document = await productCollection.document(widget.productID).get();
                                var qty = 1;
                                var total_price = qty * 0;
                                var price = 0;
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
                                  Map<String, dynamic> data = document.data;
                                  cartsCollection.document(userID).collection('Products').document(widget.productID).setData(data);
                                }
                                
                                //cartsCollection.document(userID).collection('Products').document(widget.productID).setData(data);

                                cartsCollection.document(userID).collection('Products').document(widget.productID).updateData({
                                  'ID': widget.productID,
                                  'qty': qty,
                                  'TotalProductPrice': total_price
                                });
                                //! addition end

                                //Navigator.pop(context);
                                //Navigator.push(context,  MaterialPageRoute(builder: (context) => const ShoppingCart()),);
                              },
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
                      Material(
                        elevation: 12,
                        borderRadius: BorderRadius.circular(100),
                        child: Container(
                          width:70,
                          height: 20,
                          //color: AppColors.border,
                          child: Center(child: Text( /* widget.productID */ (widget.productPrice * dynamicProductAmount).toString() + " TL")   ),
                        ),
                      )
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