import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stackedtasks/config/extensions/hex_color.dart';
import 'package:stackedtasks/constants/models/inbox_item.dart';
import 'package:stackedtasks/constants/user.dart';
import 'package:stackedtasks/models/Task.dart';
import 'package:stackedtasks/models/UserModel.dart';
import 'package:stackedtasks/repositories/inbox/inbox_repository.dart';
import 'package:stackedtasks/services/feed-back/flush_bar.dart';
import 'package:stackedtasks/services/feed-back/loader.dart';
import 'package:stackedtasks/services/user/user_service.dart';
import 'package:stackedtasks/widgets/forms/date_picker.dart';
import 'package:stackedtasks/widgets/forms/time_picker.dart';
import 'package:stackedtasks/widgets/shared/app_action_button.dart';
import 'package:stackedtasks/widgets/shared/app_appbar.dart';
import 'package:stackedtasks/constants/models/task.dart' as task_constants;
import 'package:stackedtasks/widgets/shared/app_expansion_tile.dart';
import 'package:stackedtasks/widgets/shared/app_text_field.dart';
import 'package:stackedtasks/widgets/shared/card/app_button_card.dart';
import 'package:stackedtasks/widgets/shared/user/user_card.dart';

class SaveTaskPage extends StatefulWidget {
  final String goalRef;
  final String stackRef;
  final String goalTitle;
  final String stackTitle;

  final String stackColor;
  final Task task;
  final bool addingPartner;
  SaveTaskPage(
      {Key key,
      @required this.goalRef,
      @required this.stackRef,
      @required this.goalTitle,
      @required this.stackTitle,
      @required this.stackColor,
      this.addingPartner: false,
      this.task})
      : super(key: key);

  @override
  _SaveTaskPageState createState() => _SaveTaskPageState();
}

