import 'dart:io';

import 'package:andiamo_app/Model/Account.dart';
import 'package:andiamo_app/Utils/Auth/authentication.dart';
import 'package:andiamo_app/Utils/Function/function_utils.dart';
import 'package:andiamo_app/Utils/Widget/widget_utils.dart';
import 'package:andiamo_app/Utils/firestore/users.dart';
import 'package:andiamo_app/View/Login/login_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EditAccountPage extends StatefulWidget {
  const EditAccountPage({super.key});

  @override
  State<EditAccountPage> createState() => _EditAccountPageState();
}

class _EditAccountPageState extends State<EditAccountPage> {
  Account? myAccount = Authentication.myAccount;
  TextEditingController userNameController = TextEditingController();
  TextEditingController userIdController = TextEditingController();
  TextEditingController selfIntroductionController = TextEditingController();
  File? image;

  ImageProvider getImage() {
    if(image == null) {
      return const NetworkImage('assets/defaultUserImage.png',);
    } else {
      return FileImage(image!);
    }
  }

  @override
  void initState() {
    super.initState();
    userNameController = TextEditingController(text: myAccount?.userName == null ? "ユーザー名" : myAccount!.userName);
    userIdController = TextEditingController(text: myAccount?.userID == null ? "example" : myAccount!.userID);
    selfIntroductionController = TextEditingController(text: myAccount?.selfIntroductionText == null ? "自己紹介" : myAccount!.selfIntroductionText);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WidgetUtils.createAppBar('プロフィール編集'),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          child: Column(
            children: [
              SizedBox(height: 30),
              GestureDetector(
                onTap: () async {
                  var result = await FunctionUtils.getImageFromGallery();
                  if (result != null) {
                    setState(() {
                      image = File(result.path);
                    });
                  }
                },
                child: CircleAvatar(
                  foregroundImage: getImage(),
                  radius: 40,
                  child: Icon(Icons.add),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                child: Container(
                  width: 300,
                  child: TextField(
                    controller: userNameController,
                    decoration: const InputDecoration(hintText: '名前'),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                child: Container(
                  width: 300,
                  child: TextField(
                    controller: selfIntroductionController,
                    decoration: const InputDecoration(hintText: '自己紹介文'),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                child: Container(
                  width: 300,
                  child: TextField(
                    controller: userIdController,
                    decoration: const InputDecoration(hintText: 'ユーザーID'),
                  ),
                ),
              ),
              const SizedBox(height: 50),
              ElevatedButton(
                  onPressed: () async{
                    if (userNameController.text.isNotEmpty &&
                        userIdController.text.isNotEmpty  &&
                        selfIntroductionController.text.isNotEmpty) {
                      String imagePath = '';
                      if (image == null) {
                        var myAccountImage = myAccount?.iconImage == null ? const NetworkImage('assets/defaultUserImage.png',) : NetworkImage(myAccount!.iconImage);
                        imagePath = myAccountImage as String;
                      } else {
                        var result = FunctionUtils.uploadImage(myAccount?.userID == null ? "example" : myAccount!.userID, image!);
                        imagePath = result as String;
                      }
                      Account updateAccount = Account(
                        userName: userNameController.text,
                        userID: userIdController.text,
                        selfIntroductionText: selfIntroductionController.text,
                        iconImage: imagePath
                      );
                      Authentication.myAccount = updateAccount;
                      var result = await UserFireStore.updateUser(updateAccount);
                      if (result == true) {
                        Navigator.pop(context, true);
                      }
                    }
                  },
                  child: const Text('更新')
              ),
              const SizedBox(height: 50,),
              ElevatedButton(
                  onPressed: () {
                    Authentication.signOut();
                    while(Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                    Navigator.pushReplacement(context, MaterialPageRoute(
                        builder: (context) => LoginPage()
                    ));
                  },
                  child: const Text('ログアウト')
              ),
              const SizedBox(height: 50,),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(foregroundColor: Colors.red),
                  onPressed: () {
                    UserFireStore.deleteUser(myAccount?.userID == null ? "example" : myAccount!.userID);
                    Authentication.deleteAuth();
                    while(Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                    Navigator.pushReplacement(context, MaterialPageRoute(
                        builder: (context) => LoginPage()
                    ));
                  },
                  child: const Text('アカウントを削除')
              ),
            ],
          ),
        ),
      ),
    );
  }
}
