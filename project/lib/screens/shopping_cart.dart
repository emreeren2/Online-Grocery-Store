import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:project_v1/cards/basket_card.dart';
import 'package:project_v1/loading.dart';
import 'package:project_v1/screens/edit_address_information.dart';
import 'package:project_v1/screens/edit_creditcard_information.dart';
import 'package:project_v1/screens/favorites.dart';
import 'package:project_v1/screens/profile.dart';
import 'package:project_v1/screens/search.dart';
import 'package:project_v1/services/authentication_service.dart';
import 'package:project_v1/theme.dart';
import '../buttons.dart';
import '../wrapper.dart';
import 'home.dart';


class ShoppingCart extends StatefulWidget {
  const ShoppingCart({ Key? key }) : super(key: key);

  @override
  State<ShoppingCart> createState() => _ShoppingCartState();
}

class _ShoppingCartState extends State<ShoppingCart> {

  bool is_signed_out = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference productCollection = Firestore.instance.collection('products');
  final CollectionReference userCollection = Firestore.instance.collection('users');
  final CollectionReference cartsCollection = Firestore.instance.collection('Carts');
  final CollectionReference ordersCollection = Firestore.instance.collection('myorders');

  bool isLoaded = false;
  int totalPrice = 0;
  List priceList = [];
  List amountList = [];
  List idList = [];
  bool orderPlaced = false;

  Future<String> getUserID() async {
    final FirebaseUser user = await _auth.currentUser();
    final userID = user.uid;
    return userID;
  }

  Future<List> getBasket() async {
    String userID = await getUserID();
    var basket = [];
    var docSnapshotProducts = await userCollection.document(userID).get();
    if (docSnapshotProducts.exists) {
      Map<String, dynamic> data = docSnapshotProducts.data;
      // You can then retrieve the value from the Map like this:
      basket = List.of(data['basket'].cast<String>()); //! Burdaki sacma sey olmayinca basket listesi otamatikman fixedlength list oluyo bu yuzden eleman ekleyince exception throwluyo.
    }
    return basket;
  }

  Future<List> getProductImages() async{
    var productImages = [];
    var basket = await getBasket();
    for(int i = 0; i < basket.length; i++){
      var docSnapshotUsers = await productCollection.document(basket[i]).get();
      Map<String, dynamic> data = docSnapshotUsers.data;
      String mainImage = data['product_photos'][0];
      productImages.add(mainImage);
    }
    return productImages;
  }

  Future<List> getProductPrices() async{
    var productPrices = [];
    var basket = await getBasket();
    for(int i = 0; i < basket.length; i++){
      var docSnapshotUsers = await productCollection.document(basket[i]).get();
      Map<String, dynamic> data = docSnapshotUsers.data;
      productPrices.add(data['price']);
    }
    return productPrices;
  }

  Future<List> getProductNames() async{
    var productNames = [];
    var basket = await getBasket();
    for(int i = 0; i < basket.length; i++){
      var docSnapshotUsers = await productCollection.document(basket[i]).get();
      Map<String, dynamic> data = docSnapshotUsers.data;
      productNames.add(data['product_name']);
    }
    return productNames;
  }

    Future<List> getProductIDs() async{
    var productIDs = [];
    var basket = await getBasket();
    for(int i = 0; i < basket.length; i++){
      var docSnapshotUsers = await productCollection.document(basket[i]).get();
      Map<String, dynamic> data = docSnapshotUsers.data;
      productIDs.add(data['product_id']);
    }
    return productIDs;
  }

  int calculateTotalPrice(List prices, List counts){
    int total = 0;

    for(int i = 0; i < prices.length; i++){
      int uniqueItemTotalPrice = prices[i]*counts[i];
      total += uniqueItemTotalPrice;
    }

    return total;
  }

  /*
  Future<Map<String, dynamic>> getProductDocument(String docID) async{
    var docSnapshotUsers = await productCollection.document(docID).get();
    Map<String, dynamic> data = docSnapshotUsers.data;
    return data;
  }
  */

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

