import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../loading.dart';
import '../theme.dart';

class Comments extends StatefulWidget {
  final String productID;


  Comments({required this.productID});

  @override
  State<Comments> createState() => _CommentsState();
}

class _CommentsState extends State<Comments> {

  final CollectionReference productCollection = Firestore.instance.collection('products');
  String comment = "";
  var _controller = TextEditingController();

  Future<List> getUserComments() async{
    List<String> userComments = [];
    List<bool> userCommentsApprovals = [];

    var docSnapshotProducts = await productCollection.document(widget.productID).get();
    if (docSnapshotProducts.exists) {
      Map<String, dynamic> data = docSnapshotProducts.data;
      // You can then retrieve the value from the Map like this:
      userCommentsApprovals = List.of(data['ucomments_is_approved'].cast<bool>());
      userComments = List.of(data['user_comments'].cast<String>()); //! Burdaki sacma sey olmayinca basket listesi otamatikman fixedlength list oluyo bu yuzden eleman ekleyince exception throwluyo.
    }
    List<String> approvedComments = [];
    for(int i = 0; i < userComments.length; i++){
      if(userCommentsApprovals[i]){
        approvedComments.add(userComments[i]);
      }
    }
    print(userComments);
    print(userCommentsApprovals);
    return approvedComments;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: Text("Comments"),
        centerTitle: true,
        backgroundColor: AppColors.primary,

      ),
    body:  Column(
      children: [
        Expanded(
          flex: 6,
          child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              //color: AppColors.green,
              child: FutureBuilder(
                future: getUserComments(),//Firestore.instance.collection('products/${widget.productID}/users_comments').snapshots(),
                builder: (BuildContext context, AsyncSnapshot snapshot){
                  if(!snapshot.hasData){
                    return Loading();
                  }
                  else{
                    return ListView.builder(    
                      itemCount: snapshot.data.length,
                      itemBuilder: (BuildContext context, int index) { 
                        if(!snapshot.hasData){
                          return Center(child: Text("There isn'y any comment for this product."));
                        }
                        else{
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Material(
                              elevation: 4,
                              child: Container(
                                width: MediaQuery.of(context).size.width - 10,
                                height: 50,
                                color: AppColors.box,
                                child: Center(child: Text(snapshot.data[index])) 
                              ),
                            ),
                          );
                        }
                      },
                    );
                  }
                }
              )
            ),
        ),
        Expanded(
          flex: 1,
          child: Material(
            elevation: 5,
            child: Container(
              color: AppColors.box,
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: TextFormField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: 'Comment'
                        ),
                        onChanged: (val) {
                          setState(() {
                            comment = val;
                          });
                        }, // val => paremeter of given function
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      child: ElevatedButton(
                        onPressed: () async { 
                          if(comment.isNotEmpty){
                            FocusScope.of(context).unfocus();
                            _controller.clear();
                            var comments = [];
                            //! GETTING comments FROM USER COLLECTION
                            var docSnapshotProducts = await productCollection.document(widget.productID).get();
                            if (docSnapshotProducts.exists) {
                              Map<String, dynamic> data = docSnapshotProducts.data;
                              // You can then retrieve the value from the Map like this:
                              comments = List.of(data['user_comments'].cast<String>()); //! Burdaki sacma sey olmayinca basket listesi otamatikman fixedlength list oluyo bu yuzden eleman ekleyince exception throwluyo.
                            }
                            comments.add(comment);
                            await productCollection.document(widget.productID).updateData({
                              'user_comments': comments,
                            });


                            var userCommentsApprovals = [];
                            //! GETTING comments FROM USER COLLECTION
                            if (docSnapshotProducts.exists) {
                              Map<String, dynamic> data = docSnapshotProducts.data;
                              // You can then retrieve the value from the Map like this:
                              userCommentsApprovals = List.of(data['ucomments_is_approved'].cast<bool>());
                            }
                            userCommentsApprovals.add(false);
                            await productCollection.document(widget.productID).updateData({
                              'ucomments_is_approved': userCommentsApprovals,
                            });


                            setState(() {
                              comment = "";
                            });
                          }
                        },
                        child: Center(child: Text("Send")),
                        style: ElevatedButton.styleFrom(
                          enableFeedback: true, // ne oldugunu bilmiyorum bunun.
                          elevation: 12,
                          primary: AppColors.logo_color,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(0)),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        )
      ],
    ),
    );
  }
}




/*
        child: StreamBuilder(
          //stream: Firestore.instance.collection('products/${widget.productID}/user_comments').snapshots(),
          stream: Firestore.instance.collection('products').document(widget.productID).collection('user_comments').snapshots(), //productCollection.snapshots(),
          builder: (BuildContext context, AsyncSnapshot snapshot) { //! AsyncSnapshot<QuerySnapshot> kullaninca userDocument['field'] olayini kullanamiyosun
          //var basket = List.of(data['basket'].cast<String>());
          if(!snapshot.hasData){
            return Center(child: CircularProgressIndicator());
          }
          else{
            print(snapshot.data!.documents.length.toString());
            return ListView.builder(
                itemCount: snapshot.data!.documents.length,
                scrollDirection: Axis.vertical,
                itemBuilder: (BuildContext context, int index) {  
                  if(!snapshot.hasData){
                    return Loading();
                  }
                  else{
                    final doc = snapshot.data!.documents[index];
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                      child: Text('${snapshot.data!.documents['category']}')//Text(doc['user_comments'][index])
                    );
                  }
                  }

            );
          }
        }
        
        ),

*/