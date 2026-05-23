import 'dart:core';

import 'package:flutter/material.dart';
import 'package:noclevercode_suite/checkboxes.dart';
import 'package:noclevercode_suite/common.dart' as ncc_common;
import 'package:noclevercode_suite/dropdown_picker.dart';
import 'package:noclevercode_suite/radio_buttons.dart';
import 'package:noclevercode_suite/strings.dart';
import 'package:noclevercode_suite/text_strings.dart';
import 'package:noclevercode_suite/working_button.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Strings textStrings = Strings.empty();
  int textStringDelay = 0;
  bool? textStringsDisabled;

  bool allowRadioUnselect = true;
  String? radioSelection = null;
  bool? radioDisabled;
  bool? radioAllowUnselect;

  bool? buttonDisabled;
  bool? buttonDisabledWhileWorking;

  bool? dropdownDisabled;
  String? dropdownSelection;

  bool? checkboxesDisabled;

  Strings? checkboxesSelection = null;

  bool? integerEntryDisabled;

  Strings allowRadioUnselectSelection = Strings.from(['Allow unselecting radio box']);
  BoxDecoration? boxDecoration = null;

  TextStyle? textStyle = null;

  Strings logLines = Strings.empty(growable: true);

  bool? singleCheck;
  bool? singleCheckDisabled;

  void logLine(String line) {
    this.setState(() {
      logLines.insert(0, line);
    });
  }

  int? integerEntryMinimumLength = null;
  int? integerEntryMaximumLength = null;

  TextStyle labelTextStyle = const TextStyle(fontSize: 12, color: Colors.pinkAccent);

  TextEditingController dropdownSelectionEditingController = TextEditingController();

  @override
  void dispose() {
    dropdownSelectionEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    dropdownSelectionEditingController.text = this.dropdownSelection ?? '';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('No Clever Code widget suite example'),
      ),
      body: Padding(
        padding: EdgeInsets.all(5),
        child: Column(children: [
          Table(border: TableBorder.all(color: Colors.black), defaultColumnWidth: const FlexColumnWidth(), children: [
            TableRow(
              children: [
                WorkingButton(
                  caption: 'WorkingButton',
                  workingCaption: 'working WorkingButton',
                  hint: 'hint',
                  workingHint: 'working hint',
                  disabledHint: 'disabled hint',
                  disableWhileWorking: this.buttonDisabledWhileWorking == true,
                  onPress: (ncc_common.OnEvent doneWorking) {
                    logLine('WorkingButton pressed');
                    Future.delayed(const Duration(seconds: 5), () {
                      doneWorking();
                      logLine('WorkingButton.working set to false');
                    });
                  },
                  disabled: this.buttonDisabled == true,
                ),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  SingleCheck(
                    label: 'disabled',
                    value: this.buttonDisabled == true,
                    onChange: (value) {
                      this.setState(() => this.buttonDisabled = value);
                      this.logLine('buttonDisabled set to ${this.buttonDisabled}');
                    },
                  ),
                  SingleCheck(
                    label: 'disable while working',
                    value: this.buttonDisabledWhileWorking == true,
                    onChange: (value) {
                      this.setState(() => this.buttonDisabledWhileWorking = value);
                      this.logLine('buttonDisabledWhileWorking set to ${this.buttonDisabledWhileWorking}');
                    },
                  ),
                ])
              ],
            ),
            TableRow(
              children: [
                SingleCheck(
                  label: 'SingleCheck',
                  value: this.singleCheck,
                  onChange: (value) {
                    this.setState(() => this.singleCheck = value);
                    this.logLine('SingleCheck changed to $value');
                  },
                  disabled: this.singleCheckDisabled == true,
                ),
                Center(
                  child: SingleCheck(
                    label: 'disabled',
                    value: this.singleCheckDisabled,
                    onChange: (value) {
                      this.setState(() => this.singleCheckDisabled = value);
                      this.logLine('buttonDisabled set to ${ncc_common.boolishToString(this.checkboxesDisabled)}');
                    },
                  ),
                ),
              ],
            ),
            TableRow(children: [
              TextStrings(
                  caption: 'Text Strings',
                  captionLocation: ncc_common.CaptionLocation.above,
                  boxDecoration: BoxDecoration(
                    border: Border.all(color: Colors.deepPurple),
                  ),
                  strings: this.textStrings,
                  aggregateDelay: this.textStringDelay,
                  disabled: this.textStringsDisabled == true,
                  onChange: (Strings strings) {
                    this.logLine('TextStrings changed $strings');
                    this.setState(() => this.textStrings = strings);
                  }),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('delay OnChanged by'),
                  SizedBox(
                    width: 100,
                    child: TextField(
                        textAlign: TextAlign.center,
                        onChanged: (String? value) {
                          this.setState(() {
                            this.textStringDelay = int.tryParse(value ?? '0') ?? 0;
                          });
                        }),
                  ),
                  SingleCheck(
                    label: 'disabled',
                    value: this.textStringsDisabled == true,
                    onChange: (value) {
                      this.setState(() => this.textStringsDisabled = value);
                      this.logLine('textStringsDisabled set to ${this.textStringsDisabled}');
                    },
                  ),
                ],
              ),
            ]),
            const TableRow(children: [Padding(padding: EdgeInsets.fromLTRB(5, 0, 0, 0), child: Text('Dropdown Picker')), Text('')]),
            TableRow(children: [
              SizedBox(
                height: 100,
                child: DropdownPicker(
                    labels: this.textStrings,
                    selected: this.dropdownSelection,
                    disabled: this.dropdownDisabled == true,
                    onChange: (String? value) {
                      this.setState(() => this.dropdownSelection = value);
                      this.logLine('DropdownPicker selected $value');
                    }),
              ),
              Column(children: [
                Text('set dropdown value'),
                TextField(
                  controller: dropdownSelectionEditingController,
                  onChanged: (String? value) {
                    this.setState(() => this.dropdownSelection = value);
                    this.logLine('dropdownSelection set to $value');
                  },
                ),
                Center(
                  child: SingleCheck(
                    label: 'disabled',
                    value: this.dropdownDisabled == true,
                    onChange: (value) {
                      this.setState(() => this.dropdownDisabled = value);
                      this.logLine('dropdownDisabled set to ${this.dropdownDisabled}');
                    },
                  ),
                ),
              ])
            ]),
            const TableRow(children: [Padding(padding: EdgeInsets.fromLTRB(5, 0, 0, 0), child: Text('Checkboxes')), Text('')]),
            TableRow(children: [
              CheckBoxes(
                  labels: this.textStrings,
                  selected: this.checkboxesSelection,
                  disabled: this.checkboxesDisabled == true,
                  onChange: (Strings? value) {
                    this.logLine('CheckBoxes selected $value');
                    this.setState(() => this.checkboxesSelection = value);
                  }),
              Center(
                child: SingleCheck(
                  label: 'disabled',
                  value: this.checkboxesDisabled == true,
                  onChange: (value) {
                    this.setState(() => this.checkboxesDisabled = value);
                    this.logLine('checkboxesDisabled set to ${this.checkboxesDisabled}');
                  },
                ),
              )
            ]),
            const TableRow(children: [Padding(padding: EdgeInsets.fromLTRB(5, 0, 0, 0), child: Text('Radio Buttons')), Text('')]),
            TableRow(
              children: [
                RadioButtons(
                    labels: this.textStrings,
                    selected: this.radioSelection,
                    disabled: this.radioDisabled == true,
                    onChange: (String? value) {
                      this.logLine('Radio Buttons selected $value');
                      this.setState(() => this.radioSelection = value);
                    }),
                Center(
                  child: SingleCheck(
                    label: 'disabled',
                    value: this.radioDisabled == true,
                    onChange: (value) {
                      this.setState(() {
                        this.radioDisabled = value;
                      });
                      this.logLine('radioDisabled set to ${this.radioDisabled}');
                    },
                  ),
                ),
              ],
            )
          ]),
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    style: BorderStyle.solid,
                    color: Colors.blue,
                  ),
                ),
                padding: const EdgeInsets.all(5),
                child: Text(
                  this.logLines.text,
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
