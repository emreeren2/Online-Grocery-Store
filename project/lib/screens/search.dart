


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:project_v1/cards/product_card.dart';
import 'package:project_v1/screens/favorites.dart';
import 'package:project_v1/screens/profile.dart';
import 'package:project_v1/screens/shopping_cart.dart';
import 'package:project_v1/services/authentication_service.dart';
import 'package:project_v1/theme.dart';
import '../buttons.dart';
import '../loading.dart';
import '../wrapper.dart';
import 'home.dart';
import 'package:async/async.dart';

class Search extends StatefulWidget {
  Search({ Key? key,}) : super(key: key);

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  
  bool is_signed_out = false;
  String name = '';
  final CollectionReference productCollection = Firestore.instance.collection('products');


  /*Future<String> searchProduct() async{
    Future<QuerySnapshot> snapshot = productCollection.where('product_name', isGreaterThanOrEqualTo: "banana").getDocuments();
    print(snapshot.toString());
  }*/

  void changePageTo(Widget page){
    
    Navigator.pushReplacement(
      context, 
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => page,
        transitionDuration: Duration(seconds: 0),
      ),
    ); 
  }

  int _selectedIndex = 1;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if(index == 0){
        changePageTo(Home());
      }
      else if(index == 1){
        print("XXXXXXXXXXX");
        print("IN SEARCH PAGE");
        print("XXXXXXXXXXX");
      }
      else if(index == 2){
        changePageTo(ShoppingCart());
      }
      else if(index == 3){
        changePageTo(Favorites());
      }
      else if(index == 4){
        changePageTo(Profile());
      }
    });
  }

  Icon customIcon = Icon(Icons.search);
  Widget customSearchBar = Text("Search"); 

    void initState() {
    super.initState();
    // NOTE: Calling this function here would crash the app.
  }
  Stream<List<QuerySnapshot>> getData(String name){
    final stream1 = productCollection.where('product_name', isGreaterThanOrEqualTo: name).where("product_name", isLessThan: name + 'z').snapshots();
    final stream2 = productCollection.where('product_description', isGreaterThanOrEqualTo: name).where('product_description', isLessThan: name + 'z').snapshots();
    return StreamZip([stream1, stream2]);

  }

  @override
  Widget build(BuildContext context) {

    final AuthService _auth = AuthService();
    
    return (is_signed_out) ? Wrapper() : Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: customSearchBar,
        centerTitle: true,
        backgroundColor: AppColors.logo_color,
        elevation: 0.0,
        actions: <Widget>[
          IconButton(
            icon: customIcon,
            onPressed: () {
              setState(() {
                if (this.customIcon.icon == Icons.search){
                  customIcon = const Icon(Icons.cancel);
                  customSearchBar = ListTile(
                    leading: Icon(
                      Icons.search,
                      color: Colors.white,
                    ),
                    title: TextFormField(
                      decoration: InputDecoration(
                        hintText: "search",
                      ),
                      onChanged: (input){
                        if (input.isNotEmpty) {
                            setState(() {
                              name = input;
                            });
                        }
                        else {
                          setState(() {
                            name = '';              
                          });
                        }

                      },
                    ),
                  );
                }
                else {
                  customIcon = const Icon(Icons.search);
                  customSearchBar = const Text("Search");
                }
              });

            }
          ),
          //FlatButton.icon(
          //  icon: Icon(Icons.logout),
          //  label: Text('logout'),
          //  onPressed: () async {
          //    setState(() {
          //      is_signed_out = true;
          //    });
          //    await _auth.signOut();
          //  },
          //),
        ],
      ),
      body: name == '' ? Center(child: Text("SEARCH"),)
      : StreamBuilder(
        stream: getData(name),
        builder: (BuildContext context, AsyncSnapshot<List<QuerySnapshot>> snapshot) {
          if(!snapshot.hasData){
            return Loading();
          }
          List<QuerySnapshot> query = [];
          List<QuerySnapshot> querySnapshotData =  snapshot.data?.toList() ?? query;
          querySnapshotData[0].documents.addAll(querySnapshotData[1].documents);
          if (querySnapshotData[0].documents.isEmpty) {
            return Center(child: Text("not found"),);
          }
          else {
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 20, crossAxisSpacing: 4 ,childAspectRatio: 0.70), 
              itemCount: querySnapshotData[0].documents.length,
              itemBuilder: (context,index) {
                final doc = querySnapshotData[0].documents[index];
                return ProductCard(name: doc['product_name'], image: doc['product_photos'][0], price: doc['price'], productID: doc['product_id'], productDescription: doc['product_description'], productQuantity: doc['quantity'], productDistributor: doc['distributor'], productWarranty: doc['warranty'],);           
              }
            );
          }
           
          
          
          
          
          
          
          
          /*StreamBuilder(
            stream: productCollection.where('product_description', isEqualTo: name).snapshots(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot1){
              if (snapshot1.hasData || snapshot.hasData) {
                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 20, crossAxisSpacing: 4 ,childAspectRatio: 0.70), 
                  itemCount: snapshot1.data!.documents.length,
                  itemBuilder: (context,index){
                    final doc = snapshot1.data!.documents[index];
                    
                    return ProductCard(name: doc['product_name'], image: doc['product_photos'][0], price: doc['price'], productID: doc['product_id']);
                  }
                );
              }
              /*else if (snapshot.hasData){
                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 20, crossAxisSpacing: 4 ,childAspectRatio: 0.70), 
                  itemCount: snapshot.data!.documents.length,
                  itemBuilder: (context,index){
                    final doc = snapshot.data!.documents[index];
                    return ProductCard(name: doc['product_name'], image: doc['product_photos'][0], price: doc['price'], productID: doc['product_id']);
                  }
                );
              }*/
              else{
                return Center(child: Text("no desc"),);
              }

            }
            
            );*/
          /*if(!snapshot.hasData){
              return Center(child: Text("Not Found"),);
          }
          else{
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 20, crossAxisSpacing: 4 ,childAspectRatio: 0.70),
              itemCount: snapshot.data!.documents.length,
              itemBuilder: (context, index){
                final doc = snapshot.data!.documents[index];
                //return Loading();
                // return Text(doc['product_name']),
                return ProductCard(name: doc['product_name'], image: doc['product_photos'][0], price: doc['price'], productID: doc['product_id']);           
              }, 
            );
          }*/
        }
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






      /*
      bottomNavigationBar: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Divider(
            color: AppColors.logo_color,
            thickness: 2,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 7),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.home), 
                  color: AppColors.full_black,
                  splashColor: AppColors.logo_color,
                  splashRadius: 30.0, 
                  iconSize: 32.0,
                  onPressed: () { 
                    changePageTo(Home());
                   },              
                ),
                IconButton(
                  icon: Icon(Icons.search), 
                  color: AppColors.logo_color,
                  splashColor: AppColors.logo_color,
                  splashRadius: 30.0, 
                  iconSize: 35.0,
                  onPressed: () { _auth.getCurrentUserID(); },              
                ),
                //SizedBox(width: 65,),

                IconButton(
                  icon: Icon(Icons.shopping_cart), 
                  color: AppColors.full_black,
                  splashColor: AppColors.logo_color,
                  splashRadius: 30.0, 
                  iconSize: 32.0,
                  onPressed: () { 
                    changePageTo(ShoppingCart());
                   },              
                ),
                IconButton(
                  icon: Icon(Icons.favorite_border_outlined), 
                  color: AppColors.full_black,
                  splashColor: AppColors.logo_color,
                  splashRadius: 30.0, 
                  iconSize: 32.0,
                  onPressed: () { 
                    changePageTo(Favorites());
                   },              
                ),
                IconButton(
                  icon: Icon(Icons.person), 
                  color: AppColors.full_black,
                  splashColor: AppColors.logo_color,
                  splashRadius: 30.0, 
                  iconSize: 32.0,
                  onPressed: () { 
                    changePageTo(Profile());
                   },              
                ),
              ],
            ),
          ),
        ],
      ),
      */