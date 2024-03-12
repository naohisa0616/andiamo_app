class User {
  String id;
  String name;
  String iconImage;
  String selfIntroduction;
  bool liked;
  String pastPosts;
  bool matchingDecision;
  DateTime? createdTime;
  DateTime? updatedTime;

  User({this.id = '', this.name = '', this.iconImage = '',
    this.selfIntroduction = '', this.liked = false, this.pastPosts = '',
    this.matchingDecision = false, this.createdTime, this.updatedTime,
  });
}