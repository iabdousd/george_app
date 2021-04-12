import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      backgroundColor: Theme.of(context).backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(
                top: 32,
                bottom: 24,
              ),
              child: Text(
                'StackedTasks',
                style: Theme.of(context).textTheme.headline4.copyWith(
                      fontFamily: 'logo',
                      color: Theme.of(context).primaryColor,
                    ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(
                horizontal: 16,
              ),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text:
                          'Stacked Tasks is a tool that assists you as you go about achieving your goals and dreams.\n\nThere are three parts to the system:\n',
                    ),
                    TextSpan(
                      text: '1. Planning\n2. Execution\n3. Review',
                      style: Theme.of(context).textTheme.bodyText1.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    TextSpan(
                      text: '\n\nPlanning\n',
                      style: Theme.of(context).textTheme.subtitle1.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    TextSpan(
                      text:
                          '''The Homepage is where you plan your goals. Set an overall date by when you want to achieve your goal and break it down into manageable parts called stacks.
Each stack contains a list of tasks and notes to help you along the way.
To make sure that you prioritize effectively, you can map your tasks to blocks of time on your calendar. These can be one time, recurring or just assigned to a day without specifying the time.
A pro tip is to add maintaining your task management system itself as one of your goals to clear backlog and keep everything current.''',
                    ),
                    TextSpan(
                      text: '\n\nExecution\n',
                      style: Theme.of(context).textTheme.subtitle1.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    TextSpan(
                      text:
                          '''Once you have your tasks lined up for the day, the timer page helps you stay on track. It notifies you about what is currently scheduled and what is coming up. For each activity, you could also provide some feedback which gets added to your notes.''',
                    ),
                    TextSpan(
                      text: '\n\nReview\n',
                      style: Theme.of(context).textTheme.subtitle1.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    TextSpan(
                      text:
                          '''Finally, once things are moving, you get a summarised view of your productivity by day, a feed of your activity by task and a more high level progress summary for each of your goals.
You can celebrate your wins by sharing with your friends and identify patterns where you tend to be less effective and surgically fix it.\n''',
                    ),
                  ],
                  style: Theme.of(context)
                      .textTheme
                      .bodyText1
                      .copyWith(height: 1.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
