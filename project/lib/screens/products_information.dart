
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project_v1/cards/product_card.dart';
import 'package:project_v1/main.dart';
import 'package:project_v1/screens/comments.dart';
import 'package:project_v1/services/authentication_service.dart';
import 'package:project_v1/theme.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../loading.dart';
import 'sign_in_inApp.dart';

class ProductsInfo extends StatefulWidget {
  final String productID;
  final String name;
  final String image;
  final int price;
  final String productDescription;
  final int productQuantity;
  final String productWarranty;
  final String productDistributor;
  final document;
  
  ProductsInfo({ Key? key, required this.name, required this.image, required this.price, required this.productID, required this.productDescription, required this.productQuantity,required this.productWarranty,required this.productDistributor, this.document}) : super(key: key);

  @override
  _ProductsInfoState createState() => _ProductsInfoState();
}

class _ProductsInfoState extends State<ProductsInfo> {

  final CollectionReference productCollection = Firestore.instance.collection('products');
  final CollectionReference userCollection = Firestore.instance.collection('users');
  final CollectionReference cartsCollection = Firestore.instance.collection('Carts');

  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isPressed = false;
  bool isFavorite = false;
  int counter = 0;

  Future<String> getUserID() async {
    final FirebaseUser user = await _auth.currentUser();
    final userID = user.uid;
    return userID;
  }

  Future<List> getWishList() async{
    String userID = await getUserID();
    var wishlist = [];
    //! GETTING BASKET FROM PRODUCT COLLECTION
    var docSnapshotProducts = await userCollection.document(userID).get();
    if (docSnapshotProducts.exists) {
      Map<String, dynamic> data = docSnapshotProducts.data;
      // You can then retrieve the value from the Map like this:
      wishlist = List.of(data['wishlist'].cast<String>()); //! Burdaki sacma sey olmayinca basket listesi otamatikman fixedlength list oluyo bu yuzden eleman ekleyince exception throwluyo.
    }
    if (wishlist.contains(widget.productID)){
      setState(() {
              isFavorite = true;
            });
    }
    return wishlist;
  }

