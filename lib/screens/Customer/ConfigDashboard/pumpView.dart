import 'package:flutter/material.dart';

import '../../../constants/theme.dart';

class PumpView extends StatefulWidget {
  final dynamic sourcePump;
  const PumpView({super.key,required this.sourcePump});

  @override
  State<PumpView> createState() => _PumpViewState();
}

class _PumpViewState extends State<PumpView> {
  @override
  bool check(data){
    bool val = false;
    if(data != null){
      if(data.isNotEmpty){
        val = true;
      }
    }
    return val;
  }
  int getHeight(data){
    int size = 0;
    size += check(data['on']) == true ? 20 : 0;
    size += check(data['off']) == true ? 20 : 0;
    size += check(data['scr']) == true ? 20 : 0;
    size += check(data['ecr']) == true ? 20 : 0;
    size += check(data['c1']) == true ? 20 : 0;
    size += check(data['c2']) == true ? 20 : 0;
    size += check(data['c3']) == true ? 20 : 0;
    size += check(data['TopTankHigh']) == true ? 20 : 0;
    size += check(data['TopTankLow']) == true ? 20 : 0;
    size += check(data['SumpTankHigh']) == true ? 20 : 0;
    size += check(data['SumpTankLow']) == true ? 20 : 0;
    size += check(data['waterMeter']) == true ? 20 : 0;
    size += check(data['pumpConnection']) == true ? 20 : 0;
    size += 40;
    return size;

  }

  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context,constraints){
      return Column(
        children: [
          SizedBox(height: 5,),
          Row(
            children: [
              Container(
                width: 230,
                height: 50,
                color: myTheme.primaryColor,
                child: const Center(
                  child: Text('Pump',style: TextStyle(color: Colors.white)),
                ),
              ),

              Expanded(
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    color: myTheme.primaryColor,
                    child: const Center(
                      child: Text('Connected to',style: TextStyle(color: Colors.white)),
                    ),
                  )
              ),
              Expanded(
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    color: myTheme.primaryColor,
                    child: const Center(
                      child: Text('Reference no',style: TextStyle(color: Colors.white)),
                    ),
                  )
              ),
              Expanded(
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    color: myTheme.primaryColor,
                    child: const Center(
                      child: Text('O/P',style: TextStyle(color: Colors.white)),
                    ),
                  )
              ),
              Expanded(
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    color: myTheme.primaryColor,
                    child: const Center(
                      child: Text('I/P',style: TextStyle(color: Colors.white)),
                    ),
                  )
              ),
              Expanded(
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    color: myTheme.primaryColor,
                    child: const Center(
                      child: Text('I/0 Type',style: TextStyle(color: Colors.white),),
                    ),
                  )
              ),
            ],
          ),
          Expanded(
              child: Container(

                width: double.infinity,
                child: ListView.builder(
                    itemCount: widget.sourcePump.length,
                    itemBuilder: (context,index){
                      return Container(
                        color: index % 2 == 0 ? const Color(0xfff3f3f3) : Colors.white,
                        margin: EdgeInsets.only(bottom: index == widget.sourcePump.length - 1 ? 100 : 0),
                        width: double.infinity,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 20,),
                            SizedBox(
                              width: double.infinity,
                              height: 40,
                              child: Row(
                                children: [
                                  IconButton(
                                      onPressed: (){
                                        setState(() {
                                          widget.sourcePump[index]['visible'] = !widget.sourcePump[index]['visible'];
                                        });
                                      }, icon: Icon(widget.sourcePump[index]['visible'] == true ? Icons.add_box_rounded : Icons.indeterminate_check_box)
                                  ),
                                  SizedBox(
                                    width: 40,
                                    height: 40,
                                    child: Image.asset('assets/images/source_pump.png'),
                                  ),
                                  Text('   ${widget.sourcePump[index]['name']}',style: TextStyle(fontSize: 13),)

                                ],
                              ),
                            ),
                            if(widget.sourcePump[index]['pumpConnection'] != null)
                              if(widget.sourcePump[index]['visible'])
                                object('pumpConnection',true,widget.sourcePump[index]['pumpConnection'],Colors.blueGrey.shade50),
                            if(widget.sourcePump[index]['on'] != null)
                              if(widget.sourcePump[index]['visible'])
                                object('on',true,widget.sourcePump[index]['on'],Colors.green.shade50),
                            if(widget.sourcePump[index]['off'] != null)
                              if(widget.sourcePump[index]['visible'])
                                object('off',true,widget.sourcePump[index]['off'],Colors.green.shade50),
                            if(widget.sourcePump[index]['scr'] != null)
                              if(widget.sourcePump[index]['visible'])
                                object('scr',true,widget.sourcePump[index]['scr'],Colors.green.shade50),
                            if(widget.sourcePump[index]['ecr'] != null)
                              if(widget.sourcePump[index]['visible'])
                                object('ecr',true,widget.sourcePump[index]['ecr'],Colors.green.shade50),
                            if(widget.sourcePump[index]['c1'] != null)
                              if(widget.sourcePump[index]['visible'])
                                object('c1',false,widget.sourcePump[index]['c1'],Colors.orange.shade50),
                            if(widget.sourcePump[index]['c2'] != null)
                              if(widget.sourcePump[index]['visible'])
                                object('c2',false,widget.sourcePump[index]['c2'],Colors.orange.shade50),
                            if(widget.sourcePump[index]['c3'] != null)
                              if(widget.sourcePump[index]['visible'])
                                object('c3',false,widget.sourcePump[index]['c3'],Colors.orange.shade50),
                            if(widget.sourcePump[index]['TopTankHigh'] != null)
                              if(widget.sourcePump[index]['TopTankHigh'] != null)
                                if(widget.sourcePump[index]['visible'])
                                  object('TopTankHigh',false,widget.sourcePump[index]['TopTankHigh'],Colors.lightBlue.shade50),
                            if(widget.sourcePump[index]['TopTankLow'] != null)
                              if(widget.sourcePump[index]['TopTankLow'].isNotEmpty)
                                if(widget.sourcePump[index]['visible'])
                                  object('TopTankLow',false,widget.sourcePump[index]['TopTankLow'],Colors.lightBlue.shade50),
                            if(widget.sourcePump[index]['SumpTankHigh'] != null)
                              if(widget.sourcePump[index]['SumpTankHigh'].isNotEmpty)
                                if(widget.sourcePump[index]['visible'])
                                  object('SumpTankHigh',false,widget.sourcePump[index]['SumpTankHigh'],Colors.lightBlue.shade50),
                            if(widget.sourcePump[index]['SumpTankLow'] != null)
                              if(widget.sourcePump[index]['SumpTankLow'].isNotEmpty)
                                if(widget.sourcePump[index]['visible'])
                                  object('SumpTankLow',false,widget.sourcePump[index]['SumpTankLow'],Colors.lightBlue.shade50),
                            if(widget.sourcePump[index]['waterMeter'] != null)
                              if(widget.sourcePump[index]['waterMeter'].isNotEmpty)
                                if(widget.sourcePump[index]['visible'])
                                  object('waterMeter',false,widget.sourcePump[index]['waterMeter'],Colors.purple.shade50)
                          ],
                        ),
                      );

                    }),
              )
          )
        ],
      );
    });
  }
}
Widget object(String name,bool output,data,Color color){
  print(data);
  return data.isEmpty ? Container() : Container(
    // color: color,
    width: double.infinity,
    height: 20,
    child: Row(
      children: [
        connectionName(name,Colors.black),
        expand(data['rtu'],Colors.black),
        expand(data['rfNo'],Colors.black),
        expand(output ? data['output'] : '-',Colors.black),
        expand(!output ? data['input'] : '-',Colors.black),

        if(output)
          expand('1',Colors.black)
        else
          expand(data['input_type'],Colors.black),
      ],
    ),
  );
}
Widget expand(data,Color color){
  return Expanded(
    child: Container(
      width: double.infinity,
      height: 20,
      child: Text(data,style: TextStyle(color: color,fontWeight: FontWeight.w100,fontSize: 13),),
      alignment: Alignment.bottomCenter,
    ),
  );
}

Widget connectionName(data,Color color){
  return SizedBox(
    width: 230,
    height: 20,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const SizedBox(width: 30,),
        SizedBox(
          height: 20,
          width: 1,
          child: VerticalDivider(
            thickness: 1,
            color: Colors.black87,
          ),
        ),
        SizedBox(
          height: 1,
          width: 10,
          child: Divider(
            thickness: 1,
            color: Colors.black87,
          ),
        ),
        Text(data,style: TextStyle(color: Colors.black87,fontWeight: FontWeight.w100,fontSize: 13))
      ],
    ),
  );
}
bool check(data,bool inside,[String? title]){
  print(data);
  bool item = false;
  if(inside == false){
    for(var i in data){
      if(i.isNotEmpty){
        item = true;
      }
    }
  }else{
    for(var i in data){
      if(i[title].isNotEmpty){
        item = true;
      }
    }
  }
  return item;
}
