import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:project_v1/cards/product_card.dart';
import 'package:project_v1/cards/product_card_discount.dart';
import 'package:project_v1/theme.dart';

import '../loading.dart';

class Notifications extends StatefulWidget {
  const Notifications({ Key? key }) : super(key: key);

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  final CollectionReference productCollection = Firestore.instance.collection('products');
  final CollectionReference userCollection = Firestore.instance.collection('users');
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> getUserID() async {
    final FirebaseUser user = await _auth.currentUser();
    final userID = user.uid;
    return userID;
  }

  Future<List> getWishlist() async{
    List wishlist = [];
    String userID = await getUserID();

    var docSnapshotProducts = await userCollection.document(userID).get();
    if (docSnapshotProducts.exists) {
      Map<String, dynamic> data = docSnapshotProducts.data;
      // You can then retrieve the value from the Map like this:
      wishlist = List.of(data['wishlist'].cast<String>()); //! Burdaki sacma sey olmayinca basket listesi otamatikman fixedlength list oluyo bu yuzden eleman ekleyince exception throwluyo.
    }
    return wishlist;
  }

  Future<List> getAllProductsID() async{
    var productIDs = [];
    QuerySnapshot querySnapshot = await productCollection.getDocuments();
    var productsData = querySnapshot.documents.map((doc) => doc.data).toList();
    var productID_list = List<dynamic>.from(productsData);

    for(int i = 0; i < productID_list.length; i++){
      productIDs.add(productID_list[i]['product_id']);
    }
    return productIDs;
  }

  Future<List> getAllProductsDiscount() async{
    var productDiscounts = [];
    QuerySnapshot querySnapshot = await productCollection.getDocuments();
    var productsData = querySnapshot.documents.map((doc) => doc.data).toList();
    var productDiscount_list = List<dynamic>.from(productsData);

    for(int i = 0; i < productDiscount_list.length; i++){
      productDiscounts.add(productDiscount_list[i]['isdiscounted']);
    }
    return productDiscounts;
  }

  Future<List> getAllProductNames() async{
    var productNames = [];
    QuerySnapshot querySnapshot = await productCollection.getDocuments();
    var productsData = querySnapshot.documents.map((doc) => doc.data).toList();
    var productName_list = List<dynamic>.from(productsData);

    for(int i = 0; i < productName_list.length; i++){
      productNames.add(productName_list[i]['product_name']);
    }
    return productNames;
  }

  Future<List> getAllProducts() async{
    var products = [];
    QuerySnapshot querySnapshot = await productCollection.getDocuments();
    var productsData = querySnapshot.documents.map((doc) => doc.data).toList();
    var product_list = List<dynamic>.from(productsData);

    for(int i = 0; i < product_list.length; i++){
      products.add(product_list[i]);
    }
    return products;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text("Discounts"),
        centerTitle: true,
        backgroundColor: AppColors.primary,
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: FutureBuilder(
          future: Future.wait([getAllProductsID(), getAllProductsDiscount(), getWishlist(), getAllProductNames(), getAllProducts()]),//getBasket(),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {                   
            // WHILE THE CALL IS BEING MADE AKA LOADING
            if (!snapshot.hasData) {            
              return Center(child: Loading());
            }

            // WHEN THE CALL IS DONE BUT HAPPENS TO HAVE AN ERROR
            if (ConnectionState.done != null && snapshot.hasError) {
              return Center(child: Text(snapshot.error.toString()));
              //return Center(child: Loading());
            }

            if(snapshot.data[2].length == 0){
              return Center(child: Text("Your wishlist is empty"));
            }

            var productIDs = [snapshot.data[0]];
            var productDiscount = [snapshot.data[1]];
            var wishList = [snapshot.data[2]];
            var productNames = [snapshot.data[3]];
            var allProducts = [snapshot.data[4]];
            var discountedItems = [];

            productIDs.sort();
            wishList.sort();
            print("qqqqqqqqqqqqqqqqqqqqqqqqqqqqqq");
            print(productIDs);
            print(wishList);
            print(productDiscount);
            print(productNames);
            print("asdasdasd");
            print(allProducts[0].length);

            int itemCount = 0;
            for(int i = 0; i < wishList[0].length; i++){
              String current_product_id = wishList[0][i];
              int product_index = productIDs[0].indexOf(current_product_id);
              bool is_discounted = productDiscount[0][product_index];
              print("wwwwwwwwwwwwwwwwwwwwwwww");

              print("pid:" + current_product_id);
              print("index:" + product_index.toString());

              if(is_discounted){
                itemCount++;
                discountedItems.add(allProducts[0][product_index]);
              }
            }



            //return ListView.builder(
            //  itemCount: itemCount, // data[0] means snapshot that we got from getBasket function
            //  itemBuilder: (context, position){ 
                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 20, crossAxisSpacing: 4 ,childAspectRatio: 0.70),
                    itemCount: discountedItems.length,
                    itemBuilder: (context, position){
                      final doc = discountedItems[position];
                      return ProductCardDiscount(name: discountedItems[position]['product_name'], image: discountedItems[position]['product_photos'][0], price: discountedItems[position]['price'], productID: discountedItems[position]['product_id'], productDescription: discountedItems[position]['product_description'], productQuantity: discountedItems[position]['quantity'], productWarranty: discountedItems[position]['warranty'], productDistributor: discountedItems[position]['distributor'], document: doc,);
                    }, 
                  );
                //return ProductCard(name: discountedItemNames[position]['product_name'], image: discountedItemNames[position]['product_photos'][0], price: discountedItemNames[position]['price'], productID: discountedItemNames[position]['product_id'], productDescription: discountedItemNames[position]['product_description'], productQuantity: discountedItemNames[position]['quantity'], productWarranty: discountedItemNames[position]['warranty'], productDistributor: discountedItemNames[position]['distributor'], document: discountedItemNames[position],);
                //return Padding(
                //  padding: const EdgeInsets.all(8.0),
                //  child: Container(
                //    height: MediaQuery.of(context).size.height/7,
                //    width: MediaQuery.of(context).size.width - 10,
                //    child: Center(child: Text(discountedItemNames[position]['product_name'].toString())),
                //    decoration: BoxDecoration( 
                //      color: AppColors.box,
                //      border: Border.all(
                //        color: AppColors.logo_color,
                //        width: 2.0,
                //      ),
                //      borderRadius: BorderRadius.circular(20.0),
                //    )
                //  ),
                //);
            //  }
            //);
          },
        ),
      ),
    );
  }
}



