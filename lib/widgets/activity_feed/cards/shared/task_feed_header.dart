import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:stackedtasks/providers/cache/cached_image_provider.dart';
import 'package:stackedtasks/services/user/user_service.dart';
import 'package:stackedtasks/views/user/user_profile.dart';

class TaskFeedHeader extends StatelessWidget {
  final String userID, name, profilePicture;
  final DateTime creationDate;
  const TaskFeedHeader({
    Key key,
    @required this.userID,
    @required this.name,
    @required this.profilePicture,
    @required this.creationDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: InkWell(
        onTap: openUserProfile,
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(42.0),
              child: profilePicture != null
                  ? Image(
                      image: CachedImageProvider(profilePicture),
                      fit: BoxFit.cover,
                      width: 32,
                      height: 32,
                    )
                  : SvgPicture.asset(
                      'assets/images/profile.svg',
                      fit: BoxFit.cover,
                      width: 32,
                      height: 32,
                    ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    name ?? '',
                    style: TextStyle(
                      color: Color(0xFF3B404A),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    DateFormat('EEE, dd MMM').format(creationDate),
                    style: TextStyle(
                      color: Color(0xFFB2B5C3),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void openUserProfile() async {
    final user = await UserService.getUser(userID);
    Get.to(
      () => UserProfileView(
        user: user,
      ),
    );
  }
}
