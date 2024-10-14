import 'package:andiamo_app/Model/Account.dart';
import 'package:andiamo_app/Utils/firestore/posts.dart';
import 'package:andiamo_app/Utils/firestore/users.dart';
import 'package:andiamo_app/View/RecruitmentTimeline/Post/post_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../../Model/Recruitment.dart';
import '../account/account_page.dart';
import '../matching/matching_detail_page.dart';

class RecruitmentTimelinePage extends StatefulWidget {
  const RecruitmentTimelinePage({super.key});

  @override
  State<RecruitmentTimelinePage> createState() => _RecruitmentTimelinePageState();
}

class _RecruitmentTimelinePageState extends State<RecruitmentTimelinePage> {
  // 選択中フッターメニューのインデックスを一時保存する用変数
  int selectedIndex = 0;

  // 切り替える画面のリスト
  List<Widget> display = [RecruitmentTimelinePage(), AccountPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text('募集タイムライン', style: TextStyle(color: Colors.black),),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: PostFireStore.posts.orderBy('created_time', descending: true).snapshots(),
        builder: (context, postSnapshot) {
          if (postSnapshot.hasData) {
            List<String> postAccountIds = [];
            postSnapshot.data!.docs.forEach((doc) {
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              if(!postAccountIds.contains(data['post_account_id'])) {
                postAccountIds.add(data['post_account_id']);
              }
            });
            return FutureBuilder<Map<String, Account>?>(
              future: UserFireStore.getPostUserMap(postAccountIds),
              builder: (context, userSnapshot) {
                if(userSnapshot.hasData && userSnapshot.connectionState == ConnectionState.done) {
                  return ListView.builder(
                    itemCount: postSnapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> data = postSnapshot.data!.docs[index].data() as Map<String, dynamic>;
                      Recruitment recruitment = Recruitment(
                          userID: postSnapshot.data!.docs[index].id,
                          recruitmentText: data['context'],
                          recruitmentID: data['post_account_id'],
                          createdTime: data['created_time'],
                          matchingFlag: data['matching_flag'],
                          likeFlag: data['like_flag']
                      );
                      Account postAccount = userSnapshot.data![recruitment.recruitmentID]!;
                      return Container(
                        decoration: BoxDecoration(
                            border: index == 0 ? Border(
                              top: BorderSide(color: Colors.grey, width: 0),
                              bottom: BorderSide(color: Colors.grey, width: 0),
                            ) : Border(bottom: BorderSide(color: Colors.grey, width: 0),)
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              foregroundImage: NetworkImage(postAccount.iconImage),
                            ),
                            Expanded(
                              child: Container(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Text(postAccount.userName, style: const TextStyle(fontWeight: FontWeight.bold),),
                                            Text('@${postAccount.userID}', style: const TextStyle(color: Colors.grey),),
                                          ],
                                        ),
                                        Text(DateFormat('M/d/yy').format(recruitment.createdTime!.toDate()))
                                      ],
                                    ),
                                    Text(recruitment.recruitmentText),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            // ユーザーのいいねのBool値を更新
                                            if (recruitment.likeFlag) {
                                              print('いいね解除');
                                              FirebaseFirestore.instance
                                                  .collection('posts')
                                                  .where('context', isEqualTo: recruitment.recruitmentText)
                                                  .get()
                                                  .then(
                                                    (QuerySnapshot snapshot) => {
                                                  snapshot.docs.forEach((f) {
                                                    print(f.reference.id);
                                                    f.reference.update({'like_flag': false});
                                                  }),
                                                },
                                              );
                                            } else {
                                              print('いいねに更新');
                                              FirebaseFirestore.instance
                                                  .collection('posts')
                                                  .where('context', isEqualTo: recruitment.recruitmentText)
                                                  .get()
                                                  .then(
                                                    (QuerySnapshot snapshot) => {
                                                  snapshot.docs.forEach((f) {
                                                    print(f.reference.id);
                                                    f.reference.update({'like_flag': true});
                                                  }),
                                                },
                                              );
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            foregroundColor: recruitment.likeFlag? Colors.pink : Colors.grey,
                                          ),
                                          icon: recruitment.likeFlag ? const Icon(Icons.favorite) : const Icon(Icons.favorite_border),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            if (recruitment.matchingFlag) {
                                              print('マッチング成立済み');
                                            } else {
                                              // マッチング詳細画面へ遷移
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(builder: (context) => MatchingDetailPage(
                                                      iconImage: postAccount.iconImage,
                                                      userName: postAccount.userName,
                                                      userID: postAccount.userID,
                                                      recruitmentText: recruitment.recruitmentText,
                                                      recruitment: recruitment,
                                                      createdTime: recruitment.createdTime!,))
                                              );
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            foregroundColor: recruitment.matchingFlag? Colors.blueAccent : Colors.grey,
                                          ),
                                          icon: recruitment.matchingFlag ? const Icon(Icons.handshake) : const Icon(Icons.handshake_outlined),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                } else {
                  return Container();
                }
              }
            );
          } else {
            return Container();
          }
        }
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => PostPage()));
        },
        child: Icon(Icons.chat_bubble_outline),
      ),
        // body: display[selectedIndex],
        // bottomNavigationBar: BottomNavigationBar(
        //   items: [
        //     BottomNavigationBarItem(icon: Icon(Icons.home), label: 'ホーム'),
        //     BottomNavigationBarItem(
        //         icon: Icon(Icons.notifications_none), label: 'お知らせ'),
        //     BottomNavigationBarItem(icon: Icon(Icons.people), label: 'マイページ'),
        //   ],
        //   // 現在選択されているフッターメニューのインデックス
        //   currentIndex: selectedIndex,
        //   // フッター領域の影
        //   elevation: 0,
        //   // フッターメニュータップ時の処理
        //   onTap: (int index) {
        //     selectedIndex = index;
        //     setState(() {});
        //   },
        //   // 選択中フッターメニューの色
        //   fixedColor: Colors.red,
        // ));
    );
  }
}
