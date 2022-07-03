import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:project_v1/cards/category_card.dart';
import 'package:project_v1/models/CategoryObject.dart';
import 'package:project_v1/screens/favorites.dart';
import 'package:project_v1/screens/profile.dart';
import 'package:project_v1/screens/search.dart';
import 'package:project_v1/screens/shopping_cart.dart';
import 'package:project_v1/screens/sign_in.dart';
import 'package:project_v1/services/authentication_service.dart';
import 'package:project_v1/theme.dart';
import '../buttons.dart';


import '../loading.dart';
import '../main.dart';
import '../wrapper.dart';

class Home extends StatefulWidget {
  const Home({ Key? key }) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final CollectionReference categoryCollection = Firestore.instance.collection('categories');
  //var categoryData; 
  bool is_signed_out = false;
  bool done = false;
  Random random = new Random();


  void changePageTo(Widget page){
    
    Navigator.pushReplacement(
      context, 
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => page,
        transitionDuration: Duration(seconds: 0),
      ),
    ); 
  }
  
  int _selectedIndex = 0;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if(index == 0){
        print("XXXXXXXXXXX");
        print("IN HOME PAGE");
        print("XXXXXXXXXXX");
      }
      else if(index == 1){
        changePageTo(Search());
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
  
  /*
  List<CategoryObject> categories= [
    CategoryObject(category_name: "Fruit / Vegetable", image_url: "https://external-content.duckduckgo.com/iu/?u=http%3A%2F%2F2.bp.blogspot.com%2F-P86uqpPUCY4%2FU5hluHcxovI%2FAAAAAAAAAQc%2F2gyWkS0e_Po%2Fs1600%2FVegetables.png&f=1&nofb=1"),
    CategoryObject(category_name: "Meat / Chicken / Fish", image_url: "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fpngimg.com%2Fuploads%2Fsteak%2Fsteak_PNG31.png&f=1&nofb=1"),
    CategoryObject(category_name: "Drink", image_url: "https://external-content.duckduckgo.com/iu/?u=http%3A%2F%2Fwww.pngall.com%2Fwp-content%2Fuploads%2F5%2FCocktail-PNG.png&f=1&nofb=1"),
    
    CategoryObject(category_name: "Breakfast", image_url: "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Feniyion.net%2Fwp-content%2Fuploads%2F2012%2F03%2FKahvalti11.png&f=1&nofb=1"),
    CategoryObject(category_name: "Dairy Products", image_url: "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fwww.pngarts.com%2Ffiles%2F1%2FDairy-PNG-Image-Background.png&f=1&nofb=1"), // https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fnijammigroup.com%2Fwp-content%2Fuploads%2F2019%2F04%2Fdairy-products.png&f=1&nofb=1
    CategoryObject(category_name: "Primary Food", image_url: "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fwww.pikpng.com%2Fpngl%2Fb%2F53-531155_wheat-png-transparent-image-semillas-de-trigo-png.png&f=1&nofb=1"),
    
    CategoryObject(category_name: "Bakery", image_url: "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fcdn2.iconfinder.com%2Fdata%2Ficons%2Ffood03-filled-colour%2F512%2Fbread-bakery-wheat-bake-loaf-pastry-512.png&f=1&nofb=1"),
    CategoryObject(category_name: "Snack", image_url: "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fwww.specialtyfood.com%2Fmedia%2Fmulti_image_uploader%2Fsource%2FSmall_Bars_2.png&f=1&nofb=1"),
    CategoryObject(category_name: "Convenience Food", image_url: "https://www.biofresh.com.tr/images/uploads/urunler/1-panini-mozzarella-soguk-could-sandvic-sandwich-sandwiches-toptan-uretim-uretici-ihracat-ithal-cafe-perakende-paketli-kafe-hazir-donuk-dondurulmus-ucuz-uygun-pahali-ozel-satis-firma-marka-fresh-taze-gunluk-2.jpg"),
    
    CategoryObject(category_name: "Icrecream", image_url: "https://external-content.duckduckgo.com/iu/?u=http%3A%2F%2Fvictoriabuzz.com%2Fwp-content%2Fuploads%2F2017%2F02%2F04-traits-ice-cream-chocolate.jpg&f=1&nofb=1"),
    CategoryObject(category_name: "Personal Care", image_url: "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fimg.favpng.com%2F2%2F5%2F16%2Fhygiene-hand-washing-personal-care-clip-art-png-favpng-q1hbmAG8xZBGgaqd1Z1q9g8gu.jpg&f=1&nofb=1"),
    CategoryObject(category_name: "Paper Products", image_url: "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fmedia.istockphoto.com%2Fillustrations%2Fvarious-paper-products-illustration-id164418316%3Fk%3D6%26m%3D164418316%26s%3D612x612%26w%3D0%26h%3D71qXSqqdxb6lPn-4G20WeII4ovIZMQKC5Gbv2zP0wJs%3D&f=1&nofb=1"),

    CategoryObject(category_name: "Cleaning", image_url: "https://external-content.duckduckgo.com/iu/?u=http%3A%2F%2Fclipart-library.com%2Fimg%2F822940.jpg&f=1&nofb=1"),
    CategoryObject(category_name: "Baby", image_url: "https://external-content.duckduckgo.com/iu/?u=http%3A%2F%2Fclipartix.com%2Fwp-content%2Fuploads%2F2017%2F11%2FClip-art-baby-clipart-images-on-printable.jpg&f=1&nofb=1"),
    CategoryObject(category_name: "Pet Friends", image_url: "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fstatic.vecteezy.com%2Fsystem%2Fresources%2Fpreviews%2F000%2F232%2F594%2Foriginal%2Fanimal-friends-clip-art-vector.jpg&f=1&nofb=1"),
  ];
  */
  
  //List<CategoryObject> categories= [
  //  CategoryObject(category_name: "Fruit / Vegetable", image_url: "https://external-content.duckduckgo.com/iu/?u=http%3A%2F%2Fimages.clipartpanda.com%2Fhealthy-snack-clipart-fruit-hi.png&f=1&nofb=1"), //  https://external-content.duckduckgo.com/iu/?u=http%3A%2F%2Fclipart-library.com%2Fnewhp%2Fdifferent-kinds-of-vegetables.png&f=1&nofb=1
  //  CategoryObject(category_name: "Meat / Chicken / Fish", image_url: "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fwebstockreview.net%2Fimages%2Fmeat-clipart-meat-seafood-3.png&f=1&nofb=1"),
  //  CategoryObject(category_name: "Drink", image_url: "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fwebstockreview.net%2Fimages%2Flemonade-clipart-soft-drink.png&f=1&nofb=1"),
//
  //  CategoryObject(category_name: "Breakfast", image_url: "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fwww.pinclipart.com%2Fpicdir%2Fbig%2F145-1454803_brunch-free-for-download-on-rpelm-full-clipart.png&f=1&nofb=1"), 
  //  CategoryObject(category_name: "Dairy Products", image_url: "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fwebstockreview.net%2Fimages%2Fclipart-milk-healthy-food-19.png&f=1&nofb=1"),
  //  CategoryObject(category_name: "Primary Food", image_url: "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fcreazilla-store.fra1.digitaloceanspaces.com%2Fcliparts%2F21969%2Fwheat-clipart-md.png&f=1&nofb=1"),
  //  
  //  CategoryObject(category_name: "Bakery", image_url: "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fcdn2.iconfinder.com%2Fdata%2Ficons%2Ffood03-filled-colour%2F512%2Fbread-bakery-wheat-bake-loaf-pastry-512.png&f=1&nofb=1"),
  //  CategoryObject(category_name: "Snack", image_url: "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fwww.pinclipart.com%2Fpicdir%2Fbig%2F319-3194466_chocolate-images-clip-art.png&f=1&nofb=1"),
  //  CategoryObject(category_name: "Convenience Food", image_url: "https://external-content.duckduckgo.com/iu/?u=http%3A%2F%2F4.bp.blogspot.com%2F-qx6c6VOos_o%2FUDzWMH6fuwI%2FAAAAAAAAARw%2FvMsrT2SzPtM%2Fs1600%2Fsandwich.png&f=1&nofb=1"),
  //  
  //  CategoryObject(category_name: "Icrecream", image_url: "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fwww.downloadclipart.net%2Flarge%2F1066-chocolate-soft-serve-ice-cream-cone-design.png&f=1&nofb=1"), // https://external-content.duckduckgo.com/iu/?u=http%3A%2F%2Fcliparts.co%2Fcliparts%2F8cz%2FnL7%2F8cznL7X6i.png&f=1&nofb=1
  //  CategoryObject(category_name: "Personal Care", image_url: "https://external-content.duckduckgo.com/iu/?u=http%3A%2F%2Fclipart-library.com%2Fdata_images%2F66066.png&f=1&nofb=1"),
  //  //CategoryObject(category_name: "Paper Products", image_url: "https://external-content.duckduckgo.com/iu/?u=http%3A%2F%2Fimages.clipartpanda.com%2Ftissue-clipart-Grey-Color-Tissue-Clip-Art5.png&f=1&nofb=1"),
  //  CategoryObject(category_name: "Paper Products", image_url: "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fcreazilla-store.fra1.digitaloceanspaces.com%2Fcliparts%2F1556238%2Ftissue-box-clipart-md.png&f=1&nofb=1"),
//
  //  CategoryObject(category_name: "Cleaning", image_url: "https://external-content.duckduckgo.com/iu/?u=http%3A%2F%2Fclipartmag.com%2Fimages%2Fcleaning-supplies-clipart-39.png&f=1&nofb=1"),
  //  CategoryObject(category_name: "Baby", image_url: "https://external-content.duckduckgo.com/iu/?u=http%3A%2F%2Fclipartix.com%2Fwp-content%2Fuploads%2F2018%2F03%2Fbaby-playing-clipart-2018-15.jpg&f=1&nofb=1"),
  //  CategoryObject(category_name: "Pet Friends", image_url: "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fwebstockreview.net%2Fimages%2Fpet-clipart-dog-walker-3.png&f=1&nofb=1"),
  //  //CategoryObject(category_name: "Pet Friends", image_url: "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fstatic.vecteezy.com%2Fsystem%2Fresources%2Fpreviews%2F000%2F232%2F594%2Foriginal%2Fanimal-friends-clip-art-vector.jpg&f=1&nofb=1"),
  //];

  List<CategoryObject> categories = [];
  List<String> category_names = [];

  Future<void> getCategories() async {
        // Get docs from collection reference
    List<CategoryObject> categoryList = [];
    category_names = [];
    categories = [];
    QuerySnapshot querySnapshot = await categoryCollection.getDocuments();

    // Get data from docs and convert map to List
    var categoryData = querySnapshot.documents.map((doc) => doc.data).toList();

    var category_list = List<dynamic>.from(categoryData);

    for(int i = 0; i < category_list.length; i++){
      print(category_list[i]['text']);
      CategoryObject category_object = new CategoryObject(category_name: category_list[i]['text'], image_url: category_list[i]['url']); //image_url: category_list[i]['url']
      categoryList.add(category_object);
      category_names.add(category_list[i]['text']);
    } 
    //print(category_list);
    //print(category_list.runtimeType);
    categories = categoryList;
    setState(() {
      done = true;
    });
    //return categoryList;
  }
  
  @override
  Widget build(BuildContext context) {

    final AuthService _auth = AuthService();
    
    // ignore: dead_code
    if ((is_signed_out)) {
      return Wrapper();
    } else {
      if ((!done)) {
        getCategories();
        return Loading();
      } else {
        return Scaffold(
      
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text("Get Fresh"),
        centerTitle: true,
        backgroundColor: AppColors.logo_color,
        elevation: 0.0,
        actions: <Widget>[
          FlatButton.icon(
            icon: Icon(Icons.refresh),
            label: Text('refresh'),
            onPressed: () async {
              //setState(() {
              //  is_signed_out = true;
              //});
              //await _auth.signOut();
              //categories = await getCategories();
              getCategories();
              print(categories.toString());
            },
          ),
        ],
      ),
    
      
      body: Container( //* Tepesine padding konulup top ve bottoma 8 padding verilebilir
        padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
        //child: GridView(
        //  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 8),
        //  children: <Widget>[
        //    CategoryCard(category: categories[0], color_index: 0,),
        //    CategoryCard(category: categories[1], color_index: 1,),
        //    CategoryCard(category: categories[2], color_index: 2,),
//
        //    CategoryCard(category: categories[3], color_index: 3,),
        //    CategoryCard(category: categories[4], color_index: 4,),
        //    CategoryCard(category: categories[5], color_index: 8,),
//
        //    CategoryCard(category: categories[6], color_index: 6,),
        //    CategoryCard(category: categories[7], color_index: 0,),
        //    CategoryCard(category: categories[8], color_index: 3,),
//
        //    CategoryCard(category: categories[9], color_index: 5,),
        //    CategoryCard(category: categories[10], color_index: 9,),
        //    CategoryCard(category: categories[11], color_index: 8,),
//
        //    CategoryCard(category: categories[12], color_index: 2,),
        //    CategoryCard(category: categories[13], color_index: 0,),
        //    CategoryCard(category: categories[14], color_index: 3,),
        //  ],
        //),
        child:  GridView.count(
            // Create a grid with 2 columns. If you change the scrollDirection to
            // horizontal, this produces 2 rows.
            crossAxisCount: 2,
            // Generate 100 widgets that display their index in the List.
            children: List.generate(categories.length, (index) {
              return Center(
                child: CategoryCard(
                  category: categories[index], 
                  color_index: random.nextInt(9),
                  categoryNames: category_names,
                ),
              );
            }),
          ),
      ),
      
      

      //body: Center(child: Text("HOME PAGE")),

      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
            //backgroundColor: Colors.indigo,   
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Seach',
            //backgroundColor: Colors.deepOrange,   
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Basket',
            //backgroundColor: Colors.deepOrange,   
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: 'Favorites',
            //backgroundColor: Colors.yellow, 
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
            //backgroundColor: Colors.deepPurple, 
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
    }
  }
