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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        var programPvd = Provider.of<IrrigationProgramMainProvider>(context,listen: false);
        // programPvd.updateSequenceForFert(programPvd.irrigationLine?.sequence ?? []);
        programPvd.waterAndFert();
        programPvd.editSegmentedControlGroupValue(1);
        programPvd.selectingTheSite();
        programPvd.editGroupSiteInjector(programPvd.segmentedControlCentralLocal == 0 ? 'selectedCentralSite' : 'selectedLocalSite', programPvd.segmentedControlCentralLocal == 0 ? programPvd.selectedCentralSite :programPvd.selectedLocalSite);
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    final programPvd = Provider.of<IrrigationProgramMainProvider>(context);
    var overAllPvd = Provider.of<OverAllUse>(context,listen: true);
    return programPvd.sequenceData.isNotEmpty
        ? LayoutBuilder(builder: (context,constraints){
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFFF3F3F3),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 50,
              child: CupertinoSlidingSegmentedControl(
                // thumbColor: Theme.of(context)1.colorScheme.primary,
                  thumbColor: Colors.blueGrey,
                  groupValue: programPvd.segmentedControlGroupValue,
                  children: programPvd.myTabs,
                  onValueChanged: (i) {
                    programPvd.editSegmentedControlGroupValue(i!);
                  }),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: SizedBox(
                  height: constraints.maxHeight < 425 ? 425 : constraints.maxHeight  - 60,
                  child: Row(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 25,bottom: 19),
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
                              height: 110,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      const SizedBox(
                                        width: 30,
                                        height: 50,
                                        child: Center(
                                          child: Divider(
                                            color: Colors.black,
                                            thickness: 2,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          width: double.infinity,
                                          height: 40,
                                          child: ListView.builder(
                                              scrollDirection: Axis.horizontal,
                                              itemCount: programPvd.sequenceData.length,
                                              itemBuilder: (context,index){
                                                return InkWell(
                                                  onTap: (){
                                                    programPvd.editGroupSiteInjector('selectedGroup', index);
                                                    if(programPvd.segmentedControlCentralLocal == 0){
                                                      if(!programPvd.selectionModel.data!.centralFertilizerSite!.any((element) => element.selected == true)){
                                                        programPvd.editGroupSiteInjector('selectedCentralSite', 0);
                                                      }else{
                                                        for(var i = 0;i < programPvd.selectionModel.data!.centralFertilizerSite!.length;i++){
                                                          if(programPvd.selectionModel.data!.centralFertilizerSite![i].selected == true){
                                                            for(var j = 0;j < programPvd.sequenceData[programPvd.selectedGroup]['centralDosing'].length;j++){
                                                              if(programPvd.sequenceData[programPvd.selectedGroup]['centralDosing'][j]['sNo'] == programPvd.selectionModel.data!.centralFertilizerSite![i].sNo){
                                                                programPvd.editGroupSiteInjector('selectedCentralSite', j);
                                                              }
                                                            }
                                                          }
                                                        }
                                                      }
                                                    }else{
                                                      if(!programPvd.selectionModel.data!.localFertilizerSite!.any((element) => element.selected == true)){
                                                        programPvd.editGroupSiteInjector('selectedLocalSite', 0);
                                                      }else{
                                                        for(var i = 0;i < programPvd.selectionModel.data!.localFertilizerSite!.length;i++){
                                                          if(programPvd.selectionModel.data!.localFertilizerSite![i].selected == true){
                                                            for(var j = 0;j < programPvd.sequenceData[programPvd.selectedGroup]['localDosing'].length;j++){
                                                              if(programPvd.sequenceData[programPvd.selectedGroup]['localDosing'][j]['sNo'] == programPvd.selectionModel.data!.localFertilizerSite![i].sNo){
                                                                programPvd.editGroupSiteInjector('selectedLocalSite', j);
                                                              }
                                                            }
                                                          }
                                                        }
                                                      }
                                                    }
                                                  },
                                                  child: Container(
                                                    margin: EdgeInsets.only(left: 20),
                                                    padding: const EdgeInsets.only(left: 10,right: 10),
                                                    decoration: BoxDecoration(
                                                        color: programPvd.selectedGroup == index ? Theme.of(context).primaryColor : Colors.white,
                                                        borderRadius: BorderRadius.circular(10)
                                                    ),
                                                    child:Center(
                                                      child: Text(
                                                        programPvd.sequenceData[index]['name'],
                                                        style: TextStyle(color: programPvd.selectedGroup == index ? Colors.white : Colors.black,fontWeight: FontWeight.bold,fontSize: programPvd.selectedGroup == index ? 16 : 14),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if(programPvd.segmentedControlGroupValue == 1)
                                    Row(
                                      children: [
                                        const SizedBox(
                                          width: 30,
                                          height: 60,
                                          child: Center(
                                            child: Divider(
                                              color: Colors.black,
                                              thickness: 2,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(left: 20),
                                          width: 200,
                                          height: 50,
                                          child: CupertinoSlidingSegmentedControl(
                                            // thumbColor: Theme.of(context)1.colorScheme.primary,
                                              thumbColor: Colors.blueGrey,
                                              groupValue: programPvd.segmentedControlCentralLocal,
                                              children: programPvd.cOrL,
                                              onValueChanged: (i) {
                                                programPvd.editSegmentedCentralLocal(i!);
                                                programPvd.selectingTheSite();
                                              }),
                                        ),

                                      ],
                                    ),

                                ],
                              ),
                            ),
                            if(programPvd.segmentedControlGroupValue == 0)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const SizedBox(
                                        width: 30,
                                        height: 60,
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
                                                          height: 30,
                                                          child: const Center(child: Text('Method',style: TextStyle(color: Colors.white),)),
                                                        )
                                                    ),
                                                    Expanded(
                                                        child: Container(
                                                          color: Colors.blueGrey,
                                                          height: 30,
                                                          child: const Center(child: Text('Value',style: TextStyle(color: Colors.white,fontSize: 12))),
                                                        )
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                        child: Container(
                                                          color: Colors.white,
                                                          height: 30,
                                                          child: Center(
                                                              child: DropdownButton(
                                                                dropdownColor: Colors.white,
                                                                value: programPvd.sequenceData[programPvd.selectedGroup]['method'],
                                                                underline: Container(),
                                                                items: ['Time','Quantity'].map((String items) {
                                                                  return DropdownMenuItem(
                                                                    value: items,
                                                                    child: Text(items,style: const TextStyle(fontSize: 14,color: Colors.black),),
                                                                  );
                                                                }).toList(),
                                                                onChanged: (value) {
                                                                  programPvd.editWaterSetting('method', value.toString());
                                                                },
                                                              )
                                                          ),
                                                        )
                                                    ),
                                                    Expanded(
                                                        child: Container(
                                                          color: Colors.white,
                                                          height: 30,
                                                          child: Center(
                                                              child: SizedBox(
                                                                width: 60,
                                                                height: 28,
                                                                child: programPvd.sequenceData[programPvd.selectedGroup]['method'] == 'Quantity' ? TextFormField(
                                                                  controller: programPvd.waterQuantity,
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
                                                                    programPvd.editWaterSetting('quantityValue', value);
                                                                  },
                                                                ) :  InkWell(
                                                                  onTap: (){
                                                                    _showTimePicker(programPvd,overAllPvd,programPvd.selectedGroup,'waterTimeValue');
                                                                  },
                                                                  child: SizedBox(
                                                                    width: 80,
                                                                    height: 40,
                                                                    child: Center(
                                                                      child: Text('${programPvd.sequenceData[programPvd.selectedGroup]['timeValue']}',style: wf,),
                                                                    ),
                                                                  ),
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
                            if(programPvd.segmentedControlGroupValue == 0)
                              Row(
                                children: [
                                  const SizedBox(
                                    width: 30,
                                    height: 60,
                                    child: Center(
                                      child: Divider(
                                        color: Colors.black,
                                        thickness: 2,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 20,),
                                  Text('Moisture.Cond',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: Theme.of(context).primaryColor),),
                                  SizedBox(width: 20,),
                                  DropdownButton(
                                    dropdownColor: Colors.white,
                                    value: 'Cond 1',
                                    underline: Container(),
                                    items: ['Cond 1','Cond 2','Cond 2'].map((String items) {
                                      return DropdownMenuItem(
                                        value: items,
                                        child: Text(items,style: const TextStyle(fontSize: 14,color: Colors.black),),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                    },
                                  )
                                ],
                              ),
                            if(programPvd.segmentedControlGroupValue == 0)
                              Row(
                                children: [
                                  const SizedBox(
                                    width: 30,
                                    height: 65,
                                    child: Center(
                                      child: Divider(
                                        color: Colors.black,
                                        thickness: 2,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 20,),
                                  Text('Level.Cond',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: Theme.of(context).primaryColor),),
                                  SizedBox(width: 20,),
                                  DropdownButton(
                                    dropdownColor: Colors.white,
                                    value: 'Cond 1',
                                    underline: Container(),
                                    items: ['Cond 1','Cond 2','Cond 2'].map((String items) {
                                      return DropdownMenuItem(
                                        value: items,
                                        child: Text(items,style: const TextStyle(fontSize: 14,color: Colors.black),),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                    },
                                  )
                                ],
                              ),
                            if(programPvd.isSiteVisible(programPvd.sequenceData[programPvd.selectedGroup][programPvd.segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'],programPvd.segmentedControlCentralLocal == 0 ? 'central' : 'local') == true)
                              if(programPvd.sequenceData[programPvd.selectedGroup][programPvd.segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'].length != 0)
                                if(programPvd.segmentedControlGroupValue == 1)
                                  SizedBox(
                                    width: double.infinity,
                                    height: 40,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Checkbox(
                                            value: programPvd.sequenceData[programPvd.selectedGroup]['applyFertilizer'],
                                            onChanged: (value){
                                              programPvd.editGroupSiteInjector('applyFertilizer', value);
                                            }
                                        ),
                                        Text('Apply Fertilizer',style: wf,)
                                      ],
                                    ),
                                  ),
                            if(programPvd.isSiteVisible(programPvd.sequenceData[programPvd.selectedGroup][programPvd.segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'],programPvd.segmentedControlCentralLocal == 0 ? 'central' : 'local') == true)
                              if(programPvd.sequenceData[programPvd.selectedGroup][programPvd.segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'].length != 0)
                                if(programPvd.segmentedControlGroupValue == 1)
                                  if(programPvd.sequenceData[programPvd.selectedGroup]['applyFertilizer'])
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const SizedBox(
                                              width: 30,
                                              height: 60,
                                              child: Center(
                                                child: Divider(
                                                  color: Colors.black,
                                                  thickness: 2,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Container(
                                                width: double.infinity,
                                                height: 65,
                                                child: LayoutBuilder(
                                                    builder: (context,constraints){
                                                      return  Column(
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Text('preValue',style: wf,),
                                                              Text('method',style: wf,),
                                                              Text('postValue',style: wf,),
                                                            ],
                                                          ),
                                                          Row(
                                                            children: [
                                                              Container(
                                                                // width: returnWidth(programPvd.sequenceData[programPvd.selectedGroup]['timeValue'],programPvd.sequenceData[programPvd.selectedGroup]['preValue'],constraints.maxWidth),
                                                                width: returnWidth(programPvd,'pre',constraints.maxWidth),
                                                                color: Colors.red.shade200,
                                                                height: 15,
                                                              ),
                                                              Expanded(
                                                                child: Container(
                                                                  color: Colors.blue.shade200,
                                                                  width: double.infinity,
                                                                  height: 15,
                                                                ),
                                                              ),
                                                              Container(
                                                                // width: returnWidth(programPvd.sequenceData[programPvd.selectedGroup]['timeValue'],programPvd.sequenceData[programPvd.selectedGroup]['postValue'],constraints.maxWidth),
                                                                width: returnWidth(programPvd,'post',constraints.maxWidth),
                                                                color: Colors.orange.shade200,
                                                                height: 15,
                                                              ),
                                                            ],
                                                          ),
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Container(
                                                                width: 100,
                                                                color: Colors.white,
                                                                height: 30,
                                                                child: Center(
                                                                    child: SizedBox(
                                                                      width: 80,
                                                                      height: 28,
                                                                      child: programPvd.sequenceData[programPvd.selectedGroup]['prePostMethod'] == 'Quantity' ? TextFormField(
                                                                        controller: programPvd.preValue,
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
                                                                          programPvd.editPrePostMethod('preValue',programPvd.selectedGroup,value);
                                                                        },
                                                                      ) :  InkWell(
                                                                        onTap: (){
                                                                          _showTimePicker(programPvd,overAllPvd,programPvd.selectedGroup,'pre');
                                                                        },
                                                                        child: SizedBox(
                                                                          width: 80,
                                                                          height: 40,
                                                                          child: Center(
                                                                            child: Text('${programPvd.sequenceData[programPvd.selectedGroup]['preValue']}',style: wf,),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    )
                                                                ),
                                                              ),

                                                              Container(
                                                                width: 100,
                                                                color: Colors.white,
                                                                height: 30,
                                                                child: Center(
                                                                    child: DropdownButton(
                                                                      dropdownColor: Colors.white,
                                                                      value: programPvd.sequenceData[programPvd.selectedGroup]['prePostMethod'],
                                                                      underline: Container(),
                                                                      items: ['Time','Quantity'].map((String items) {
                                                                        return DropdownMenuItem(
                                                                          value: items,
                                                                          child: Text(items,style: const TextStyle(fontSize: 12,color: Colors.black),),
                                                                        );
                                                                      }).toList(),
                                                                      onChanged: (value) {
                                                                        programPvd.editPrePostMethod('prePostMethod',programPvd.selectedGroup,value.toString());
                                                                      },
                                                                    )
                                                                ),
                                                              ),
                                                              Container(
                                                                width: 100,
                                                                color: Colors.white,
                                                                height: 30,
                                                                child: Center(
                                                                    child: SizedBox(
                                                                      width: 60,
                                                                      height: 28,
                                                                      child: programPvd.sequenceData[programPvd.selectedGroup]['prePostMethod'] == 'Quantity' ? TextFormField(
                                                                        controller: programPvd.postValue,
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
                                                                          programPvd.editPrePostMethod('postValue',programPvd.selectedGroup,value);
                                                                        },
                                                                      ) :  InkWell(
                                                                        onTap: (){
                                                                          _showTimePicker(programPvd,overAllPvd,programPvd.selectedGroup,'post');
                                                                        },
                                                                        child: SizedBox(
                                                                          width: 80,
                                                                          height: 40,
                                                                          child: Center(
                                                                            child: Text('${programPvd.sequenceData[programPvd.selectedGroup]['postValue']}',style: wf,),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    )
                                                                ),
                                                              ),

                                                            ],
                                                          ),
                                                        ],
                                                      );
                                                    }),
                                              ),
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                            if(programPvd.isSiteVisible(programPvd.sequenceData[programPvd.selectedGroup][programPvd.segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'],programPvd.segmentedControlCentralLocal == 0 ? 'central' : 'local') == true)
                              if(programPvd.sequenceData[programPvd.selectedGroup][programPvd.segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'].length != 0)
                                if(programPvd.segmentedControlGroupValue == 1)
                                  if(programPvd.sequenceData[programPvd.selectedGroup]['applyFertilizer'])
                                    Container(
                                      height: 40,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              const SizedBox(
                                                width: 30,
                                                height: 2,
                                                child: Center(
                                                  child: Divider(
                                                    color: Colors.black,
                                                    thickness: 2,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Container(
                                                  width: double.infinity,
                                                  height: 40,
                                                  child: ListView.builder(
                                                      scrollDirection: Axis.horizontal,
                                                      itemCount: programPvd.sequenceData[programPvd.selectedGroup][programPvd.segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'].length,
                                                      itemBuilder: (context,index){
                                                        return InkWell(
                                                          onTap: (){
                                                            programPvd.editGroupSiteInjector(programPvd.segmentedControlCentralLocal == 0 ? 'selectedCentralSite' : 'selectedLocalSite', index);
                                                            programPvd.editGroupSiteInjector('selectedInjector', 0);
                                                            // programPvd.editSelectedSite(programPvd.segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing',index);
                                                          },
                                                          child: Visibility(
                                                            visible: programPvd.isSiteVisible([programPvd.sequenceData[programPvd.selectedGroup][programPvd.segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][index]],programPvd.segmentedControlCentralLocal == 0 ? 'central' : 'local'),
                                                            child: Container(
                                                              margin: EdgeInsets.only(left: 20),
                                                              padding: const EdgeInsets.only(left: 10,top: 5,bottom: 5,right: 10),
                                                              decoration: BoxDecoration(
                                                                  color: (programPvd.segmentedControlCentralLocal == 0 ? programPvd.selectedCentralSite : programPvd.selectedLocalSite) == index ? Theme.of(context).primaryColor : Colors.white,
                                                                  borderRadius: BorderRadius.circular(10)
                                                              ),
                                                              child: Column(
                                                                children: [
                                                                  Row(
                                                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                    children: [
                                                                      if(programPvd.sequenceData[programPvd.selectedGroup][programPvd.segmentedControlCentralLocal == 0 ? 'selectedCentralSite' : 'selectedLocalSite'] != index)
                                                                        Icon(Icons.radio_button_off,color: (programPvd.segmentedControlCentralLocal == 0 ? programPvd.selectedCentralSite : programPvd.selectedLocalSite) == index ? Colors.white : Colors.black,)
                                                                      else
                                                                        Icon(Icons.radio_button_checked,color: Colors.yellow,),
                                                                      SizedBox(width: 5,),
                                                                      Text(
                                                                        programPvd.sequenceData[programPvd.selectedGroup][programPvd.segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][index]['name'],
                                                                        style: TextStyle(color: (programPvd.segmentedControlCentralLocal == 0 ? programPvd.selectedCentralSite : programPvd.selectedLocalSite) == index ? Colors.white : Colors.black,fontSize: 12),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
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
                            if(programPvd.recipe != null)
                              if(programPvd.isSiteVisible(programPvd.sequenceData[programPvd.selectedGroup][programPvd.segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'],programPvd.segmentedControlCentralLocal == 0 ? 'central' : 'local') == true)
                                if(programPvd.sequenceData[programPvd.selectedGroup][programPvd.segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'].length != 0)
                                  if(programPvd.segmentedControlGroupValue == 1)
                                    if(programPvd.sequenceData[programPvd.selectedGroup]['applyFertilizer'])
                                      Container(
                                        height: 40,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                const SizedBox(
                                                  width: 30,
                                                  height: 2,
                                                  child: Center(
                                                    child: Divider(
                                                      color: Colors.black,
                                                      thickness: 2,
                                                    ),
                                                  ),
                                                ),
                                                if(programPvd.sequenceData[programPvd.selectedGroup][programPvd.segmentedControlCentralLocal == 0 ? 'selectedCentralSite' : 'selectedLocalSite'] != -1)
                                                  SizedBox(
                                                    width: 120,
                                                    height: 40,
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Checkbox(
                                                            value: programPvd.sequenceData[programPvd.selectedGroup][programPvd.segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][programPvd.segmentedControlCentralLocal == 0 ? programPvd.selectedCentralSite : programPvd.selectedLocalSite]['applyRecipe'],
                                                            onChanged: (value){
                                                              programPvd.editGroupSiteInjector('applyRecipe', value);
                                                            }
                                                        ),
                                                        Text('Apply Recipe',style: wf,)
                                                      ],
                                                    ),
                                                  ),
                                                if(programPvd.sequenceData[programPvd.selectedGroup][programPvd.segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][programPvd.sequenceData[programPvd.selectedGroup][programPvd.segmentedControlCentralLocal == 0 ? 'selectedCentralSite' : 'selectedLocalSite']]['applyRecipe'])
                                                  Expanded(
                                                    child: Container(
                                                      width: double.infinity,
                                                      height: 40,
                                                      child: ListView.builder(
                                                          scrollDirection: Axis.horizontal,
                                                          //TODO : SEE
                                                          itemCount: returnSelectedSiteRecipe(programPvd).length,
                                                          itemBuilder: (context,index){
                                                            // return Text('yes');
                                                            return InkWell(
                                                              onTap: (){
                                                                // programPvd.editGroupSiteInjector(programPvd.segmentedControlCentralLocal == 0 ? 'selectedCentralSite' : 'selectedLocalSite', index);
                                                                programPvd.editGroupSiteInjector('selectedRecipe', index);
                                                              },
                                                              child: Container(
                                                                margin: EdgeInsets.only(left: 20),
                                                                padding: const EdgeInsets.only(left: 10,top: 5,bottom: 5,right: 10),
                                                                decoration: BoxDecoration(
                                                                    color: programPvd.sequenceData[programPvd.selectedGroup][programPvd.segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][programPvd.sequenceData[programPvd.selectedGroup][programPvd.segmentedControlCentralLocal == 0 ? 'selectedCentralSite' : 'selectedLocalSite']]['recipe'] == index ? Theme.of(context).primaryColor : Colors.white,
                                                                    borderRadius: BorderRadius.circular(10)
                                                                ),
                                                                child: Column(
                                                                  children: [
                                                                    Row(
                                                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                      children: [
                                                                        if(programPvd.sequenceData[programPvd.selectedGroup][programPvd.segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][programPvd.segmentedControlCentralLocal == 0 ? programPvd.selectedCentralSite : programPvd.selectedLocalSite]['recipe'] != index)
                                                                          Icon(Icons.radio_button_off,color: programPvd.sequenceData[programPvd.selectedGroup][programPvd.segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][programPvd.sequenceData[programPvd.selectedGroup][programPvd.segmentedControlCentralLocal == 0 ? 'selectedCentralSite' : 'selectedLocalSite']]['recipe'] == index ? Colors.white : Colors.black,)
                                                                        else
                                                                          Icon(Icons.radio_button_checked,color: Colors.yellow,),
                                                                        SizedBox(width: 5,),
                                                                        Text(
                                                                          '${returnSelectedSiteRecipe(programPvd)[index]['name']}',style: TextStyle(color: programPvd.sequenceData[programPvd.selectedGroup][programPvd.segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][programPvd.sequenceData[programPvd.selectedGroup][programPvd.segmentedControlCentralLocal == 0 ? 'selectedCentralSite' : 'selectedLocalSite']]['recipe'] == index ? Colors.white : Colors.black,fontSize: 12),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ],
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
                            ////
                            if(programPvd.isSiteVisible(programPvd.sequenceData[programPvd.selectedGroup][programPvd.segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'],programPvd.segmentedControlCentralLocal == 0 ? 'central' : 'local') == true)
                              if(programPvd.sequenceData[programPvd.selectedGroup][programPvd.segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'].length != 0)
                                if(programPvd.segmentedControlGroupValue == 1)
                                  if(programPvd.sequenceData[programPvd.selectedGroup][programPvd.segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][programPvd.segmentedControlCentralLocal == 0 ? programPvd.selectedCentralSite :  programPvd.selectedLocalSite]['ecValue'] != null || programPvd.sequenceData[programPvd.selectedGroup][programPvd.segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][programPvd.segmentedControlCentralLocal == 0 ? programPvd.selectedCentralSite :  programPvd.selectedLocalSite]['phValue'] != null)
                                    if(programPvd.sequenceData[programPvd.selectedGroup]['applyFertilizer'])
                                      Row(
                                        children: [
                                          const SizedBox(
                                            width: 30,
                                            height: 2,
                                            child: Center(
                                              child: Divider(
                                                color: Colors.black,
                                                thickness: 2,
                                              ),
                                            ),
                                          ),
                                          if(programPvd.sequenceData[programPvd.selectedGroup][programPvd.segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][programPvd.selectedCentralSite]['ecValue'] != null)
                                            Container(
                                              width: 120,
                                              height: 40,
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                children: [
                                                  if(programPvd.sequenceData[programPvd.selectedGroup][programPvd.segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][programPvd.segmentedControlCentralLocal == 0 ? programPvd.selectedCentralSite : programPvd.selectedLocalSite]['needEcValue'] == false)
                                                    InkWell(
                                                        onTap: (){
                                                          programPvd.editEcPhNeedOrNot('ec');
                                                        },
                                                        child: Icon(Icons.radio_button_off,color: Colors.black,)
                                                    )
                                                  else
                                                    InkWell(
                                                        onTap: (){
                                                          programPvd.editEcPhNeedOrNot('ec');
                                                        },
                                                        child: Icon(Icons.radio_button_checked,color: Colors.green)
                                                    ),
                                                  Text("EC",style: wf,),
                                                  if(programPvd.sequenceData[programPvd.selectedGroup][programPvd.segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][programPvd.segmentedControlCentralLocal == 0 ? programPvd.selectedCentralSite : programPvd.selectedLocalSite]['needEcValue'] == true)
                                                    SizedBox(
                                                      width: 60,
                                                      height: 40,
                                                      child: TextFormField(
                                                        controller: programPvd.ec,
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
                                                          programPvd.editEcPh(programPvd.segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing', 'ecValue', value);
                                                        },
                                                      ),
                                                    )
                                                  else
                                                    SizedBox(width: 60,)
                                                ],
                                              ),
                                            ),
                                          if(programPvd.sequenceData[programPvd.selectedGroup][programPvd.segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][programPvd.segmentedControlCentralLocal == 0 ? programPvd.selectedCentralSite : programPvd.selectedLocalSite]['phValue'] != null)
                                            Container(
                                              width: 120,
                                              height: 40,
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                children: [
                                                  if(programPvd.sequenceData[programPvd.selectedGroup][programPvd.segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][programPvd.segmentedControlCentralLocal == 0 ? programPvd.selectedCentralSite : programPvd.selectedLocalSite]['needPhValue'] == false)
                                                    InkWell(
                                                        onTap: (){
                                                          programPvd.editEcPhNeedOrNot('ph');
                                                        },
                                                        child: Icon(Icons.radio_button_off,color: Colors.black,)
                                                    )
                                                  else
                                                    InkWell(
                                                        onTap: (){
                                                          programPvd.editEcPhNeedOrNot('ph');
                                                        },
                                                        child: Icon(Icons.radio_button_checked,color: Colors.green)
                                                    ),
                                                  Text("PH",style: TextStyle(fontSize: 12),),
                                                  if(programPvd.sequenceData[programPvd.selectedGroup][programPvd.segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][programPvd.segmentedControlCentralLocal == 0 ? programPvd.selectedCentralSite : programPvd.selectedLocalSite]['needPhValue'] == true)
                                                    SizedBox(
                                                      width: 60,
                                                      height: 40,
                                                      child: TextFormField(
                                                        controller: programPvd.ph,
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
                                                          programPvd.editEcPh(programPvd.segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing', 'phValue', value);
                                                        },
                                                      ),
                                                    )
                                                  else
                                                    SizedBox(width: 60,)
                                                ],
                                              ),
                                            ),
                                        ],
                                      ),

                            if(programPvd.isSiteVisible(programPvd.sequenceData[programPvd.selectedGroup][programPvd.segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'],programPvd.segmentedControlCentralLocal == 0 ? 'central' : 'local') == true)
                              if(programPvd.sequenceData[programPvd.selectedGroup][programPvd.segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'].length != 0)
                                if(programPvd.segmentedControlGroupValue == 1)
                                  if(programPvd.sequenceData[programPvd.selectedGroup]['applyFertilizer'])
                                    Container(
                                      height: 40,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              const SizedBox(
                                                width: 30,
                                                height: 2,
                                                child: Center(
                                                  child: Divider(
                                                    color: Colors.black,
                                                    thickness: 2,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Container(
                                                  width: double.infinity,
                                                  height: 40,
                                                  child: ListView.builder(
                                                      scrollDirection: Axis.horizontal,
                                                      itemCount: programPvd.sequenceData[programPvd.selectedGroup][programPvd.segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][programPvd.segmentedControlCentralLocal == 0 ? programPvd.selectedCentralSite : programPvd.selectedLocalSite]['fertilizer'].length,
                                                      itemBuilder: (context,index){
                                                        return InkWell(
                                                          onTap: (){
                                                            programPvd.editGroupSiteInjector('selectedInjector', index);
                                                          },
                                                          child: Container(
                                                            margin: EdgeInsets.only(left: 20),
                                                            padding: const EdgeInsets.only(left: 10,right: 10),
                                                            decoration: BoxDecoration(
                                                                color: programPvd.selectedInjector == index ? Theme.of(context).primaryColor : Colors.white,
                                                                borderRadius: BorderRadius.circular(10)
                                                            ),
                                                            child: Column(
                                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    Text(
                                                                      programPvd.sequenceData[programPvd.selectedGroup][programPvd.segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][programPvd.segmentedControlCentralLocal == 0 ? programPvd.selectedCentralSite : programPvd.selectedLocalSite]['fertilizer'][index]['name'],
                                                                      style: TextStyle(color: programPvd.selectedInjector == index ? Colors.white : Colors.black,fontSize: 12),
                                                                    ),
                                                                    SizedBox(
                                                                      width: 10,
                                                                    ),
                                                                    Switch(
                                                                        activeTrackColor: Colors.green,
                                                                        activeColor: Colors.yellow.shade50,
                                                                        value: programPvd.sequenceData[programPvd.selectedGroup][programPvd.segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][programPvd.segmentedControlCentralLocal == 0 ? programPvd.selectedCentralSite : programPvd.selectedLocalSite]['fertilizer'][index]['onOff'],
                                                                        onChanged: (value){
                                                                          programPvd.editOnOffInInjector(programPvd.segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing',index,value);
                                                                        }
                                                                    )
                                                                  ],
                                                                ),

                                                              ],
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
                            if(programPvd.isSiteVisible(programPvd.sequenceData[programPvd.selectedGroup][programPvd.segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'],programPvd.segmentedControlCentralLocal == 0 ? 'central' : 'local') == true)
                              if(programPvd.sequenceData[programPvd.selectedGroup][programPvd.segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'].length != 0)
                                if(programPvd.segmentedControlGroupValue == 1)
                                  if(programPvd.sequenceData[programPvd.selectedGroup]['applyFertilizer'])
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const SizedBox(
                                              width: 30,
                                              height: 60,
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
                                                                height: 30,
                                                                child: const Center(child: Text('Method',style: TextStyle(color: Colors.white,fontSize: 12),)),
                                                              )
                                                          ),
                                                          Expanded(
                                                              child: Container(
                                                                color: Colors.blueGrey,
                                                                height: 30,
                                                                child: const Center(child: Text('Value',style: TextStyle(color: Colors.white,fontSize: 12))),
                                                              )
                                                          ),
                                                        ],
                                                      ),
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                              child: Container(
                                                                color: Colors.white,
                                                                height: 30,
                                                                child: Center(
                                                                    child: DropdownButton(
                                                                      dropdownColor: Colors.white,
                                                                      value: programPvd.sequenceData[programPvd.selectedGroup][programPvd.segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][programPvd.segmentedControlCentralLocal == 0 ? programPvd.selectedCentralSite : programPvd.selectedLocalSite]['fertilizer'][programPvd.selectedInjector]['method'],
                                                                      underline: Container(),
                                                                      items: ['Time','Pro.time','Quantity','Pro.quantity'].map((String items) {
                                                                        return DropdownMenuItem(
                                                                          value: items,
                                                                          child: Text(items,style: const TextStyle(fontSize: 12,color: Colors.black),),
                                                                        );
                                                                      }).toList(),
                                                                      onChanged: (value) {
                                                                        programPvd.editParticularChannelDetails('method', programPvd.segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing', value);
                                                                      },
                                                                    )
                                                                ),
                                                              )
                                                          ),
                                                          Expanded(
                                                              child: Container(
                                                                color: Colors.white,
                                                                height: 30,
                                                                child: Center(
                                                                    child: SizedBox(
                                                                      width: 60,
                                                                      height: 28,
                                                                      child: ['Pro.quantity','Quantity'].contains(programPvd.sequenceData[programPvd.selectedGroup][programPvd.segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][programPvd.segmentedControlCentralLocal == 0 ? programPvd.selectedCentralSite : programPvd.selectedLocalSite]['fertilizer'][programPvd.selectedInjector]['method']) ? TextFormField(
                                                                        controller: programPvd.injectorValue,
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
                                                                          programPvd.editParticularChannelDetails('quantityValue', programPvd.segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing', value);
                                                                        },
                                                                      ) :  InkWell(
                                                                        onTap: (){
                                                                          _showTimePicker(programPvd,overAllPvd,programPvd.selectedGroup,'timeValue');
                                                                        },
                                                                        child: SizedBox(
                                                                          width: 80,
                                                                          height: 40,
                                                                          child: Center(
                                                                            child: Text('${programPvd.sequenceData[programPvd.selectedGroup][programPvd.segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][programPvd.segmentedControlCentralLocal == 0 ? programPvd.selectedCentralSite : programPvd.selectedLocalSite]['fertilizer'][programPvd.selectedInjector]['timeValue']}',style: TextStyle(fontSize: 12),),
                                                                          ),
                                                                        ),
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
                            if(programPvd.sequenceData[programPvd.selectedGroup][programPvd.segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'].length == 0 || programPvd.isSiteVisible(programPvd.sequenceData[programPvd.selectedGroup][programPvd.segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'],programPvd.segmentedControlCentralLocal == 0 ? 'central' : 'local') == false)
                              if(programPvd.segmentedControlGroupValue == 1)
                                Row(
                                  children: [
                                    const SizedBox(
                                      width: 30,
                                      height: 60,
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

                            SizedBox(
                              height: 60,
                              // margin: const EdgeInsets.only(bottom: 25),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                      height: 20,
                                      margin: const EdgeInsets.only(left: 30),
                                      child: const Text('Click next to change channel',style: TextStyle(fontStyle: FontStyle.italic,fontWeight: FontWeight.bold,fontSize: 12),)),
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
                                            programPvd.editBack();
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
                                            programPvd.editNext();
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
    })
        : const Center(child: Padding(
      padding: EdgeInsets.all(8.0),
      child: Text('Without selecting sequence, water and fertigation can not be configured', textAlign: TextAlign.center,style: TextStyle(fontSize: 12),),
    ),);

  }
  void _showTimePicker(IrrigationProgramMainProvider programPvd,OverAllUse overAllPvd,int index,String purpose) async {
    overAllPvd.editTimeAll();
    // programPvd.sequenceData[programPvd.selectedGroup]['timeValue'],programPvd.sequenceData[programPvd.selectedGroup]['postValue']
    await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          surfaceTintColor: Colors.white,
          backgroundColor: Colors.white,
          title: const Column(
            children: [
              Text(
                'Select time',style: TextStyle(fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          content: MyTimePicker(displayHours: true,hourString: 'hr',hrsLimit: (purpose == 'waterTimeValue' || purpose ==  'timeValue' ) ? null : returnHrsLimit(programPvd,purpose) as int, displayMins: true,minString: 'min',secString: 'sec', displaySecs: true, displayCustom: false, CustomString: '', CustomList: [0,10], displayAM_PM: false,),
          actionsAlignment: MainAxisAlignment.end,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel',style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold,fontSize: 12),),
            ),
            TextButton(
              onPressed: () {
                if(purpose == 'post'){
                  programPvd.editPrePostMethod('postValue',programPvd.selectedGroup,'${overAllPvd.hrs < 10 ? '0' :''}${overAllPvd.hrs}:${overAllPvd.min < 10 ? '0' :''}${overAllPvd.min}:${overAllPvd.sec < 10 ? '0' :''}${overAllPvd.sec}');
                }else if(purpose == 'pre'){
                  programPvd.editPrePostMethod('preValue',programPvd.selectedGroup,'${overAllPvd.hrs < 10 ? '0' :''}${overAllPvd.hrs}:${overAllPvd.min < 10 ? '0' :''}${overAllPvd.min}:${overAllPvd.sec < 10 ? '0' :''}${overAllPvd.sec}');
                }else if(purpose == 'timeValue'){
                  programPvd.editParticularChannelDetails('timeValue', programPvd.segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing', '${overAllPvd.hrs < 10 ? '0' :''}${overAllPvd.hrs}:${overAllPvd.min < 10 ? '0' :''}${overAllPvd.min}:${overAllPvd.sec < 10 ? '0' :''}${overAllPvd.sec}');
                }else if(purpose == 'waterTimeValue'){
                  programPvd.editWaterSetting('timeValue', '${overAllPvd.hrs < 10 ? '0' :''}${overAllPvd.hrs}:${overAllPvd.min < 10 ? '0' :''}${overAllPvd.min}:${overAllPvd.sec < 10 ? '0' :''}${overAllPvd.sec}');
                }
                Navigator.of(context).pop();
              },
              child: Text('OK',style: TextStyle(color: Theme.of(context).primaryColor,fontWeight: FontWeight.bold,fontSize: 12)),
            ),
          ],
        );
      },
    );
  }
}

int returnHrsLimit(IrrigationProgramMainProvider programPvd,String preOrPostValue){
  var diff = programPvd.waterValueInSec() - (preOrPostValue == 'pre' ? programPvd.postValueInSec() : programPvd.preValueInSec());
  // print('diff : $diff');
  var limit = (diff/3600 - 1).round();
  // print('limit : ${limit}');
  return limit as int < 1 ? 0 : limit as int;
}

double returnWidth(IrrigationProgramMainProvider programPvd,String preOrPostValue,double screenWidth){
  var water = programPvd.waterValueInSec();
  var ratio = water / (preOrPostValue == 'pre' ? programPvd.preValueInSec() : programPvd.postValueInSec());
  // print('water : $water || prePost : ${(preOrPostValue == 'pre' ? programPvd.preValueInSec() : programPvd.postValueInSec())} || ratio : $ratio');
  return (ratio == 0 || water == 0 || ratio.isInfinite) ? 0 : screenWidth/ratio;
}

List<dynamic> returnSelectedSiteRecipe(IrrigationProgramMainProvider programPvd){
  var list = [];
  // print('recipe : ${programPvd.recipe}');
  for(var i in programPvd.recipe){
    var selectedSite = programPvd.sequenceData[programPvd.selectedGroup][programPvd.segmentedControlCentralLocal == 0 ? 'selectedCentralSite' : 'selectedLocalSite'];
    if(selectedSite != -1){
      if(programPvd.sequenceData[programPvd.selectedGroup][programPvd.segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][selectedSite]['sNo'] == i['sNo']){
        list = i['recipe'];
      }
    }
  }
  // print('selectes recipe : ${list}');
  return list;
}

TextStyle wf = const TextStyle(fontSize: 12);