class _SaveTaskPageState extends State<SaveTaskPage> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _weeksCountController = TextEditingController();
  TextEditingController _dayInMonthController = TextEditingController();
  TextEditingController _monthsCountController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  List<int> selectedWeekDays = [];

  bool loadingPartners = true;
  List<UserModel> partners = [];

  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now().add(Duration(days: 1));
  DateTime startTime = DateTime(
    1970,
    1,
    1,
    DateTime.now().hour,
    DateTime.now().minute,
  );
  DateTime endTime = DateTime(
    1970,
    1,
    1,
    DateTime.now().hour + 1,
    DateTime.now().minute,
  );
  Map<int, String> weekDays = {
    0: 'Mon',
    1: 'Tue',
    2: 'Wed',
    3: 'Thu',
    4: 'Fri',
    5: 'Sat',
    6: 'Sun',
  };

  bool anyTime = false;
  String repetition = 'No repetition';

  _submitTask() async {
    if (!_formKey.currentState.validate()) return;
    if (repetition == 'weekly' && (selectedWeekDays ?? []).length == 0) {
      await showFlushBar(
        title: 'Required field',
        message: 'Please select the days of week first.',
        success: false,
      );
      return;
    }
    toggleLoading(state: true);
    if (repetition == 'No repetition') {
      endDate = startDate;
      if (DateTime(endDate.year, endDate.month, endDate.day, endTime.hour,
              endTime.minute)
          .isBefore(DateTime(startDate.year, startDate.month, startDate.day,
              startTime.hour, startTime.minute))) {
        endDate = DateTime(
          startDate.year,
          startDate.month,
          startDate.day + 1,
        );
      }
    }
    if (DateTime(endDate.year, endDate.month, endDate.day, endTime.hour,
            endTime.minute)
        .isBefore(DateTime.now())) {
      await toggleLoading(state: false);
      await showFlushBar(
        title: 'Malformat dates',
        message:
            'With the selected dates this date won\'t occurred once! Please make sure you entered the correct dates/times',
        success: false,
      );
      return;
    }

    Task task = Task(
      id: widget.task?.id,
      userID: getCurrentUser().uid,
      partnersIDs: partners.map((e) => e.uid).toList(),
      goalRef: widget.goalRef,
      stackRef: widget.stackRef,
      goalTitle: widget.goalTitle,
      stackTitle: widget.stackTitle,
      repetition: TaskRepetition(
        type: repetition,
        weeksCount: int.tryParse(_weeksCountController.text),
        selectedWeekDays: (selectedWeekDays ?? [])..sort(),
        monthsCount: int.tryParse(_monthsCountController.text),
        dayNumber: int.tryParse(_dayInMonthController.text),
      ),
      title: _titleController.text,
      description: _descriptionController.text,
      creationDate: DateTime.now(),
      startDate: DateTime(startDate.year, startDate.month, startDate.day),
      endDate: DateTime(endDate.year, endDate.month, endDate.day),
      startTime: startTime,
      endTime: endTime,
      status: 0,
      anyTime: anyTime,
      stackColor: widget.stackColor,
      donesHistory: widget.task?.donesHistory ?? [],
      taskNotes: widget.task?.taskNotes ?? [],
      oldDueDatesCount: widget.task?.dueDates?.length ?? 0,
      oldDuration: widget.task != null
          ? widget.task.endTime.difference(widget.task.startTime)
          : Duration(),
    );
    await task.save(
      updateSummaries: true,
    );
    if (widget.goalRef == 'inbox' && widget.stackRef == 'inbox') {
      final res = await InboxRepository.saveInboxItem(
        INBOX_TASK_ITEM_TYPE,
        reference: task.id,
      );
      if (!res.status) {
        await toggleLoading(state: false);
        await showFlushBar(
          title: 'Error',
          message:
              'An error occurred while adding your task to the inbox. Please try again later.',
          success: false,
        );
        return;
      }
    }
    toggleLoading(state: false);
    Navigator.of(context).pop();
    showFlushBar(
      title: 'Task added successfully!',
      message: 'You can now see your task in tasks list.',
    );
  }

  _pickStartTime(DateTime pickedTime) async {
    setState(() {
      startTime = pickedTime;
    });
  }

  _pickEndTime(DateTime pickedTime) async {
    setState(() {
      endTime = pickedTime;
    });
  }

  _pickStartDateOnly(DateTime pickedDate) async {
    setState(() {
      startDate = pickedDate;
      if (pickedDate.isAfter(endDate))
        endDate = pickedDate.add(Duration(days: 1));
    });
  }

  _pickEndDateOnly(DateTime pickedDate) async {
    setState(() {
      endDate = pickedDate;
    });
  }

  @override
  void initState() {
    super.initState();
    anyTime = widget.goalRef == 'inbox';
    if (widget.task != null) {
      _titleController.text = widget.task.title ?? '';
      _descriptionController.text = widget.task.description ?? '';
      startDate = DateTime(
        widget.task.startDate.year,
        widget.task.startDate.month,
        widget.task.startDate.day,
        0,
        0,
      );
      endDate = DateTime(
        widget.task.endDate.year,
        widget.task.endDate.month,
        widget.task.endDate.day,
        0,
        0,
      );
      startTime = DateTime(
        1970,
        1,
        1,
        widget.task.startTime.hour,
        widget.task.startTime.minute,
      );
      endTime = DateTime(
        1970,
        1,
        1,
        widget.task.endTime.hour,
        widget.task.endTime.minute,
      );

      anyTime = widget.task.anyTime;
      if (widget.task.repetition != null) {
        repetition = widget.task.repetition.type ?? repetition;
        _weeksCountController.text =
            (widget.task.repetition.weeksCount ?? '').toString();
        selectedWeekDays = widget.task.repetition.selectedWeekDays ?? [];
        _dayInMonthController.text =
            (widget.task.repetition.dayNumber ?? '').toString();
        _monthsCountController.text =
            (widget.task.repetition.monthsCount ?? '').toString();
      }
    }
    _init();
  }

  _init() async {
    if (widget.task?.partnersIDs != null &&
        widget.task.partnersIDs.isNotEmpty) {
      final partnersQuery = await FirebaseFirestore.instance
          .collection(USERS_KEY)
          .where(
            USER_UID_KEY,
            whereIn: widget.task.partnersIDs,
          )
          .get();
      partners = partnersQuery.docs
          .map(
            (e) => UserModel.fromMap(e.data()),
          )
          .toList();
    }
    if (widget.addingPartner) {
      addPartner();
    }
    setState(() {
      loadingPartners = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appAppBar(
        title: widget.task != null ? 'Task details' : 'New Task',
        actions: [
          TextButton(
            onPressed: _submitTask,
            child: Text(
              'Done',
              style: Theme.of(context).textTheme.subtitle1.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ],
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).backgroundColor,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Task title',
                    hintText: 'The title of the task',
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 20.0,
                      horizontal: 20.0,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(width: 1),
                    ),
                  ),
                  validator: (t) {
                    if (t.isEmpty) return 'The task title is required';
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                ),
              ),
              if (widget.goalRef != 'inbox')
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).backgroundColor,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  child: TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Task description',
                      hintText: 'The description of the task',
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 20.0,
                        horizontal: 20.0,
                      ),
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(width: 1),
                      ),
                    ),
                    minLines: 5,
                    maxLines: 7,
                  ),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Any time:',
                    style: Theme.of(context).textTheme.subtitle1.copyWith(
                          fontSize: 18.0,
                          color: Theme.of(context)
                              .textTheme
                              .subtitle1
                              .color
                              .withOpacity(.75),
                        ),
                  ),
                  Switch(
                    value: anyTime,
                    onChanged: (value) => setState(() => anyTime = value),
                    activeColor: HexColor.fromHex(widget.stackColor),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: TimePickerWidget(
                      title: 'Start time',
                      active: !anyTime,
                      initialTime: DateTime(
                        1970,
                        1,
                        1,
                        startTime.hour,
                        startTime.minute,
                      ),
                      color: widget.stackColor,
                      onSubmit: _pickStartTime,
                    ),
                  ),
                  Expanded(
                    child: TimePickerWidget(
                      title: 'End time',
                      active: !anyTime,
                      initialTime: DateTime(
                        1970,
                        1,
                        1,
                        endTime.hour,
                        endTime.minute,
                      ),
                      color: widget.stackColor,
                      onSubmit: _pickEndTime,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: DatePickerWidget(
                      key: const Key('start_date'),
                      title: 'Start date',
                      color: widget.stackColor,
                      onSubmit: _pickStartDateOnly,
                      selectedDate: DateTime(
                        startDate.year,
                        startDate.month,
                        startDate.day,
                        startTime.hour,
                        startTime.minute,
                      ),
                      endDate:
                          // repetition == 'No repetition'?
                          DateTime.now().add(Duration(days: 365))
                      // : DateTime(
                      //     endDate.year,
                      //     endDate.month,
                      //     endDate.day,
                      //     endTime.hour,
                      //     endTime.minute,
                      //   )
                      ,
                      dateFormat: 'dd MMMM yyyy',
                    ),
                  ),
                  if (repetition != 'No repetition')
                    Expanded(
                      child: DatePickerWidget(
                        key: const Key('end_date'),
                        title: 'End date',
                        color: widget.stackColor,
                        startDate: DateTime(
                          startDate.year,
                          startDate.month,
                          startDate.day,
                          startTime.hour,
                          startTime.minute,
                        ),
                        onSubmit: _pickEndDateOnly,
                        selectedDate: DateTime(
                          endDate.year,
                          endDate.month,
                          endDate.day,
                          endTime.hour,
                          endTime.minute,
                        ),
                        dateFormat: 'dd MMMM yyyy',
                        margin: EdgeInsets.only(top: 8.0),
                      ),
                    ),
                ],
              ),
              SizedBox(
                height: 12,
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 12.0),
                child: DropdownButtonFormField(
                  onChanged: (value) {
                    print(value);
                    setState(() {
                      repetition = value;
                    });
                  },
                  value: repetition,
                  decoration: InputDecoration(
                    labelText: 'Task repetition:',
                    prefixIcon: Icon(
                      repetition == 'No repetition'
                          ? Icons.repeat_one
                          : Icons.repeat,
                      size: 24,
                      color: HexColor.fromHex(widget.stackColor),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(width: 1),
                    ),
                  ),
                  items: ['No repetition', ...task_constants.REPETITION_OPTIONS]
                      .map(
                        (e) => DropdownMenuItem(
                          child: Text(
                              e.substring(0, 1).toUpperCase() + e.substring(1)),
                          value: e == 'none' ? null : e,
                        ),
                      )
                      .toList(),
                ),
              ),
              if (repetition == 'weekly')
                Container(
                  child: Column(
                    children: [
                      Container(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Evey  ',
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle1
                                  .copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Container(
                              width: 44,
                              height: 44,
                              child: TextFormField(
                                validator: (t) => t.isEmpty ? '' : null,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 0.0,
                                    horizontal: 4.0,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: BorderSide(width: 1),
                                  ),
                                  errorStyle: TextStyle(height: 0),
                                  counterText: '',
                                ),
                                scrollPadding: EdgeInsets.zero,
                                textAlign: TextAlign.center,
                                controller: _weeksCountController,
                                maxLength: 1,
                              ),
                            ),
                            Text(
                              '  weeks on',
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle1
                                  .copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      GridView.count(
                        crossAxisCount: 4,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        childAspectRatio: 3,
                        padding: EdgeInsets.all(8.0),
                        children: weekDays.keys
                            .map((key) => Container(
                                  child: Row(
                                    children: [
                                      Checkbox(
                                          value: selectedWeekDays.contains(key),
                                          onChanged: (value) => setState(() =>
                                              value
                                                  ? selectedWeekDays.add(key)
                                                  : selectedWeekDays
                                                      .remove(key))),
                                      Text(weekDays[key]),
                                    ],
                                  ),
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                )
              else if (repetition == 'monthly')
                Container(
                  child: Row(
                    // mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Day:  ',
                        style: Theme.of(context).textTheme.subtitle1.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Container(
                        width: 44,
                        height: 44,
                        child: TextFormField(
                          validator: (t) =>
                              t.isEmpty ? 'This field is required' : null,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 4.0,
                              horizontal: 4.0,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide(width: 1),
                            ),
                            errorStyle: TextStyle(height: 0),
                            counterText: '',
                          ),
                          scrollPadding: EdgeInsets.zero,
                          textAlign: TextAlign.center,
                          controller: _dayInMonthController,
                          maxLength: 2,
                        ),
                      ),
                      Text(
                        '  of every:  ',
                        style: Theme.of(context).textTheme.subtitle1.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Container(
                        width: 44,
                        height: 44,
                        child: TextFormField(
                          validator: (t) =>
                              t.isEmpty ? 'This field is required' : null,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 4.0,
                              horizontal: 4.0,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide(width: 1),
                            ),
                            errorStyle: TextStyle(height: 0),
                            counterText: '',
                          ),
                          scrollPadding: EdgeInsets.zero,
                          textAlign: TextAlign.center,
                          controller: _monthsCountController,
                          maxLength: 2,
                        ),
                      ),
                      Text(
                        '  months',
                        style: Theme.of(context).textTheme.subtitle1.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),

              // PARTNERS
              if (loadingPartners)
                Center(
                  child: LoadingWidget(),
                )
              else
                AppExpansionTile(
                  title: Row(
                    children: [
                      Text('Partners'),
                      SizedBox(width: 8),
                      Badge(
                        padding: EdgeInsets.all(8),
                        badgeColor: HexColor.fromHex(widget.stackColor),
                        animationType: BadgeAnimationType.fade,
                        badgeContent: Text(
                          '${partners.length}',
                          style: TextStyle(
                            color: Theme.of(context).backgroundColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  color: HexColor.fromHex(widget.stackColor).darken(),
                  trailing: Icon(
                    Icons.group_rounded,
                    size: 28,
                  ),
                  children: [
                    ...partners.map(
                      (e) => UserCard(
                        user: e,
                        onDelete: () => setState(() {
                          partners.remove(e);
                        }),
                      ),
                    ),
                    AppActionButton(
                      onPressed: addPartner,
                      margin: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      backgroundColor:
                          HexColor.fromHex(widget.stackColor).darken(),
                      label: 'Add Partner',
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  void addPartner() async {
    String addType;
    bool loading = false;
    UserModel foundUser;
    final emailFieldController = TextEditingController();

    void searchByEmail(StateSetter smallSetState) async {
      foundUser = null;
      if (getCurrentUser().email.toLowerCase() ==
          emailFieldController.text.trim().toLowerCase()) {
        smallSetState(() {
          loading = false;
          foundUser = null;
        });
        showFlushBar(
          title: 'Hmm..',
          message: 'You can\'t add your self as partner !',
          success: false,
        );
        return;
      }
      smallSetState(() => loading = true);
      final userQuery = await FirebaseFirestore.instance
          .collection(USERS_KEY)
          .where(
            USER_EMAIL_KEY,
            isEqualTo: emailFieldController.text,
          )
          .get();
      if (userQuery.size > 0) {
        final user = UserModel.fromMap(
          userQuery.docs.first.data(),
        );
        if (partners
            .where((element) => element.email == user.email)
            .isNotEmpty) {
          showFlushBar(
            title: 'Already Present',
            message:
                'The sought user is already present in your partners list.',
            success: false,
          );
          smallSetState(() {
            loading = false;
            foundUser = null;
          });
        } else
          smallSetState(() {
            loading = false;
            foundUser = user;
          });
      } else {
        showFlushBar(
          title: 'Not Found',
          message: 'Couldn\'t found a user with the selected email.',
          success: false,
        );
        smallSetState(() {
          loading = false;
          foundUser = null;
        });
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: StatefulBuilder(
            builder: (context, smallSetState) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: EdgeInsets.only(
                    top: 16,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Add Partner',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ),
                // AppButtonCard(
                //   icon: Icon(
                //     Icons.person_outline_rounded,
                //     size: 44.0,
                //   ),
                //   text: 'Add By Username',
                //   onPressed: () {
                //     //
                //   },
                //   margin: EdgeInsets.symmetric(
                //     horizontal: 16,
                //     vertical: 8,
                //   ),
                //   textStyle: TextStyle(
                //     color: Theme.of(context).primaryColor,
                //   ),
                // ),
                AnimatedContainer(
                  duration: Duration(milliseconds: 350),
                  height: addType != 'email' ? 0 : 178,
                  margin: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ClipRect(
                    child: loading
                        ? Center(
                            child: LoadingWidget(),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.email_outlined,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    onPressed: () => smallSetState(
                                      () {
                                        foundUser = null;
                                        addType = null;
                                      },
                                    ),
                                  ),
                                  Text(
                                    'Add By Email',
                                    style:
                                        Theme.of(context).textTheme.subtitle1,
                                  ),
                                ],
                              ),
                              AppTextField(
                                label: 'Email',
                                controller: emailFieldController,
                                margin: EdgeInsets.zero,
                                autoFocus: true,
                                keyboardType: TextInputType.emailAddress,
                                onSubmit: (email) => searchByEmail(
                                  smallSetState,
                                ),
                                suffix: InkWell(
                                  onTap: () => searchByEmail(smallSetState),
                                  child: Container(
                                    width: 44,
                                    height: 44,
                                    child: Center(
                                      child: Icon(
                                        Icons.search,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                AnimatedContainer(
                  duration: Duration(milliseconds: 350),
                  height: addType == 'email' ? 0 : 144,
                  child: ClipRect(
                    child: AppButtonCard(
                      icon: Icon(
                        Icons.email_outlined,
                        size: 44.0,
                      ),
                      text: 'Add By Email',
                      onPressed: () => smallSetState(
                        () {
                          foundUser = null;
                          addType = 'email';
                        },
                      ),
                      margin: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      textStyle: TextStyle(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ),
                if (foundUser != null)
                  UserCard(
                    user: foundUser,
                    onDelete: () => smallSetState(
                      () => foundUser = null,
                    ),
                  ),

                if (!loading)
                  AppActionButton(
                    onPressed: foundUser != null
                        ? () async {
                            setState(() {
                              partners.add(foundUser);
                            });
                            Navigator.pop(context);
                          }
                        : addType != null
                            ? () => searchByEmail(smallSetState)
                            : () => Navigator.pop(context),
                    label: foundUser != null
                        ? 'Add'
                        : addType != null
                            ? 'Search'
                            : 'Close',
                    margin: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
