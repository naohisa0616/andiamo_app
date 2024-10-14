import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../RecruitmentTimeline/recruitment_time_line_page.dart';

class MatchingDecisionDialog extends StatelessWidget {
  const MatchingDecisionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const FittedBox(
          fit: BoxFit.fitWidth,
          child: Text('マッチングが成立しました！！')
      ),
      actions: <Widget>[
        GestureDetector(
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('OK', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
              ),
            ],
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RecruitmentTimelinePage()),
            );
          },
        )
      ],
    );
  }
}
