// ignore: import_of_legacy_library_into_null_safe
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project_v1/models/UserObject.dart';

class AuthService
{
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // create user object based on FirebaseUser
  UserObject? _userFromFirebaseUser(FirebaseUser user) {
    // ignore: unnecessary_null_comparison
    if(user != null) {
      /*
      return UserObject(userID: user.uid,
                        email: user.email, password: '',
                        name: "deneme", surname: "nabani", type: "",
                        basket: {}, watchlist: {}, products: {});
      */
      return UserObject(userID: user.uid);
    }
    else {
      return null;
    }
  }

  // authentication change user stream
  Stream<UserObject?> get user{ // https://www.youtube.com/watch?v=LkpPEYuqbIY&list=PL4cUxeGkcC9j--TKIdkb3ISfRbJeJYQwC&index=7
    return _auth.onAuthStateChanged
    //.map((FirebaseUser user) => _userFromFirebaseUser(user)); // asagidakiyle bu satirdaki ayni seyler.
      .map(_userFromFirebaseUser);
  }

  // sign-in anon
  Future signInAnon() async { // calisabilmesi zaman alabilecegi icin Future. Bu fonksiyonu cagiriken await yazmak gerekmis galiba
    try {
      AuthResult result = await _auth.signInAnonymously(); // AuthResult UserCredential olarak degismis
      FirebaseUser user = result.user;                                // FirebaseUser, User olarak degismis
      return _userFromFirebaseUser(user);
    }
    catch(e) {
      print(e.toString());
      return null;
    }
  }

  Future<void> getCurrentUserID() async {
    final FirebaseUser user = await _auth.currentUser();
    final uid = user.uid;
    print(uid);
  }



  // sign-in email/password
  Future signInWithEmailAndPassword(String email, String password) async{
    try {
      AuthResult result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      FirebaseUser user = result.user;
      return _userFromFirebaseUser(user);
    }
    catch(e) {
      print(e.toString());
      return null;
    }
  }

  // register email/password
  Future registerWithEmailAndPassword(String email, String password, String name, String surname, String type) async{
    try {
      AuthResult result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      FirebaseUser user = result.user;

      //await UserObject(userID: user.uid, email: email, password: password, name: name, surname: surname, type: type, basket: {}, watchlist: {}, products: {}).addUser(name, surname, email, password);
      await UserObject(userID: user.uid).addUser(email, password, name, surname);
      return _userFromFirebaseUser(user);
    }
    catch(e) {
      print(e.toString());
      return null;
    }
  }


  // sign-out
  Future signOut() async{
    try{
      return await _auth.signOut();
    }
    catch(e){
      print(e.toString());
      return null;
    }
  }

}