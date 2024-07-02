import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:oro_irrigation_new/constants/theme.dart';
import 'package:provider/provider.dart';

import '../../../Models/Customer/Dashboard/DashboardNode.dart';
import '../../../constants/MQTTManager.dart';
import '../../../constants/http_service.dart';
import '../../../state_management/MqttPayloadProvider.dart';
import '../Dashboard/SentAndReceived.dart';

import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class PumpDashboard extends StatefulWidget {
  const PumpDashboard({Key? key, required this.siteData, required this.masterIndex, required this.customerId}) : super(key: key);
  final DashboardModel siteData;
  final int customerId, masterIndex;

  @override
  State<PumpDashboard> createState() => _PumpDashboardState();
}

class _PumpDashboardState extends State<PumpDashboard> {

  String valR = '000',
      valY = '000',
      valB = '000';
  String cVersion = '';
  int wifiStrength = 0;
  int batVolt = 0;

  List<CMType1> pumpList = [];

  //late List<ChartSampleData> chartData;


  final List<String> _subjectCollection = <String>[];
  final List<Color> _colorCollection = <Color>[];
  final _MeetingDataSource _events = _MeetingDataSource(<_PumpModel>[]);
  final DateTime _minDate = DateTime.now().subtract(const Duration(days: 365 ~/ 2)),
      _maxDate = DateTime.now();

  final List<CalendarView> _allowedViews = <CalendarView>[
    CalendarView.day,
    CalendarView.week,
  ];

  final List<String> _viewNavigationModeList =
  <String>['snap', 'none'].toList();
  final List<String> _numberOfDaysList = <String>[
    'default',
    '1 day',
    '2 days',
    '3 days',
    '4 days',
    '5 days',
    '6 days',
    '7 days'
  ].toList();

  final List<String> _numberOfDaysListWorkWeek = <String>[
    'default',
    '1 day',
    '2 days',
    '3 days',
    '4 days',
    '5 days',
  ].toList();

  /// Global key used to maintain the state, when we change the parent of the
  /// widget
  final GlobalKey _globalKey = GlobalKey();
  final ScrollController _controller = ScrollController();
  final CalendarController _calendarController = CalendarController();

  List<DateTime> _blackoutDates = <DateTime>[];
  bool _showLeadingAndTrailingDates = true;
  bool _showDatePickerButton = true;
  bool _allowViewNavigation = true;
  bool _showCurrentTimeIndicator = true;
  StateSetter? _setter;

  ViewNavigationMode _viewNavigationMode = ViewNavigationMode.snap;
  String _viewNavigationModeString = 'snap';
  bool _showWeekNumber = false;
  String _numberOfDaysString = 'default';
  int _numberOfDays = -1;

  @override
  void initState() {
    super.initState();

    _calendarController.view = CalendarView.day;
    addAppointmentDetails();


    if (widget.siteData.master[widget.masterIndex].pumpLive[3] is CMType2) {
      List<String> rybValue = (widget.siteData.master[widget.masterIndex]
          .pumpLive[3] as CMType2).v!.split(',');
      valR = rybValue[0];
      valY = rybValue[1];
      valB = rybValue[2];
      cVersion =
      (widget.siteData.master[widget.masterIndex].pumpLive[3] as CMType2).vs!;

      wifiStrength =
      (widget.siteData.master[widget.masterIndex].pumpLive[3] as CMType2).ss!;
      batVolt =
      (widget.siteData.master[widget.masterIndex].pumpLive[3] as CMType2).b!;

      pumpList = widget.siteData.master[widget.masterIndex].pumpLive.whereType<
          CMType1>().cast<CMType1>().toList();
    }

    syncLive();
    getPumpLogs();
  }

  void syncLive() {
    String livePayload = jsonEncode({"sentSMS": "#live"});
    Future.delayed(const Duration(seconds: 3), () {
      MQTTManager().publish(livePayload,
          'AppToFirmware/${widget.siteData.master[widget.masterIndex]
              .deviceId}');
    });
  }

