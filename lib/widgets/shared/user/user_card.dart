import 'package:flutter/material.dart';

import 'package:stackedtasks/models/UserModel.dart';
import 'package:stackedtasks/providers/cache/cached_image_provider.dart';

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
    return Stack(
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
            children: [
              Container(
                width: 44,
                height: 44,
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
                  child: Text(
                    user.fullName,
                    style: Theme.of(context)
                        .textTheme
                        .headline6
                        .copyWith(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 8,
          right: 18,
          child: GestureDetector(
            onTap: onDelete,
            child: Icon(
              Icons.close,
              color: Colors.red[700],
            ),
          ),
        ),
      ],
    );
  }
}
