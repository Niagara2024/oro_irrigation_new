import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../state_management/FertilizerSetProvider.dart';
import '../../../state_management/overall_use.dart';
import '../../../widgets/my_number_picker.dart';

class ListOfFertilizerInSet extends StatefulWidget {
  final int index;
  final int recipeIndex;
  const ListOfFertilizerInSet({super.key, required this.index, required this.recipeIndex});

  @override
  State<ListOfFertilizerInSet> createState() => _ListOfFertilizerInSetState();
}

class _ListOfFertilizerInSetState extends State<ListOfFertilizerInSet> {
  @override
  Widget build(BuildContext context) {
    var fertSetPvd = Provider.of<FertilizerSetProvider>(context, listen: true);
    var overAllPvd = Provider.of<OverAllUse>(context,listen: true);
    return Scaffold(
      backgroundColor: Colors.brown.shade50.withOpacity(0.3),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('${fertSetPvd.listOfRecipe[widget.index]['recipe'][widget.recipeIndex]['name']}',style: TextStyle(color: Colors.black87),),
        actions: [
          Checkbox(
              value: fertSetPvd.listOfRecipe[widget.index]['recipe'][widget.recipeIndex]['ecActive'],
              onChanged: (value){
                fertSetPvd.listOfFertilizerFunctionality(['editEcActive',widget.index,widget.recipeIndex,value]);
              }
          ),
          Text('EC : ',style: TextStyle(fontSize: 16,fontWeight: FontWeight.w100),),
          SizedBox(
            width: 50,
            height: 40,
            child: TextFormField(
              enabled: fertSetPvd.listOfRecipe[widget.index]['recipe'][widget.recipeIndex]['ecActive'],
              initialValue: fertSetPvd.listOfRecipe[widget.index]['recipe'][widget.recipeIndex]['Ec'],
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                  )
              ),
              onChanged: (value){
                fertSetPvd.listOfFertilizerFunctionality(['editEc',widget.index,widget.recipeIndex,value]);
              },
            ),
          ),
          SizedBox(width: 50,),
          Checkbox(
              value: fertSetPvd.listOfRecipe[widget.index]['recipe'][widget.recipeIndex]['phActive'],
              onChanged: (value){
                fertSetPvd.listOfFertilizerFunctionality(['editPhActive',widget.index,widget.recipeIndex,value]);
              }
          ),
          Text('PH : ',style: TextStyle(fontSize: 16,fontWeight: FontWeight.w100),),
          SizedBox(
            width: 50,
            height: 40,
            child: TextFormField(
              enabled: fertSetPvd.listOfRecipe[widget.index]['recipe'][widget.recipeIndex]['phActive'],
              initialValue: fertSetPvd.listOfRecipe[widget.index]['recipe'][widget.recipeIndex]['Ph'],
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                  )
              ),
              onChanged: (value){
                fertSetPvd.listOfFertilizerFunctionality(['editPh',widget.index,widget.recipeIndex,value]);
              },
            ),
          ),
          SizedBox(width: 50,),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.brown.shade100,
            width: double.infinity,
            height: 60,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    height: 60,
                    child: Center(
                      child: Text(
                        'Active',style: TextStyle(color: Colors.black,fontSize: 16,fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    height: 60,
                    child: Center(
                      child: Text(
                        'Id',style: TextStyle(color: Colors.black,fontSize: 16,fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    height: 60,
                    child: Center(
                      child: Text(
                        'Dosing channel',style: TextStyle(color: Colors.black,fontSize: 16,fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    height: 60,
                    child: Center(
                      child: Text(
                        'Method',style: TextStyle(color: Colors.black,fontSize: 16,fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    height: 60,
                    child: Center(
                      child: Text(
                        'Value',style: TextStyle(color: Colors.black,fontSize: 16,fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    height: 60,
                    child: Center(
                      child: Text(
                        'DM control',style: TextStyle(color: Colors.black,fontSize: 16,fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              child: ListView.builder(
                  itemCount: fertSetPvd.listOfRecipe[widget.index]['recipe'][widget.recipeIndex]['fertilizer'].length,
                  itemBuilder: (context,index){
                    print(fertSetPvd.listOfRecipe[widget.index]['recipe'][widget.recipeIndex]['fertilizer'][index]);
                    return Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child:  Container(
                        color: fertSetPvd.listOfRecipe[widget.index]['recipe'][widget.recipeIndex]['fertilizer'][index]['active'] == true ? Colors.white : Color(0XFFF3F3F3),
                        width: double.infinity,
                        height: 60,
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                height: 60,
                                child: Center(
                                    child: Checkbox(
                                        value: fertSetPvd.listOfRecipe[widget.index]['recipe'][widget.recipeIndex]['fertilizer'][index]['active'],
                                        onChanged: (value){
                                          fertSetPvd.listOfFertilizerFunctionality(['editActive',widget.index,widget.recipeIndex,index,value]);
                                        }
                                    )
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                height: 60,
                                child: Center(
                                  child: Text(
                                      '${fertSetPvd.listOfRecipe[widget.index]['recipe'][widget.recipeIndex]['fertilizer'][index]['id']}',style: TextStyle(color: fertSetPvd.listOfRecipe[widget.index]['recipe'][widget.recipeIndex]['fertilizer'][index]['active'] == true ? Colors.black87 : Colors.black54)
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                height: 60,
                                child: Center(
                                  child: Text(
                                    '${fertSetPvd.listOfRecipe[widget.index]['recipe'][widget.recipeIndex]['fertilizer'][index]['name']}',style: TextStyle(color: fertSetPvd.listOfRecipe[widget.index]['recipe'][widget.recipeIndex]['fertilizer'][index]['active'] == true ? Colors.black87 : Colors.black54),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Visibility(
                                visible: fertSetPvd.listOfRecipe[widget.index]['recipe'][widget.recipeIndex]['fertilizer'][index]['active'],
                                child: Container(
                                  width: double.infinity,
                                  height: 60,
                                  child:  Center(
                                      child: DropdownButton(
                                        dropdownColor: Colors.black87,
                                        focusColor: Colors.black87,
                                        // style: TextStyle(color: Colors.green),
                                        value: fertSetPvd.listOfRecipe[widget.index]['recipe'][widget.recipeIndex]['fertilizer'][index]['method'],
                                        underline: Container(),
                                        items: ['Time','Time Proportional','Quantity','Quantity Proportional'].map((String items) {
                                          return DropdownMenuItem(
                                            value: items,
                                            child: Text(items,style: const TextStyle(fontSize: 14,color: Colors.green,fontWeight: FontWeight.bold),),
                                          );
                                        }).toList(),
                                        onChanged: (value) {
                                          fertSetPvd.listOfFertilizerFunctionality(['editMethod',widget.index,widget.recipeIndex,index,value]);
                                        },
                                      )
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Visibility(
                                visible: fertSetPvd.listOfRecipe[widget.index]['recipe'][widget.recipeIndex]['fertilizer'][index]['active'],
                                child: Container(
                                  width: double.infinity,
                                  height: 60,
                                  child: Center(
                                      child: SizedBox(
                                        width: 60,
                                        height: 28,
                                        child: ['Quantity','Quantity Proportional'].contains(fertSetPvd.listOfRecipe[widget.index]['recipe'][widget.recipeIndex]['fertilizer'][index]['method']) ? TextFormField(
                                          initialValue: fertSetPvd.listOfRecipe[widget.index]['recipe'][widget.recipeIndex]['fertilizer'][index]['quantityValue'],
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
                                            fertSetPvd.listOfFertilizerFunctionality(['editQuantityValue',widget.index,widget.recipeIndex,index,value]);
                                          },
                                        ) :  InkWell(
                                          onTap: (){
                                            _showTimePicker(fertSetPvd,overAllPvd,index,'timeValue');
                                          },
                                          child: SizedBox(
                                            width: 80,
                                            height: 40,
                                            child: Center(
                                              child: Text('${fertSetPvd.listOfRecipe[widget.index]['recipe'][widget.recipeIndex]['fertilizer'][index]['timeValue']}'),
                                            ),
                                          ),
                                        ),
                                      )
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Visibility(
                                visible: fertSetPvd.listOfRecipe[widget.index]['recipe'][widget.recipeIndex]['fertilizer'][index]['active'],
                                child: Container(
                                  width: double.infinity,
                                  height: 60,
                                  child: Center(
                                      child: Switch(
                                        value: fertSetPvd.listOfRecipe[widget.index]['recipe'][widget.recipeIndex]['fertilizer'][index]['dmControl'],
                                        onChanged: (bool value) {
                                          fertSetPvd.listOfFertilizerFunctionality(['editDmControl',widget.index,widget.recipeIndex,index]);
                                        },
                                      )
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
              ),
            ),
          )
        ],
      ),
    );
  }
  void _showTimePicker(FertilizerSetProvider fertSetPvd,OverAllUse overAllPvd,int index,String purpose) async {

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
                if(purpose == 'timeValue'){
                  fertSetPvd.listOfFertilizerFunctionality(['editTimeValue',widget.index,widget.recipeIndex,index,'${overAllPvd.hrs < 10 ? '0' :''}${overAllPvd.hrs}:${overAllPvd.min < 10 ? '0' :''}${overAllPvd.min}:${overAllPvd.sec < 10 ? '0' :''}${overAllPvd.sec}']);
                }
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