import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../Models/IrrigationModel/sequence_model.dart';
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
  final ScrollController _scrollController = ScrollController();
  Map<int, ScrollController> itemScrollControllers = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sequenceProvider = Provider.of<IrrigationProgramMainProvider>(context);
    final Map<int, GlobalKey> itemKeys = {};
    var sequenceIndex = 0;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Column(
          children: [
            const SizedBox(height: 10,),
            SizedBox(
              height: 60,
              width: double.infinity,
              child: (sequenceProvider.irrigationLine!.sequence.isNotEmpty)
                  ? Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onHorizontalDragUpdate: (details) {
                        _scrollController
                            .jumpTo(_scrollController.offset - details.primaryDelta! / 2);
                      },
                      child: Center(
                        child: ReorderableListView.builder(
                          scrollController: _scrollController,
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
                            // sequenceIndex = sequenceProvider.irrigationLine!.sequence[index];
                            // print(sequenceProvider.irrigationLine!.sequence[index]);
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
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 60,
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(10), bottomLeft: Radius.circular(15))
                    ),
                    child: IconButton(
                      icon: Transform.rotate(
                        angle: 600,
                        child: const Icon(Icons.cut),
                      ),
                      onPressed: (){
                        sequenceProvider.isNext;
                        sequenceProvider.enableSkipNex();
                      },
                    ),
                  )
                ],
              )
                  : const Center(child: Text('Select desired sequence')),
            ),
            const SizedBox(height: 10,),
            Expanded(
              child: ListView.builder(
                padding: constraints.maxWidth > 550 ? EdgeInsets.symmetric(horizontal: constraints.maxWidth * 0.025) : EdgeInsets.zero,
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
                  if (widget.serialNumber == 0
                      ? sequenceProvider.isIrrigationProgram
                      : sequenceProvider.programDetails?.programType == "Irrigation Program") {
                    if (index == 0) {
                      if(sequenceProvider.irrigationLine!.defaultData.namedGroup && sequenceProvider.irrigationLine!.defaultData.group.isNotEmpty) {
                        return Column(
                          children: [
                            CustomTrainWidget(
                                title: 'Predefined Groups',
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

                                          return GestureDetector(
                                            child: Row(
                                              children: [
                                                InkWell(
                                                    child: Card(
                                                      shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(12)
                                                      ),
                                                      elevation: 2,
                                                      surfaceTintColor: Colors.white,
                                                      color: sequenceProvider.isSelected(valveIndex, 0, true, false, groupValve.name)
                                                          ? Theme.of(context).colorScheme.secondary
                                                          : Colors.white,
                                                      borderOnForeground: true,
                                                      semanticContainer: true,
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(8.0),
                                                        child: Text(groupValve.name, style: Theme.of(context).textTheme.bodyLarge),
                                                      ),
                                                    ),
                                                    onTap: () {
                                                      List<dynamic> valve = groupValve.valve.map((e) => Valve(
                                                        sNo: e.sNo,
                                                        id: e.id,
                                                        location: e.location,
                                                        name: e.name,
                                                      ).toJson()).toList();
                                                      sequenceProvider.valveSelection(valve, 0, index, true,
                                                          widget.serialNumber == 0 ? sequenceProvider.serialNumberCreation : widget.serialNumber);
                                                      if (sequenceProvider.groupAdding) {
                                                        showAdaptiveDialog(
                                                          context: context,
                                                          builder: (BuildContext context) {
                                                            return CustomAlertDialog(
                                                              title: 'Warning',
                                                              content: "Group cannot be added into group",
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
                                            ),
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

                      if (!itemScrollControllers.containsKey(lineIndex)) {
                        // If not, create a new ScrollController for the current item
                        itemScrollControllers[lineIndex] = ScrollController();
                      }

                      // Use the individual ScrollController for the current item
                      ScrollController? itemScrollController = itemScrollControllers[lineIndex];

                      return Column(
                        children: [
                          CustomTrainWidget(
                              title: line.name,
                              child: Expanded(
                                child: GestureDetector(
                                  onHorizontalDragUpdate: (details) {
                                    itemScrollController?.jumpTo(itemScrollController.offset - details.primaryDelta! / 2);
                                  },
                                  child: ListView.builder(
                                      controller: itemScrollController,
                                      scrollDirection: Axis.horizontal,
                                      itemCount: line.valve.length,
                                      itemBuilder: (context, index) {
                                        final valvesMap = line.valve.asMap();
                                        if(index < valvesMap.length) {
                                          final valveEntry = valvesMap.entries.elementAt(index);
                                          final valveIndex = valveEntry.key;
                                          final valveMap = valveEntry.value;

                                          return Row(
                                            children: [
                                              InkWell(
                                                  child: Card(
                                                    shape: constraints.maxWidth < 550
                                                        ? const CircleBorder()
                                                        : RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                    color: constraints.maxWidth > 550
                                                        ? sequenceProvider.isSelected(valveIndex, lineIndex, false, true, valveMap.name)
                                                        ? Theme.of(context).colorScheme.secondary
                                                        : Colors.white : null,
                                                    surfaceTintColor: Colors.white,
                                                    elevation: 2,
                                                    borderOnForeground: true,
                                                    semanticContainer: true,
                                                    child: constraints.maxWidth < 550 ? CircleAvatar(
                                                        radius: 25,
                                                        backgroundColor: sequenceProvider.isSelected(valveIndex, lineIndex, false, false, valveMap.name)
                                                            ? Theme.of(context).colorScheme.secondary
                                                            : Colors.white,
                                                        child: Center(child: Text('${index+1}', style: Theme.of(context).textTheme.bodyLarge))
                                                    ) : Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: Text(valveMap.name),
                                                    ),
                                                  ),
                                                  onTap: () {
                                                    Valve valve = Valve(
                                                      sNo: valveMap.sNo,
                                                      id: valveMap.id,
                                                      location: valveMap.location,
                                                      name: valveMap.name,
                                                    );
                                                    int targetIndex = sequenceIndex;
                                                    // print(targetIndex);
                                                    double itemSize = 60.0;
                                                    double targetOffset = targetIndex * itemSize;
                                                    _scrollController.animateTo(targetOffset, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
                                                    sequenceProvider.valveSelection(valve.toJson(), lineIndex, index, false, widget.serialNumber == 0
                                                        ? sequenceProvider.serialNumberCreation
                                                        : widget.serialNumber,
                                                    );
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
                                                    } else if (sequenceProvider.groupAdding) {
                                                      showAdaptiveDialog(
                                                        context: context,
                                                        builder: (BuildContext context) {
                                                          return CustomAlertDialog(
                                                            title: 'Warning',
                                                            content: "Group added cannot be added into group",
                                                            actions: [
                                                              TextButton(child: const Text("OK"), onPressed: () => Navigator.of(context).pop(),),
                                                            ],
                                                          );
                                                        },
                                                      );
                                                    }
                                                    // else if(sequenceProvider.groupCannotAdd){
                                                    //   showAdaptiveDialog(
                                                    //     context: context,
                                                    //     builder: (BuildContext context) {
                                                    //       return CustomAlertDialog(
                                                    //         title: 'Warning',
                                                    //         content: "Group cannot added while 'Multiple Valve Mode is enabled",
                                                    //         actions: [
                                                    //           TextButton(child: const Text("OK"), onPressed: () => Navigator.of(context).pop(),),
                                                    //         ],
                                                    //       );
                                                    //     },
                                                    //   );
                                                    // }
                                                    // print(sequenceProvider.groupCannotAdd);
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
                                              color: sequenceProvider.isSelected(index, 0, true, false, name)
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
                                              sequenceProvider.valveSelection(agitator.toJson(), 0, 0, false,
                                                  widget.serialNumber == 0 ? sequenceProvider.serialNumberCreation : widget.serialNumber);
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
                  return null;
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