  Future<void> showAlertDialog(String title, String message, String requirement, Widget page) async {
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
                child: Text('Close Alert'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('Add ' + requirement),
                onPressed: () {
                  pushPageTo(page);
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

  int _selectedIndex = 2;
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
        print("XXXXXXXXXXX");
        print("IN SHOPPING CART PAGE");
        print("XXXXXXXXXXX");
      }
      else if(index == 3){
        changePageTo(Favorites());
      }
      else if(index == 4){
        changePageTo(Profile());
      }
    });
  }

  @override
  void initState() {
    super.initState();
    // NOTE: Calling this function here would crash the app.
    totalPrice = calculateTotalPrice(priceList, amountList);
  }

  @override
  Widget build(BuildContext context) {

    final AuthService _auth = AuthService();
    

    return (is_signed_out) ? Wrapper() : Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text("Shopping Cart"),
        centerTitle: true,
        backgroundColor: AppColors.logo_color,
        elevation: 0.0,
        actions: <Widget>[
          FlatButton.icon(
            icon: Icon(Icons.refresh, color: AppColors.full_white,),
            color: AppColors.primary,
            label: Text(''),
            onPressed: () async {
              Navigator.pop(context);
              Navigator.push(context,  MaterialPageRoute(builder: (context) => const ShoppingCart()),);   
            },
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 5,
            child: Container(
              width: MediaQuery.of(context).size.width,
              color: AppColors.background,
              child: FutureBuilder(
                future: Future.wait([getBasket(), getProductImages(), getProductPrices(), getProductNames()]),//getBasket(),
                builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {                   
                  // WHILE THE CALL IS BEING MADE AKA LOADING
                  if (!snapshot.hasData) {
                    isLoaded = false;
                  
                    return Center(child: Loading());
                  }

                  // WHEN THE CALL IS DONE BUT HAPPENS TO HAVE AN ERROR
                  if (ConnectionState.done != null && snapshot.hasError) {
                    return Center(child: Text(snapshot.error.toString()));
                    //return Center(child: Loading());
                  }

                  if(snapshot.data[0].length == 0){
                    return Center(child: Text("Your basket is empty"));
                  }

                  // finding length of the basket array without duplicates
                  var uniqueID = [snapshot.data[0][0]];
                  var uniqueImages = [snapshot.data[1][0]];
                  var uniquePrices = [snapshot.data[2][0]];
                  var uniqueNames = [snapshot.data[3][0]];
                  bool duplicateFound = false;
                  for(int i = 0; i < snapshot.data[0].length; i++){
                    for(int j = 0; j < uniqueID.length; j++){
                      if(snapshot.data[0][i] == uniqueID[j]){
                        duplicateFound = true;
                        break;
                      }
                    }
                    if(!duplicateFound){
                      uniqueID.add(snapshot.data[0][i]);
                      uniqueImages.add(snapshot.data[1][i]);
                      uniquePrices.add(snapshot.data[2][i]);
                      uniqueNames.add(snapshot.data[3][i]);
                    }
                    duplicateFound = false;
                  }

                  int countWithoutDuplicates = uniqueID.length;
                  int totalProductAmount = 0;
                  var totalProductAmountList = [];
                  var lookedIDs = [];
                  for(int i = 0; i < snapshot.data[0].length; i++){
                    totalProductAmount = 0;
                    for(int j = i; j < snapshot.data[0].length; j++){
                      if(lookedIDs.contains(snapshot.data[0][i])){
                        break;
                      }
                      if(snapshot.data[0][i] == snapshot.data[0][j]){
                        totalProductAmount++;
                      }
                    }
                    if(totalProductAmount != 0){
                      lookedIDs.add(snapshot.data[0][i]);
                      totalProductAmountList.add(totalProductAmount);
                    }
                  }


                  
                  //print(lookedIDs);
                  //print(uniqueID);
                  //print(uniquePrices);
                  //print(uniqueNames);
                  //print(totalProductAmountList);
                  //print("YUYUYUYUYUYUYUYUYUYUYUYUYUUY");
                  //print(countWithoutDuplicates);
                  //futurebuilderda set state ise yaramiyo, o yuzden bunu kullaniyoruz    
                  SchedulerBinding.instance!
                    .addPostFrameCallback((_) => setState(() {
                    priceList = uniquePrices;
                    amountList = totalProductAmountList;
                    idList = uniqueID;
                    totalPrice = calculateTotalPrice(uniquePrices, totalProductAmountList);
                    isLoaded = true;
                  }));
                  return ListView.builder(
                    itemCount: countWithoutDuplicates, // data[0] means snapshot that we got from getBasket function
                    itemBuilder: (context, position){ 
                      return BasketCard(productID: uniqueID[position], productAmount: totalProductAmountList[position], productImage: uniqueImages[position] , productPrice: uniquePrices[position], productName: uniqueNames[position],);
                    }
                  );
                },
              ),
            ),
          ),
          if(isLoaded)
          Expanded(
            flex: 1,
            child: Material(
              elevation: 20,
              child: Container(
                width: MediaQuery.of(context).size.width,
                color: AppColors.full_white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                        Material(elevation: 10, color: AppColors.transparent_box, child: Text("Total Price: ")),
                        Material(
                          elevation: 10,
                          color: AppColors.full_white,
                          borderRadius: BorderRadius.all(Radius.circular(100)),
                          child: Container(
                            width: 50,
                            height: 50,
                            child: Center(child: Text(totalPrice.toString())),  
                          ),
                        ),
                        ],
                      ),
                    ),

                          Container(
                            width: 150,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () async { 
                                print("naban");
                                print(idList);
                                print(amountList);
                                  
                                var userID = await getUserID();
                                var documentSnapshot = await userCollection.document(userID).get();
                                Map<String, dynamic> data = documentSnapshot.data;

                                if(data['credit_card_number'] == ""){
                                  showAlertDialog("Your order cannot be placed", "Please enter your credit card information", "card", EdtiCreditCard());
                                }
                                else if(data['delivery_address'] == ""){
                                  showAlertDialog("Your order cannot be placed", "Please enter your address information", "address", EdtiAddress());
                                }
                                // clear user basket, put them to the delivered items, decrement product quantity.
                                else{ 
                                  List basket_product_ids = await getProductIDs();
                                  print(basket_product_ids);
                                  var unavailable_to_order = [];
                                  var product_quantity;
                                  for(int x = 0; x < idList.length; x++){
                                    //!  DECREASING QUANTITY OF PRODUCT FROM PRODUCT COLLECTION
                                    var docSnapshotProducts = await productCollection.document(idList[x]).get();
                                    if (docSnapshotProducts.exists) {
                                      Map<String, dynamic> data = docSnapshotProducts.data;
                                      // You can then retrieve the value from the Map like this:
                                      product_quantity = data['quantity']; 
                                    }
                                    print("asdasdasdasdasdasdasdasdasd");
                                    print(product_quantity);
                                    print(amountList[x]);
                                    print(idList[x]);
                                    if(product_quantity >= amountList[x]){
                                      product_quantity = product_quantity - amountList[x];
                                      await productCollection.document(idList[x]).updateData({
                                        'quantity': product_quantity,
                                      });
                                    }
                                    else{
                                      unavailable_to_order.add(idList[x]);
                                    }
                                  }
                                  print(" QQQQLLLLLQQQQQLLLL" + unavailable_to_order.toString());
                                  if(unavailable_to_order.length > 0){
                                    // getting product name from the id.
                                    var productNames = [];
                                    for(int j = 0; j < unavailable_to_order.length; j++){
                                      var product_name;
                                      var docSnapshotProducts = await productCollection.document(basket_product_ids[j]).get();
                                      if (docSnapshotProducts.exists) {
                                        Map<String, dynamic> data = docSnapshotProducts.data;
                                        // You can then retrieve the value from the Map like this:
                                        product_name = data['product_name']; 
                                      }
                                      productNames.add(product_name);
                                    }
                                    showAlertDialog_2("Out of Stock", "Your order couldn't be placed. For the following item(s) your demand exceeds stock: " + productNames.toString());
                                  }
                                  else {
                                    print("NABANNABANNABANNABANNABANNABANNABANNABAN");
                                    var basket = [];
                                    var delivered_items = [];
                                    delivered_items = List.of(data['ordered_items'].cast<String>()); //! Burdaki sacma sey olmayinca basket listesi otamatikman fixedlength list oluyo bu yuzden eleman ekleyince exception throwluyo.
                                    basket = List.of(data['basket'].cast<String>());
                                      
                                    for(int i = 0; i < basket.length; i++){
                                      delivered_items.add(basket[i]);
                                    }
                                    
                                    await userCollection.document(userID).updateData({
                                      'ordered_items': delivered_items
                                    });
                                    await userCollection.document(userID).updateData({
                                      'basket': []
                                    });

                                    await showAlertDialog_2("Congratulations!", "We got your order. Thank you for choosing us :)");
                                    //Navigator.pop(context);
                                    changePageTo(ShoppingCart());

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
                                    int total_qty = 0;
                                    int total_price = 0;
                                    var cart_products = [];
                                    for(int j = 0; j < basket_product_ids.length; j++){
                                      var product_name;
                                      var docSnapshotProducts = await cartsCollection.document(userID).collection('Products').document(basket_product_ids[j]).get();
                                      if (docSnapshotProducts.exists) {
                                        Map<String, dynamic> data = docSnapshotProducts.data;   
                                        int q =  data['qty'];
                                        int tp = data['TotalProductPrice'];
                                        total_qty += q;
                                        total_price += tp;                           
                                        cart_products.add(data);
                                      }
                                    } 
                                    ordersCollection.document(delivery_id).setData({
                                      'Address': address,
                                      'delivery_id': delivery_id,
                                      'delivery_name': delivery_name,
                                      'order_status': order_status,
                                      'placement_date': placement_date,
                                      'products': cart_products,
                                      'total_price': total_price,
                                      'total_qty': total_qty,
                                      'used_id': user_id
                                    });

                                    for(int j = 0; j < basket_product_ids.length; j++){
                                      cartsCollection.document(userID).collection('Products').document(basket_product_ids[j]).delete();
                                    } 

                                    //! end

                                  }
                                }

                              },
                              child: Center(child: Text("Place Order")),
                              style: ElevatedButton.styleFrom(
                                enableFeedback: true, // ne oldugunu bilmiyorum bunun.
                                elevation: 12,
                                primary: (priceList.length != 0) ? AppColors.logo_color : AppColors.box,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(20)),
                                ),
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ),
        ],
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