/*
import 'package:flutter/material.dart';
import 'package:project_v1/screens/home.dart';
import 'package:project_v1/screens/profile.dart';
import 'package:project_v1/screens/search.dart';
import 'package:project_v1/screens/shopping_cart.dart';
import 'package:project_v1/services/authentication_service.dart';
import 'package:project_v1/theme.dart';
import '../buttons.dart';
import '../wrapper.dart';

class Favorites extends StatefulWidget {
  const Favorites({ Key? key }) : super(key: key);

  @override
  State<Favorites> createState() => _FavoritesState();
}

class _FavoritesState extends State<Favorites> {

  bool is_signed_out = false;

  void changePageTo(Widget page){
    
    Navigator.pushReplacement(
      context, 
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => page,
        transitionDuration: Duration(seconds: 0),
      ),
    ); 
  }

  int _selectedIndex = 3;
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
        print("XXXXXXXXXXX");
        print("IN FAVORITES PAGE");
        print("XXXXXXXXXXX");
      }
      else if(index == 4){
        changePageTo(Profile());
      }
    });
  }
  @override
  Widget build(BuildContext context) {

    final AuthService _auth = AuthService();

    return (is_signed_out) ? Wrapper() : Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text("Favorites"),
        centerTitle: true,
        backgroundColor: AppColors.logo_color,
        elevation: 0.0,
        actions: <Widget>[
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
        ],
      ),
      body: Center(child: Text("FAVORITES")),
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

*/

/*
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project_v1/cards/product_card.dart';
import 'package:project_v1/models/CategoryObject.dart';
import 'package:project_v1/screens/profile.dart';
import 'package:project_v1/screens/search.dart';
import 'package:project_v1/screens/shopping_cart.dart';
import 'package:project_v1/services/authentication_service.dart';
import 'package:project_v1/theme.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../loading.dart';


class Products extends StatefulWidget {

  //Products({ Key? key, required this.current_category });

  String current_category;
  Products({ Key? key, required this.current_category}) : super(key: key);

  @override
  State<Products> createState() => _ProductsState();
}

class _ProductsState extends State<Products> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ASD"),
      ),
    );
  }
}
*/

