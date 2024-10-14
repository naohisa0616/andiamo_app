import 'dart:ffi';

import 'package:andiamo_app/Model/Recruitment.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class PostFireStore {
  static final _firestoreInstance = FirebaseFirestore.instance;
  static final CollectionReference posts = _firestoreInstance.collection('posts');
  static Recruitment? recruitment;

  static Future<dynamic> addPost(Recruitment newPost) async {
    try {
      final CollectionReference _userPosts = _firestoreInstance.collection('users').doc(newPost.recruitmentID).collection('my_posts');
      var result = await posts.add({
        'context': newPost.recruitmentText,
        'post_account_id': newPost.recruitmentID,
        'post_id': newPost.postID,
        'like_flag': false,
        'matching_flag': false,
        'created_time': Timestamp.now()
      });
      _userPosts.doc(result.id).set({
        'post_id': result.id,
        'created_time': Timestamp.now()
      });
      print('投稿完了');
      return true;
    } on FirebaseException catch(e) {
      print('投稿エラー: $e');
      return false;
    }
  }

  static Future<dynamic> updateLikeFlagPosts(Recruitment recruitment, bool isFavorite) async {
    try {
      _firestoreInstance.collection('posts').doc(recruitment.postID).update({'like_flag': isFavorite});
      print('ユーザー募集投稿のいいねフラグ更新完了: $isFavorite');
      return true;
    } on FirebaseException catch(e) {
      print('ユーザー募集投稿のいいねフラグ更新失敗: $e');
      return false;
    }
  }

  static Future<List<Recruitment>?> getPostsFromIds(List<String> ids) async {
    List<Recruitment> postList = [];
    try {
      await Future.forEach(ids, (String id) async {
        var doc = await posts.doc(id).get();
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        Recruitment post = Recruitment(
          recruitmentID: doc.id,
          recruitmentText: data['recruitmentText'],
          likeFlag: data['like_flag'],
          createdTime: data['created_time']
        );
        postList.add(post);
      });
      print('自分の投稿を取得完了');
      return postList;
    } on FirebaseException catch(e) {
      print('自分の投稿取得エラー: $e');
      return null;
    }
  }

  static Future<dynamic> deletePosts(String accountId) async {
    final CollectionReference _userPosts = _firestoreInstance.collection('users').doc('accountId').collection('my_posts');
    var snapshot = await _userPosts.get();
    snapshot.docs.forEach((doc) async {
      await posts.doc(doc.id).delete();
      _userPosts.doc(doc.id).delete();
    });
  }
}