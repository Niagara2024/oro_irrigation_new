import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../state_management/irrigation_program_main_provider.dart';
import '../../../widgets/SCustomWidgets/custom_list_tile.dart';
import '../../../widgets/SCustomWidgets/custom_snack_bar.dart';
import 'irrigation_program_main.dart';

class ProgramLibraryScreen extends StatefulWidget {
  final int userId;
  final int controllerId;

  const ProgramLibraryScreen({Key? programLibraryKey, this.userId = 1, this.controllerId = 1}) : super(key: programLibraryKey);

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Program Library'),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () => _showAdaptiveDialog(context, mainProvider),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: _buildProgramList(mainProvider),
    );
  }

  Widget _buildProgramList(IrrigationProgramMainProvider mainProvider) {
    return mainProvider.programLibrary?.program != null
        ? (mainProvider.programLibrary!.program.isNotEmpty
        ? _buildProgramListView(mainProvider)
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

  Widget _buildProgramListView(IrrigationProgramMainProvider mainProvider) {
    return Column(
      children: [
        const SizedBox(height: 10),
        _buildButtonsRow(mainProvider),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.builder(
            itemCount: mainProvider.programLibrary!.program.length,
            itemBuilder: (context, index) {
              return _buildProgramItem(mainProvider, index);
            },
          ),
        ),
      ],
    );
  }


  Widget _buildProgramItem(IrrigationProgramMainProvider mainProvider, int index) {
    final program = mainProvider.programLibrary!.program[index];

    if (
    (mainProvider.showIrrigationPrograms && program.programType == 'Irrigation Program')
        || (mainProvider.showAllPrograms)
    ) {
      return Visibility(
        visible: true,  // Adjust this based on your specific conditions
        child: Column(
          children: [
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => IrrigationProgram(
                      userId: widget.userId,
                      controllerId: widget.controllerId,
                      serialNumber: program.serialNumber,
                      programType: program.programType,
                    ),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: CustomTile(
                  title: (program.programName.isNotEmpty)
                      ? program.programName
                      : program.defaultProgramName,
                  showCircleAvatar: true,
                  content: '${index + 1}',
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          mainProvider.userProgramReset(widget.userId, widget.controllerId, widget.userId, program.programId)
                              .then((String message) {
                            ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(message: message));
                          }).catchError((error) {
                            print('Error: $error');
                          });
                        },
                        icon: Icon(Icons.delete_outline),
                      ),
                      IconButton(
                        onPressed: () {
                          showAdaptiveDialog(
                            context: context,
                            builder: (dialogContext) => Consumer<IrrigationProgramMainProvider>(
                                builder: (context, scheduleProvider, child) {
                                  return AlertDialog(
                                    title: const Text('Edit Item'),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TextFormField(
                                          initialValue: (program.programName.isNotEmpty)
                                              ? program.programName
                                              : program.defaultProgramName,
                                          // autofocus: true,
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
                                              selectedValue: program.priority != 0 ? mainProvider.priority.toString() :'None',
                                              onChanged: (newValue) {
                                                mainProvider.updateProgramName(newValue, 'priority');
                                                _programNameFocusNode.unfocus();
                                              }
                                          ),
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(dialogContext);
                                        },
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(dialogContext);
                                          mainProvider.updateUserProgramDetails(
                                              widget.userId,
                                              widget.controllerId,
                                              program.serialNumber,
                                              program.programId,
                                              program.programName,
                                              mainProvider.selectedProgramType,
                                              mainProvider.priority
                                          ).then(
                                                  (value) => ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(message: value))
                                          );
                                        },
                                        child: const Text('Save'),
                                      ),
                                    ],
                                  );
                                }),
                          );
                        },
                        icon: const Icon(Icons.edit),
                      ),
                      IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 5),
          ],
        ),
      );
    } else {
      return Container();
    }
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
                              ),
                            ),
                          );
                        } else if (programProvider.selectedProgramType ==
                            'Agitator Program') {
                          programProvider.updateIsAgitatorProgram();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => IrrigationProgram(
                                userId: widget.userId,
                                controllerId: widget.controllerId,
                                serialNumber: 0,
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
