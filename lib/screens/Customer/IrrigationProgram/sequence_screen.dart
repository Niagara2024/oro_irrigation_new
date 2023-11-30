import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../Models/IrrigationModel/irrigation_program_model.dart';
import '../../../state_management/irrigation_program_main_provider.dart';
import '../../../widgets/SCustomWidgets/custom_alert_dialog.dart';
import '../../../widgets/SCustomWidgets/custom_train_widget.dart';


class SequenceScreen extends StatefulWidget {
  final int userId;
  final int controllerId;
  final int serialNumber;
  const SequenceScreen({Key? sequenceScreenKey, required this.userId, required this.controllerId, required this.serialNumber}) : super(key: sequenceScreenKey);

  @override
  State<SequenceScreen> createState() => _SequenceScreenState();
}

class _SequenceScreenState extends State<SequenceScreen> {

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sequenceProvider = Provider.of<IrrigationProgramMainProvider>(context);
    final Map<int, GlobalKey> itemKeys = {};

    return Column(
      children: [
        const SizedBox(height: 10,),
        SizedBox(
          height: 60,
          child: (sequenceProvider.irrigationLine != null || sequenceProvider.irrigationLine!.sequence.isNotEmpty)
              ? ReorderableListView.builder(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            onReorder: (oldIndex, newIndex) {
              sequenceProvider.reorderSelectedValves(oldIndex, newIndex);
            },
            proxyDecorator: (widget, animation, index) {
              return Transform.scale(
                scale: 1.05,
                child: widget,
              );
            },
            itemCount: sequenceProvider.irrigationLine!.sequence.length,
            itemBuilder: (context, index) {
              final valveList = sequenceProvider.irrigationLine!.sequence[index]['selected'];
              final nonEmptyStrings = valveList?.toList();
              if (!itemKeys.containsKey(index)) {
                itemKeys[index] = GlobalKey();
              }
              return Card(
                key: itemKeys[index],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                color: Theme.of(context).primaryColor,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    child: Text(
                      nonEmptyStrings!.join(' & '),
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              );
            },
          )
              : const Center(child: Text('Select desired sequence')),
        ),
        const SizedBox(height: 10,),
        Expanded(
          child: ListView.builder(
            itemCount: (widget.serialNumber == 0
                ? sequenceProvider.isIrrigationProgram
                : sequenceProvider.programDetails?.programType == "Irrigation Program")
                ? (sequenceProvider.irrigationLine?.defaultData.group != null
                ? sequenceProvider.irrigationLine!.defaultData.line.length + 1
                : sequenceProvider.irrigationLine!.defaultData.line.length)
                : 1,
            itemBuilder: (context, index){
              final linesMap = sequenceProvider.irrigationLine?.defaultData.line.asMap();
              final groupMap = sequenceProvider.irrigationLine?.defaultData.group.asMap();
              final totalLength = groupMap != null ? linesMap!.length + groupMap.length : linesMap!.length;
              if (widget.serialNumber == 0 ? sequenceProvider.isIrrigationProgram : sequenceProvider.programDetails?.programType == "Irrigation Program") {
                if (index == 0) {
                  if(sequenceProvider.irrigationLine!.defaultData.namedGroup || sequenceProvider.irrigationLine!.defaultData.group.isNotEmpty) {
                    return Column(
                      children: [
                        CustomTrainWidget(
                            title: 'Named Group',
                            child: Expanded(
                              child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: sequenceProvider.irrigationLine?.defaultData.group.asMap().length,
                                  itemBuilder: (context, index) {
                                    final groupMap = sequenceProvider.irrigationLine?.defaultData.group.asMap();
                                    if(index < groupMap!.length) {
                                      final valveEntry = groupMap.entries.elementAt(index);
                                      final valveIndex = valveEntry.key;
                                      final groupValve = valveEntry.value;

                                      return Row(
                                        children: [
                                          InkWell(
                                            child: Card(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(12)
                                              ),
                                              elevation: 2,
                                              surfaceTintColor: Colors.white,
                                              color: sequenceProvider.isSelected(valveIndex, 0, true)
                                                  ? Theme.of(context).colorScheme.secondary
                                                  : Colors.white,
                                              borderOnForeground: true,
                                              semanticContainer: true,
                                              child: Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Text(groupValve.name, style: Theme.of(context).textTheme.bodyLarge),
                                              ),
                                            ),
                                            // onTap: () {
                                            //   sequenceProvider.valveSelection(groupValve.sNo, 0, index, true);
                                            //   if (sequenceProvider.isRecentlySelected) {
                                            //     showAdaptiveDialog(
                                            //       context: context,
                                            //       builder: (BuildContext context) {
                                            //         return CustomAlertDialog(
                                            //           title: 'Warning',
                                            //           content: "Valve ${groupValve.name} is recently added and it cannot be added again next to it",
                                            //           actions: [
                                            //             TextButton(child: const Text("OK"), onPressed: () => Navigator.of(context).pop(),),
                                            //           ],
                                            //         );
                                            //       },
                                            //     );
                                            //   }
                                            // }
                                          ),
                                          const SizedBox(width: 5,)
                                        ],
                                      );
                                    } else {
                                      return const Text('No Valves');
                                    }
                                  }
                              ),
                            )
                        ),
                        const SizedBox(height: 10,),
                      ],
                    );
                  } else {
                    return Container();
                  }
                }
                if (index <= totalLength) {
                  final lineEntry = linesMap.entries.elementAt(index-1);
                  final lineIndex = lineEntry.key;
                  final line = lineEntry.value;

                  return Column(
                    children: [
                      CustomTrainWidget(
                          title: line.name,
                          child: Expanded(
                            child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: line.valve.length,
                                itemBuilder: (context, index) {
                                  final valvesMap = line.valve.asMap();
                                  if(index < valvesMap.length) {
                                    final valveEntry = valvesMap.entries.elementAt(index);
                                    final valveIndex = valveEntry.key;
                                    final valveMap = valveEntry.value;
                                    final sNo = valveMap.sNo;
                                    final id = valveMap.id;
                                    final name = valveMap.name;
                                    final location = valveMap.location;

                                    return Row(
                                      children: [
                                        InkWell(
                                            child: Card(
                                              shape: const CircleBorder(),
                                              elevation: 2,
                                              borderOnForeground: true,
                                              semanticContainer: true,
                                              child: CircleAvatar(
                                                  radius: 25,
                                                  backgroundColor: sequenceProvider.isSelected(valveIndex, lineIndex, false)
                                                      ? Theme.of(context).colorScheme.secondary
                                                      : Colors.white,
                                                  child: Center(child: Text('${index+1}', style: Theme.of(context).textTheme.bodyLarge))
                                              ),
                                            ),
                                            onTap: () {
                                              Valve valve = Valve(
                                                sNo: sNo,
                                                id: id,
                                                location: location,
                                                name: name,
                                              );
                                              sequenceProvider.valveSelection(valve, lineIndex, index, false);
                                              if (sequenceProvider.isRecentlySelected) {
                                                showAdaptiveDialog(
                                                  context: context,
                                                  builder: (BuildContext context) {
                                                    return CustomAlertDialog(
                                                      title: 'Warning',
                                                      content: "Valve ${valveIndex+1} in ${line.name} is recently added and it cannot be added again next to it",
                                                      actions: [
                                                        TextButton(child: const Text("OK"), onPressed: () => Navigator.of(context).pop()),
                                                      ],
                                                    );
                                                  },
                                                );
                                              }
                                              else if (sequenceProvider.isStartTogether) {
                                                showAdaptiveDialog(
                                                  context: context,
                                                  builder: (BuildContext context) {
                                                    return CustomAlertDialog(
                                                      title: 'Warning',
                                                      content: "Enable 'Start Together' option in the dealer definition to add multiple valves in multiple lines",
                                                      actions: [
                                                        TextButton(child: const Text("OK"), onPressed: () => Navigator.of(context).pop(),),
                                                      ],
                                                    );
                                                  },
                                                );
                                              }
                                              else if (sequenceProvider.isReuseValve) {
                                                showAdaptiveDialog(
                                                  context: context,
                                                  builder: (BuildContext context) {
                                                    return CustomAlertDialog(
                                                      title: 'Warning',
                                                      content: "Enable 'Reuse valve' option in the dealer definition to reuse the valves in the sequence",
                                                      actions: [
                                                        TextButton(child: const Text("OK"), onPressed: () => Navigator.of(context).pop(),),
                                                      ],
                                                    );
                                                  },
                                                );
                                              }
                                            }
                                        ),
                                        const SizedBox(width: 5,)
                                      ],
                                    );
                                  } else {
                                    return const Text('No Valves');
                                  }
                                }
                            ),
                          )
                      ),
                      const SizedBox(height: 10,)
                    ],
                  );
                }
                return null;
              }
              else {
                if(sequenceProvider.irrigationLine!.defaultData.agitator.isNotEmpty) {
                  final agitatorEntry = sequenceProvider.irrigationLine?.defaultData.agitator.asMap();
                  final agitatorIndex = agitatorEntry!.entries;
                  final agitator = sequenceProvider.irrigationLine?.defaultData.agitator;
                  return CustomTrainWidget(
                      title: 'Agitators',
                      child: Expanded(
                        child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: agitator?.length,
                            itemBuilder: (context, index) {
                              if(index <= agitator!.length) {
                                final sNo = agitator[index].sNo;
                                final id = agitator[index].id;
                                final name = agitator[index].name;
                                final location = agitator[index].location;

                                return Row(
                                  children: [
                                    InkWell(
                                        child: Card(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(15)
                                          ),
                                          elevation: 2,
                                          color: sequenceProvider.isSelected(index, 0, true)
                                              ? Theme.of(context).colorScheme.secondary
                                              : Colors.white,
                                          borderOnForeground: true,
                                          semanticContainer: true,
                                          surfaceTintColor: Colors.white,
                                          child: Center(child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(name, style: Theme.of(context).textTheme.bodyLarge),
                                          )),
                                        ),
                                        onTap: () {
                                          Valve agitator = Valve(
                                            sNo: sNo,
                                            id: id,
                                            location: location,
                                            name: name,
                                          );
                                          sequenceProvider.updateIsAgitator();
                                          sequenceProvider.valveSelection(agitator, 0, 0, false);
                                        }
                                    ),
                                    const SizedBox(width: 5,)
                                  ],
                                );
                              } else {
                                return const Text('No Valves');
                              }
                            }
                        ),
                      )
                  );               }
              }
            },
          ),
        ),
      ],
    );
  }
}
