import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:project_v1/cards/product_card.dart';
import 'package:project_v1/models/CategoryObject.dart';
import 'package:project_v1/services/authentication_service.dart';
import 'package:project_v1/theme.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../loading.dart';

/*
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

class Products extends StatefulWidget {
  String current_category;
  final List<String> categoryNames;
  Products({ Key? key, required this.current_category, required this.categoryNames}) : super(key: key);

  @override
  _ProductsState createState() => _ProductsState();
}

class _ProductsState extends State<Products> {

  final AuthService _auth = AuthService();  
  final CollectionReference productCollection = Firestore.instance.collection('products');
  final CollectionReference categoryCollection = Firestore.instance.collection('categories');

  bool sortByPrice = false;
  bool sortByRating = false;
  String dropdownValue = "Default";
  var items =  ['Default', 'Price', 'Popularity', 'Total Points'];
  
  int findCurrentIndex(){
    int current_index = 0;
    for(int i = 0 ; i < widget.categoryNames.length ; i++){
      if(widget.current_category == widget.categoryNames[i]){
        current_index = i;
        break;
      }
    }
    return current_index;
  }

  //List<String> categoryNames = [];
  //var categoryData; 
//
  //Future<void> getCategories() async {
  //      // Get docs from collection reference
  //  QuerySnapshot querySnapshot = await categoryCollection.getDocuments();
//
  //  // Get data from docs and convert map to List
  //  categoryData = querySnapshot.documents.map((doc) => doc.data).toList();
//
  //  var category_list = List<dynamic>.from(categoryData);
//
  //  for(int i = 0; i < category_list.length; i++){
  //    categoryNames.add(category_list[i]['text']);
  //  } 
  //  //print(category_list);
  //  //print(category_list.runtimeType);
  //  //return categoryNames;
  //}
/*
  List<String> categoryNames = [
    "Fruit / Vegetable",
    "Meat / Chicken / Fish",
    "Drink",
    "Breakfast",
    "Dairy Products",
    "Primary Food",
    "Bakery",
    "Snack",
    "Convenience Food",
    "Icecream",
    "Personal Care",
    "Paper Products",
    "Cleaning",
    "Baby",
    "Pet Friends"
  ];
*/
  @override
  void initState() {
    super.initState();
    // NOTE: Calling this function here would crash the app.
    //categories =  getCategories();
    //WidgetsBinding.instance!.addPostFrameCallback((_) => getCategories());

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.current_category),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        actions: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: DropdownButton<String>(
              dropdownColor: AppColors.background,
              iconEnabledColor: AppColors.full_white,
              
              //hint: Text("sort"),
              //value: dropdownValue,
              icon: const Icon(Icons.sort),
              elevation: 16,
              //style: const TextStyle(color: AppColors.background, fontSize: 8),
              //underline: Container(
              //  height: 2,
              //  color: AppColors.full_white,
              //),
              onChanged: (String? newValue) {
                setState(() {
                  dropdownValue = newValue!;
                });
              },
              items:items.map((String items) {
                return DropdownMenuItem(
                  value: items,
                  child: Text(items, style: TextStyle(fontSize: 18, color: AppColors.full_black),),
                );
              }).toList(),
            ),
          )
        ],
      ),

      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(5),
            height: 50,
            color: Colors.orangeAccent,
            child: ScrollablePositionedList.builder(
              initialScrollIndex: findCurrentIndex(),
              scrollDirection: Axis.horizontal,
              itemCount: widget.categoryNames.length,
              itemBuilder: (BuildContext, index){
                return Padding(
                  padding: const EdgeInsets.fromLTRB(10, 2, 10, 0),
                  child: InkWell(
                    //(widget.current_category == categoryNames[index]) ? AppColors.logo_color : AppColors.transparent_box,
                    onTap: () {
                      print(index);
                      setState(() {
                        widget.current_category = widget.categoryNames[index];
                      });
                    },
                    child: Container(
                      //color: (widget.current_category == categoryNames[index]) ? AppColors.primary : AppColors.transparent_box,
                      decoration: (widget.current_category == widget.categoryNames[index]) 
                        ? BoxDecoration(
                          //border: Border.all(color: AppColors.dark_box),
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          color: AppColors.primary,
                          ) 
                        : null,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(widget.categoryNames[index]),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          //SizedBox(height: 20,),

          Container(
            height: MediaQuery.of(context).size.height * 80 / 100,
            //color: AppColors.green,
            child: StreamBuilder(
              //stream: productCollection.where('category', isEqualTo: categoryNames[findCurrentIndex()]).snapshots(),
              stream: ((){
                if(dropdownValue == 'Default'){
                  return productCollection.where('category', isEqualTo: widget.categoryNames[findCurrentIndex()]).snapshots();
                }
                else if(dropdownValue == 'Price'){
                  return productCollection.where('category', isEqualTo: widget.categoryNames[findCurrentIndex()]).orderBy('price').snapshots();
                }
                else if(dropdownValue == 'Popularity'){
                  return productCollection.where('category', isEqualTo: widget.categoryNames[findCurrentIndex()]).orderBy('total_votings').snapshots();
                }
                else{ // dropdownValue == Total Points
                  return productCollection.where('category', isEqualTo: widget.categoryNames[findCurrentIndex()]).orderBy('total_points').snapshots();
                }
              }()),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if(!snapshot.hasData){
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
                      // ! databasede distibutor diye yanlis yazmisim onu duzeltince burayi da guncellemek lazim distributor olarak
                      return ProductCard(name: doc['product_name'], image: doc['product_photos'][0], price: doc['price'], productID: doc['product_id'], productDescription: doc['product_description'], productQuantity: doc['quantity'], productDistributor: doc['distributor'], productWarranty: doc['warranty'], document: doc);           
                    }, 
                  );
                }
              }
            
            ),
          ),
        ],
      ),
    );
  }
}

