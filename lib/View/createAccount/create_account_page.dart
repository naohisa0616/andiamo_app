import 'dart:io';
import 'package:andiamo_app/Utils/Function/function_utils.dart';
import 'package:andiamo_app/Utils/Widget/widget_utils.dart';
import 'package:andiamo_app/Utils/Auth/authentication.dart';
import 'package:andiamo_app/Utils/firestore/users.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:andiamo_app/Model/Account.dart';

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  TextEditingController userNameController = TextEditingController();
  TextEditingController userIdController = TextEditingController();
  TextEditingController selfIntroductionController = TextEditingController();
  TextEditingController passController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  File? image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: WidgetUtils.createAppBar('新規登録'),
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
                  foregroundImage: image == null ? null : FileImage(image!),
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
                    decoration: const InputDecoration(hintText: '自己紹介'),
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
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                child: Container(
                  width: 300,
                  child: TextField(
                    controller: emailController,
                    decoration: const InputDecoration(hintText: 'メールアドレス'),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                child: Container(
                  width: 300,
                  child: TextField(
                    controller: passController,
                    decoration: const InputDecoration(hintText: 'パスワード'),
                  ),
                ),
              ),
              SizedBox(height: 50),
              ElevatedButton(
                  onPressed: () async{
                    if (userNameController.text.isNotEmpty &&
                        userIdController.text.isNotEmpty  &&
                        selfIntroductionController.text.isNotEmpty  &&
                        emailController.text.isNotEmpty  &&
                        passController.text.isNotEmpty  &&
                        image != null) {
                        var result = await Authentication.signUp(email: emailController.text, pass: passController.text);
                        if (result is UserCredential) {
                          String imagePath = await FunctionUtils.uploadImage(result.user!.uid, image!);
                          Account newAccount = Account(
                            userID: result.user!.uid,
                            userName: userNameController.text,
                            selfIntroductionText: selfIntroductionController.text,
                            iconImage: imagePath,
                          );
                          var _result = await UserFireStore.setUser(newAccount);
                          if (_result == true) {
                            /// TODO: アカウント完了したことを通知するダイアログ表示
                            Navigator.pop(context);
                          }
                        }
                    }
                  },
                  child: Text('アカウントを作成')
              )
            ],
          ),
        ),
      ),
    );
  }
}