  Future<double> calculateProductRating() async {
    double rating = 0.0;
    var docSnapshotProducts = await productCollection.document(widget.productID).get();
    Map<String, dynamic> data = docSnapshotProducts.data;

    int total_points = data['total_points'];
    int total_votings = data['total_votings'];
    rating = total_points / total_votings;
    return rating;
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
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: () {
                Navigator.of(context).pop();
                pushPageTo(SignIn_InApp());
              },
            ),
          ],
        );
      }
  );
}

  Future<void> showAlertDialog_2(String title, String message) async {
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
                child: Text('Okay'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        }
    );
  }

  void initState() {
    super.initState();
    // NOTE: Calling this function here would crash the app.
    getUserID();
    getWishList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        actions: <Widget>[
          IconButton(
            color: isFavorite ? AppColors.red
              : AppColors.background,
            icon: Icon(Icons.favorite), 
            onPressed: () async{
              String userID = await getUserID();
              var userName = "";
              var docSnapshotUsers = await userCollection.document(userID).get();
              if (docSnapshotUsers.exists) {
                Map<String, dynamic> data = docSnapshotUsers.data;
                // You can then retrieve the value from the Map like this:
                userName = data['name'];
              }
              if(userName.isEmpty){
                showAlertDialog("Item cannot be added", "You have not been registered. Do you want to register or login?");
              }
              else{
                List wishlist = await getWishList();
                if(isFavorite){
                  wishlist.remove(widget.productID);
                  setState(() {
                    isFavorite = false;
                  });
                }
                else{
                  wishlist.add(widget.productID);
                  setState(() {
                    isFavorite = true;
                  });
                }
                await userCollection.document(userID).updateData({
                  'wishlist': wishlist,
                });
              }
            }
          ),
        ],
      ),
      body: 
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                
                  child: Image(image: NetworkImage(widget.image)),
                ),
              ),
              SizedBox(height: 10.0),
              Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      //Text(widget.name, style: TextStyle(color: AppColors.full_black),),
                      Text(widget.price.toString() + " TL", style: TextStyle(color: AppColors.full_black, fontSize: 20.0),),
                    ],
              ),
              Divider(thickness: 1.2, color: Colors.black,),
              Expanded(
                flex: 2,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  //color: Colors.amber,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () async {setState(() {
                            isPressed = !isPressed;
                          });},
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Product Information",style: TextStyle(color: AppColors.full_black),),
                              (isPressed) ? Icon(Icons.arrow_upward_rounded, color: AppColors.full_black, size: 18,) : Icon(Icons.arrow_downward_rounded, color: AppColors.full_black, size: 18,),
                              
                            ],
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          enableFeedback: true, // ne oldugunu bilmiyorum bunun.
                          elevation: 3,
                          primary: AppColors.full_white,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(0)),
                          ),
                        ),
                      ),
                      Container(
                        child: (isPressed) ?
                          Padding(
                            padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                (widget.productQuantity > 0) ? Text(widget.productQuantity.toString() + " item(s) left.") : Text("Out of Stock"),
                                //SizedBox(height: 10,),
                                Text("Product Distributor: " + widget.productDistributor),
                                //SizedBox(height: 10,),
                                Text("Warranty: " + widget.productWarranty),
                                //SizedBox(height: 10,),
                                Text("Product Information: " + widget.productDescription),
                          
                              ],
                            ),
                          )
                          : Text('')
                      ),

                      SizedBox(height: MediaQuery.of(context).size.height/5,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          FloatingActionButton( // comment button
                            backgroundColor: AppColors.primary,
                            elevation: 20,
                            child: Icon(Icons.comment),
                            onPressed: () async {
                            List<String> comments = [];
                            var docSnapshotProducts = await productCollection.document(widget.productID).get();
                            if (docSnapshotProducts.exists) {
                              Map<String, dynamic> data = docSnapshotProducts.data;
                              // You can then retrieve the value from the Map like this:
                              comments = List.of(data['user_comments'].cast<String>()); //! Burdaki sacma sey olmayinca basket listesi otamatikman fixedlength list oluyo bu yuzden eleman ekleyince exception throwluyo.
                              print("QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQ");
                              print(comments);
                            }
                              pushPageTo(Comments(productID: widget.productID,));
                            }
                            ),
                          FutureBuilder(
                            future: calculateProductRating(),
                            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot){
                              return RatingBar.builder(

                              initialRating: snapshot.data,
                              minRating: 1,
                              direction: Axis.horizontal,
                              allowHalfRating: false,
                              itemCount: 5,
                              itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
                              itemBuilder: (context, _) => Icon(
                                Icons.star,
                                color: Colors.amberAccent,
                              ),
                              onRatingUpdate: (rating) async {
                                String userID = await getUserID();
                                var userName = "";
                                var docSnapshotUsers = await userCollection.document(userID).get();
                                if (docSnapshotUsers.exists) {
                                  Map<String, dynamic> data = docSnapshotUsers.data;
                                  // You can then retrieve the value from the Map like this:
                                  userName = data['name'];
                                }
                                
                                if(userName.isEmpty){
                                  showAlertDialog("Item cannot be evaluated", "You have not been registered. Do you want to register or login?");
                                }
                                else{
                                  var docSnapshotProducts = await productCollection.document(widget.productID).get();
                                  Map<String, dynamic> data = docSnapshotProducts.data;
                                  int total_points = data['total_points']; //! TOTAL_POINTS COLLECTIONDA INT OLDUGU ICIN BURDA DA INT OLARAK ALDIK
                                  int total_votings = data['total_votings'];
                                  
                                  int new_total_points = total_points + rating.toInt(); //! INT YERINE DOUBLE OLSA DAHA IYI O0LUR AMA PRODUCT COLLECTIONINDA TOTALPOINTS INT
                                  int new_total_votings = total_votings + 1;

                                  await productCollection.document(widget.productID).updateData({
                                    'total_points': new_total_points,
                                    'total_votings': new_total_votings
                                  });
                                  print(new_total_points);
                                  print(new_total_votings);
                                  }
                                  if(userName.isNotEmpty){
                                    showAlertDialog_2("Congratulations!", "Your evaluation has been received successfully");
                                  }
                              },
                            );
                            }
                          ),  
                          FloatingActionButton(
                            backgroundColor: (widget.productQuantity > 0) ? AppColors.primary : AppColors.red,
                            //child: (widget.productQuantity > 0) ? Text("+", style: TextStyle(fontSize: 30),) : Text("0"),
                            child: 
                            (() {
                              if((widget.productQuantity > 0)){
                                if(counter > 0){
                                  return Text(counter.toString(), style: TextStyle(fontSize: 30),);
                                  
                                }
                                else{
                                  return Text("+", style: TextStyle(fontSize: 30),);
                                }
                              }
                              else{
                                return Text("0");
                              }
                            }()),
                            elevation: (widget.productQuantity > 0) ? 20 : 5,
                            onPressed: () async{
                              if(widget.productQuantity > 0){
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

                                //! GETTING BASKET FROM PRODUCT COLLECTION
                                var docSnapshotProducts = await userCollection.document(userID).get();
                                if (docSnapshotProducts.exists) {
                                  Map<String, dynamic> data = docSnapshotProducts.data;
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
                          ),                       
                        ],
                      )
                    ],
                  )
                ),
              ), 
            ],
          ),
        ),
    );
  }

}