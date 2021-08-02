import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stackedtasks/constants/theme.dart';

// ignore: non_constant_identifier_names
Widget AppAppBar({
  @required BuildContext context,
  Widget customTitle,
  Widget leading,
  Widget trailing,
  Widget bottom,
  bool autoImplifyLeading: false,
  bool centerTitle: true,
  Color leadingColor,
  BoxDecoration decoration,
  Size preferredSize: const Size.fromHeight(56),
}) =>
    PreferredSize(
      child: Container(
        decoration: decoration ??
            BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomRight,
                end: Alignment.topLeft,
                colors: [
                  kSecondaryColor,
                  kPrimaryColor,
                ],
              ),
            ),
        child: Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: centerTitle && leading == null
                    ? MainAxisAlignment.center
                    : centerTitle
                        ? MainAxisAlignment.spaceBetween
                        : MainAxisAlignment.start,
                children: [
                  if (autoImplifyLeading && leading == null)
                    DefaultTextStyle(
                      style: Theme.of(context).textTheme.headline6.copyWith(
                            color: leadingColor ?? Color(0xFFB2B5C3),
                            fontSize: 17.0,
                          ),
                      child: InkWell(
                        onTap: Navigator.of(context).pop,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: SvgPicture.asset(
                                  'assets/images/icons/back.svg',
                                  color: leadingColor,
                                ),
                              ),
                              Text(
                                'Back',
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else if (leading != null)
                    leading,
                  Expanded(
                    child: DefaultTextStyle(
                      style: Theme.of(context).textTheme.headline6.copyWith(
                            color: Theme.of(context).backgroundColor,
                            fontSize: 17.0,
                          ),
                      child: Align(
                        alignment: centerTitle
                            ? Alignment.center
                            : Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.all(13.5),
                          child: customTitle ??
                              SvgPicture.asset(
                                'assets/images/logo.svg',
                              ),
                        ),
                      ),
                    ),
                  ),
                  if (trailing != null)
                    trailing
                  else if (leading != null && centerTitle)
                    Opacity(
                      opacity: 0,
                      child: IgnorePointer(
                        ignoring: true,
                        child: leading,
                      ),
                    ),
                ],
              ),
              if (bottom != null) bottom,
            ],
          ),
        ),
      ),
      preferredSize: preferredSize,
    );
