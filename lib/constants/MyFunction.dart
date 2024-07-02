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

enum GemReasonCode {
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

  const GemReasonCode(this.code, this.content);

  static GemReasonCode fromCode(int code) {
    return GemReasonCode.values.firstWhere((e) => e.code == code,
      orElse: () => GemReasonCode.unknown,
    );
  }
}
