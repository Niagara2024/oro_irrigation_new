import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../state_management/irrigation_program_main_provider.dart';
import '../../../widgets/SCustomWidgets/custom_alert_dialog.dart';
import '../../../widgets/SCustomWidgets/custom_list_tile.dart';
import '../../../widgets/SCustomWidgets/custom_snack_bar.dart';
import 'irrigation_program_main.dart';

class ProgramLibraryScreen extends StatefulWidget {
  final int userId;
  final int controllerId;

  const ProgramLibraryScreen({Key? programLibraryKey, this.userId = 21, this.controllerId = 10}) : super(key: programLibraryKey);

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
          body: _buildProgramList(mainProvider, constraints),
        );
      },
    );
  }

  Widget _buildProgramList(IrrigationProgramMainProvider mainProvider, constraints) {
    return mainProvider.programLibrary?.program != null
        ? (mainProvider.programLibrary!.program.isNotEmpty
        ? _buildProgramListView(mainProvider, constraints)
        : Center(
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Programs not yet created, To create a program tap the '+' icon button",
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10,),
            IconButton(
              onPressed: () {
                if(mainProvider.programLibrary?.agitatorCount != 0) {
                  _showAdaptiveDialog(context, mainProvider);
                } else {
                  mainProvider.selectedProgramType = 'Irrigation Program';
                  mainProvider.updateIsIrrigationProgram();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => IrrigationProgram(
                        userId: widget.userId,
                        controllerId: widget.controllerId,
                        serialNumber: 0,
                        conditionsLibraryIsNotEmpty: mainProvider.conditionsLibraryIsNotEmpty,
                      ),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.add),
            )
          ],
        ),
      ),
    ))
        : const Center(child: CircularProgressIndicator());
  }

  Widget _buildProgramListView(IrrigationProgramMainProvider mainProvider, constraints) {
    return Column(
      children: [
        mainProvider.programLibrary?.agitatorCount != 0 ? const SizedBox(height: 10) : Container(),
        mainProvider.programLibrary?.agitatorCount != 0 ? Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildButtonsRow(mainProvider),
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: IconButton(
                tooltip: 'New program',
                onPressed: () {
                  if(mainProvider.programLibrary?.agitatorCount != 0) {
                    _showAdaptiveDialog(context, mainProvider);
                  } else {
                    mainProvider.selectedProgramType = 'Irrigation Program';
                    mainProvider.updateIsIrrigationProgram();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => IrrigationProgram(
                          userId: widget.userId,
                          controllerId: widget.controllerId,
                          serialNumber: 0,
                          conditionsLibraryIsNotEmpty: mainProvider.conditionsLibraryIsNotEmpty,
                        ),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.add),
              ),
            ),
          ],) : Container(),
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
    String scheduleType = program.schedule['selected'] ?? '';
    String startDate = '';
    String rtcOnTime = '';
    String rtcOffTime = '';
    if (program.schedule.isNotEmpty) {
      startDate = program.schedule['selected'] == mainProvider.scheduleTypes[1]
          ? program.schedule['scheduleAsRunList']['schedule']['startDate']
          : program.schedule['scheduleByDays']['schedule']['startDate'];
      rtcOnTime = program.schedule['selected'] == mainProvider.scheduleTypes[1]
          ? program.schedule['scheduleAsRunList']['rtc']['rtc1']['onTime']
          : program.schedule['scheduleByDays']['rtc']['rtc1']['onTime'];
      rtcOffTime = program.schedule['selected'] == mainProvider.scheduleTypes[1]
          ? program.schedule['scheduleAsRunList']['rtc']['rtc1']['offTime']
          : program.schedule['scheduleByDays']['rtc']['rtc1']['offTime'];
    }
    final DateFormat formatter = DateFormat('dd-MM-yyyy');
    final formattedStartDate = program.schedule.isNotEmpty ? formatter.format(DateTime.parse(startDate)) : '';


    if (_shouldShowProgram(mainProvider, program)) {
      return Column(
        children: [
          InkWell(
              onTap: () => _navigateToIrrigationProgram(program, mainProvider),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                padding: constraints.maxWidth > 550 ? EdgeInsets.all(8) : null,
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
                    Visibility(visible: constraints.maxWidth > 620,child: Expanded(child: Text('Status'))),
                    _buildProgramActions(program, mainProvider, index),
                  ],
                )
                    :  CustomTile(
                  title: (program.programName.isNotEmpty)
                      ? program.programName
                      : program.defaultProgramName,
                  showCircleAvatar: true,
                  showSubTitle: true,
                  subtitle: '${scheduleType == '' ? 'Program Data Erased': scheduleType} , ${scheduleType != "NO SCHEDULE" ? formattedStartDate : ''}',
                  content: '${index + 1}',
                  trailing:  SizedBox(width: constraints.maxWidth * 0.3, child: _buildProgramActions(program, mainProvider, index)),
                ),
              )),
          const SizedBox(height: 10),
        ],
      );
    } else {
      return Container();
    }
  }

  bool _shouldShowProgram(mainProvider, program) {
    return (mainProvider.showIrrigationPrograms && program.programType == 'Irrigation Program') ||
        (mainProvider.showAgitatorPrograms && program.programType == 'Agitator Program') ||
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
              offset: Offset(0,2),
              color: Colors.black12
          )
        ]
    );
  }

  Widget _buildCircleAvatar(int index) {
    return CircleAvatar(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      child: Text('${index + 1}', style: const TextStyle(color: Colors.black)),
    );
  }

  Widget _buildProgramDetails(program, constraints) {
    return (constraints.maxWidth > 550 && constraints.maxWidth <= 1050) ?
    SizedBox(
      width: constraints.maxWidth * 0.18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text((program.programName.isNotEmpty) ? program.programName : program.defaultProgramName, style: Theme.of(context).textTheme.bodyLarge,),
          Text(program.sequence != null ? '${program.sequence.length} Zones' : 'Sequence is not selected'),
        ],
      ),
    ) :
    SizedBox(
      width: constraints.maxWidth * 0.25,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text((program.programName.isNotEmpty) ? program.programName : program.defaultProgramName, style: Theme.of(context).textTheme.bodyLarge,),
          Text(program.sequence != null ? '${program.sequence.length} Zones' : 'Sequence is not selected'),
        ],
      ),
    );
  }

  Widget _buildScheduleDetails(program, constraints, mainProvider) {
    final widthRatio = (constraints.maxWidth > 550 && constraints.maxWidth <= 1050) ? 0.2 : 0.25;
    String scheduleType = program.schedule['selected'] ?? '';
    String startDate = '';
    String rtcOnTime = '';
    String rtcOffTime = '';
    if (program.schedule.isNotEmpty) {
      startDate = program.schedule['selected'] == mainProvider.scheduleTypes[1]
          ? program.schedule['scheduleAsRunList']['schedule']['startDate']
          : program.schedule['scheduleByDays']['schedule']['startDate'];
      rtcOnTime = program.schedule['selected'] == mainProvider.scheduleTypes[1]
          ? program.schedule['scheduleAsRunList']['rtc']['rtc1']['onTime']
          : program.schedule['scheduleByDays']['rtc']['rtc1']['onTime'];
      rtcOffTime = program.schedule['selected'] == mainProvider.scheduleTypes[1]
          ? program.schedule['scheduleAsRunList']['rtc']['rtc1']['offTime']
          : program.schedule['scheduleByDays']['rtc']['rtc1']['offTime'];
    }

    final DateFormat formatter = DateFormat('dd-MM-yyyy');
    final formattedStartDate = program.schedule.isNotEmpty ? formatter.format(DateTime.parse(startDate)) : '';

    return SizedBox(
      width: constraints.maxWidth * widthRatio,
      child: constraints.maxWidth > 1100 ?
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(scheduleType == '' ? 'Program Data Erased': scheduleType,),
          scheduleType != "NO SCHEDULE" ? Text(formattedStartDate) : Container(),
        ],
      ) :
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(scheduleType == '' ? 'Program Data Erased': scheduleType,),
          scheduleType != "NO SCHEDULE" ? Text(formattedStartDate) : Container(),
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

    return  (constraints.maxWidth > 550 && constraints.maxWidth <= 1050) ?
    SizedBox(
      width: constraints.maxWidth * 0.1,
      child: scheduleType != "NO SCHEDULE" ? Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            scheduleType != "NO SCHEDULE" ? Text(rtcOnTime) : Container(),
            scheduleType != "NO SCHEDULE" ? Text(rtcOffTime) : Container(),
          ],
        ),
      ) : const Center(child: Text('-')),
    ) :
    SizedBox(
      width: constraints.maxWidth * 0.15,
      child: Row(
        mainAxisAlignment: scheduleType != "NO SCHEDULE" ? MainAxisAlignment.spaceBetween :  MainAxisAlignment.spaceAround,
        children: [
          scheduleType != "NO SCHEDULE" ? Column(
            children: [
              const Text('On Time'),
              Text(rtcOnTime),
            ],
          ) : const Text('-'),
          scheduleType != "NO SCHEDULE" ? Column(
            children: [
              const Text('Off Time'),
              Text(rtcOffTime),
            ],
          ) : const Text('-'),
        ],
      ),
    );
  }

  Widget _buildProgramActions(program, IrrigationProgramMainProvider mainProvider, int index) {
    return Row(
      children: [
        IconButton(
          onPressed: () => _showDeleteConfirmationDialog(mainProvider, program),
          icon: Icon(Icons.delete, color: Colors.black,),
        ),
        IconButton(
          onPressed: () => _showEditItemDialog(mainProvider, program, index),
          icon: const Icon(Icons.edit, color: Colors.black,),
        ),
        IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert, color: Colors.black,)),
      ],
    );
  }

  void _showDeleteConfirmationDialog(IrrigationProgramMainProvider mainProvider, program) {
    showAdaptiveDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return CustomAlertDialog(
              title: "Confirmation",
              content: 'Are you sure you want to delete?',
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('No'),
                ),
                TextButton(
                  onPressed: () => _deleteProgram(mainProvider, program),
                  child: const Text('Yes'),
                ),
              ]
          );
        }
    );
  }

  void _deleteProgram(IrrigationProgramMainProvider mainProvider, program) {
    mainProvider.userProgramReset(widget.userId, widget.controllerId, widget.userId, program.programId)
        .then((String message) {
      ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(message: message));
    })
        .catchError((error) {
      print('Error: $error');
    });
  }

  void _showEditItemDialog(IrrigationProgramMainProvider mainProvider, program, int index) {
    showAdaptiveDialog(
      context: context,
      builder: (BuildContext dialogContext) => Consumer<IrrigationProgramMainProvider>(
          builder: (context, scheduleProvider, child) {
            return AlertDialog(
              title: const Text('Edit Item'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    initialValue: program.programName.isNotEmpty ? program.programName : program.defaultProgramName,
                    focusNode: _programNameFocusNode,
                    onChanged: (newValue) => program.programName = newValue,
                    inputFormatters: [LengthLimitingTextInputFormatter(20)],
                  ),
                  const SizedBox(height: 5),
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15)
                    ),
                    child: CustomDropdownTile(
                      showCircleAvatar: false,
                      width: 70,
                      title: 'Priority',
                      subtitle: 'Description',
                      showSubTitle: false,
                      content: Icons.priority_high,
                      dropdownItems: mainProvider.priorityList.map((item) => item.toString()).toList(),
                      selectedValue: program.priority != 0 ? program.priority.toString() :'None',
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
          }
      ),
    );
  }

  void _saveProgramDetails(IrrigationProgramMainProvider mainProvider, program, int index) {
    mainProvider.updateUserProgramDetails(
        widget.userId,
        widget.controllerId,
        program.serialNumber,
        program.programId,
        program.programName,
        program.priority
    ).then((value) => ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(message: value)));
  }

  Widget _buildButtonsRow(IrrigationProgramMainProvider mainProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(width: 10),
        _buildOutlinedButton('ALL', mainProvider.showAllPrograms, () {
          mainProvider.updateShowPrograms(true, false, false);
        }),
        const SizedBox(width: 10),
        _buildOutlinedButton('IRRIGATION', mainProvider.showIrrigationPrograms,
                () {
              mainProvider.updateShowPrograms(false, true, false);
            }),
        const SizedBox(width: 10),
        _buildOutlinedButton('AGITATOR', mainProvider.showAgitatorPrograms, () {
          mainProvider.updateShowPrograms(false, false, true);
        }),
      ],
    );
  }

  Widget _buildOutlinedButton(String text, bool isSelected, VoidCallback onPressed) {
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
              return AlertDialog(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: programProvider.programLibrary!.programType.map((e) {
                    return RadioListTile(
                        title: Text(e),
                        value: e,
                        groupValue: programProvider.selectedProgramType,
                        onChanged: (newValue) {
                          programProvider.updateProgramName(newValue, 'programType');
                        });
                  }).toList(),
                ),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                      },
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
                                serialNumber: 0,
                                conditionsLibraryIsNotEmpty: programProvider.conditionsLibraryIsNotEmpty,
                              ),
                            ),
                          );
                        }
                        else if (programProvider.selectedProgramType == 'Agitator Program') {
                          programProvider.updateIsAgitatorProgram();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => IrrigationProgram(
                                userId: widget.userId,
                                controllerId: widget.controllerId,
                                serialNumber: 0,
                                conditionsLibraryIsNotEmpty: programProvider.conditionsLibraryIsNotEmpty,
                              ),
                            ),
                          );
                        }
                      },
                      child: const Text('OK')),
                ],
              );
            },
          ),
    );
  }
}
