import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

import '../constants/theme.dart';
import '../state_management/irrigation_program_main_provider.dart';
import '../state_management/overall_use.dart';

class HoursMinutesSeconds extends StatefulWidget {
  final String initialTime;
  String? validation;
  String? waterTime;
  String? preTime;
  String? postTime;
  void Function()? onPressed;
  HoursMinutesSeconds({
    super.key, required this.initialTime,this.validation,this.waterTime,this.preTime,this.postTime,this.onPressed
  });
  @override
  State<HoursMinutesSeconds> createState() => _HoursMinutesSecondsState();
}

class _HoursMinutesSecondsState extends State<HoursMinutesSeconds> {
  double hrs = 0;
  double mins = 0;
  double secs = 0;
  int selected = 0;
  bool releaseTimeForPrePost = true;
  bool releaseTimeForWater = true;
  bool viewWidget = false;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(mounted){
      WidgetsBinding.instance.addPostFrameCallback((_) {
        var overAllPvd = Provider.of<OverAllUse>(context,listen: false);
        overAllPvd.editTime('hrs', double.parse(widget.initialTime.split(':')[0]) as int);
        overAllPvd.editTime('min', double.parse(widget.initialTime.split(':')[1]) as int);
        overAllPvd.editTime('sec', double.parse(widget.initialTime.split(':')[2]) as int);
        print('hr : ${overAllPvd.hrs}');
        print('initialTime : ${widget.initialTime}');
      });
    }
  }

  int parseTimeString(String timeString) {
    List<String> parts = timeString.split(':');
    int totalSeconds = ((int.parse(parts[0]) * 3600) + (int.parse(parts[1]) * 60) + (int.parse(parts[2])));
    return totalSeconds;
  }

  void checkCondition(OverAllUse overAllPvd){
    int duration1 = 0;
    int duration2 = 0;
    int duration3 = 0;
    if(widget.validation == 'pre'){
      duration1 = parseTimeString(widget.waterTime!);
      duration2 = parseTimeString(widget.postTime!);
      duration3 = parseTimeString('${overAllPvd.hrs!}:${overAllPvd.min!}:${overAllPvd.sec!}');
    }else{
      duration1 = parseTimeString(widget.waterTime!);
      duration2 = parseTimeString(widget.preTime!);
      duration3 = parseTimeString('${overAllPvd.hrs!}:${overAllPvd.min!}:${overAllPvd.sec!}');
    }
    var result = duration1 - (duration2 + duration3);
    print(result);
    if(result > 0 || result == 0){
      setState(() {
        releaseTimeForPrePost = true;
      });
    }else{
      setState(() {
        releaseTimeForPrePost = false;
      });
    }
  }
  void checkCondition1(overAllPvd){
    int water = parseTimeString('${overAllPvd.hrs!}:${overAllPvd.min!}:${overAllPvd.sec!}');
    int pre = parseTimeString(widget.preTime!);
    int post = parseTimeString(widget.postTime!);
    var result = water - (pre + post);
    print(result);
    if(result > 0 || result == 0){
      setState(() {
        releaseTimeForWater = true;
      });
    }else{
      setState(() {
        releaseTimeForWater = false;
      });
    }
  }

  String message(){
    if(widget.validation == 'water'){
      return 'water value should be more than (Pre + Post)value';
    }else if(widget.validation == 'pre' || widget.validation == 'post'){
      return '(Pre + Post)value should less than water value';
    }else{
      return '';
    }
  }

  // You can change this to the desired number
  @override
  Widget build(BuildContext context) {
    final programPvd = Provider.of<IrrigationProgramMainProvider>(context);
    var overAllPvd = Provider.of<OverAllUse>(context,listen: true);
    return Container(
      color : Colors.white,
      width: 250,
      height: 380,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if(releaseTimeForPrePost == false || releaseTimeForWater == false)
            Row(
              children: [
                SizedBox(
                    width: 205,
                    child: Center(child: Text(message(),style: TextStyle(fontSize: 15,color: Colors.red),))),
                SizedBox(width: 5,),
                IconButton(
                    onPressed: (){
                      setState(() {
                        viewWidget = !viewWidget;
                      });
                    },
                    icon: Icon(viewWidget == false ? Icons.visibility : Icons.visibility_off)
                )
              ],
            ),
          SizedBox(height: 10,),
          if(viewWidget == false)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                InkWell(
                  onTap: (){
                    setState(() {
                      selected = 0;
                    });
                  },
                  child: Container(
                    width: 60,
                    height: 50,
                    color: selected == 0 ? myTheme.primaryColor.withOpacity(0.2) : Colors.transparent,
                    child: Center(
                      child: Text('${overAllPvd.hrs} Hr',style: TextStyle(fontSize: 16,color: selected == 0 ? Colors.black87 : Colors.black),),
                    ),
                  ),
                ),
                const Text(':',style: TextStyle(fontSize: 20),),
                InkWell(
                  onTap: (){
                    setState(() {
                      selected = 1;
                    });
                  },
                  child: Container(
                    width: 60,
                    height: 50,
                    color: selected == 1 ? myTheme.primaryColor.withOpacity(0.2) : Colors.transparent,
                    child: Center(
                      child: Text('${overAllPvd.min} Min',style: TextStyle(fontSize: 16,color: selected == 1 ? Colors.black87 : Colors.black)),
                    ),
                  ),
                ),
                const Text(':',style: TextStyle(fontSize: 20),),
                InkWell(
                  onTap: (){
                    setState(() {
                      selected = 2;
                    });
                  },
                  child: Container(
                    width: 60,
                    height: 50,
                    color: selected == 2 ? myTheme.primaryColor.withOpacity(0.2) : Colors.transparent,
                    child: Center(
                      child: Text('${overAllPvd.sec} Sec',style: TextStyle(fontSize: 16,color: selected == 2 ? Colors.black87 : Colors.black)),
                    ),
                  ),
                ),

              ],
            ),
          SizedBox(height: 10,),
          if(viewWidget == false)
            if(selected == 0)
              Container(
                width: 210,
                height: 210,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage(
                            'assets/images/24hoursClock.png'
                        )
                    )
                ),
                child: Center(
                  child: Container(
                    // color: Colors.green,
                    width: 210,
                    height: 210,
                    child: SleekCircularSlider(
                      onChangeEnd: (value){
                        setState(() {
                          if(selected != 2){
                            selected += 1;
                          }
                        });
                      },
                      initialValue: overAllPvd.hrs as double,
                      min: 0,// Initial value
                      max: 24, // Maximum value
                      appearance: CircularSliderAppearance(
                        animDurationMultiplier: 0,
                        customColors: CustomSliderColors(
                          progressBarColors: [Colors.transparent,Colors.transparent], // Customize progress bar colors
                          trackColor: Colors.transparent, // Customize track color
                          shadowColor: myTheme.primaryColor, // Customize shadow color
                          shadowMaxOpacity: 0.3, // Set shadow maximum opacity
                        ),
                        customWidths: CustomSliderWidths(
                            progressBarWidth: 55, // Set progress bar width
                            // trackWidth: 50, // Set track width
                            shadowWidth: 20,
                            handlerSize: 2// Set shadow width
                        ),
                        size: 210, // Set the slider's size
                        startAngle: 270, // Set the starting angle
                        angleRange: 360, // Set the angle range
                        infoProperties: InfoProperties(
                          // Customize label style
                          mainLabelStyle: TextStyle(fontSize: 24, color: myTheme.primaryColor),
                          modifier: (double value) {
                            // Display value as a percentage
                            return '${(value.toStringAsFixed(0))} hr' == '24 hr' ? '0 hr' : '${(value.toStringAsFixed(0))} hr';
                          },
                        ),
                        spinnerMode: false, // Disable spinner mode
                        animationEnabled: true, // Enable animation
                      ),
                      onChange: (double value) {
                        overAllPvd.editTime('hrs', (value.round().toDouble() as int) == 24 ? 0 : (value.round().toDouble() as int));
                        // setState(() {
                        //   overAllPvd.hrs  = value.round().toDouble();
                        // });
                        // Handle value change here
                      },
                    ),
                  ),
                ),
              ),
          if(viewWidget == false)
            if(selected == 1)
              Container(
                width: 210,
                height: 210,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage(
                            'assets/images/minsClock.png'
                        )
                    )
                ),
                child: Center(
                  child: Container(
                    // color: Colors.green,
                    width: 210,
                    height: 210,
                    child: SleekCircularSlider(
                      onChangeEnd: (value){
                        setState(() {
                          if(selected != 2){
                            selected += 1;
                          }
                        });
                      },
                      initialValue: overAllPvd.min as double, // Initial value
                      max: 59, // Maximum value
                      appearance: CircularSliderAppearance(
                        animDurationMultiplier: 0,

                        customColors: CustomSliderColors(
                          progressBarColors: [Colors.transparent,Colors.transparent], // Customize progress bar colors
                          trackColor: Colors.transparent, // Customize track color
                          shadowColor: myTheme.primaryColor, // Customize shadow color
                          shadowMaxOpacity: 0.3, // Set shadow maximum opacity
                        ),
                        customWidths: CustomSliderWidths(
                            progressBarWidth: 55, // Set progress bar width
                            // trackWidth: 50, // Set track width
                            shadowWidth: 20,
                            handlerSize: 2// Set shadow width
                        ),
                        size: 210, // Set the slider's size
                        startAngle: 270, // Set the starting angle
                        angleRange: 360, // Set the angle range
                        infoProperties: InfoProperties(
                          // Customize label style
                          mainLabelStyle: TextStyle(fontSize: 24, color: myTheme.primaryColor),
                          modifier: (double value) {
                            // Display value as a percentage
                            return '${(value.toStringAsFixed(0))} min' == '60 min' ? '0 min' : '${(value.toStringAsFixed(0))} min';

                          },
                        ),
                        spinnerMode: false, // Disable spinner mode
                        animationEnabled: true, // Enable animation
                      ),
                      onChange: (double value) {
                        overAllPvd.editTime('min', (value.round().toDouble() as int) == 60 ? 0 : (value.round().toDouble() as int));
                        // Handle value change here
                      },
                    ),
                  ),
                ),
              ),
          if(viewWidget == false)
            if(selected == 2)
              Container(
                width: 210,
                height: 210,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage(
                            'assets/images/minsClock.png'
                        )
                    )
                ),
                child: Center(
                  child: Container(
                    // color: Colors.green,
                    width: 210,
                    height: 210,
                    child: SleekCircularSlider(
                      initialValue: overAllPvd.sec as double, // Initial value
                      max: 59, // Maximum value
                      appearance: CircularSliderAppearance(
                        animDurationMultiplier: 0,
                        customColors: CustomSliderColors(
                          progressBarColors: [Colors.transparent,Colors.transparent], // Customize progress bar colors
                          trackColor: Colors.transparent, // Customize track color
                          shadowColor: myTheme.primaryColor, // Customize shadow color
                          shadowMaxOpacity: 0.3,  // Set shadow maximum opacity
                        ),
                        customWidths: CustomSliderWidths(
                            progressBarWidth: 55, // Set progress bar width
                            // trackWidth: 50, // Set track width
                            shadowWidth: 20,
                            handlerSize: 2// Set shadow width
                        ),
                        size: 210, // Set the slider's size
                        startAngle: 270, // Set the starting angle
                        angleRange: 360, // Set the angle range
                        infoProperties: InfoProperties(
                          // Customize label style
                          mainLabelStyle: TextStyle(fontSize: 24, color: myTheme.primaryColor),
                          modifier: (double value) {
                            // Display value as a percentage
                            return '${(value.toStringAsFixed(0))} sec' == '60 sec' ? '0 sec' : '${(value.toStringAsFixed(0))} sec';

                          },
                        ),
                        spinnerMode: false, // Disable spinner mode
                        animationEnabled: true, // Enable animation
                      ),
                      onChange: (double value) {
                        overAllPvd.editTime('sec', (value.round().toDouble() as int) == 60 ? 0 : (value.round().toDouble() as int));
                        // Handle value change here
                      },
                    ),
                  ),
                ),
              ),
          if(viewWidget == true)
            Container(
                width: 250,
                height: 200,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    if(viewWidget == true)
                      Container(
                        color: Colors.blue.shade50,
                        child: ListTile(
                          title: Text('Water'),
                          trailing: Text(widget.validation == 'water' ? '${overAllPvd.hrs! < 10 ? '0' :''}${overAllPvd.hrs!}:${overAllPvd.min! < 10 ? '0' :''}${overAllPvd.min!}:${overAllPvd.sec! < 10 ? '0' :''}${overAllPvd.sec!}' : '${widget.waterTime}'),
                        ),
                      ),
                    if(viewWidget == true)
                      Container(
                        color: Colors.brown.shade50,
                        child: ListTile(
                          title: Text('Pre time'),
                          trailing: Text(widget.validation == 'pre' ? '${overAllPvd.hrs! < 10 ? '0' :''}${overAllPvd.hrs!}:${overAllPvd.min! < 10 ? '0' :''}${overAllPvd.min!}:${overAllPvd.sec! < 10 ? '0' :''}${overAllPvd.sec!}' : '${widget.preTime}'),
                        ),
                      ),
                    if(viewWidget == true)
                      Container(
                        color: Colors.brown.shade50,
                        child: ListTile(
                          title: Text('Post time'),
                          trailing: Text(widget.validation == 'post' ? '${overAllPvd.hrs! < 10 ? '0' :''}${overAllPvd.hrs!}:${overAllPvd.min! < 10 ? '0' :''}${overAllPvd.min!}:${overAllPvd.sec! < 10 ? '0' :''}${overAllPvd.sec!}' : '${widget.postTime}'),
                        ),
                      ),

                  ],
                )
            ),
          SizedBox(height: 20,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(myTheme.primaryColor.withOpacity(0.2))
                  ),
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  child: Text('Cancel',style: TextStyle(color: Colors.black87),)
              ),
              TextButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(myTheme.primaryColor)
                  ),
                  onPressed: widget.onPressed ?? (){
                    if(widget.validation == 'pre' || widget.validation == 'post'){
                      print('ok for prepost');
                      checkCondition(overAllPvd);
                      if(widget.validation == 'pre' && releaseTimeForPrePost){
                        programPvd.editPrePostMethod('preValue', programPvd.selectedGroup,'${overAllPvd.hrs! < 10 ? '0' :''}${overAllPvd.hrs!}:${overAllPvd.min! < 10 ? '0' :''}${overAllPvd.min!}:${overAllPvd.sec! < 10 ? '0' :''}${overAllPvd.sec!}');
                        Navigator.pop(context);
                      }
                      if(widget.validation == 'post' && releaseTimeForPrePost){
                        programPvd.editPrePostMethod('postValue', programPvd.selectedGroup,'${overAllPvd.hrs! < 10 ? '0' :''}${overAllPvd.hrs!}:${overAllPvd.min! < 10 ? '0' :''}${overAllPvd.min!}:${overAllPvd.sec! < 10 ? '0' :''}${overAllPvd.sec!}');
                        Navigator.pop(context);
                      }
                    }else if(widget.validation == 'water'){
                      print('ok for water');
                      checkCondition1(overAllPvd);
                      if(widget.validation == 'water' && releaseTimeForWater){
                        programPvd.editWaterSetting('timeValue', '${overAllPvd.hrs! < 10 ? '0' :''}${overAllPvd.hrs!}:${overAllPvd.min! < 10 ? '0' :''}${overAllPvd.min!}:${overAllPvd.sec! < 10 ? '0' :''}${overAllPvd.sec!}');
                        Navigator.pop(context);
                      }
                    }
                  },
                  child: Text('Ok')
              )
            ],
          )
        ],
      ),
    );
  }
}