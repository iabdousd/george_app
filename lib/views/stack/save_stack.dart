import 'package:flutter/material.dart';
import 'package:george_project/config/extensions/hex_color.dart';
import 'package:george_project/models/Stack.dart' as stack_model;
import 'package:george_project/services/feed-back/flush_bar.dart';
import 'package:george_project/services/feed-back/loader.dart';
import 'package:george_project/widgets/forms/date_picker.dart';
import 'package:george_project/widgets/shared/app_appbar.dart';

class SaveStackPage extends StatefulWidget {
  final String goalRef;
  final stack_model.Stack stack;
  SaveStackPage({Key key, @required this.goalRef, this.stack})
      : super(key: key);

  @override
  _SaveStackPageState createState() => _SaveStackPageState();
}

class _SaveStackPageState extends State<SaveStackPage> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _titleController = TextEditingController();
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();

  List<String> availableColors = [
    '#f7f13b',
    '#ed5858',
    '#70f065',
    '#eba373',
    '#eb73d7',
    '#4b9ede',
  ];
  String selectedColor = '#ed5858';

  pickColor() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'The color of your stack item',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.subtitle1,
          ),
          content: Container(
            width: MediaQuery.of(context).size.width * .7,
            child: GridView.count(
              crossAxisCount: 3,
              childAspectRatio: 1.0,
              padding: const EdgeInsets.all(8.0),
              mainAxisSpacing: 12.0,
              crossAxisSpacing: 12.0,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: availableColors
                  .map(
                    (e) => Center(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            selectedColor = e;
                          });
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4.0),
                          child: Icon(
                            Icons.brightness_1,
                            color: HexColor.fromHex(e),
                            size: 32,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        );
      },
    );
  }

  _submitStack() async {
    toggleLoading(state: true);
    await stack_model.Stack(
      goalRef: widget.goalRef,
      id: widget.stack?.id,
      title: _titleController.text,
      color: selectedColor,
      creationDate: DateTime.now(),
      startDate: startDate,
      endDate: endDate,
      status: 0,
    ).save();
    toggleLoading(state: false);
    Navigator.of(context).pop();
    showFlushBar(
      title: 'Stack added successfully!',
      message: 'You can now see your stack in stacks list.',
    );
  }

  _pickStartDate(DateTime picked) async {
    setState(() {
      startDate = picked;
    });
  }

  _pickEndDate(DateTime picked) async {
    setState(() {
      endDate = picked;
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.stack != null) {
      _titleController.text = widget.stack.title;
      startDate = widget.stack.startDate;
      endDate = widget.stack.endDate;
      selectedColor = widget.stack.color;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appAppBar(
        title: widget.stack != null ? 'Stack details' : 'New Stack',
        actions: [
          TextButton(
            onPressed: _submitStack,
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
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).backgroundColor,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Stack title',
                    hintText: 'The title of the stack',
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 20.0,
                      horizontal: 20.0,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(width: 1),
                    ),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                decoration: BoxDecoration(
                  color: Color(0x07000000),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: InkWell(
                  onTap: pickColor,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.brightness_1,
                          color: HexColor.fromHex(selectedColor),
                          size: 32,
                        ),
                      ),
                      SizedBox(
                        width: 12,
                      ),
                      Text(
                        'Color',
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      SizedBox(
                        width: 12,
                      ),
                    ],
                  ),
                ),
              ),
              DatePickerWidget(
                title: 'I want to start this stack on',
                color: selectedColor,
                onSubmit: _pickStartDate,
                initialDate: startDate,
              ),
              DatePickerWidget(
                title: 'I want to end this stack on',
                color: selectedColor,
                onSubmit: _pickEndDate,
                initialDate: endDate,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
