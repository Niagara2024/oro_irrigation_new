import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../state_management/irrigation_program_main_provider.dart';
import '../../../widgets/SCustomWidgets/custom_list_tile.dart';

class DoneScreen extends StatefulWidget {
  final int userId;
  final int controllerId;
  final int serialNumber;
  const DoneScreen({super.key, required this.userId, required this.controllerId, required this.serialNumber});


  @override
  State<DoneScreen> createState() => _DoneScreenState();
}

class _DoneScreenState extends State<DoneScreen> {
  final TextEditingController _textEditingController = TextEditingController();
  String tempProgramName = '';
  @override
  Widget build(BuildContext context) {
    final doneProvider = Provider.of<IrrigationProgramMainProvider>(context);
    String programName = doneProvider.programName == ''? "Program ${doneProvider.programCount}" : doneProvider.programName;

    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return ListView(
            padding: constraints.maxWidth > 550
                ? EdgeInsets.symmetric(horizontal: constraints.maxWidth * 0.025, vertical: constraints.maxWidth * 0.025)
                : const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            children: [
              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15)
                ),
                child: CustomTile(
                  title: 'PROGRAM NAME',
                  content: Icons.perm_device_info,
                  showSubTitle: true,
                  subtitle: widget.serialNumber == 0
                      ? "Program ${doneProvider.programCount}"
                      : doneProvider.programDetails!.programName.isNotEmpty ? programName : doneProvider.programDetails!.defaultProgramName,
                  trailing: InkWell(
                    child: Icon(Icons.drive_file_rename_outline_rounded, color: Theme.of(context).primaryColor,),
                    onTap: () {
                      _textEditingController.text = doneProvider.programDetails!.programName.isNotEmpty
                          ? programName
                          : doneProvider.programDetails!.defaultProgramName;
                      _textEditingController.selection = TextSelection(
                        baseOffset: 0,
                        extentOffset: _textEditingController.text.length,
                      );
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text("Edit program name"),
                          content: TextFormField(
                            autofocus: true,
                            controller: _textEditingController,
                            onChanged: (newValue) => tempProgramName = newValue,
                            inputFormatters: [LengthLimitingTextInputFormatter(20)],
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              child: const Text("CANCEL", style: TextStyle(color: Colors.red),),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(ctx).pop();
                                doneProvider.updateProgramName(tempProgramName, 'programName');
                              },
                              child: const Text("OKAY", style: TextStyle(color: Colors.green),),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15)
                ),
                child: CustomSwitchTile(
                    title: 'Completion option',
                    icon: const Icon(Icons.incomplete_circle, color: Colors.black,),
                    subtitle: 'Description',
                    showSubTitle: true,
                    showCircleAvatar: true,
                    value: doneProvider.isCompletionEnabled,
                    onChanged: (newValue) => doneProvider.updateProgramName(newValue, 'completion')
                ),
              ),
              const SizedBox(height: 5,),
              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15)
                ),
                child: CustomDropdownTile(
                    width: 70,
                    title: 'Priority',
                    subtitle: 'Description',
                    showSubTitle: true,
                    content: Icons.priority_high,
                    dropdownItems: doneProvider.priorityList.map((item) => item.toString()).toList(),
                    selectedValue: doneProvider.priority != 0 ? doneProvider.priority.toString() :'None',
                    onChanged: (newValue) => doneProvider.updateProgramName(newValue, 'priority')
                ),
              ),
            ],
          );
        }
    );
  }
}
