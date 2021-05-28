import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:stackedtasks/providers/cache/cached_image_provider.dart';
import 'package:stackedtasks/services/user/user_service.dart';
import 'package:stackedtasks/views/user/user_profile.dart';

class TaskFeedHeader extends StatelessWidget {
  final String userID, name, profilePicture;
  const TaskFeedHeader({
    Key key,
    this.userID,
    this.name,
    this.profilePicture,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: InkWell(
        onTap: openUserProfile,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(42.0),
              child: profilePicture != null
                  ? Image(
                      image: CachedImageProvider(profilePicture),
                      fit: BoxFit.cover,
                      width: 42,
                      height: 42,
                    )
                  : SvgPicture.asset(
                      'assets/images/profile.svg',
                      fit: BoxFit.cover,
                      width: 42,
                      height: 42,
                    ),
            ),
            SizedBox(width: 12),
            Text(
              name,
              style: Theme.of(context).textTheme.subtitle1.copyWith(
                    fontWeight: FontWeight.w600,
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
