import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../state_management/irrigation_program_main_provider.dart';
import '../../../state_management/overall_use.dart';
import '../../../widgets/my_number_picker.dart';


class WaterAndFertScreen extends StatefulWidget {
  final int userId;
  final int controllerId;
  final int serialNumber;
  const WaterAndFertScreen({super.key, required this.userId, required this.controllerId, required this.serialNumber});

  @override
  State<WaterAndFertScreen> createState() => _WaterAndFertScreenState();
}

class _WaterAndFertScreenState extends State<WaterAndFertScreen> with SingleTickerProviderStateMixin{
  int selectedGroupHover = 0;
  String selectedOption = '';
  dynamic apiData = {};
  int selectedSiteHover = 0;
  int selectedInjectorHover = 0;
  TextEditingController dosingMethodPlanned = TextEditingController();
  TextEditingController ec = TextEditingController();
  TextEditingController ph = TextEditingController();
  TextEditingController flow = TextEditingController();
  ScrollController scrollControllerGroup = ScrollController();
  ScrollController scrollControllerSite = ScrollController();
  ScrollController scrollControllerInjector = ScrollController();
  bool timePickerShow = false;

  TextStyle segment(){
    return const TextStyle();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        var programPvd = Provider.of<IrrigationProgramMainProvider>(context,listen: false);
        programPvd.updateSequenceForFert(programPvd.irrigationLine?.sequence ?? []);
        programPvd.waterAndFert({'selectedGroup' : programPvd.sequence[programPvd.selectedGroup],'data' : programPvd.apiData});
        programPvd.editSegmentedControlGroupValue(0);
        if(programPvd.segmentedControlGroupValue == 0){
          flow.text = programPvd.currentSequenceDetails[programPvd.sequence[programPvd.selectedGroup]]?['flow'];
        }

        if(programPvd.segmentedControlGroupValue == 1){
          if(checkForChannel(programPvd) == true){
            dosingMethodPlanned.text = takeCurrentChannel(programPvd)['type'] == 'Time' ? takeCurrentChannel(programPvd)['time'] : takeCurrentChannel(programPvd)['flow'];
            ec.text = takeCurrentChannel(programPvd)['EC'];
            ph.text = takeCurrentChannel(programPvd)['PH'];
          }
        }
      });
    }
  }
  dynamic takeCurrentChannel(IrrigationProgramMainProvider programPvd){
    return programPvd.currentSequenceDetails[programPvd.sequence[programPvd.selectedGroup]]['dSite'][programPvd.selectedSite]['injector'][programPvd.selectedInjector];
  }

  bool checkForChannel(IrrigationProgramMainProvider programPvd,[String? extra]){
    if(programPvd.currentSequenceDetails.isEmpty){

      return false;
    }else{
      if(programPvd.currentSequenceDetails[programPvd.sequence[programPvd.selectedGroup]]['dSite'].length != 0){
        return true;
      }else{
        return false;
      }
    }
  }

  void moveGroup(int index,[double? length]){
    setState(() {
      double screenWidth = MediaQuery.of(context).size.width;
      double itemWidth = length ?? 100.0;
      double offset = (index * itemWidth) - (screenWidth / 2) + (itemWidth / 2);

      scrollControllerGroup.animateTo(
        offset < 0 ? 0 : offset,
        duration: const Duration(milliseconds: 500),
        curve: Curves.ease,
      );
    });
  }
  void moveSite(int index,[double? length]){
    setState(() {
      double screenWidth = MediaQuery.of(context).size.width;
      double itemWidth = length ?? 100.0;
      double offset = (index * itemWidth) - (screenWidth / 2) + (itemWidth / 2);
      scrollControllerSite.animateTo(
        offset < 0 ? 0 : offset,
        duration: const Duration(milliseconds: 500),
        curve: Curves.ease,
      );
    });
  }
  void moveInjector(int index){
    setState(() {
      double screenWidth = MediaQuery.of(context).size.width;
      double itemWidth = 100.0;
      double offset = (index * itemWidth) - (screenWidth / 2) + (itemWidth / 2);

      scrollControllerInjector.animateTo(
        offset < 0 ? 0 : offset,
        duration: const Duration(milliseconds: 500),
        curve: Curves.ease,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final programPvd = Provider.of<IrrigationProgramMainProvider>(context);
    var overAllPvd = Provider.of<OverAllUse>(context,listen: true);
    return LayoutBuilder(builder: (context,constraints){
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFFF3F3F3),
        child: Column(
          children: [
            SizedBox(
              width: constraints.maxWidth < 350 ? double.infinity : 350,
              height: 50,
              child: CupertinoSlidingSegmentedControl(
                // thumbColor: myTheme1.colorScheme.primary,
                  thumbColor: Colors.blueGrey,
                  groupValue: programPvd.segmentedControlGroupValue,
                  children: programPvd.myTabs,
                  onValueChanged: (i) {
                    programPvd.editSegmentedControlGroupValue(i!);
                    if(i == 1){
                      if(checkForChannel(programPvd) == true){
                        dosingMethodPlanned.text = takeCurrentChannel(programPvd)['type'] == 'Time' ? takeCurrentChannel(programPvd)['time'] : takeCurrentChannel(programPvd)['flow'];
                        ec.text = takeCurrentChannel(programPvd)['EC'];
                        ph.text = takeCurrentChannel(programPvd)['PH'];
                      }
                    }
                  }),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: SizedBox(
                  height: constraints.maxHeight < 425 ? 425 : constraints.maxHeight  - 60,
                  child: Row(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 39,bottom: 19),
                        width: 10,
                        height: double.infinity,
                        decoration: const BoxDecoration(
                            border: Border(right: BorderSide(width: 2))
                        ),
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 60,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                      height : 20,
                                      margin: const EdgeInsets.only(left: 40),
                                      child: const Text('Select Group',style: TextStyle(fontStyle: FontStyle.italic,fontWeight: FontWeight.bold),)),
                                  SizedBox(
                                    height: 40,
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        const SizedBox(
                                          width: 30,
                                          // height: 75,
                                          child: Center(
                                            child: Divider(
                                              color: Colors.black,
                                              thickness: 2,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: SizedBox(
                                            width: double.infinity,
                                            height: 40,
                                            child: ListView.builder(
                                                controller: scrollControllerGroup,
                                                scrollDirection: Axis.horizontal,
                                                itemCount: programPvd.sequence.length,
                                                itemBuilder: (context,index){

                                                  return InkWell(
                                                    onHover: (value){
                                                      setState(() {
                                                        if(value){
                                                          selectedGroupHover = index;
                                                        }else{
                                                          selectedGroupHover = -1;
                                                        }
                                                      });
                                                    },
                                                    onTap: (){
                                                      moveGroup(index);
                                                      programPvd.editGroupSiteInjector('selectedGroup', index);
                                                      programPvd.editGroupSiteInjector('selectedSite', 0);
                                                      programPvd.editGroupSiteInjector('selectedInjector', 0);
                                                      programPvd.waterAndFert({'selectedGroup' :programPvd.sequence[programPvd.selectedGroup],'data' : programPvd.apiData});
                                                      if(programPvd.segmentedControlGroupValue == 0){
                                                        setState(() {
                                                          flow.text = programPvd.currentSequenceDetails[programPvd.sequence[programPvd.selectedGroup]]?['flow'];
                                                        });
                                                      }
                                                      if(programPvd.segmentedControlGroupValue == 1){
                                                        if(checkForChannel(programPvd) == true){
                                                          setState(() {
                                                            dosingMethodPlanned.text = takeCurrentChannel(programPvd)['type'] == 'Time' ? takeCurrentChannel(programPvd)['time'] : takeCurrentChannel(programPvd)['flow'];
                                                            ec.text = takeCurrentChannel(programPvd)['EC'];
                                                            ph.text = takeCurrentChannel(programPvd)['PH'];
                                                          });
                                                        }
                                                      }
                                                      },
                                                    child: Card(
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(5),
                                                      ),
                                                      color: programPvd.selectedGroup == index ? Theme.of(context).primaryColor : selectedGroupHover == index ? Colors.blueGrey.shade50 : Colors.white,
                                                      child: Container(
                                                        padding: const EdgeInsets.only(left: 10,top: 5,bottom: 5,right: 10),
                                                        child: Center(
                                                          child: Text(
                                                            programPvd.sequence[index],
                                                            style: TextStyle(color: programPvd.selectedGroup == index ? Colors.white : Colors.black),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                }),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if(programPvd.segmentedControlGroupValue == 0)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      SizedBox(
                                        width: 30,
                                        height: 20,
                                        child: Center(
                                          child: Divider(
                                            color: Colors.black,
                                            thickness: 2,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 10,),
                                      Text('Set Water Setting',style: TextStyle(fontStyle: FontStyle.italic,fontWeight: FontWeight.bold),)
                                    ],
                                  ),
                                  const SizedBox(height: 10,),
                                  SizedBox(
                                    width: 250,
                                    height: 60,
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Row(
                                          children: [
                                            SizedBox(width: 50,),
                                            Text('Water Type',style: TextStyle(fontStyle: FontStyle.italic,fontWeight: FontWeight.bold,color: Colors.blueGrey),),
                                            SizedBox(width: 10,),
                                            Text(':',style: TextStyle(fontStyle: FontStyle.italic,fontWeight: FontWeight.bold,color: Colors.blueGrey),),
                                            SizedBox(width: 10,),
                                          ],
                                        ),
                                        SizedBox(
                                          width: 80,
                                          height: 30,
                                          child: Center(
                                              child: DropdownButton(
                                                value: programPvd.currentSequenceDetails[programPvd.sequence[programPvd.selectedGroup]]?['type'],
                                                underline: Container(),
                                                items: ['Time','Flow'].map((String items) {
                                                  return DropdownMenuItem(
                                                    value: items,
                                                    child: Text(items,style: const TextStyle(fontSize: 14,color: Colors.black),),
                                                  );
                                                }).toList(),
                                                onChanged: (value) {
                                                  programPvd.editWaterSetting('type',value.toString());
                                                  // if(checkForChannel(programPvd) == true){
                                                  //   setState(() {
                                                  //     dosing_method_planned.text = takeCurrentChannel(programPvd)['type] == 'Time' ? takeCurrentChannel(programPvd)['time] : takeCurrentChannel(programPvd)['flow];
                                                  //     EC.text = takeCurrentChannel(programPvd)['EC'];
                                                  //     PH.text = takeCurrentChannel(programPvd)['PH'];
                                                  //   });
                                                  //
                                                  // }
                                                },

                                              )
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10,),
                                  SizedBox(
                                    width: 250,
                                    height: 60,
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Row(
                                          children: [
                                            SizedBox(width: 50,),
                                            Text('Time',style: TextStyle(fontStyle: FontStyle.italic,fontWeight: FontWeight.bold,color: Colors.blueGrey),),
                                            SizedBox(width: 10,),
                                            Text(':',style: TextStyle(fontStyle: FontStyle.italic,fontWeight: FontWeight.bold,color: Colors.blueGrey),),
                                            SizedBox(width: 10,),
                                          ],
                                        ),
                                        InkWell(
                                          onTap: (){
                                            setState(() {
                                              timePickerShow = true;
                                            });
                                            if(timePickerShow == true){
                                              _showTimePicker(programPvd,overAllPvd);
                                            }
                                          },
                                          child: SizedBox(
                                            width: 80,
                                            height: 40,
                                            child: Center(
                                              child: Text('${programPvd.currentSequenceDetails[programPvd.sequence[programPvd.selectedGroup]]?['time']}'),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: 250,
                                    height: 60,
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Row(
                                          children: [
                                            SizedBox(width: 50,),
                                            Text('Flow',style: TextStyle(fontStyle: FontStyle.italic,fontWeight: FontWeight.bold,color: Colors.blueGrey),),
                                            SizedBox(width: 10,),
                                            Text(':',style: TextStyle(fontStyle: FontStyle.italic,fontWeight: FontWeight.bold,color: Colors.blueGrey),),
                                            SizedBox(width: 10,),
                                          ],
                                        ),
                                        SizedBox(
                                          width: 80,
                                          height: 40,
                                          child: Center(
                                              child: TextFormField(
                                                controller: flow,
                                                style: const TextStyle(fontSize: 13),
                                                decoration: const InputDecoration(
                                                  contentPadding: EdgeInsets.all(0),
                                                  focusedBorder: UnderlineInputBorder(
                                                    borderSide: BorderSide(color: Colors.blue), // Focused bottom border color
                                                  ),
                                                  enabledBorder: UnderlineInputBorder(
                                                    borderSide: BorderSide(color: Colors.grey), // Unfocused bottom border color
                                                  ),
                                                ),
                                              )
                                          ),
                                        )


                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            if(programPvd.segmentedControlGroupValue == 1)
                              if(programPvd.isThereData = true)
                                if(checkForChannel(programPvd,'inside widget') == true)
                                  SizedBox(
                                    height: 60,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                            height: 20,
                                            margin: const EdgeInsets.only(left: 30),
                                            child: const Text('Select Site',style: TextStyle(fontStyle: FontStyle.italic,fontWeight: FontWeight.bold),)),
                                        Row(
                                          children: [
                                            const SizedBox(
                                              width: 30,
                                              child: Center(
                                                child: Divider(
                                                  color: Colors.black,
                                                  thickness: 2,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: SizedBox(
                                                width: double.infinity,
                                                height: 40,
                                                child: ListView.builder(
                                                    controller: scrollControllerSite,
                                                    scrollDirection: Axis.horizontal,
                                                    itemCount: programPvd.currentSequenceDetails[programPvd.sequence[programPvd.selectedGroup]]['dSite'].length,
                                                    itemBuilder: (context,index){
                                                      return InkWell(
                                                        onHover: (value){
                                                          setState(() {
                                                            if(value){
                                                              selectedSiteHover = index;
                                                            }else{
                                                              selectedSiteHover = -1;
                                                            }
                                                          });
                                                        },
                                                        onTap: (){
                                                          moveSite(index,150);
                                                          programPvd.editGroupSiteInjector('selectedSite', index);
                                                          programPvd.editGroupSiteInjector('selectedInjector', 0);
                                                          if(checkForChannel(programPvd) == true){
                                                            setState(() {
                                                              dosingMethodPlanned.text = takeCurrentChannel(programPvd)['type'] == 'Time' ? takeCurrentChannel(programPvd)['time'] : takeCurrentChannel(programPvd)['flow'];
                                                              ec.text = takeCurrentChannel(programPvd)['EC'];
                                                              ph.text = takeCurrentChannel(programPvd)['PH'];
                                                            });
                                                          }
                                                        },
                                                        child: Card(
                                                          color: programPvd.selectedSite == index ? Theme.of(context).primaryColor : selectedSiteHover == index ? Colors.blueGrey.shade50 : Colors.white,
                                                          surfaceTintColor: programPvd.selectedSite == index ? Theme.of(context).primaryColor : Colors.white,
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.circular(5)
                                                          ),
                                                          child: Container(
                                                              padding: const EdgeInsets.only(left: 10,right: 10,top: 5,bottom: 5),
                                                              child: Center(child: Text('${programPvd.currentSequenceDetails[programPvd.sequence[programPvd.selectedGroup]]['dSite'][index]['name']}',style: TextStyle(color: programPvd.selectedSite == index ? Colors.white : Colors.black),))
                                                          ),
                                                        ),
                                                      );
                                                    }),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  )
                                else
                                  const Row(
                                    children: [
                                      SizedBox(
                                        width: 30,
                                        height: 100,
                                        child: Center(
                                          child: Divider(
                                            color: Colors.black,
                                            thickness: 2,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        'Not Available: \u{1F6AB}', // Unicode for "no entry" emoji
                                        style: TextStyle(fontSize: 36,color: Colors.red),
                                      ),
                                    ],
                                  ),
                            if(programPvd.segmentedControlGroupValue == 1)
                              if(programPvd.isThereData = true)
                                if(checkForChannel(programPvd,'inside widget') == true)
                                  SizedBox(
                                    height: 65,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                            margin: const EdgeInsets.only(left: 30),
                                            child: const Text('Select Injector',style: TextStyle(fontStyle: FontStyle.italic,fontWeight: FontWeight.bold),)),
                                        Row(
                                          children: [
                                            const SizedBox(
                                              width: 30,
                                              child: Center(
                                                child: Divider(
                                                  color: Colors.black,
                                                  thickness: 2,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: SizedBox(
                                                width: double.infinity,
                                                height: 40,
                                                child: ListView.builder(
                                                    controller: scrollControllerInjector,
                                                    scrollDirection: Axis.horizontal,
                                                    itemCount: programPvd.currentSequenceDetails[programPvd.sequence[programPvd.selectedGroup]]['dSite'][programPvd.selectedSite]['injector'].length,
                                                    itemBuilder: (context,index){
                                                      return InkWell(
                                                        onHover: (value){
                                                          setState(() {
                                                            if(value){
                                                              selectedInjectorHover = index;
                                                            }else{
                                                              selectedInjectorHover = -1;
                                                            }
                                                          });
                                                        },
                                                        onTap: (){
                                                          moveInjector(index);
                                                          programPvd.editGroupSiteInjector('selectedInjector', index);
                                                          if(checkForChannel(programPvd) == true){
                                                            setState(() {
                                                              dosingMethodPlanned.text = takeCurrentChannel(programPvd)['type'] == 'Time' ? takeCurrentChannel(programPvd)['time'] : takeCurrentChannel(programPvd)['flow'];
                                                              ec.text = takeCurrentChannel(programPvd)['EC'];
                                                              ph.text = takeCurrentChannel(programPvd)['PH'];
                                                            });
                                                          }
                                                        },
                                                        child: Card(
                                                          color: programPvd.selectedInjector == index ? Theme.of(context).primaryColor : selectedInjectorHover == index ? Colors.blueGrey.shade50 : Colors.white,
                                                          surfaceTintColor: programPvd.selectedInjector == index ? Theme.of(context).primaryColor : Colors.white,
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.circular(5)
                                                          ),
                                                          child: Container(
                                                              padding: const EdgeInsets.only(left: 10,right: 10,top: 5,bottom: 5),
                                                              child: Center(child: Text('${programPvd.currentSequenceDetails[programPvd.sequence[programPvd.selectedGroup]]['dSite'][programPvd.selectedSite]['injector'][index]['name']}',style: TextStyle(color: programPvd.selectedInjector == index ? Colors.white : Colors.black),))
                                                          ),
                                                        ),
                                                      );
                                                    }),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                            if(programPvd.segmentedControlGroupValue == 1)
                              if(programPvd.isThereData = true)
                                if(checkForChannel(programPvd,'inside widget') == true)
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 5,),
                                      Container(
                                          margin: const EdgeInsets.only(left: 30),
                                          child: const Text('Select Dosing Method',style: TextStyle(fontStyle: FontStyle.italic,fontWeight: FontWeight.bold),)),
                                      Row(
                                        children: [
                                          const SizedBox(
                                            width: 30,
                                            height: 100,
                                            child: Center(
                                              child: Divider(
                                                color: Colors.black,
                                                thickness: 2,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                              child: Container(
                                                padding: const EdgeInsets.only(left: 10,right: 10),
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                            child: Container(
                                                              color: Colors.blueGrey,
                                                              height: 40,
                                                              child: const Center(child: Text('Method',style: TextStyle(color: Colors.white),)),
                                                            )
                                                        ),
                                                        Expanded(
                                                            child: Container(
                                                              color: Colors.blueGrey,
                                                              height: 40,
                                                              child: const Center(child: Text('Planned',style: TextStyle(color: Colors.white))),
                                                            )
                                                        ),
                                                        Expanded(
                                                            child: Container(
                                                              color: Colors.blueGrey,
                                                              height: 40,
                                                              child: const Center(child: Text('EC',style: TextStyle(color: Colors.white))),
                                                            )
                                                        ),
                                                        Expanded(
                                                            child: Container(
                                                              color: Colors.blueGrey,
                                                              height: 40,
                                                              child: const Center(child: Text('PH',style: TextStyle(color: Colors.white))),
                                                            )
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                            child: Container(
                                                              color: Colors.white,
                                                              height: 40,
                                                              child: Center(
                                                                  child: DropdownButton(
                                                                    dropdownColor: Colors.white,
                                                                    value: programPvd.currentSequenceDetails[programPvd.sequence[programPvd.selectedGroup]]['dSite'][programPvd.selectedSite]['injector'][programPvd.selectedInjector]['type'],
                                                                    underline: Container(),
                                                                    items: ['Time','Flow'].map((String items) {
                                                                      return DropdownMenuItem(
                                                                        value: items,
                                                                        child: Text(items,style: const TextStyle(fontSize: 14,color: Colors.black),),
                                                                      );
                                                                    }).toList(),
                                                                    onChanged: (value) {
                                                                      programPvd.editParticularChannelDetails('type',value.toString());
                                                                      if(checkForChannel(programPvd) == true){
                                                                        setState(() {
                                                                          dosingMethodPlanned.text = takeCurrentChannel(programPvd)['type'] == 'Time' ? takeCurrentChannel(programPvd)['time'] : takeCurrentChannel(programPvd)['flow'];
                                                                          ec.text = takeCurrentChannel(programPvd)['EC'];
                                                                          ph.text = takeCurrentChannel(programPvd)['PH'];
                                                                        });
                                                                      }
                                                                    },
                                                                  )
                                                              ),
                                                            )
                                                        ),
                                                        Expanded(
                                                            child: Container(
                                                              color: Colors.white,
                                                              height: 40,
                                                              child: Center(
                                                                  child: SizedBox(
                                                                    width: 80,
                                                                    height: 30,
                                                                    child: TextFormField(
                                                                      controller: dosingMethodPlanned,
                                                                      maxLength: 6,
                                                                      textAlign: TextAlign.center,
                                                                      style: const TextStyle(fontSize: 13),
                                                                      decoration: const InputDecoration(
                                                                          counterText: '',
                                                                          contentPadding: EdgeInsets.only(bottom: 5),
                                                                          enabledBorder: OutlineInputBorder(
                                                                          ),
                                                                          border: OutlineInputBorder(

                                                                              borderSide: BorderSide(width: 1)
                                                                          )
                                                                      ),
                                                                      onChanged: (value){
                                                                        programPvd.editParticularChannelDetails('flow',value);
                                                                      },
                                                                    ),
                                                                    // child: TextField(
                                                                    //
                                                                    // ),
                                                                    // child: Text('${programPvd.currentChannel['flow]}'),
                                                                  )
                                                              ),
                                                            )
                                                        ),
                                                        Expanded(
                                                            child: Container(
                                                              color: Colors.white,
                                                              height: 40,
                                                              child: Center(
                                                                  child: SizedBox(
                                                                    width: 60,
                                                                    height: 30,
                                                                    child: TextFormField(
                                                                      controller: ec,
                                                                      maxLength: 6,
                                                                      textAlign: TextAlign.center,
                                                                      style: const TextStyle(fontSize: 13),
                                                                      decoration: const InputDecoration(
                                                                          counterText: '',
                                                                          contentPadding: EdgeInsets.only(bottom: 5),
                                                                          enabledBorder: OutlineInputBorder(
                                                                          ),
                                                                          border: OutlineInputBorder(

                                                                              borderSide: BorderSide(width: 1)
                                                                          )
                                                                      ),
                                                                      onChanged: (value){
                                                                        programPvd.editParticularChannelDetails('EC',value);
                                                                      },
                                                                    ),
                                                                  )
                                                              ),
                                                            )
                                                        ),
                                                        Expanded(
                                                            child: Container(
                                                              color: Colors.white,
                                                              height: 40,
                                                              child: Center(
                                                                  child: SizedBox(
                                                                    width: 60,
                                                                    height: 30,
                                                                    child: TextFormField(
                                                                      controller: ph,
                                                                      maxLength: 6,
                                                                      textAlign: TextAlign.center,
                                                                      style: const TextStyle(fontSize: 13),
                                                                      decoration: const InputDecoration(
                                                                          counterText: '',
                                                                          contentPadding: EdgeInsets.only(bottom: 5),
                                                                          enabledBorder: OutlineInputBorder(
                                                                          ),
                                                                          border: OutlineInputBorder(

                                                                              borderSide: BorderSide(width: 1)
                                                                          )
                                                                      ),
                                                                      onChanged: (value){
                                                                        programPvd.editParticularChannelDetails('PH',value);
                                                                      },
                                                                    ),
                                                                  )
                                                              ),
                                                            )
                                                        ),
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              )
                                          )

                                        ],
                                      ),
                                    ],
                                  ),

                            SizedBox(
                              height: 60,
                              // margin: const EdgeInsets.only(bottom: 25),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                      height: 20,
                                      margin: const EdgeInsets.only(left: 30),
                                      child: const Text('Click next to change channel',style: TextStyle(fontStyle: FontStyle.italic,fontWeight: FontWeight.bold),)),
                                  SizedBox(
                                    height: 40,
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        const SizedBox(
                                          width: 30,
                                          height: 40,
                                          child: Center(
                                            child: Divider(
                                              color: Colors.black,
                                              thickness: 2,
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: (){
                                            bool injector = false;
                                            bool site = false;
                                            if(programPvd.segmentedControlGroupValue == 1){
                                              if(checkForChannel(programPvd) == true){
                                                if(programPvd.selectedInjector != 0){
                                                  if(checkForChannel(programPvd) == true){
                                                    programPvd.editBackForGroupSiteInjector('selectedInjector');
                                                    moveInjector(programPvd.selectedInjector);
                                                    setState(() {
                                                      dosingMethodPlanned.text = takeCurrentChannel(programPvd)['type'] == 'Time' ? takeCurrentChannel(programPvd)['time'] : takeCurrentChannel(programPvd)['flow'];
                                                      ec.text = takeCurrentChannel(programPvd)['EC'];
                                                      ph.text = takeCurrentChannel(programPvd)['PH'];
                                                    });
                                                    injector = true;
                                                  }
                                                }
                                                if(injector == false && programPvd.selectedSite != 0){
                                                  if(checkForChannel(programPvd) == true){
                                                    programPvd.editBackForGroupSiteInjector('selectedSite');
                                                    programPvd.editGroupSiteInjector('selectedInjector', programPvd.currentSequenceDetails[programPvd.sequence[programPvd.selectedGroup]]['dSite'][programPvd.selectedSite]['injector'].length - 1);
                                                    moveSite(programPvd.selectedSite);
                                                    moveInjector(programPvd.selectedInjector);
                                                    setState(() {
                                                      dosingMethodPlanned.text = takeCurrentChannel(programPvd)['type'] == 'Time' ? takeCurrentChannel(programPvd)['time'] : takeCurrentChannel(programPvd)['flow'];
                                                      ec.text = takeCurrentChannel(programPvd)['EC'];
                                                      ph.text = takeCurrentChannel(programPvd)['PH'];
                                                    });
                                                    site = true;
                                                  }
                                                }
                                              }
                                            }
                                            if(injector == false && site == false && programPvd.selectedGroup != 0){
                                              programPvd.editBackForGroupSiteInjector('selectedGroup');
                                              moveGroup(programPvd.selectedGroup);
                                              programPvd.waterAndFert({'selectedGroup' : programPvd.sequence[programPvd.selectedGroup],'data' : programPvd.apiData});
                                              if(programPvd.segmentedControlGroupValue == 1){
                                                if(checkForChannel(programPvd) == true){
                                                  programPvd.editGroupSiteInjector('selectedSite', programPvd.currentSequenceDetails[programPvd.sequence[programPvd.selectedGroup]]['dSite'].length - 1);
                                                  programPvd.editGroupSiteInjector('selectedInjector', programPvd.currentSequenceDetails[programPvd.sequence[programPvd.selectedGroup]]['dSite'][programPvd.selectedSite]['injector'].length - 1);
                                                  setState(() {
                                                    dosingMethodPlanned.text = takeCurrentChannel(programPvd)['type'] == 'Time' ? takeCurrentChannel(programPvd)['time'] : takeCurrentChannel(programPvd)['flow'];
                                                    ec.text = takeCurrentChannel(programPvd)['EC'];
                                                    ph.text = takeCurrentChannel(programPvd)['PH'];
                                                  });
                                                }
                                              }

                                            }
                                          },
                                          child: Container(
                                            width: 80,
                                            height: 35,
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(5),
                                                color: Colors.white
                                            ),
                                            child: const Center(child: Text('Back',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: Colors.black),)),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        InkWell(
                                          onTap: (){
                                            bool injector = false;
                                            bool site = false;
                                            if(programPvd.segmentedControlGroupValue == 1){
                                              if(checkForChannel(programPvd) == true){
                                                if(programPvd.selectedInjector != programPvd.currentSequenceDetails[programPvd.sequence[programPvd.selectedGroup]]['dSite'][programPvd.selectedSite]['injector'].length - 1){
                                                  if(checkForChannel(programPvd) == true){
                                                    programPvd.editNextForGroupSiteInjector('selectedInjector');
                                                    if(programPvd.segmentedControlGroupValue == 1){
                                                      moveInjector(programPvd.selectedInjector);
                                                      setState(() {
                                                        dosingMethodPlanned.text = takeCurrentChannel(programPvd)['type'] == 'Time' ? takeCurrentChannel(programPvd)['time'] : takeCurrentChannel(programPvd)['flow'];
                                                        ec.text = takeCurrentChannel(programPvd)['EC'];
                                                        ph.text = takeCurrentChannel(programPvd)['PH'];
                                                      });
                                                      injector = true;
                                                    }
                                                  }
                                                }
                                                if(injector == false && programPvd.selectedSite != programPvd.currentSequenceDetails[programPvd.sequence[programPvd.selectedGroup]]['dSite'].length - 1){
                                                  if(checkForChannel(programPvd) == true){
                                                    programPvd.editNextForGroupSiteInjector('selectedSite');
                                                    programPvd.editGroupSiteInjector('selectedInjector', 0);
                                                    moveSite(programPvd.selectedSite);
                                                    moveInjector(programPvd.selectedInjector);
                                                    setState(() {
                                                      dosingMethodPlanned.text = takeCurrentChannel(programPvd)['type'] == 'Time' ? takeCurrentChannel(programPvd)['time'] : takeCurrentChannel(programPvd)['flow'];
                                                      ec.text = takeCurrentChannel(programPvd)['EC'];
                                                      ph.text = takeCurrentChannel(programPvd)['PH'];
                                                    });
                                                    site = true;
                                                  }
                                                }
                                              }
                                            }
                                            if(injector == false && site == false && programPvd.selectedGroup != programPvd.sequence.length - 1){
                                              moveGroup(programPvd.selectedGroup);
                                              programPvd.editNextForGroupSiteInjector('selectedGroup');
                                              programPvd.waterAndFert({'selectedGroup' : programPvd.sequence[programPvd.selectedGroup],'data' : programPvd.apiData});
                                              if(programPvd.segmentedControlGroupValue == 1){
                                                if(checkForChannel(programPvd,'i created') == true){
                                                  programPvd.editGroupSiteInjector('selectedSite', 0);
                                                  programPvd.editGroupSiteInjector('selectedInjector', 0);
                                                  moveSite(programPvd.selectedSite);
                                                  moveInjector(programPvd.selectedInjector);
                                                  setState(() {
                                                    dosingMethodPlanned.text = takeCurrentChannel(programPvd)['type'] == 'Time' ? takeCurrentChannel(programPvd)['time'] : takeCurrentChannel(programPvd)['flow'];
                                                    ec.text = takeCurrentChannel(programPvd)['EC'];
                                                    ph.text = takeCurrentChannel(programPvd)['PH'];
                                                  });
                                                }
                                              }

                                            }
                                          },
                                          child: Container(
                                            width: 80,
                                            height: 35,
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(5),
                                                color: Colors.green
                                            ),
                                            child: const Center(child: Text('Next',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: Colors.white),)),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });

  }
  void _showTimePicker(IrrigationProgramMainProvider programPvd,OverAllUse overAllPvd) async {
    overAllPvd.editTimeAll();
    await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          surfaceTintColor: Colors.white,
          backgroundColor: Colors.white,
          title: const Column(
            children: [
              Text(
                'Select time',style: TextStyle(color: Colors.black),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          content: MyTimePicker(displayHours: true,hourString: 'hr', displayMins: true,minString: 'min',secString: 'sec', displaySecs: true, displayCustom: false, CustomString: '', CustomList: [0,10], displayAM_PM: false,),
          actionsAlignment: MainAxisAlignment.end,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel',style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold),),
            ),
            TextButton(
              onPressed: () {
                programPvd.editWaterSetting('time','${overAllPvd.hrs < 10 ? '0' :''}${overAllPvd.hrs}:${overAllPvd.min < 10 ? '0' :''}${overAllPvd.min}:${overAllPvd.sec < 10 ? '0' :''}${overAllPvd.sec}');
                Navigator.of(context).pop();
              },
              child: Text('OK',style: TextStyle(color: Theme.of(context).primaryColor,fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

}
