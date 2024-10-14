import 'package:andiamo_app/Utils/Auth/authentication.dart';
import 'package:andiamo_app/Utils/firestore/posts.dart';
import 'package:andiamo_app/Utils/firestore/users.dart';
import 'package:andiamo_app/View/account/edit_account_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../Model/Account.dart';
import '../../Model/Recruitment.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  Account? myAccount = Authentication.myAccount;

  Account account = Account(
    userID: 'o12WhCzkYTbA6NQLWUz6TmukLeV2',
    userName: 'test06',
    selfIntroductionText: 'test',
    iconImage: 'https://firebasestorage.googleapis.com/v0/b/andiamo-2269f.appspot.com/o/o12WhCzkYTbA6NQLWUz6TmukLeV2?alt=media&token=3fc683d7-8cdc-4b14-bd64-07d0b866197b'
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(left: 15, right: 15, top: 15),
                  height: 200,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 32,
                                foregroundImage: myAccount?.iconImage == null ? const NetworkImage('assets/defaultUserImage.png',) : NetworkImage(myAccount!.iconImage),
                              ),
                              SizedBox(width: 10,),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(myAccount?.userName == null ? "ユーザー名" : myAccount!.userName, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                                  Text('@${myAccount?.userName == null ? "ユーザー名" : myAccount!.userName}', style: TextStyle(color: Colors.grey),),
                                ],
                              )
                            ],
                          ),
                          OutlinedButton(
                              onPressed: () async {
                                  var result = await Navigator.push(context, MaterialPageRoute(builder: (context) => EditAccountPage()));
                                  if(result == true) {
                                    setState(() {
                                      myAccount = Authentication.myAccount == null ? myAccount : Authentication.myAccount!;
                                    });
                                  }
                                },
                              child: Text('プロフィール編集'))
                        ],
                      ),
                      SizedBox(height: 15,),
                      Text(myAccount?.selfIntroductionText == null ? "自己紹介" : myAccount!.selfIntroductionText)
                    ],
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(
                      color: Colors.blue, width: 3
                    ))
                  ),
                  child: Text('過去の投稿', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),),
                ),
                Expanded(child: StreamBuilder<QuerySnapshot>(
                    stream: UserFireStore.users.doc(myAccount?.userID).collection('my_posts').orderBy('created_time', descending: true).snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List<String> myPostIds = List.generate(snapshot.data!.docs.length, (index) {
                        return snapshot.data!.docs[index].id;
                      });
                      return FutureBuilder<List<Recruitment>?>(
                        future: PostFireStore.getPostsFromIds(myPostIds),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return ListView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: snapshot.data!.length,
                                itemBuilder: (context, index){
                                  Recruitment recruitment = snapshot.data![index];
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
                                          foregroundImage: myAccount?.iconImage == null ? const NetworkImage('assets/defaultUserImage.png',) : NetworkImage(myAccount!.iconImage),
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
                                                        Text(myAccount?.userName == null ? "ユーザー名" : myAccount!.userName, style: const TextStyle(fontWeight: FontWeight.bold),),
                                                        Text('@${myAccount?.userID == null ? "example" : myAccount!.userID}', style: const TextStyle(color: Colors.grey),),
                                                      ],
                                                    ),
                                                    Text(DateFormat('M/d/yy').format(recruitment.createdTime!.toDate()))
                                                  ],
                                                ),
                                                Text(recruitment.recruitmentText)
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                });
                          } else {
                            return Container();
                          }
                        }
                      );
                    } else {
                      return Container();
                    }
                  }
                )
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