/*

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:project_v1/cards/product_card.dart';
import 'package:project_v1/cards/product_card_discount.dart';
import 'package:project_v1/theme.dart';

import '../loading.dart';
import '../wrapper.dart';
import 'home.dart';

class Favorites extends StatefulWidget {
  const Favorites({ Key? key }) : super(key: key);

  @override
  State<Favorites> createState() => _FavoritesState();
}

class _FavoritesState extends State<Favorites> {
  final CollectionReference productCollection = Firestore.instance.collection('products');
  final CollectionReference userCollection = Firestore.instance.collection('users');
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool is_signed_out = false;

  void changePageTo(Widget page){
    
    Navigator.pushReplacement(
      context, 
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => page,
        transitionDuration: Duration(seconds: 0),
      ),
    ); 
  }

  int _selectedIndex = 3;
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
        print("XXXXXXXXXXX");
        print("IN FAVORITES PAGE");
        print("XXXXXXXXXXX");
      }
      else if(index == 4){
        changePageTo(Profile());
      }
    });
  }

  Future<String> getUserID() async {
    final FirebaseUser user = await _auth.currentUser();
    final userID = user.uid;
    return userID;
  }

  Future<List> getWishlist() async{
    List wishlist = [];
    String userID = await getUserID();

    var docSnapshotProducts = await userCollection.document(userID).get();
    if (docSnapshotProducts.exists) {
      Map<String, dynamic> data = docSnapshotProducts.data;
      // You can then retrieve the value from the Map like this:
      wishlist = List.of(data['wishlist'].cast<String>()); //! Burdaki sacma sey olmayinca basket listesi otamatikman fixedlength list oluyo bu yuzden eleman ekleyince exception throwluyo.
    }
    return wishlist;
  }

  Future<List> getAllProductsID() async{
    var productIDs = [];
    QuerySnapshot querySnapshot = await productCollection.getDocuments();
    var productsData = querySnapshot.documents.map((doc) => doc.data).toList();
    var productID_list = List<dynamic>.from(productsData);

    for(int i = 0; i < productID_list.length; i++){
      productIDs.add(productID_list[i]['product_id']);
    }
    return productIDs;
  }

  Future<List> getAllProductsDiscount() async{
    var productDiscounts = [];
    QuerySnapshot querySnapshot = await productCollection.getDocuments();
    var productsData = querySnapshot.documents.map((doc) => doc.data).toList();
    var productDiscount_list = List<dynamic>.from(productsData);

    for(int i = 0; i < productDiscount_list.length; i++){
      productDiscounts.add(productDiscount_list[i]['isdiscounted']);
    }
    return productDiscounts;
  }

  Future<List> getAllProductNames() async{
    var productNames = [];
    QuerySnapshot querySnapshot = await productCollection.getDocuments();
    var productsData = querySnapshot.documents.map((doc) => doc.data).toList();
    var productName_list = List<dynamic>.from(productsData);

    for(int i = 0; i < productName_list.length; i++){
      productNames.add(productName_list[i]['product_name']);
    }
    return productNames;
  }

  Future<List> getAllProducts() async{
    var products = [];
    QuerySnapshot querySnapshot = await productCollection.getDocuments();
    var productsData = querySnapshot.documents.map((doc) => doc.data).toList();
    var product_list = List<dynamic>.from(productsData);

    for(int i = 0; i < product_list.length; i++){
      products.add(product_list[i]);
    }
    return products;
  }


  @override
  Widget build(BuildContext context) {
    final AuthService _auth = AuthService();

    return (is_signed_out) ? Wrapper() : Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text("Favorites"),
        centerTitle: true,
        backgroundColor: AppColors.logo_color,
        elevation: 0.0,
        actions: <Widget>[
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
        ],
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: FutureBuilder(
          future: Future.wait([getAllProductsID(), getAllProductsDiscount(), getWishlist(), getAllProductNames(), getAllProducts()]),//getBasket(),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {                   
            // WHILE THE CALL IS BEING MADE AKA LOADING
            if (!snapshot.hasData) {            
              return Center(child: Loading());
            }

            // WHEN THE CALL IS DONE BUT HAPPENS TO HAVE AN ERROR
            if (ConnectionState.done != null && snapshot.hasError) {
              return Center(child: Text(snapshot.error.toString()));
              //return Center(child: Loading());
            }

            if(snapshot.data[2].length == 0){
              return Center(child: Text("Your wishlist is empty"));
            }

            var productIDs = [snapshot.data[0]];
            var productDiscount = [snapshot.data[1]];
            var wishList = [snapshot.data[2]];
            var productNames = [snapshot.data[3]];
            var allProducts = [snapshot.data[4]];
            var wishlistItems = [];

            productIDs.sort();
            wishList.sort();
            print("qqqqqqqqqqqqqqqqqqqqqqqqqqqqqq");
            print(productIDs);
            print(wishList);
            print(productDiscount);
            print(productNames);
            print("asdasdasd");
            print(allProducts[0].length);

            int itemCount = 0;
            for(int i = 0; i < wishList[0].length; i++){
              String current_product_id = wishList[0][i];
              int product_index = productIDs[0].indexOf(current_product_id);

              print("pid:" + current_product_id);
              print("index:" + product_index.toString());

              wishlistItems.add(allProducts[0][product_index]);
              itemCount++;
            }
            //return ListView.builder(
            //  itemCount: itemCount, // data[0] means snapshot that we got from getBasket function
            //  itemBuilder: (context, position){ 
                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 20, crossAxisSpacing: 4 ,childAspectRatio: 0.70),
                    itemCount: wishlistItems.length,
                    itemBuilder: (context, position){
                      final doc = wishlistItems[position];
                      return ProductCardDiscount(name: wishlistItems[position]['product_name'], image: wishlistItems[position]['product_photos'][0], price: wishlistItems[position]['price'], productID: wishlistItems[position]['product_id'], productDescription: wishlistItems[position]['product_description'], productQuantity: wishlistItems[position]['quantity'], productWarranty: wishlistItems[position]['warranty'], productDistributor: wishlistItems[position]['distributor'], document: doc,);
                    }, 
                  );
                //return ProductCard(name: discountedItemNames[position]['product_name'], image: discountedItemNames[position]['product_photos'][0], price: discountedItemNames[position]['price'], productID: discountedItemNames[position]['product_id'], productDescription: discountedItemNames[position]['product_description'], productQuantity: discountedItemNames[position]['quantity'], productWarranty: discountedItemNames[position]['warranty'], productDistributor: discountedItemNames[position]['distributor'], document: discountedItemNames[position],);
                //return Padding(
                //  padding: const EdgeInsets.all(8.0),
                //  child: Container(
                //    height: MediaQuery.of(context).size.height/7,
                //    width: MediaQuery.of(context).size.width - 10,
                //    child: Center(child: Text(discountedItemNames[position]['product_name'].toString())),
                //    decoration: BoxDecoration( 
                //      color: AppColors.box,
                //      border: Border.all(
                //        color: AppColors.logo_color,
                //        width: 2.0,
                //      ),
                //      borderRadius: BorderRadius.circular(20.0),
                //    )
                //  ),
                //);
            //  }
            //);
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

*/







