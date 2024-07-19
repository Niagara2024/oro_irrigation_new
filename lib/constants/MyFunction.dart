import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../state_management/MqttPayloadProvider.dart';

class MyFunction {

  void clearMQTTPayload(context){
    MqttPayloadProvider payloadProvider = Provider.of<MqttPayloadProvider>(context, listen: false);
    payloadProvider.currentSchedule.clear();
    payloadProvider.PrsIn=[];
    payloadProvider.PrsOut=[];
    payloadProvider.programQueue.clear();
    payloadProvider.scheduledProgram.clear();
    payloadProvider.filtersCentral=[];
    payloadProvider.filtersLocal=[];
    payloadProvider.sourcePump=[];
    payloadProvider.irrigationPump=[];
    payloadProvider.fertilizerCentral=[];
    payloadProvider.fertilizerLocal=[];
    payloadProvider.waterMeter=[];
    payloadProvider.wifiStrength = 0;
    payloadProvider.alarmList = [];
    payloadProvider.payload2408 = [];
  }
}

enum GemProgramSSReasonCode {
  runningAsPerSchedule(1, 'Running As Per Schedule'),
  turnedOnManually(2, 'Turned On Manually'),
  startedByCondition(3, 'Started By Condition'),
  turnedOffManually(4, 'Turned Off Manually'),
  programTurnedOff(5, 'Program Turned Off'),
  zoneTurnedOff(6, 'Zone Turned Off'),
  stoppedByCondition(7, 'Stopped By Condition'),
  disabledByCondition(8, 'Disabled By Condition'),
  standAloneProgramStarted(9, 'StandAlone Program Started'),
  standAloneProgramStopped(10, 'StandAlone Program Stopped'),
  standAloneProgramStoppedAfterSetValue(11, 'StandAlone Program Stopped After Set Value'),
  standAloneManualStarted(12, 'StandAlone Manual Started'),
  standAloneManualStopped(13, 'StandAlone Manual Stopped'),
  standAloneManualStoppedAfterSetValue(14, 'StandAlone Manual Stopped After Set Value'),
  startedByDayCountRtc(15, 'Started By Day Count Rtc'),
  pausedByUser(16, 'Paused By User'),
  manuallyStartedPausedByUser(17, 'Manually Started Paused By User'),
  programDeleted(18, 'Program Deleted'),
  programReady(19, 'Program Ready'),
  programCompleted(20, 'Program Completed'),
  resumedByUser(21, 'Resumed By User'),
  pausedByCondition(23, 'Paused By Condition'),
  unknown(0, 'Unknown content');

  final int code;
  final String content;

  const GemProgramSSReasonCode(this.code, this.content);

  static GemProgramSSReasonCode fromCode(int code) {
    return GemProgramSSReasonCode.values.firstWhere((e) => e.code == code,
      orElse: () => GemProgramSSReasonCode.unknown,
    );
  }
}

enum GemLineSSReasonCode {
  linePausedManually(1, 'The Line Paused Manually'),
  pausedByStandAloneMode(2, 'The Line Paused By StandAlone Mode'),
  pausedBySystemDefinition(3, 'The Line Paused By System Definition'),
  pausedByLowFlowAlarm(4, 'The Line Paused By Low Flow Alarm'),
  pausedByHighFlowAlarm(5, 'The Line Paused By High Flow Alarm'),
  pausedByNoFlowAlarm(6, 'The Line Paused By No Flow Alarm'),
  pausedByEcHigh(7, 'The Line Paused By Ec High'),
  pausedByPhLow(8, 'The Line Paused By Ph Low'),
  pausedByPhHigh(9, 'The Line Paused By Ph High'),
  pausedByPressureLow(10, 'The Line Paused By Pressure Low'),
  pausedByPressureHigh(11, 'The Line Paused By Pressure High'),
  pausedByNoPowerSupply(12, 'The Line Paused By No Power Supply'),
  pausedByNoCommunication(13, 'The Line Paused By No Communication'),
  unknown(0, 'Unknown content');

  final int code;
  final String content;

  const GemLineSSReasonCode(this.code, this.content);

  static GemLineSSReasonCode fromCode(int code) {
    return GemLineSSReasonCode.values.firstWhere((e) => e.code == code,
      orElse: () => GemLineSSReasonCode.unknown,
    );
  }
}

String convert24HourTo12Hour(String timeString) {
  if(timeString=='-'){
    return '-';
  }
  final parsedTime = DateFormat('HH:mm:ss').parse(timeString);
  final formattedTime = DateFormat('hh:mm a').format(parsedTime);
  return formattedTime;
}

enum PumpReasonCode {
  reason1(1, 'Motor off due to sump empty'),
  reason2(2, 'Motor off due to upper tank full'),
  reason3(3, 'Motor off due to low voltage'),
  reason4(4, 'Motor off due to high voltage'),
  reason5(5, 'Motor off due to voltage SPP'),
  reason6(6, 'Motor off due to reverse phase'),
  reason7(7, 'Motor off due to starter trip'),
  reason8(8, 'Motor off due to dry run'),
  reason9(9, 'Motor off due to overload'),
  reason10(10, 'Motor off due to current SPP'),
  reason11(11, 'Motor off due to cyclic trip'),
  reason12(12, 'Motor off due to maximum run time'),
  reason13(13, 'Motor off due to sump empty'),
  reason14(14, 'Motor off due to upper tank full'),
  reason15(15, 'Motor off due to RTC 1'),
  reason16(16, 'Motor off due to RTC 2'),
  reason17(17, 'Motor off due to RTC 3'),
  reason18(18, 'Motor off due to RTC 4'),
  reason19(19, 'Motor off due to RTC 5'),
  reason20(20, 'Motor off due to RTC 6'),
  reason21(21, 'Motor off due to auto mobile key off'),

