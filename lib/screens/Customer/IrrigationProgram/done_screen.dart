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
                  title: 'Program Name',
                  content: Icons.perm_device_info,
                  showSubTitle: true,
                  subtitle: tempProgramName != '' ? tempProgramName : widget.serialNumber == 0
                      ? "Program ${doneProvider.programCount}"
                      : doneProvider.programDetails!.programName.isNotEmpty ? programName : doneProvider.programDetails!.defaultProgramName,
                  trailing: SizedBox(
                    width: constraints.maxWidth < 550 ? 80 : 100,
                    child: InkWell(
                      child: Icon(Icons.drive_file_rename_outline_rounded, color: Theme.of(context).primaryColor,),
                      onTap: () {
                        _textEditingController.text = widget.serialNumber == 0
                            ? "Program ${doneProvider.programCount}"
                            : doneProvider.programDetails!.programName.isNotEmpty ? programName : doneProvider.programDetails!.defaultProgramName;
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
              ),
              const SizedBox(height: 5,),
              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15)
                ),
                child: CustomDropdownTile(
                    width: constraints.maxWidth < 550 ? 80 : 100,
                    title: 'Priority',
                    subtitle: 'Description',
                    showSubTitle: true,
                    content: Icons.priority_high,
                    dropdownItems: doneProvider.priorityList.map((item) => item.toString()).toList(),
                    selectedValue: doneProvider.priority != 0 ? doneProvider.priority.toString() :'None',
                    onChanged: (newValue) => doneProvider.updateProgramName(newValue, 'priority')
                ),
              ),
              const SizedBox(height: 5,),
              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15)
                ),
                child: CustomTimerTile(
                  subtitle: 'Delay Between Zones',
                  showSubTitle: true,
                  subtitle2: "Description",
                  initialValue: doneProvider.delayBetweenZones != "" ? doneProvider.delayBetweenZones : "00:00",
                  onChanged: (newTime){
                    doneProvider.updateProgramName(newTime, 'delayBetweenZones');
                  },
                  isSeconds: false,
                  is24HourMode: true,
                  isNative: true,
                  icon: Icons.timer_outlined,
                ),
              ),
              const SizedBox(height: 5,),
              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15)
                ),
                child: CustomTextFormTile(
                  subtitle: 'Water Adjust Percentage',
                  subtitle2: "Description",
                  initialValue: doneProvider.adjustPercentage != "" ? doneProvider.adjustPercentage : "100",
                  hintText: '0%',
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp('[^0-9]')),
                    LengthLimitingTextInputFormatter(5),
                  ],
                  onChanged: (newValue){
                    doneProvider.updateProgramName(newValue, 'adjustPercentage');
                  },
                  icon: Icons.safety_check,
                  trailing: true,
                  trailingText: "%",
                ),
              ),
            ],
          );
        }
    );
  }
}

class PercentageInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Extract the numeric part of the input
    String numericValue = newValue.text.replaceAll('%', '');

    // Check if the numeric part is empty or not
    if (numericValue.isEmpty) {
      // Handle empty input (e.g., display '0%' by default)
      return TextEditingValue(
        text: '0%',
        selection: TextSelection.fromPosition(
          const TextPosition(offset: '0%'.length),
        ),
      );
    } else {
      // Format the input with the '%' symbol
      String formattedValue = '$numericValue%';

      // Ensure that the input doesn't exceed 5 characters (excluding '%')
      if (formattedValue.length <= 5) {
        return TextEditingValue(
          text: formattedValue,
          selection: TextSelection.fromPosition(
            TextPosition(offset: formattedValue.length),
          ),
        );
      } else {
        // If the input exceeds 5 characters, truncate it
        return TextEditingValue(
          text: formattedValue.substring(0, 5),
          selection: TextSelection.fromPosition(
            const TextPosition(offset: 5),
          ),
        );
      }
    }
  }
}
