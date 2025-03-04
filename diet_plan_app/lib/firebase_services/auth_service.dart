
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseServices{

  FirebaseAuth _auth= FirebaseAuth.instance;
  Future<User?>signUpMethod(String email, String password  )
  async {
    try{
        UserCredential credential = 
     await   _auth.createUserWithEmailAndPassword(
          email: email, 
          password: password);
          return credential.user;
    }
    catch(e){
      print('failed to signup user');
    }
    return null;
  }

   
  Future<User?>signInMethod(String email, String password  )
  async {
    try{
        UserCredential credential = 
     await   _auth.signInWithEmailAndPassword(
          email: email, 
          password: password);
          return credential.user;
    }
    catch(e){
      print('failed to signin user');
    }
    return null;
  }

}