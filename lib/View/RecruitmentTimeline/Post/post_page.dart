import 'package:andiamo_app/Model/Recruitment.dart';
import 'package:andiamo_app/Utils/Auth/authentication.dart';
import 'package:andiamo_app/Utils/GenerateUUID/uuid.dart';
import 'package:andiamo_app/Utils/firestore/posts.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PostPage extends StatefulWidget {
  const PostPage({super.key});

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  TextEditingController contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text('新規募集投稿', style: TextStyle(color: Colors.black),),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: contentController,
            ),
            SizedBox(height: 20),
            ElevatedButton(
                onPressed: () async {
                  print('textの値: $contentController.text');
                  if(contentController.text.isEmpty) {
                    print('TextEditingの値が $contentController.text');
                    return;
                  }
                  print('Authentication.myAccount!.userIDのnullチェック前');
                  if(Authentication.myAccount?.userID == null) {
                    print('myAccountのuserIDの値が $Authentication.myAccount!.userID');
                    return;
                  }
                  print('Recruitmentインスタンス生成前');
                  Recruitment newRecruitment = Recruitment(
                    postID: GenerateUUID.generateUUID(),
                    recruitmentText: contentController.text,
                    recruitmentID: Authentication.myAccount!.userID,
                  );
                  print('Recruitment取得結果: $newRecruitment');
                  var result = await PostFireStore.addPost(newRecruitment);
                  print('addPost結果: $result');
                  if(result == true) {
                    Navigator.pop(context);
                  }
                },
                child: Text('投稿')
            )
          ],
        ),
      ),
    );
  }
}
