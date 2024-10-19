import 'package:andiamo_app/Utils/Auth/authentication.dart';
import 'package:andiamo_app/Utils/firestore/users.dart';
import 'package:andiamo_app/View/RecruitmentTimeline/recruitment_time_line_page.dart';
import 'package:andiamo_app/View/createAccount/create_account_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          child: Column(
            children: [
              SizedBox(height: 50,),
              Text('Andiamo', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Container(
                  width: 300,
                  child: TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      hintText: 'メールアドレス'
                    ),
                  ),
                ),
              ),
              Container(
                width: 300,
                child: TextField(
                  controller: passController,
                  decoration: InputDecoration(
                      hintText: 'パスワード'
                  ),
                ),
              ),
              const SizedBox(height: 10),
              RichText(
                  text: TextSpan(
                      style: TextStyle(color: Colors.black),
                      children: [
                        TextSpan(text: 'アカウントを作成していない方は'),
                        TextSpan(text: 'こちら',
                            style: TextStyle(color: Colors.blue),
                            recognizer: TapGestureRecognizer()..onTap = () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateAccountPage()));
                            }
                        ),
                      ]
                  )
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: () async {
                  var result = await Authentication.emailSignIn(email: emailController.text, pass: passController.text);
                  if (result is UserCredential) {
                    var _result = await UserFireStore.getUser(result.user!.uid);
                    if (_result == true) {
                      print('ユーザー情報取得成功');
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => RecruitmentTimelinePage()));
                    }
                  }
                },
                child: const Text('ログイン'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
