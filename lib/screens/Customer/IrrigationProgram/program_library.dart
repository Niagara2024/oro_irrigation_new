import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../state_management/irrigation_program_main_provider.dart';
import '../../../widgets/SCustomWidgets/custom_alert_dialog.dart';
import '../../../widgets/SCustomWidgets/custom_animated_switcher.dart';
import '../../../widgets/SCustomWidgets/custom_list_tile.dart';
import '../../../widgets/SCustomWidgets/custom_snack_bar.dart';
import 'irrigation_program_main.dart';

class ProgramLibraryScreen extends StatefulWidget {
  final int userId;
  final int controllerId;

  const ProgramLibraryScreen(
      {Key? programLibraryKey, required this.userId, required this.controllerId})
      : super(key: programLibraryKey);

  @override
  State<ProgramLibraryScreen> createState() => _ProgramLibraryScreenState();
}

class _ProgramLibraryScreenState extends State<ProgramLibraryScreen> {
  final TextEditingController _textEditingController = TextEditingController();
  final FocusNode _programNameFocusNode = FocusNode();

  @override
  void initState() {
    final irrigationProvider = Provider.of<IrrigationProgramMainProvider>(context, listen: false);
    irrigationProvider.programLibraryData(widget.userId, widget.controllerId, 0);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _programNameFocusNode.dispose();
    _textEditingController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mainProvider = Provider.of<IrrigationProgramMainProvider>(context);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Scaffold(
          appBar: constraints.maxWidth < 550 ?
          AppBar(
            title: const Text('Program Library'),
            centerTitle: false,
            actions: [
              IconButton(
                onPressed: () {
                  if (mainProvider.programLibrary?.agitatorCount != 0) {
                    _showAdaptiveDialog(context, mainProvider);
                  } else {
                    mainProvider.selectedProgramType = 'Irrigation Program';
                    mainProvider.updateIsIrrigationProgram();
                    mainProvider.programLibrary!.program.length <= mainProvider.programLibrary!.programLimit ?
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => IrrigationProgram(
                          userId: widget.userId,
                          controllerId: widget.controllerId,
                          serialNumber: mainProvider.programLibrary!.program.any((element) => element.programName.isEmpty)
                              ? mainProvider.programLibrary!.program.firstWhere((element) => element.programName.isEmpty).serialNumber : 0,
                          conditionsLibraryIsNotEmpty: mainProvider.conditionsLibraryIsNotEmpty,
                          programType: mainProvider.programLibrary!.program.any((element) => element.programName.isEmpty)
                              ? mainProvider.programLibrary!.program.firstWhere((element) => element.programName.isEmpty).programType : null,
                        ),
                      ),
                    ) :
                    CustomAlertDialog(
                        title: "Alert",
                        content: "The program limit is exceeded as defined in the Constants!",
                        actions: [
                          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text("OK"))
                        ]
                    );
                  }
                },
                icon: const Icon(Icons.add),
              ),
            ],
          ) : PreferredSize(preferredSize: const Size(0, 0), child: Container()),
          body: _buildProgramList(mainProvider, constraints),
        );
      },
    );
  }

  Widget _buildProgramList(IrrigationProgramMainProvider mainProvider, constraints) {
    return mainProvider.programLibrary?.program != null
        ? (mainProvider.programLibrary!.program.isNotEmpty
        ? _buildProgramListView(mainProvider, constraints)
        : const Center(
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Text(
          "Programs not yet created, To create a program tap the '+' icon button",
          textAlign: TextAlign.center,
        ),
      ),
    ))
        : const Center(child: CircularProgressIndicator());
  }

  Widget _buildProgramListView(IrrigationProgramMainProvider mainProvider, constraints) {
    return Column(
      children: [
        const SizedBox(height: 10),
        (mainProvider.programLibrary?.agitatorCount != 0 && mainProvider.programLibrary!.program.any((element) => element.programType == "Agitator Program"))
            ?
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildButtonsRow(mainProvider, constraints),
            constraints.maxWidth > 700 ?
            OutlinedButton(
              onPressed: () {
                if (mainProvider.programLibrary?.agitatorCount != 0) {
                  _showAdaptiveDialog(context, mainProvider);
                } else {
                  mainProvider.selectedProgramType = 'Irrigation Program';
                  mainProvider.updateIsIrrigationProgram();
                  mainProvider.programLibrary!.program.length <= mainProvider.programLibrary!.programLimit ?
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => IrrigationProgram(
                        userId: widget.userId,
                        controllerId: widget.controllerId,
                        serialNumber: mainProvider.programLibrary!.program.any((element) => element.programName.isEmpty)
                            ? mainProvider.programLibrary!.program.firstWhere((element) => element.programName.isEmpty).serialNumber : 0,
                        conditionsLibraryIsNotEmpty: mainProvider.conditionsLibraryIsNotEmpty,
                        programType: mainProvider.programLibrary!.program.any((element) => element.programName.isEmpty)
                            ? mainProvider.programLibrary!.program.firstWhere((element) => element.programName.isEmpty).programType : null,
                      ),
                    ),
                  ) :
                  CustomAlertDialog(
                      title: "Alert",
                      content: "The program limit is exceeded as defined in the Constants!",
                      actions: [
                        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text("OK"))
                      ]
                  );
                }
              },
              child: const Text("Create new Program"),
            )
                : (constraints.maxWidth > 550 && constraints.maxWidth <= 700)
                ? IconButton(
              onPressed: () {
                if (mainProvider.programLibrary?.agitatorCount != 0) {
                  _showAdaptiveDialog(context, mainProvider);
                } else {
                  mainProvider.selectedProgramType = 'Irrigation Program';
                  mainProvider.updateIsIrrigationProgram();
                  mainProvider.programLibrary!.program.length <= mainProvider.programLibrary!.programLimit ?
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => IrrigationProgram(
                        userId: widget.userId,
                        controllerId: widget.controllerId,
                        serialNumber: mainProvider.programLibrary!.program.any((element) => element.programName.isEmpty)
                            ? mainProvider.programLibrary!.program.firstWhere((element) => element.programName.isEmpty).serialNumber : 0,
                        conditionsLibraryIsNotEmpty: mainProvider.conditionsLibraryIsNotEmpty,
                        programType: mainProvider.programLibrary!.program.any((element) => element.programName.isEmpty)
                            ? mainProvider.programLibrary!.program.firstWhere((element) => element.programName.isEmpty).programType : null,
                      ),
                    ),
                  ) :
                  CustomAlertDialog(
                      title: "Alert",
                      content: "The program limit is exceeded as defined in the Constants!",
                      actions: [
                        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text("OK"))
                      ]
                  );
                }
              },
              icon: const Icon(Icons.add),
            )
                : Container()
          ],
        )
            : Row(
          mainAxisAlignment: constraints.maxWidth > 700 ? MainAxisAlignment.spaceEvenly : MainAxisAlignment.center,
          children: [
            _buildOutlinedButton(mainProvider.isActive ? 'ACTIVE PROGRAMS' : 'INACTIVE PROGRAMS', mainProvider.isActive, () {
              mainProvider.updateActiveProgram();
            }),
            constraints.maxWidth > 700 ?
            OutlinedButton(
              onPressed: () {
                if (mainProvider.programLibrary?.agitatorCount != 0) {
                  _showAdaptiveDialog(context, mainProvider);
                } else {
                  mainProvider.selectedProgramType = 'Irrigation Program';
                  mainProvider.updateIsIrrigationProgram();
                  mainProvider.programLibrary!.program.length <= mainProvider.programLibrary!.programLimit ?
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => IrrigationProgram(
                        userId: widget.userId,
                        controllerId: widget.controllerId,
                        serialNumber: mainProvider.programLibrary!.program.any((element) => element.programName.isEmpty)
                            ? mainProvider.programLibrary!.program.firstWhere((element) => element.programName.isEmpty).serialNumber : 0,
                        conditionsLibraryIsNotEmpty: mainProvider.conditionsLibraryIsNotEmpty,
                        programType: mainProvider.programLibrary!.program.any((element) => element.programName.isEmpty)
                            ? mainProvider.programLibrary!.program.firstWhere((element) => element.programName.isEmpty).programType : null,
                      ),
                    ),
                  ) :
                  CustomAlertDialog(
                      title: "Alert",
                      content: "The program limit is exceeded as defined in the Constants!",
                      actions: [
                        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text("OK"))
                      ]
                  );
                }
              },
              child: const Text("Create new Program"),
            )
                : Container()
          ],
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.builder(
            itemCount: mainProvider.programLibrary!.program.length,
            itemBuilder: (context, index) {
              return _buildProgramItem(mainProvider, index, constraints);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProgramItem(IrrigationProgramMainProvider mainProvider, int index, constraints) {
    final program = mainProvider.programLibrary!.program[index];
    // return buildShowProgramItems(mainProvider, index, constraints);
    if (_shouldShowProgram(mainProvider, program)) {
      return Column(
        children: [
          if (mainProvider.isActive)
            CustomAnimatedSwitcher(
              condition: program.programName.isNotEmpty,
              child: buildShowProgramItems(mainProvider, index, constraints),
            ),
          if (!mainProvider.isActive)
            CustomAnimatedSwitcher(
              condition: program.programName.isEmpty,
              child: buildShowProgramItems(mainProvider, index, constraints),
            ),
        ],
      );
    } else {
      return Container();
    }
  }

  Widget buildShowProgramItems(IrrigationProgramMainProvider mainProvider, int index, constraints) {
    final program = mainProvider.programLibrary!.program[index];
    String scheduleType = program.schedule['selected'] ?? '';
    String startDate = '';
    if (program.schedule.isNotEmpty) {
      startDate = program.schedule['selected'] == mainProvider.scheduleTypes[1]
          ? program.schedule['scheduleAsRunList']['schedule']['startDate']
          : program.schedule['scheduleByDays']['schedule']['startDate'];
    }
    final DateFormat formatter = DateFormat('dd-MM-yyyy');
    final formattedStartDate = program.schedule.isNotEmpty
        ? formatter.format(DateTime.parse(startDate))
        : '';
    return Column(
      children: [
        InkWell(
            onTap: () => _navigateToIrrigationProgram(program, mainProvider),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              padding: constraints.maxWidth > 550 ? const EdgeInsets.all(8) : null,
              decoration: _buildContainerDecoration(),
              child: constraints.maxWidth > 550
                  ? Row(
                children: [
                  _buildCircleAvatar(index),
                  const SizedBox(width: 10,),
                  Container(width: 1, color: Colors.black38, height: 50,),
                  const SizedBox(width: 10,),
                  _buildProgramDetails(program, constraints),
                  const SizedBox(width: 10,),
                  Container(width: 1, color: Colors.black38, height: 50,),
                  const SizedBox(width: 10,),
                  _buildScheduleDetails(program, constraints, mainProvider),
                  const SizedBox(width: 10,),
                  Container(width: 1, color: Colors.black38, height: 50,),
                  const SizedBox(width: 10,),
                  _buildRtcDetails(program, constraints, mainProvider),
                  const SizedBox(width: 10,),
                  Container(width: 1, color: Colors.black38, height: 50,),
                  const SizedBox(width: 10,),
                  Visibility(
                      visible: constraints.maxWidth > 620,
                      child: const Expanded(child: Text('Status'))),
                  _buildProgramActions(program, mainProvider, index),
                ],
              )
                  :
              CustomTile(
                title: (program.programName.isNotEmpty) ? program.programName : program.defaultProgramName,
                showCircleAvatar: true,
                showSubTitle: true,
                subtitle: '${scheduleType == '' ? 'Program Data Erased' : scheduleType} , ${scheduleType != "NO SCHEDULE" ? formattedStartDate : ''}',
                content: '${index + 1}',
                trailing: SizedBox(
                    width: constraints.maxWidth * 0.3,
                    child: _buildProgramActions(program, mainProvider, index)
                ),
              ),
            )),
        const SizedBox(height: 10,)
      ],
    );
  }

  bool _shouldShowProgram(mainProvider, program) {
    return (mainProvider.showIrrigationPrograms &&
        program.programType == 'Irrigation Program') ||
        (mainProvider.showAgitatorPrograms &&
            program.programType == 'Agitator Program') ||
        (mainProvider.showAllPrograms);
  }

  void _navigateToIrrigationProgram(program, mainProvider) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => IrrigationProgram(
          userId: widget.userId,
          controllerId: widget.controllerId,
          serialNumber: program.serialNumber,
          programType: program.programType,
          conditionsLibraryIsNotEmpty: mainProvider.conditionsLibraryIsNotEmpty,
        ),
      ),
    );
  }

  Decoration _buildContainerDecoration() {
    return BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
              blurRadius: 5,
              spreadRadius: 3,
              offset: Offset(0, 2),
              color: Colors.black12)
        ]);
  }

  Widget _buildCircleAvatar(int index) {
    return CircleAvatar(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      child: Text('${index + 1}', style: const TextStyle(color: Colors.black)),
    );
  }

  Widget _buildProgramDetails(program, constraints) {
    return (constraints.maxWidth > 550 && constraints.maxWidth <= 1050)
        ? SizedBox(
      width: constraints.maxWidth * 0.18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            (program.programName.isNotEmpty)
                ? program.programName
                : program.defaultProgramName,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          Text(program.sequence != null
              ? '${program.sequence.length} Zones'
              : 'Sequence is not selected'),
        ],
      ),
    )
        : SizedBox(
      width: constraints.maxWidth * 0.25,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            (program.programName.isNotEmpty)
                ? program.programName
                : program.defaultProgramName,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          Text(program.sequence != null
              ? '${program.sequence.length} Zones'
              : 'Sequence is not selected'),
        ],
      ),
    );
  }

  Widget _buildScheduleDetails(program, constraints, mainProvider) {
    final widthRatio =
    (constraints.maxWidth > 550 && constraints.maxWidth <= 1050)
        ? 0.2
        : 0.25;
    String scheduleType = program.schedule['selected'] ?? '';
    String startDate = '';
    if (program.schedule.isNotEmpty) {
      startDate = program.schedule['selected'] == mainProvider.scheduleTypes[1]
          ? program.schedule['scheduleAsRunList']['schedule']['startDate']
          : program.schedule['scheduleByDays']['schedule']['startDate'];
    }

    final DateFormat formatter = DateFormat('dd-MM-yyyy');
    final formattedStartDate = program.schedule.isNotEmpty
        ? formatter.format(DateTime.parse(startDate))
        : '';

    return SizedBox(
      width: constraints.maxWidth * widthRatio,
      child: constraints.maxWidth > 1100
          ? Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            scheduleType == '' ? 'Program Data Erased' : scheduleType,
          ),
          scheduleType != "NO SCHEDULE"
              ? Text(formattedStartDate)
              : Container(),
        ],
      )
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            scheduleType == '' ? 'Program Data Erased' : scheduleType,
          ),
          scheduleType != "NO SCHEDULE"
              ? Text(formattedStartDate)
              : Container(),
        ],
      ),
    );
  }

  Widget _buildRtcDetails(program, constraints, mainProvider) {
    String scheduleType = program.schedule['selected'] ?? '';
    String rtcOnTime = '';
    String rtcOffTime = '';
    if (program.schedule.isNotEmpty) {
      rtcOnTime = program.schedule['selected'] == mainProvider.scheduleTypes[1]
          ? program.schedule['scheduleAsRunList']['rtc']['rtc1']['onTime']
          : program.schedule['scheduleByDays']['rtc']['rtc1']['onTime'];
      rtcOffTime = program.schedule['selected'] == mainProvider.scheduleTypes[1]
          ? program.schedule['scheduleAsRunList']['rtc']['rtc1']['offTime']
          : program.schedule['scheduleByDays']['rtc']['rtc1']['offTime'];
    }

    return (constraints.maxWidth > 550 && constraints.maxWidth <= 1050)
        ? SizedBox(
      width: constraints.maxWidth * 0.1,
      child: scheduleType != "NO SCHEDULE"
          ? Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            scheduleType != "NO SCHEDULE"
                ? Text(rtcOnTime)
                : Container(),
            scheduleType != "NO SCHEDULE"
                ? Text(rtcOffTime)
                : Container(),
          ],
        ),
      )
          : const Center(child: Text('-')),
    )
        : SizedBox(
      width: constraints.maxWidth * 0.15,
      child: Row(
        mainAxisAlignment: scheduleType != "NO SCHEDULE"
            ? MainAxisAlignment.spaceBetween
            : MainAxisAlignment.spaceAround,
        children: [
          scheduleType != "NO SCHEDULE"
              ? Column(
            children: [
              const Text('On Time'),
              Text(rtcOnTime),
            ],
          )
              : const Text('-'),
          scheduleType != "NO SCHEDULE"
              ? Column(
            children: [
              const Text('Off Time'),
              Text(rtcOffTime),
            ],
          )
              : const Text('-'),
        ],
      ),
    );
  }

  Widget _buildProgramActions(program, IrrigationProgramMainProvider mainProvider, int index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if(program.programName.isNotEmpty)
          IconButton(
            onPressed: () => _showDeleteConfirmationDialog(mainProvider, program),
            icon: Icon(
              Icons.delete,
              color: Colors.red,
            ),
          ),
        if(program.programName.isNotEmpty)
          IconButton(
            onPressed: () => _showEditItemDialog(mainProvider, program, index),
            icon: const Icon(
              Icons.edit,
              // color: Colors.black,
            ),
          ),
        IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.navigate_next,
              color: Colors.black,
            )),
      ],
    );
  }

  void _showDeleteConfirmationDialog(
      IrrigationProgramMainProvider mainProvider, program) {
    showAdaptiveDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return CustomAlertDialog(
              title: "Confirmation",
              content: 'Are you sure you want to delete?',
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('No'),
                ),
                TextButton(
                  onPressed: () {
                    _deleteProgram(mainProvider, program);
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Yes'),
                ),
              ]);
        });
  }

  void _deleteProgram(IrrigationProgramMainProvider mainProvider, program) {
    mainProvider
        .userProgramReset(widget.userId, widget.controllerId, widget.userId,
        program.programId)
        .then((String message) {
      ScaffoldMessenger.of(context)
          .showSnackBar(CustomSnackBar(message: message));
    })
        .then((value) => mainProvider.programLibraryData(
        widget.userId, widget.controllerId, widget.userId))
        .catchError((error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(CustomSnackBar(message: error));
    });
  }

  void _showEditItemDialog(
      IrrigationProgramMainProvider mainProvider, program, int index) {
    showAdaptiveDialog(
      context: context,
      builder: (BuildContext dialogContext) =>
          Consumer<IrrigationProgramMainProvider>(
              builder: (context, scheduleProvider, child) {
                return AlertDialog(
                  title: const Text('Edit Item'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        initialValue: program.programName.isNotEmpty
                            ? program.programName
                            : program.defaultProgramName,
                        focusNode: _programNameFocusNode,
                        onChanged: (newValue) => program.programName = newValue,
                        inputFormatters: [LengthLimitingTextInputFormatter(20)],
                      ),
                      const SizedBox(height: 5),
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15)),
                        child: CustomDropdownTile(
                          showCircleAvatar: false,
                          width: 70,
                          title: 'Priority',
                          subtitle: 'Description',
                          showSubTitle: false,
                          content: Icons.priority_high,
                          dropdownItems: mainProvider.priorityList
                              .map((item) => item.toString())
                              .toList(),
                          selectedValue: program.priority != 0
                              ? program.priority.toString()
                              : 'None',
                          onChanged: (newValue) {
                            mainProvider.updatePriority(newValue, index);
                            _programNameFocusNode.unfocus();
                          },
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        _saveProgramDetails(mainProvider, program, index);
                        Navigator.pop(dialogContext);
                      },
                      child: const Text('Save'),
                    ),
                  ],
                );
              }),
    );
  }

  void _saveProgramDetails(
      IrrigationProgramMainProvider mainProvider, program, int index) {
    mainProvider
        .updateUserProgramDetails(
        widget.userId,
        widget.controllerId,
        program.serialNumber,
        program.programId,
        program.programName,
        program.priority)
        .then((value) => ScaffoldMessenger.of(context)
        .showSnackBar(CustomSnackBar(message: value)));
  }

  Widget _buildButtonsRow(IrrigationProgramMainProvider mainProvider, constraints) {
    return Row(
      children: [
        const SizedBox(width: 10),
        _buildOutlinedButton('ALL', mainProvider.showAllPrograms, () {
          mainProvider.updateShowPrograms(true, false, false, false);
        }),
        const SizedBox(width: 10),
        _buildOutlinedButton('IRRIGATION', mainProvider.showIrrigationPrograms,
                () {
              mainProvider.updateShowPrograms(false, true, false, false);
            }),
        const SizedBox(width: 10),
        _buildOutlinedButton('AGITATOR', mainProvider.showAgitatorPrograms, () {
          mainProvider.updateShowPrograms(false, false, true, false);
        }),
        const SizedBox(width: 10),
        constraints.maxWidth < 700 ?
        IconButton(
          onPressed: () {
            mainProvider.updateActiveProgram();
          },
          style: ButtonStyle(
            foregroundColor: mainProvider.isActive
                ? MaterialStateProperty.all(Colors.white)
                : MaterialStateProperty.all(Theme.of(context).primaryColor),
            backgroundColor: mainProvider.isActive
                ? MaterialStateProperty.all(Theme.of(context).primaryColor)
                : MaterialStateProperty.all(Colors.white),
          ),
          icon: Icon(
            mainProvider.isActive ? Icons.done_rounded : Icons.cancel,
            color: mainProvider.isActive ? Colors.white : Colors.red,
          ),
        ):
        _buildOutlinedButton(mainProvider.isActive ? 'ACTIVE PROGRAMS' : 'INACTIVE PROGRAMS', mainProvider.isActive, () {
          mainProvider.updateActiveProgram();
        }),
      ],
    );
  }

  Widget _buildOutlinedButton(
      String text, bool isSelected, VoidCallback onPressed) {
    return OutlinedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        foregroundColor: isSelected
            ? MaterialStateProperty.all(Colors.white)
            : MaterialStateProperty.all(Theme.of(context).primaryColor),
        backgroundColor: isSelected
            ? MaterialStateProperty.all(Theme.of(context).primaryColor)
            : MaterialStateProperty.all(Colors.white),
      ),
      child: Text(text),
    );
  }

  void _showAdaptiveDialog(BuildContext context, IrrigationProgramMainProvider programProvider,) {
    showAdaptiveDialog(
      context: context,
      builder: (BuildContext dialogContext) =>
          Consumer<IrrigationProgramMainProvider>(
            builder: (context, programProvider, child) {
              if(programProvider.programLibrary!.program.length <= programProvider.programLibrary!.programLimit){
                return AlertDialog(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: programProvider.programLibrary!.programType.map((e) {
                      return RadioListTile(
                          title: Text(e),
                          value: e,
                          groupValue: programProvider.selectedProgramType,
                          onChanged: (newValue) => programProvider.updateProgramName(newValue, 'programType'));
                    }).toList(),
                  ),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text('Cancel')),
                    TextButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                          if (programProvider.selectedProgramType == 'Irrigation Program') {
                            programProvider.updateIsIrrigationProgram();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => IrrigationProgram(
                                  userId: widget.userId,
                                  controllerId: widget.controllerId,
                                  serialNumber: programProvider.programLibrary!.program.any((element) => element.programName.isEmpty && element.programType == "Irrigation Program")
                                      ? programProvider.programLibrary!.program.firstWhere((element) => element.programName.isEmpty && element.programType == "Irrigation Program").serialNumber : 0,
                                  conditionsLibraryIsNotEmpty: programProvider.conditionsLibraryIsNotEmpty,
                                  programType: programProvider.programLibrary!.program.any((element) => element.programName.isEmpty && element.programType == "Irrigation Program")
                                      ? programProvider.programLibrary!.program.firstWhere((element) => element.programName.isEmpty && element.programType == "Irrigation Program").programType : programProvider.selectedProgramType,
                                ),
                              ),
                            );
                          } else if (programProvider.selectedProgramType == 'Agitator Program') {
                            programProvider.updateIsAgitatorProgram();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => IrrigationProgram(
                                  userId: widget.userId,
                                  controllerId: widget.controllerId,
                                  serialNumber: programProvider.programLibrary!.program.any((element) => element.programName.isEmpty && element.programType == "Agitator Program")
                                      ? programProvider.programLibrary!.program.firstWhere((element) => element.programName.isEmpty && element.programType == "Agitator Program").serialNumber : 0,
                                  conditionsLibraryIsNotEmpty: programProvider.conditionsLibraryIsNotEmpty,
                                  programType: programProvider.programLibrary!.program.any((element) => element.programName.isEmpty && element.programType == "Agitator Program")
                                      ? programProvider.programLibrary!.program.firstWhere((element) => element.programName.isEmpty
                                      && element.programType == "Agitator Program").programType : null,
                                ),
                              ),
                            );
                          }
                        },
                        child: const Text('OK')),
                  ],
                );
              } else {
                return CustomAlertDialog(
                    title: "Alert",
                    content: "The program limit is exceeded as defined in the Constants!",
                    actions: [
                      TextButton(onPressed: () => Navigator.of(context).pop(), child: Text("OK"))
                    ]
                );
              }
            },
          ),
    );
  }
}
