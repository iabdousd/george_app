import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share/share.dart';
import 'package:stackedtasks/models/Task.dart';
import 'package:stackedtasks/models/UserModel.dart';
import 'package:stackedtasks/services/user/user_service.dart';

class TaskRepository {
  static Future<UserModel> inviteTaskPartnerByPhone(
      Task task, String phoneNumber) async {
    final user = await UserService.getUserByPhone(
      phoneNumber.replaceAll(' ', ''),
    );
    if (user != null) {
      return user;
    } else {
      await showDialog(
        context: Get.context,
        builder: (context) {
          return AlertDialog(
            title: Text('User not found'),
            content: Text(
                'The selected contact doesn\'t have an account associated to it, would you like to invite them ?'),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                    Colors.red[400],
                  ),
                ),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await Share.share(
                    'Hey. I\'m using the Stacked Tasks app to get more done. Could you please help me out by being my accountability buddy? stackedtasks.com',
                  );
                },
                child: Text('Invite'),
              ),
            ],
          );
        },
      );
    }
    return null;
  }
}
