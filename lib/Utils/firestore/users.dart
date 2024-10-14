import 'package:andiamo_app/Utils/Auth/authentication.dart';
import 'package:andiamo_app/Utils/firestore/posts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../Model/Account.dart';

class UserFireStore {
  static final _firestoreInstance = FirebaseFirestore.instance;
  static final CollectionReference users = _firestoreInstance.collection('users');

  static Future<dynamic> setUser(Account user) async {
    try {
      await users.doc(user.userID).set({
        'name': user.userName,
        'user_id': user.userID,
        'self_Introduction': user.selfIntroductionText,
        'image_path': user.iconImage,
      });
      print('新規ユーザー作成完了');
      return true;
    } on FirebaseException catch(e) {
      print('新規ユーザー作成エラー: $e');
      return false;
    }
  }

  static Future<dynamic> getUser(String uid) async {
      try {
        DocumentSnapshot documentSnapshot = await users.doc(uid).get();
        Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
        Account myAccount = Account(
          userID: data['user_id'],
          userName: data['name'],
          selfIntroductionText: data['self_Introduction'],
          iconImage: data['image_path'],
        );
        Authentication.myAccount = myAccount;
        print('ユーザー取得完了');
        return true;
      } on FirebaseException catch(e) {
        print('ユーザー取得エラー: $e');
        return false;
      }
  }

  static Future<dynamic> updateUser(Account updateAccount) async {
    try {
      await users.doc(updateAccount.userID).update({
        'name': updateAccount.userName,
        'image_path': updateAccount.iconImage,
        'user_id': updateAccount.userID,
        'self_Introduction': updateAccount.selfIntroductionText
      });
      print('ユーザー情報の更新完了');
      return true;
    } on FirebaseException catch(e) {
      print('ユーザー情報の更新エラー: $e');
      return false;
    }
  }

  static Future<Map<String, Account>?> getPostUserMap(List<String> accountIds) async {
    Map<String, Account> map = {};
    try {
      await Future.forEach(accountIds, (String accountId) async{
        var doc = await users.doc(accountId).get();
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        Account postAccount = Account(
          userID: data['user_id'],
          userName: data['name'],
          iconImage: data['image_path'],
          selfIntroductionText: data['self_Introduction'],
        );
        map[accountId] = postAccount;
      });
      print('投稿ユーザーの情報取得完了');
      return map;
    } on FirebaseException catch(e) {
      print('投稿ユーザーの情報取得エラー：　$e');
      return null;
    }
  }

  static Future<dynamic> deleteUser(String accountId) async {
    await users.doc(accountId).delete();
    PostFireStore.deletePosts(accountId);
  }
}