  Future<void> getPumpLogs() async
  {
    Map<String, Object> body = {
      "userId": widget.customerId,
      "controllerId": widget.siteData.master[widget.masterIndex].controllerId,
      "fromDate": "2024-06-20",
      "toDate": "2024-06-28"
    };
    print(body);
    final response = await HttpService().postRequest("getUserPumpLog", body);
    if (response.statusCode == 200) {
      //siteListFinal.clear();
      var data = jsonDecode(response.body);
      print(response.body);
      if (data["code"] == 200) {
        final jsonData = data["data"] as List;
        try {
          //siteListFinal = jsonData.map((json) => DashboardModel.fromJson(json)).toList();
        } catch (e) {
          print('Error: $e');
        }
      }
    }
    else {
      //_showSnackBar(response.body);
    }
  }




  @override
  Widget build(BuildContext context) {
    final pcLivePayload = Provider.of<MqttPayloadProvider>(context).pumpControllerLive;
    //Map<String, dynamic> json = jsonDecode(pcLivePayload.isNotEmpty? pcLivePayload:null);


    final Widget calendar = Theme(
        key: _globalKey,
        data: myTheme,
        child: _getGettingStartedCalendar(_calendarController, _events,
            _onViewChanged, _minDate, _maxDate, scheduleViewBuilder));

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Row(
        children: [
          SizedBox(
            width: 300,
            height: double.infinity,
            child: Column(
              children: [
                Container(
                  width: 300,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.greenAccent,
                    border: Border.all(
                      color: Colors.green,
                      width: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Container(
                    width: 300,
                    height: 50,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 45,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(wifiStrength == 0 ? Icons.wifi_off :
                              wifiStrength >= 1 && wifiStrength <= 20 ? Icons
                                  .network_wifi_1_bar_outlined :
                              wifiStrength >= 21 && wifiStrength <= 40 ? Icons
                                  .network_wifi_2_bar_outlined :
                              wifiStrength >= 41 && wifiStrength <= 60 ? Icons
                                  .network_wifi_3_bar_outlined :
                              wifiStrength >= 61 && wifiStrength <= 80 ? Icons
                                  .network_wifi_3_bar_outlined :
                              Icons.wifi, color: Colors.black,),
                              Text('$wifiStrength%'),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 205,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('MOTOR OFF'),
                              Text('ams : 100'),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 45,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(batVolt == 0 ? Icons.battery_alert_sharp :
                              batVolt >= 1 && batVolt <= 20 ? Icons
                                  .battery_1_bar :
                              batVolt >= 21 && batVolt <= 40 ? Icons
                                  .battery_2_bar :
                              batVolt >= 41 && batVolt <= 60 ? Icons
                                  .battery_3_bar :
                              batVolt >= 61 && batVolt <= 80 ? Icons
                                  .battery_4_bar :
                              Icons.battery_6_bar, color: Colors.black,),
                              Text('$batVolt%'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 5,),
                Container(
                  width: 300,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    border: Border.all(
                      color: Colors.green,
                      width: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: SizedBox(
                    width: 250,
                    height: 30,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(flex: 1, child: Container(
                          color: Colors.red.shade100,
                          child: Center(child: Text('R : $valR V')),
                        )),
                        Flexible(flex: 1, child: Container(
                          color: Colors.yellow.shade100,
                          child: Center(child: Text('Y : $valY V')),
                        )),
                        Flexible(flex: 1, child: Container(
                          color: Colors.blue.shade100,
                          child: Center(child: Text('B : $valB V')),
                        )),
                        Flexible(flex: 1, child: MaterialButton(
                          color: Colors.teal,
                          textColor: Colors.white,
                          onPressed: () {
                            String livePayload = jsonEncode(
                                {"sentSMS": "#live"});
                            MQTTManager().publish(livePayload,
                                'AppToFirmware/${widget.siteData.master[widget
                                    .masterIndex].deviceId}');
                          },
                          child: const Text('Refresh'),
                        )),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 5,),
                SizedBox(
                  width: 300,
                  height: MediaQuery
                      .sizeOf(context)
                      .height - 202,
                  child: ListView.builder(
                    itemCount: pumpList.length,
                    itemBuilder: (context, index) {
                      List<String> floatVal = pumpList[index].ft!.split(':');
                      return Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: Colors.teal,
                                width: 0.5,
                              ),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: Column(
                              children: [
                                SizedBox(
                                  width: 300,
                                  height: 75,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 5),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment
                                          .center,
                                      children: [
                                        Center(child: Image(image: AssetImage(
                                            pumpList[index].st == 1
                                                ? "assets/GifFile/motor_on_new.gif"
                                                : "assets/GifFile/motor_off_new.gif"),
                                          width: 75,)),
                                        const SizedBox(width: 30,),
                                        Material(
                                          elevation: 8.0,
                                          // Add shadow elevation
                                          shape: const CircleBorder(),
                                          // Ensure the shadow has the same shape as the CircleAvatar
                                          child: CircleAvatar(
                                            radius: 22.0,
                                            backgroundColor: Colors.green,
                                            child: IconButton(tooltip: 'Start',
                                                onPressed: () {
                                                  String onPayload = jsonEncode(
                                                      {
                                                        "sentSMS": "MOTOR${index +
                                                            1}ON"
                                                      });
                                                  MQTTManager().publish(
                                                      onPayload,
                                                      'AppToFirmware/${widget
                                                          .siteData
                                                          .master[widget
                                                          .masterIndex]
                                                          .deviceId}');
                                                },
                                                icon: const Icon(
                                                  Icons.power_settings_new,
                                                  color: Colors.white,)),
                                          ),
                                        ),
                                        const SizedBox(width: 10,),
                                        Material(
                                          elevation: 8.0,
                                          // Add shadow elevation
                                          shape: const CircleBorder(),
                                          // Ensure the shadow has the same shape as the CircleAvatar
                                          child: CircleAvatar(
                                            radius: 22.0,
                                            backgroundColor: Colors.redAccent,
                                            child: IconButton(
                                                tooltip: 'Stop',
                                                onPressed: () {
                                                  String onPayload = jsonEncode(
                                                      {
                                                        "sentSMS": "MOTOR${index +
                                                            1}OF"
                                                      });
                                                  MQTTManager().publish(
                                                      onPayload,
                                                      'AppToFirmware/${widget
                                                          .siteData
                                                          .master[widget
                                                          .masterIndex]
                                                          .deviceId}');
                                                },
                                                icon: const Icon(
                                                  Icons.power_settings_new,
                                                  color: Colors.white,)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 300,
                                  height: 100,
                                  child: Column(
                                    children: [
                                      Flexible(
                                        flex: 1,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 15, right: 15, top: 10),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment
                                                .spaceBetween,
                                            children: [
                                              Column(
                                                children: [
                                                  pumpList[index].ft ==
                                                      '-:-:-:-' ? const Text(
                                                      '--') :
                                                  Row(
                                                    children: [
                                                      Text('${floatVal[0]}%',
                                                        style: const TextStyle(
                                                            fontSize: 14,
                                                            fontWeight: FontWeight
                                                                .normal),),
                                                      const Text(' | ',
                                                        style: TextStyle(
                                                            fontWeight: FontWeight
                                                                .normal,
                                                            fontSize: 16,
                                                            color: Colors
                                                                .teal),),
                                                      Text('${floatVal[1]}%',
                                                        style: const TextStyle(
                                                            fontSize: 14,
                                                            fontWeight: FontWeight
                                                                .normal),),
                                                      const Text(' | ',
                                                        style: TextStyle(
                                                            fontWeight: FontWeight
                                                                .normal,
                                                            fontSize: 16,
                                                            color: Colors
                                                                .teal),),
                                                      Text('${floatVal[2]}%',
                                                        style: const TextStyle(
                                                            fontSize: 14,
                                                            fontWeight: FontWeight
                                                                .normal),),
                                                      const Text(' | ',
                                                        style: TextStyle(
                                                            fontWeight: FontWeight
                                                                .normal,
                                                            fontSize: 16,
                                                            color: Colors
                                                                .teal),),
                                                      Text('${floatVal[3]}%',
                                                        style: const TextStyle(
                                                            fontSize: 14,
                                                            fontWeight: FontWeight
                                                                .normal),),
                                                    ],
                                                  ),
                                                  const Text('Float Status',
                                                    style: TextStyle(
                                                        color: Colors.grey,
                                                        fontWeight: FontWeight
                                                            .normal),),
                                                ],
                                              ),
                                              Column(
                                                children: [
                                                  Text(pumpList[index].lv == '-'
                                                      ? '--'
                                                      : '${pumpList[index]
                                                      .lv} %',
                                                    style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight: FontWeight
                                                            .normal),),
                                                  const Text('Level',
                                                    style: TextStyle(
                                                        color: Colors.grey,
                                                        fontWeight: FontWeight
                                                            .normal),),
                                                ],
                                              ),
                                              Column(
                                                children: [
                                                  Text('${pumpList[index].ph}',
                                                    style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight: FontWeight
                                                            .normal),),
                                                  const Text('Phase',
                                                    style: TextStyle(
                                                        color: Colors.grey,
                                                        fontWeight: FontWeight
                                                            .normal),),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Flexible(
                                        flex: 1,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 20, right: 20),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment
                                                .spaceBetween,
                                            children: [
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment
                                                    .center,
                                                mainAxisAlignment: MainAxisAlignment
                                                    .center,
                                                children: [
                                                  Text(pumpList[index].pr == '-'
                                                      ? '--'
                                                      : '${pumpList[index]
                                                      .pr}/bar',
                                                    style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight: FontWeight
                                                            .normal),),
                                                  const Text('Pressure',
                                                    style: TextStyle(
                                                        color: Colors.grey,
                                                        fontWeight: FontWeight
                                                            .normal),),
                                                ],
                                              ),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment
                                                    .center,
                                                mainAxisAlignment: MainAxisAlignment
                                                    .center,
                                                children: [
                                                  Text(pumpList[index].wm == '-'
                                                      ? '--'
                                                      : '${pumpList[index]
                                                      .wm}/bar',
                                                    style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight: FontWeight
                                                            .normal),),
                                                  const Text('Flow rate',
                                                    style: TextStyle(
                                                        color: Colors.grey,
                                                        fontWeight: FontWeight
                                                            .normal),),
                                                ],
                                              ),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment
                                                    .center,
                                                mainAxisAlignment: MainAxisAlignment
                                                    .center,
                                                children: [
                                                  Text(pumpList[index].cf == '-'
                                                      ? '--'
                                                      : '${pumpList[index]
                                                      .cf}/Lts',
                                                    style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight: FontWeight
                                                            .normal),),
                                                  const Text('C-Flow',
                                                    style: TextStyle(
                                                        color: Colors.grey,
                                                        fontWeight: FontWeight
                                                            .normal),),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 300,
                                  height: 32,
                                  color: Colors.teal.shade100,
                                  child: const Center(child: Text(
                                    'reason text here',
                                    style: TextStyle(fontSize: 11),)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 5,),
                        ],
                      );
                    },
                  ),
                ),
                const Divider(thickness: 0.3,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Version : ',
                      style: TextStyle(fontWeight: FontWeight.normal),),
                    Text(cVersion,
                      style: const TextStyle(fontWeight: FontWeight.bold),),
                  ],
                )
              ],
            ),
          ),
          SizedBox(
            width: MediaQuery
                .sizeOf(context)
                .width - 412,
            height: double.infinity,
            child: DefaultTabController(
              length: 4, // Number of tabs
              child: Column(
                children: [
                  const TabBar(
                    indicatorColor: Colors.pinkAccent,
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.grey,
                    tabs: [
                      Row(
                        children: [
                          Icon(Icons.auto_graph),
                          SizedBox(width: 5,),
                          Tab(text: 'Power & Motor'),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.question_answer_outlined),
                          SizedBox(width: 5,),
                          Tab(text: 'Sent & Received'),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.report),
                          SizedBox(width: 5,),
                          Tab(text: 'Reports'),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.settings_outlined),
                          SizedBox(width: 5,),
                          Tab(text: 'Settings'),
                        ],
                      ),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        const Center(child: Text('Tab 1 Content')),
                        SentAndReceived(customerID: widget.customerId,
                          controllerId: widget.siteData.master[widget
                              .masterIndex].controllerId,
                          from: 'Pump',),
                        Center(
                          child: Expanded(
                            child: Container(
                                color: Colors.white,
                                child: calendar),
                          ),
                        ),
                        const Center(child: Text('Tab 5 Content')),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// The method called whenever the calendar view navigated to previous/next
  /// view or switched to different calendar view, based on the view changed
  /// details new appointment collection added to the calendar
  void _onViewChanged(ViewChangedDetails visibleDatesChangedDetails) {
    final List<_PumpModel> appointment = <_PumpModel>[];
    _events.appointments.clear();
    final Random random = Random();
    final List<DateTime> blockedDates = <DateTime>[];
    /*if (_calendarController.view == CalendarView.month ||
        _calendarController.view == CalendarView.timelineMonth) {
      for (int i = 0; i < 5; i++) {
        blockedDates.add(visibleDatesChangedDetails.visibleDates[
        random.nextInt(visibleDatesChangedDetails.visibleDates.length)]);
      }
    }*/

    SchedulerBinding.instance.addPostFrameCallback((Duration timeStamp) {
      setState(() {
        if (_calendarController.view == CalendarView.workWeek) {
          if (_numberOfDaysString == '6 days' || _numberOfDaysString == '7 days') {
            _numberOfDaysString = '5 days';
          }
        }
        if (_numberOfDays > 5 && _calendarController.view == CalendarView.workWeek) {
          _numberOfDays = 5;
        }

      });
      if (_setter != null) {
        _setter!(() {});
      }
    });

    /// Creates new appointment collection based on
    /// the visible dates in calendar.
    if (_calendarController.view != CalendarView.schedule) {
      for (int i = 0; i < visibleDatesChangedDetails.visibleDates.length; i++) {
        final DateTime date = visibleDatesChangedDetails.visibleDates[i];
        if (blockedDates.isNotEmpty &&
            blockedDates.contains(date)) {
          continue;
        }
        final int count = 1 + random.nextInt(2);
        for (int j = 0; j < count; j++) {
          final DateTime startDate =
          DateTime(date.year, date.month, date.day, 8 + random.nextInt(8));
          appointment.add(_PumpModel(
            _subjectCollection[random.nextInt(7)],
            startDate,
            startDate.add(Duration(hours: random.nextInt(3))),
            _colorCollection[random.nextInt(9)],
          ));
        }
      }
    } else {
      final DateTime rangeStartDate =
      DateTime.now().add(const Duration(days: -(365 ~/ 2)));
      final DateTime rangeEndDate =
      DateTime.now().add(const Duration(days: 365));
      for (DateTime i = rangeStartDate;
      i.isBefore(rangeEndDate);
      i = i.add(const Duration(days: 1))) {
        final DateTime date = i;
        final int count = 1 + random.nextInt(3);
        for (int j = 0; j < count; j++) {
          final DateTime startDate =
          DateTime(date.year, date.month, date.day, 8 + random.nextInt(8));
          appointment.add(_PumpModel(
            _subjectCollection[random.nextInt(7)],
            startDate,
            startDate.add(Duration(hours: random.nextInt(3))),
            _colorCollection[random.nextInt(9)],
          ));
        }
      }
    }

    for (int i = 0; i < appointment.length; i++) {
      _events.appointments.add(appointment[i]);
    }

    /// Resets the newly created appointment collection to render
    /// the appointments on the visible dates.
    _events.notifyListeners(CalendarDataSourceAction.reset, appointment);
  }

  /// Creates the required appointment details as a list.
  void addAppointmentDetails() {
    _subjectCollection.add('Pump 1 ON');
    _subjectCollection.add('Pump 2 ON');
    _subjectCollection.add('Pump 3 ON');
    _subjectCollection.add('Pump 1 OFF');
    _subjectCollection.add('Pump 2 OFF');
    _subjectCollection.add('Pump 3 OFF');


    _colorCollection.add(const Color(0xFF0F8644));
    _colorCollection.add(const Color(0xFF8B1FA9));
    _colorCollection.add(const Color(0xFFD20100));
    _colorCollection.add(const Color(0xFFFC571D));
    _colorCollection.add(const Color(0xFF36B37B));
    _colorCollection.add(const Color(0xFF01A1EF));

  }

  /// Allows/Restrict switching to previous/next views through swipe interaction
  void onViewNavigationModeChange(String value) {
    _viewNavigationModeString = value;
    if (value == 'snap') {
      _viewNavigationMode = ViewNavigationMode.snap;
    } else if (value == 'none') {
      _viewNavigationMode = ViewNavigationMode.none;
    }
    setState(() {
      /// update the view navigation mode changes
    });
  }

  /// Allows to switching the days count customization in calendar.
  void customNumberOfDaysInView(String value) {
    _numberOfDaysString = value;
    if (value == 'default') {
      _numberOfDays = -1;
    } else if (value == '1 day') {
      _numberOfDays = 1;
    } else if (value == '2 days') {
      _numberOfDays = 2;
    } else if (value == '3 days') {
      _numberOfDays = 3;
    } else if (value == '4 days') {
      _numberOfDays = 4;
    } else if (value == '5 days') {
      _numberOfDays = 5;
    } else if (value == '6 days') {
      _numberOfDays = 6;
    } else if (value == '7 days') {
      _numberOfDays = 7;
    }
    setState(() {});
  }


  /// Returns the calendar widget based on the properties passed.
  SfCalendar _getGettingStartedCalendar(
      [CalendarController? calendarController,
        CalendarDataSource? calendarDataSource,
        ViewChangedCallback? viewChangedCallback,
        DateTime? minDate,
        DateTime? maxDate,
        dynamic scheduleViewBuilder]) {
    return SfCalendar(
      controller: calendarController,
      dataSource: calendarDataSource,
      allowedViews: _allowedViews,
      scheduleViewMonthHeaderBuilder: scheduleViewBuilder,
      showNavigationArrow: true,
      showDatePickerButton: _showDatePickerButton,
      allowViewNavigation: _allowViewNavigation,
      showCurrentTimeIndicator: _showCurrentTimeIndicator,
      onViewChanged: viewChangedCallback,
      blackoutDates: _blackoutDates,
      blackoutDatesTextStyle: const TextStyle(
          decoration: null,
          color: Colors.red),
      minDate: minDate,
      maxDate: maxDate,
      monthViewSettings: MonthViewSettings(
          appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
          showTrailingAndLeadingDates: _showLeadingAndTrailingDates),
      timeSlotViewSettings: TimeSlotViewSettings(
          numberOfDaysInView: _numberOfDays,
          minimumAppointmentDuration: const Duration(minutes: 60)),
      viewNavigationMode: _viewNavigationMode,
      showWeekNumber: _showWeekNumber,
    );
  }
}

/// Returns the month name based on the month value passed from date.
String _getMonthDate(int month) {
  if (month == 01) {
    return 'January';
  } else if (month == 02) {
    return 'February';
  } else if (month == 03) {
    return 'March';
  } else if (month == 04) {
    return 'April';
  } else if (month == 05) {
    return 'May';
  } else if (month == 06) {
    return 'June';
  } else if (month == 07) {
    return 'July';
  } else if (month == 08) {
    return 'August';
  } else if (month == 09) {
    return 'September';
  } else if (month == 10) {
    return 'October';
  } else if (month == 11) {
    return 'November';
  } else {
    return 'December';
  }
}

/// Returns the builder for schedule view.
Widget scheduleViewBuilder(
    BuildContext buildContext, ScheduleViewMonthHeaderDetails details) {
  final String monthName = _getMonthDate(details.date.month);
  return Stack(
    children: <Widget>[
      Image(
          image: ExactAssetImage('images/$monthName.png'),
          fit: BoxFit.cover,
          width: details.bounds.width,
          height: details.bounds.height),
      Positioned(
        left: 55,
        right: 0,
        top: 20,
        bottom: 0,
        child: Text(
          '$monthName ${details.date.year}',
          style: const TextStyle(fontSize: 18),
        ),
      )
    ],
  );
}


class _MeetingDataSource extends CalendarDataSource<_PumpModel> {
  _MeetingDataSource(this.source);

  List<_PumpModel> source;

  @override
  List<dynamic> get appointments => source;

  @override
  DateTime getStartTime(int index) {
    return source[index].from;
  }

  @override
  DateTime getEndTime(int index) {
    return source[index].to;
  }

  @override
  String getSubject(int index) {
    return source[index].eventName;
  }

  @override
  Color getColor(int index) {
    return source[index].background;
  }

  @override
  _PumpModel convertAppointmentToObject(
      _PumpModel eventName, Appointment appointment) {
    return _PumpModel(appointment.subject, appointment.startTime,  appointment.endTime, appointment.color);
  }
}

/// Custom business object class which contains properties to hold the detailed
/// information about the event data which will be rendered in calendar.
class _PumpModel {
  _PumpModel(this.eventName, this.from, this.to, this.background);

  String eventName;
  DateTime from;
  DateTime to;
  Color background;
}