  reason22(22, 'Motor on due to cyclic time'),
  reason23(23, 'Motor on due to RTC 1'),
  reason24(24, 'Motor on due to RTC 2'),
  reason25(25, 'Motor on due to RTC 3'),
  reason26(26, 'Motor on due to RTC 4'),
  reason27(27, 'Motor on due to RTC 5'),
  reason28(28, 'Motor on due to RTC 6'),
  reason29(29, 'Motor on due to auto mobile key on'),
  reason30(30, 'Motor on due to Power off'),
  reason31(31, 'Motor on due to Power on'),
  unknown(0, 'Unknown content');

  final int code;
  final String content;
  final String motorOff = "Motor off due to";
  final String motorOn = "Motor on due to";

  const PumpReasonCode(this.code, this.content);

  static PumpReasonCode fromCode(int code) {
    return PumpReasonCode.values.firstWhere((e) => e.code == code,
      orElse: () => PumpReasonCode.unknown,
    );
  }
}

String getImageForProduct(String product) {
  String baseImgPath = 'assets/images/';
  String value = product.substring(0, 2);
  switch (value) {
    case 'VL':
      return '${baseImgPath}dl_valve.png';
    case 'MV':
      return '${baseImgPath}dl_main_valve.png';
    case 'SP':
      return '${baseImgPath}dl_source_pump.png';
    case 'IP':
      return '${baseImgPath}dl_irrigation_pump.png';
    case 'AS':
      return '${baseImgPath}dl_analog_sensor.png';
    case 'LS':
      return '${baseImgPath}dl_level_sensor.png';
    case 'FB':
      return '${baseImgPath}dl_booster_pump.png';
    case 'Central Filter Site':
      return '${baseImgPath}dl_central_filtration_site.png';
    case 'AG':
      return '${baseImgPath}dl_agitator.png';
    case 'Injector':
      return '${baseImgPath}dl_injector.png';
    case 'FL':
      return '${baseImgPath}dl_filter.png';
    case 'Downstream Valve':
      return '${baseImgPath}dl_downstream_valve.png';
    case 'Fan':
      return '${baseImgPath}dl_fan.png';
    case 'FB':
      return '${baseImgPath}dl_fogger.png';
    case 'SL':
      return '${baseImgPath}dl_selector.png';
    case 'Water Meter':
      return '${baseImgPath}dl_water_meter.png';
    case 'FM':
      return '${baseImgPath}dl_fertilizer_meter.png';
    case 'Co2 Sensor':
      return '${baseImgPath}dl_co2.png';
    case 'PSW':
      return '${baseImgPath}dl_pressure_switch.png';
    case 'LO':
      return '${baseImgPath}dl_pressure_sensor.png';
    case 'Differential Pressure Sensor':
      return '${baseImgPath}dl_differential_pressure_sensor.png';
    case 'EC':
      return '${baseImgPath}dl_ec_sensor.png';
    case 'PH':
      return '${baseImgPath}dl_ph_sensor.png';
    case 'Temperature':
      return '${baseImgPath}dl_temperature_sensor.png';
    case 'Soil Temperature Sensor':
      return '${baseImgPath}dl_soil_temperature_sensor.png';
    case 'Wind Direction Sensor':
      return '${baseImgPath}dl_wind_direction_sensor.png';
    case 'Wind Speed Sensor':
      return '${baseImgPath}dl_wind_speed_sensor.png';
    case 'LUX Sensor':
      return '${baseImgPath}dl_lux_sensor.png';
    case 'LDR Sensor':
      return '${baseImgPath}dl_ldr_sensor.png';
    case 'Humidity Sensor':
      return '${baseImgPath}dl_humidity_sensor.png';
    case 'Leaf Wetness Sensor':
      return '${baseImgPath}dl_leaf_wetness_sensor.png';
    case 'Rain Gauge Sensor':
      return '${baseImgPath}dl_rain_gauge_sensor.png';
    case 'Contact':
      return '${baseImgPath}dl_contact.png';
    case 'Weather Station':
      return '${baseImgPath}dl_weather_station.png';
    case 'Condition':
      return '${baseImgPath}dl_condition.png';
    case 'Valve Group':
      return '${baseImgPath}dl_valve_group.png';
    case 'Virtual Water Meter':
      return '${baseImgPath}dl_virtual_water_meter.png';
    case 'Program':
      return '${baseImgPath}dl_programs.png';
    case 'Radiation Set':
      return '${baseImgPath}dl_radiation_sets.png';
    case 'FC':
      return '${baseImgPath}dl_fertilization_sets.png';
    case 'Filter Set':
      return '${baseImgPath}dl_filter_sets.png';
    case 'SM':
      return '${baseImgPath}dl_moisture_sensor.png';
    case 'Float':
      return '${baseImgPath}dl_float.png';
    case 'Moisture Condition':
      return '${baseImgPath}dl_moisture_condition.png';
    case 'Tank Float':
      return '${baseImgPath}dl_tank_float.png';
    case 'Power Supply':
      return '${baseImgPath}dl_power_supply.png';
    case 'Level Condition':
      return '${baseImgPath}dl_level_condition.png';
    case 'Common Pressure Sensor':
      return '${baseImgPath}dl_common_pressure_sensor.png';
    case 'SW':
      return '${baseImgPath}dl_common_pressure_switch.png';
    default:
      return '${baseImgPath}dl_humidity_sensor.png';
  }
}



