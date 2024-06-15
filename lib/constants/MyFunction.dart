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