/*
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:project_v1/cards/product_card.dart';
import 'package:project_v1/cards/refund_card.dart';

import '../loading.dart';
import '../theme.dart';
import 'home.dart';

class Notifications extends StatefulWidget {
  const Notifications({ Key? key }) : super(key: key);

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  final CollectionReference productCollection = Firestore.instance.collection('products');
  final CollectionReference userCollection = Firestore.instance.collection('users');

  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool is_signed_out = false;

  void changePageTo(Widget page){
    
    Navigator.pushReplacement(
      context, 
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => page,
        transitionDuration: Duration(seconds: 0),
      ),
    ); 
  }

  List wishlistItems = [];

Future<void> getWishlist() async{
    final FirebaseUser user = await FirebaseAuth.instance.currentUser();
    final userID = user.uid;

    var docSnapshotUsers = await userCollection.document(userID).get();
    if (docSnapshotUsers.exists) {
      Map<String, dynamic> data = docSnapshotUsers.data;
      // You can then retrieve the value from the Map like this:
      wishlistItems = List.of(data['wishlist'].cast<String>()); //! Burdaki sacma sey olmayinca basket listesi otamatikman fixedlength list oluyo bu yuzden eleman ekleyince exception throwluyo.
      print("QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQ");
      print(wishlistItems);
    }
}

@override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_){
      getWishlist();
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text("Discounts"),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        elevation: 0.0,
        actions: <Widget>[
          FlatButton.icon(
            icon: Icon(Icons.refresh, color: AppColors.full_white,),
            color: AppColors.primary,
            label: Text(''),
            onPressed: () async {
              Navigator.pop(context);
              Navigator.push(context,  MaterialPageRoute(builder: (context) => const Notifications()),);   
            },
          ),
        ],
      ),
      body: Container(
        height: MediaQuery.of(context).size.height * 80 / 100,
        //color: AppColors.green,
        child: StreamBuilder(
          
          //stream: productCollection.where('category', isEqualTo: categoryNames[findCurrentIndex()]).snapshots(),
          stream: ((){
            return productCollection.where('product_id', whereIn: wishlistItems).where('isdiscounted', isEqualTo: true).snapshots();

          }()),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if(!snapshot.hasData){
              //Navigator.pop(context);
              Navigator.push(context,  MaterialPageRoute(builder: (context) => const Notifications()),); 
              return Loading();
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
                  return ProductCard(name: doc['product_name'], image: doc['product_photos'][0], price: doc['price'], productID: doc['product_id'], productDescription: doc['product_description'], productQuantity: doc['quantity'], productDistributor: doc['distributor'], productWarranty: doc['warranty'], document: doc);           
                }, 
              );
            }
          }
        
        ),
      ),
    );
  }
}

*/
