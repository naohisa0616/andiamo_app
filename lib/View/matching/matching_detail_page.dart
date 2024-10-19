import 'package:andiamo_app/Model/Recruitment.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../RecruitmentTimeline/recruitment_time_line_page.dart';
import 'Dialog/matching_decision_dialog.dart';

class MatchingDetailPage extends StatefulWidget {
  String iconImage;
  String userName;
  String userID;
  String recruitmentText;
  Recruitment recruitment;
  Timestamp createdTime;

  MatchingDetailPage(
      {super.key,
      required this.iconImage,
      required this.userName,
      required this.userID,
      required this.recruitmentText,
      required this.recruitment,
      required this.createdTime});

  @override
  State<MatchingDetailPage> createState() => _MatchingDetailPageState();
}

class _MatchingDetailPageState extends State<MatchingDetailPage> {
  late String iconImage;
  late String userName;
  late String userID;
  late String recruitmentText;
  late Recruitment recruitment;
  late Timestamp createdTime;

  @override
  void initState() {
    super.initState();
    iconImage = widget.iconImage;
    userName = widget.userName;
    userID = widget.userID;
    recruitmentText = widget.recruitmentText;
    recruitment = widget.recruitment;
    createdTime = widget.createdTime;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 2,
          iconTheme: const IconThemeData(color: Colors.black),
          title: const Text(
            'マッチング詳細画面',
            style: TextStyle(color: Colors.black),
          ),
          centerTitle: true,
        ),
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 130),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('以下のマッチングを成立させてよろしいですか？', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 22,
                                foregroundImage: NetworkImage(iconImage),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                userName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              // SizedBox(
                              //   width: 10,
                              // ),
                              // Text(
                              //   '@$userID',
                              //   style: const TextStyle(color: Colors.grey),
                              // ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(recruitmentText),

                      const SizedBox(
                        height: 15,
                      ),
                      Text(DateFormat('M/d/yy')
                          .format(createdTime!.toDate())),

                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => RecruitmentTimelinePage()),
                              );
                            },
                            child: const Text('キャンセル'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              showDialog<void>(
                                  barrierDismissible: false,
                                  context: context,
                                  builder: (_) {
                                    return const MatchingDecisionDialog();
                                  });
                              // マッチングフラグをtrueにする（タイムラインの募集投稿を「成立済み」にする）
                              FirebaseFirestore.instance
                                  .collection('posts')
                                  .where('context', isEqualTo: recruitmentText)
                                  .get()
                                  .then(
                                    (QuerySnapshot snapshot) => {
                                  snapshot.docs.forEach((f) {
                                    print(f.reference.id);
                                    f.reference.update({'matching_flag': true});
                                  }),
                                },
                              );
                            },
                            child: const Text('成立する'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  ),
                ),
            ],
          ),
        )
    );
  }
}
