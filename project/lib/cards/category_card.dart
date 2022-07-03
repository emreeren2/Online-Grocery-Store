import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:project_v1/models/CategoryObject.dart';
import 'package:project_v1/screens/products.dart';
import 'package:project_v1/theme.dart';
import '../buttons.dart';


class CategoryCard extends StatefulWidget {
  //const CategoryCard({ Key? key, required this.categoty}) : super(key: key);

  final CategoryObject category;
  final int color_index;
  final List<String> categoryNames;
  CategoryCard({required this.category, required this.color_index, required this.categoryNames});

  @override
  _CategoryCardState createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard> {
  final List<MaterialColor> color_list = [
    Colors.blue,          // 0 
    Colors.amber,         // 1
    Colors.deepPurple,    // 2
    Colors.indigo,        // 3
    Colors.deepOrange,    // 4
    Colors.green,         // 5
    Colors.red,           // 6
    Colors.pink,          // 7
    Colors.yellow,        // 8
    Colors.lightGreen     // 9
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            enableFeedback: true, // ne oldugunu bilmiyorum bunun.
            elevation: 12,
            primary: color_list[widget.color_index],
            minimumSize: Size(100, 50),
            padding: EdgeInsets.all(10),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(30)),
            ),
          ),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => Products(current_category: widget.category.category_name, categoryNames: widget.categoryNames,)));
            print(widget.category.category_name); // TODO basildiginda products sayfasina gidilicek. Products sayfasinda geri donme tusu olucak ve basildiginda bu sayfaya geri donulecek. Product sayfasi basilan category kartinin ismini arguman olarak alicak ve firebase querysinde o ismi kullanicak. 
          },
          child: Image(
          image: NetworkImage(widget.category.image_url),
          width: MediaQuery.of(context).size.width / 2.7,
          height: MediaQuery.of(context).size.width / 2.7,
          ),
        ),
        SizedBox(height: 3,),
        Text(widget.category.category_name)
      ],
    );
  }
}
