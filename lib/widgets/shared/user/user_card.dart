import 'package:flutter/material.dart';

import 'package:stackedtasks/models/UserModel.dart';
import 'package:stackedtasks/providers/cache/cached_image_provider.dart';
import 'package:stackedtasks/widgets/shared/app_action_button.dart';

class UserCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback onDelete;
  const UserCard({
    Key key,
    @required this.user,
    @required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Color(0x10000000),
                blurRadius: 4,
              ),
            ],
            color: Theme.of(context).backgroundColor,
          ),
          margin: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 8,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                margin: const EdgeInsets.symmetric(vertical: 16.0),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: CachedImageProvider(
                      user.photoURL,
                    ),
                    fit: BoxFit.cover,
                  ),
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.fullName,
                        style: Theme.of(context)
                            .textTheme
                            .headline6
                            .copyWith(fontSize: 18),
                      ),
                      Text(
                        user.email,
                        style: Theme.of(context)
                            .textTheme
                            .subtitle1
                            .copyWith(fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        AppActionButton(
          onPressed: onDelete,
          icon: Icons.close,
          label: 'Remove Partner',
          backgroundColor: Colors.red,
          margin: EdgeInsets.only(
            bottom: 8.0,
            left: 16.0,
            right: 16.0,
          ),
        ),
      ],
    );
  }
}
