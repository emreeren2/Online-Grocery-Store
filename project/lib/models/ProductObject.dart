import 'package:cloud_firestore/cloud_firestore.dart';

class ProductObject {
  String productID;

  ProductObject({required this.productID});

  final CollectionReference productCollection = Firestore.instance.collection('products');

    Future<void> addProduct(String category, int price, String product_description, String product_id, String product_name, List<String> product_photos, int quantity, int total_points, int total_votings, List<String> user_comments) async {
    return await productCollection.document(productID).setData({
      'category': category,
      'price': price,
      'product_description': product_description,
      'product_id': product_id,
      'product_name': product_name,
      'product_photos': product_photos,
      'quantity': quantity,
      'total_points': total_points,
      'total_votings': total_votings,
      'user_comments': user_comments
    });
  }
}