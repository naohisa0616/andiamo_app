import 'package:cloud_firestore/cloud_firestore.dart';

class Recruitment {
  String recruitmentID;
  String postID;
  String userID;
  String replyID;
  String hashTagID;
  String recruitmentText;
  Timestamp? createdTime;
  bool matchingFlag;
  bool likeFlag;

  Recruitment({this.recruitmentID = '', this.postID = '', this.userID = '', this.replyID = '',
    this.hashTagID = '', this.recruitmentText = '', this.createdTime,
    this.matchingFlag = false, this.likeFlag = false});
}