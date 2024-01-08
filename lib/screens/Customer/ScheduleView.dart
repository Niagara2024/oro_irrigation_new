import 'package:flutter/material.dart';

import '../../widgets/SCustomWidgets/custom_date_picker.dart';
import '../../widgets/SCustomWidgets/custom_drop_down.dart';


class ScheduleViewScreen extends StatefulWidget {
  const ScheduleViewScreen({super.key});

  @override
  State<ScheduleViewScreen> createState() => _ScheduleViewScreenState();
}

class _ScheduleViewScreenState extends State<ScheduleViewScreen> {
  var data = [
    {
      "ScheduleId": 57,
      "Date": "04-01-2024",
      "ProgramCategory": "IL.1",
      "ProgramS_No": 1,
      "ProgramName": "TOM AND JERRY",
      "ZoneS_No": 1,
      "ZoneName": "Group_1",
      "RtcNumber": 1,
      "CycleNumber": 1,
      "RtcOnTime": "04:00:00",
      "ProgramStopMethod": 1,
      "RtcOffTime": "06:00:00",
      "Priority": 1,
      "SkipFlag": 0,
      "Status": 0,
      "Pump": "Irrigation Pump 1",
      "SequenceData": "VL.1.1",
      "MainValve": "Main Valve 1",
      "IrrigationMethod": 2,
      "ScheduledStartTime": "04:00:00",
      "PlannedStartTime": "04:00:00",
      "ActualStartTime": "None",
      "ActualStopTime": "None",
      "IrrigationDuration_Quantity": "10000",
      "IrrigationDurationCompleted": "00:10:00",
      "IrrigationQuantityCompleted": "6000",
      "ValveFlowrate": 5000,
      "CentralFilterSite": "None",
      "LocalFilterSite": "None",
      "CentralFilterSiteOperationMode": "None",
      "LocalFilterSiteOperationMode": "None",
      "CentralFilterSelection": "None",
      "LocalFilterSelection": "None",
      "CentralFilterBeginningOnly": "None",
      "LocalFilterBeginningOnly": "None",
      "CentralFilterLimit": "None",
      "LocalFilterLimit": "None",
      "CentralFertOnOff": "0",
      "LocalFertOnOff": "0",
      "CentralFertilizerSite": "Central Fertilizer Site 1",
      "LocalFertilizerSite": "-",
      "PrePostMethod": "None",
      "Pretime": "None",
      "PostTime": "None",
      "PreQty": "None",
      "PostQty": "None",
      "CentralFertMethod": "None",
      "LocalFertMethod": "None",
      "CentralFertChannelSelection": "0",
      "LocalFertChannelSelection": "0",
      "CentralFertilizerChannelDuration": "None",
      "LocalFertilizerChannelDuration": "None",
      "CentralFertilizerChannelQuantity": "None",
      "LocalFertilizerChannelQuantity": "None",
      "CentralFertilizerTankSelection": "0",
      "LocalFertilizerTankSelection": "0",
      "EcBasedOnOff": 0,
      "EcSetValue": 7.0,
      "PhBasedOnOff": 0,
      "CentralFertilizerChannelDurationCompleted": "None",
      "LocalFertilizerChannelDurationCompleted": "None",
      "PhSetValue": 8.0,
      "CentralFertilizerChannelOnDuration": "None",
      "CentralFertilizerChannelOffDuration": "None",
      "CentralFertilizerChannelOnPulseCount": "None",
      "LocalFertilizerChannelOnDuration": "None",
      "LocalFertilizerChannelOffDuration": "None",
      "LocalFertilizerChannelOnPulseCount": "None",
      "CentralFertilizerChannelOnDurationCompleted": "None",
      "CentralFertilizerChannelOffDurationCompleted": "None",
      "CentralFertilizerChannelOnPulseCountCompleted": "None",
      "LocalFertilizerChannelOnDurationCompleted": "None",
      "LocalFertilizerChannelOffDurationCompleted": "None",
      "LocalFertilizerChannelOnPulseCountCompleted": "None",
      "CentralFertChannelSelectionCompleted": "None",
      "LocalFertChannelSelectionCompleted": "None",
      "CentralBoosterDurationCompleted": "None",
      "LocalBoosterDurationCompleted": "None",
      "IrrigationBeginningFlag": 0,
      "CentralFertBeginningFlag": 0,
      "LocalFertBeginningFlag": 0,
      "CentralFertChannelBeginningFlag": "None",
      "LocalFertChannelBeginningFlag": "None",
      "BeginningTime": "0",
      "ProgramDuration": 0.0,
      "Factor": 100,
    },
    {
      "ScheduleId": 58,
      "Date": "04-01-2024",
      "ProgramCategory": "IL.1",
      "ProgramS_No": 1,
      "ProgramName": "TOM AND JERRY",
      "ZoneS_No": 2,
      "ZoneName": "Group_2",
      "RtcNumber": 1,
      "CycleNumber": 1,
      "RtcOnTime": "04:00:00",
      "ProgramStopMethod": 1,
      "RtcOffTime": "06:00:00",
      "Priority": 1,
      "SkipFlag": 0,
      "Status": 1,
      "Pump": "Irrigation Pump 1",
      "SequenceData": "VL.1.2+VL.1.3",
      "MainValve": "Main Valve 1",
      "IrrigationMethod": 1,
      "ScheduledStartTime": "05:00:00",
      "PlannedStartTime": "04:01:00",
      "ActualStartTime": "None",
      "ActualStopTime": "None",
      "IrrigationDuration_Quantity": "02:00:00",
      "IrrigationDurationCompleted": "00:50:00",
      "IrrigationQuantityCompleted": 0,
      "ValveFlowrate": 10000,
      "CentralFilterSite": "None",
      "LocalFilterSite": "None",
      "CentralFilterSiteOperationMode": "None",
      "LocalFilterSiteOperationMode": "None",
      "CentralFilterSelection": "None",
      "LocalFilterSelection": "None",
      "CentralFilterBeginningOnly": "None",
      "LocalFilterBeginningOnly": "None",
      "CentralFilterLimit": "None",
      "LocalFilterLimit": "None",
      "CentralFertOnOff": "0",
      "LocalFertOnOff": "0",
      "CentralFertilizerSite": "-",
      "LocalFertilizerSite": "Local Fertilizer Site 1",
      "PrePostMethod": "None",
      "Pretime": "None",
      "PostTime": "None",
      "PreQty": "None",
      "PostQty": "None",
      "CentralFertMethod": "None",
      "LocalFertMethod": "None",
      "CentralFertChannelSelection": "0",
      "LocalFertChannelSelection": "0",
      "CentralFertilizerChannelDuration": "None",
      "LocalFertilizerChannelDuration": "None",
      "CentralFertilizerChannelQuantity": "None",
      "LocalFertilizerChannelQuantity": "None",
      "CentralFertilizerTankSelection": "0",
      "LocalFertilizerTankSelection": "0",
      "EcBasedOnOff": 0,
      "EcSetValue": 7.0,
      "PhBasedOnOff": 0,
      "CentralFertilizerChannelDurationCompleted": "None",
      "LocalFertilizerChannelDurationCompleted": "None",
      "PhSetValue": 8.0,
      "CentralFertilizerChannelOnDuration": "None",
      "CentralFertilizerChannelOffDuration": "None",
      "CentralFertilizerChannelOnPulseCount": "None",
      "LocalFertilizerChannelOnDuration": "None",
      "LocalFertilizerChannelOffDuration": "None",
      "LocalFertilizerChannelOnPulseCount": "None",
      "CentralFertilizerChannelOnDurationCompleted": "None",
      "CentralFertilizerChannelOffDurationCompleted": "None",
      "CentralFertilizerChannelOnPulseCountCompleted": "None",
      "LocalFertilizerChannelOnDurationCompleted": "None",
      "LocalFertilizerChannelOffDurationCompleted": "None",
      "LocalFertilizerChannelOnPulseCountCompleted": "None",
      "CentralFertChannelSelectionCompleted": "None",
      "LocalFertChannelSelectionCompleted": "None",
      "CentralBoosterDurationCompleted": "None",
      "LocalBoosterDurationCompleted": "None",
      "IrrigationBeginningFlag": 0,
      "CentralFertBeginningFlag": 0,
      "LocalFertBeginningFlag": 0,
      "CentralFertChannelBeginningFlag": "None",
      "LocalFertChannelBeginningFlag": "None",
      "BeginningTime": "0",
      "ProgramDuration": 0.0,
      "Factor": 100,
    },
    {
      "ScheduleId": 59,
      "Date": "04-01-2024",
      "ProgramCategory": "IL.1",
      "ProgramS_No": 1,
      "ProgramName": "TOM AND JERRY",
      "ZoneS_No": 3,
      "ZoneName": "Group_3",
      "RtcNumber": 1,
      "CycleNumber": 1,
      "RtcOnTime": "04:00:00",
      "ProgramStopMethod": 1,
      "RtcOffTime": "06:00:00",
      "Priority": 1,
      "SkipFlag": 0,
      "Status": 4,
      "Pump": "Irrigation Pump 1",
      "SequenceData": "VL.1.4",
      "MainValve": "Main Valve 1",
      "IrrigationMethod": 1,
      "ScheduledStartTime": "07:00:00",
      "PlannedStartTime": "04:02:00",
      "ActualStartTime": "None",
      "ActualStopTime": "None",
      "IrrigationDuration_Quantity": "02:00:00",
      "IrrigationDurationCompleted": "01:00:00",
      "IrrigationQuantityCompleted": 0,
      "ValveFlowrate": 5000,
      "CentralFilterSite": "None",
      "LocalFilterSite": "None",
      "CentralFilterSiteOperationMode": "None",
      "LocalFilterSiteOperationMode": "None",
      "CentralFilterSelection": "None",
      "LocalFilterSelection": "None",
      "CentralFilterBeginningOnly": "None",
      "LocalFilterBeginningOnly": "None",
      "CentralFilterLimit": "None",
      "LocalFilterLimit": "None",
      "CentralFertOnOff": "0",
      "LocalFertOnOff": "0",
      "CentralFertilizerSite": "-",
      "LocalFertilizerSite": "Local Fertilizer Site 1",
      "PrePostMethod": "None",
      "Pretime": "None",
      "PostTime": "None",
      "PreQty": "None",
      "PostQty": "None",
      "CentralFertMethod": "None",
      "LocalFertMethod": "None",
      "CentralFertChannelSelection": "0",
      "LocalFertChannelSelection": "0",
      "CentralFertilizerChannelDuration": "None",
      "LocalFertilizerChannelDuration": "None",
      "CentralFertilizerChannelQuantity": "None",
      "LocalFertilizerChannelQuantity": "None",
      "CentralFertilizerTankSelection": "0",
      "LocalFertilizerTankSelection": "0",
      "EcBasedOnOff": 0,
      "EcSetValue": 7.0,
      "PhBasedOnOff": 0,
      "CentralFertilizerChannelDurationCompleted": "None",
      "LocalFertilizerChannelDurationCompleted": "None",
      "PhSetValue": 8.0,
      "CentralFertilizerChannelOnDuration": "None",
      "CentralFertilizerChannelOffDuration": "None",
      "CentralFertilizerChannelOnPulseCount": "None",
      "LocalFertilizerChannelOnDuration": "None",
      "LocalFertilizerChannelOffDuration": "None",
      "LocalFertilizerChannelOnPulseCount": "None",
      "CentralFertilizerChannelOnDurationCompleted": "None",
      "CentralFertilizerChannelOffDurationCompleted": "None",
      "CentralFertilizerChannelOnPulseCountCompleted": "None",
      "LocalFertilizerChannelOnDurationCompleted": "None",
      "LocalFertilizerChannelOffDurationCompleted": "None",
      "LocalFertilizerChannelOnPulseCountCompleted": "None",
      "CentralFertChannelSelectionCompleted": "None",
      "LocalFertChannelSelectionCompleted": "None",
      "CentralBoosterDurationCompleted": "None",
      "LocalBoosterDurationCompleted": "None",
      "IrrigationBeginningFlag": 0,
      "CentralFertBeginningFlag": 0,
      "LocalFertBeginningFlag": 0,
      "CentralFertChannelBeginningFlag": "None",
      "LocalFertChannelBeginningFlag": "None",
      "BeginningTime": "0",
      "ProgramDuration": 0.0,
      "Factor": 100,
    },
    {
      "ScheduleId": 60,
      "Date": "04-01-2024",
      "ProgramCategory": "IL.1",
      "ProgramS_No": 1,
      "ProgramName": "TOM AND JERRY",
      "ZoneS_No": 4,
      "ZoneName": "Group_4",
      "RtcNumber": 1,
      "CycleNumber": 1,
      "RtcOnTime": "04:00:00",
      "ProgramStopMethod": 1,
      "RtcOffTime": "06:00:00",
      "Priority": 1,
      "SkipFlag": 0,
      "Status": 3,
      "Pump": "Irrigation Pump 1",
      "SequenceData": "VL.1.5",
      "MainValve": "Main Valve 1",
      "IrrigationMethod": 2,
      "ScheduledStartTime": "09:00:00",
      "PlannedStartTime": "04:03:00",
      "ActualStartTime": "None",
      "ActualStopTime": "None",
      "IrrigationDuration_Quantity": "5000",
      "IrrigationDurationCompleted": "00:00:10",
      "IrrigationQuantityCompleted": "3000",
      "ValveFlowrate": 10000,
      "CentralFilterSite": "None",
      "LocalFilterSite": "None",
      "CentralFilterSiteOperationMode": "None",
      "LocalFilterSiteOperationMode": "None",
      "CentralFilterSelection": "None",
      "LocalFilterSelection": "None",
      "CentralFilterBeginningOnly": "None",
      "LocalFilterBeginningOnly": "None",
      "CentralFilterLimit": "None",
      "LocalFilterLimit": "None",
      "CentralFertOnOff": "0",
      "LocalFertOnOff": "0",
      "CentralFertilizerSite": "-",
      "LocalFertilizerSite": "-",
      "PrePostMethod": "None",
      "Pretime": "None",
      "PostTime": "None",
      "PreQty": "None",
      "PostQty": "None",
      "CentralFertMethod": "None",
      "LocalFertMethod": "None",
      "CentralFertChannelSelection": "0",
      "LocalFertChannelSelection": "0",
      "CentralFertilizerChannelDuration": "None",
      "LocalFertilizerChannelDuration": "None",
      "CentralFertilizerChannelQuantity": "None",
      "LocalFertilizerChannelQuantity": "None",
      "CentralFertilizerTankSelection": "0",
      "LocalFertilizerTankSelection": "0",
      "EcBasedOnOff": 0,
      "EcSetValue": 7.0,
      "PhBasedOnOff": 0,
      "CentralFertilizerChannelDurationCompleted": "None",
      "LocalFertilizerChannelDurationCompleted": "None",
      "PhSetValue": 8.0,
      "CentralFertilizerChannelOnDuration": "None",
      "CentralFertilizerChannelOffDuration": "None",
      "CentralFertilizerChannelOnPulseCount": "None",
      "LocalFertilizerChannelOnDuration": "None",
      "LocalFertilizerChannelOffDuration": "None",
      "LocalFertilizerChannelOnPulseCount": "None",
      "CentralFertilizerChannelOnDurationCompleted": "None",
      "CentralFertilizerChannelOffDurationCompleted": "None",
      "CentralFertilizerChannelOnPulseCountCompleted": "None",
      "LocalFertilizerChannelOnDurationCompleted": "None",
      "LocalFertilizerChannelOffDurationCompleted": "None",
      "LocalFertilizerChannelOnPulseCountCompleted": "None",
      "CentralFertChannelSelectionCompleted": "None",
      "LocalFertChannelSelectionCompleted": "None",
      "CentralBoosterDurationCompleted": "None",
      "LocalBoosterDurationCompleted": "None",
      "IrrigationBeginningFlag": 0,
      "CentralFertBeginningFlag": 0,
      "LocalFertBeginningFlag": 0,
      "CentralFertChannelBeginningFlag": "None",
      "LocalFertChannelBeginningFlag": "None",
      "BeginningTime": "0",
      "ProgramDuration": 0.0,
      "Factor": 100,
    },
    {
      "ScheduleId": 61,
      "Date": "04-01-2024",
      "ProgramCategory": "IL.1",
      "ProgramS_No": 1,
      "ProgramName": "TOM AND JERRY",
      "ZoneS_No": 1,
      "ZoneName": "Group_1",
      "RtcNumber": 1,
      "CycleNumber": 2,
      "RtcOnTime": "04:00:00",
      "ProgramStopMethod": 1,
      "RtcOffTime": "06:00:00",
      "Priority": 1,
      "SkipFlag": 0,
      "Status": 2,
      "Pump": "Irrigation Pump 1",
      "SequenceData": "VL.1.1",
      "MainValve": "Main Valve 1",
      "IrrigationMethod": 1,
      "ScheduledStartTime": "12:00:00",
      "PlannedStartTime": "12:00:00",
      "ActualStartTime": "None",
      "ActualStopTime": "None",
      "IrrigationDuration_Quantity": "01:00:00",
      "IrrigationDurationCompleted": "01:00:00",
      "IrrigationQuantityCompleted": 0,
      "ValveFlowrate": 5000,
      "CentralFilterSite": "None",
      "LocalFilterSite": "None",
      "CentralFilterSiteOperationMode": "None",
      "LocalFilterSiteOperationMode": "None",
      "CentralFilterSelection": "None",
      "LocalFilterSelection": "None",
      "CentralFilterBeginningOnly": "None",
      "LocalFilterBeginningOnly": "None",
      "CentralFilterLimit": "None",
      "LocalFilterLimit": "None",
      "CentralFertOnOff": "0",
      "LocalFertOnOff": "0",
      "CentralFertilizerSite": "Central Fertilizer Site 2",
      "LocalFertilizerSite": "-",
      "PrePostMethod": "None",
      "Pretime": "None",
      "PostTime": "None",
      "PreQty": "None",
      "PostQty": "None",
      "CentralFertMethod": "None",
      "LocalFertMethod": "None",
      "CentralFertChannelSelection": "0",
      "LocalFertChannelSelection": "0",
      "CentralFertilizerChannelDuration": "None",
      "LocalFertilizerChannelDuration": "None",
      "CentralFertilizerChannelQuantity": "None",
      "LocalFertilizerChannelQuantity": "None",
      "CentralFertilizerTankSelection": "0",
      "LocalFertilizerTankSelection": "0",
      "EcBasedOnOff": 0,
      "EcSetValue": 7.0,
      "PhBasedOnOff": 0,
      "CentralFertilizerChannelDurationCompleted": "None",
      "LocalFertilizerChannelDurationCompleted": "None",
      "PhSetValue": 8.0,
      "CentralFertilizerChannelOnDuration": "None",
      "CentralFertilizerChannelOffDuration": "None",
      "CentralFertilizerChannelOnPulseCount": "None",
      "LocalFertilizerChannelOnDuration": "None",
      "LocalFertilizerChannelOffDuration": "None",
      "LocalFertilizerChannelOnPulseCount": "None",
      "CentralFertilizerChannelOnDurationCompleted": "None",
      "CentralFertilizerChannelOffDurationCompleted": "None",
      "CentralFertilizerChannelOnPulseCountCompleted": "None",
      "LocalFertilizerChannelOnDurationCompleted": "None",
      "LocalFertilizerChannelOffDurationCompleted": "None",
      "LocalFertilizerChannelOnPulseCountCompleted": "None",
      "CentralFertChannelSelectionCompleted": "None",
      "LocalFertChannelSelectionCompleted": "None",
      "CentralBoosterDurationCompleted": "None",
      "LocalBoosterDurationCompleted": "None",
      "IrrigationBeginningFlag": 0,
      "CentralFertBeginningFlag": 0,
      "LocalFertBeginningFlag": 0,
      "CentralFertChannelBeginningFlag": "None",
      "LocalFertChannelBeginningFlag": "None",
      "BeginningTime": "0",
      "ProgramDuration": 0.0,
      "Factor": 100,
    },
    {
      "ScheduleId": 62,
      "Date": "04-01-2024",
      "ProgramCategory": "IL.1",
      "ProgramS_No": 1,
      "ProgramName": "TOM AND JERRY",
      "ZoneS_No": 2,
      "ZoneName": "Group_2",
      "RtcNumber": 1,
      "CycleNumber": 2,
      "RtcOnTime": "04:00:00",
      "ProgramStopMethod": 1,
      "RtcOffTime": "06:00:00",
      "Priority": 1,
      "SkipFlag": 0,
      "Status": 5,
      "Pump": "Irrigation Pump 1",
      "SequenceData": "VL.1.2+VL.1.3",
      "MainValve": "Main Valve 1",
      "IrrigationMethod": 1,
      "ScheduledStartTime": "13:00:00",
      "PlannedStartTime": "12:01:00",
      "ActualStartTime": "None",
      "ActualStopTime": "None",
      "IrrigationDuration_Quantity": "02:00:00",
      "IrrigationDurationCompleted": "00:30:00",
      "IrrigationQuantityCompleted": 0,
      "ValveFlowrate": 10000,
      "CentralFilterSite": "None",
      "LocalFilterSite": "None",
      "CentralFilterSiteOperationMode": "None",
      "LocalFilterSiteOperationMode": "None",
      "CentralFilterSelection": "None",
      "LocalFilterSelection": "None",
      "CentralFilterBeginningOnly": "None",
      "LocalFilterBeginningOnly": "None",
      "CentralFilterLimit": "None",
      "LocalFilterLimit": "None",
      "CentralFertOnOff": "0",
      "LocalFertOnOff": "0",
      "CentralFertilizerSite": "Central Fertilizer Site 1",
      "LocalFertilizerSite": "-",
      "PrePostMethod": "None",
      "Pretime": "None",
      "PostTime": "None",
      "PreQty": "None",
      "PostQty": "None",
      "CentralFertMethod": "None",
      "LocalFertMethod": "None",
      "CentralFertChannelSelection": "0",
      "LocalFertChannelSelection": "0",
      "CentralFertilizerChannelDuration": "None",
      "LocalFertilizerChannelDuration": "None",
      "CentralFertilizerChannelQuantity": "None",
      "LocalFertilizerChannelQuantity": "None",
      "CentralFertilizerTankSelection": "0",
      "LocalFertilizerTankSelection": "0",
      "EcBasedOnOff": 0,
      "EcSetValue": 7.0,
      "PhBasedOnOff": 0,
      "CentralFertilizerChannelDurationCompleted": "None",
      "LocalFertilizerChannelDurationCompleted": "None",
      "PhSetValue": 8.0,
      "CentralFertilizerChannelOnDuration": "None",
      "CentralFertilizerChannelOffDuration": "None",
      "CentralFertilizerChannelOnPulseCount": "None",
      "LocalFertilizerChannelOnDuration": "None",
      "LocalFertilizerChannelOffDuration": "None",
      "LocalFertilizerChannelOnPulseCount": "None",
      "CentralFertilizerChannelOnDurationCompleted": "None",
      "CentralFertilizerChannelOffDurationCompleted": "None",
      "CentralFertilizerChannelOnPulseCountCompleted": "None",
      "LocalFertilizerChannelOnDurationCompleted": "None",
      "LocalFertilizerChannelOffDurationCompleted": "None",
      "LocalFertilizerChannelOnPulseCountCompleted": "None",
      "CentralFertChannelSelectionCompleted": "None",
      "LocalFertChannelSelectionCompleted": "None",
      "CentralBoosterDurationCompleted": "None",
      "LocalBoosterDurationCompleted": "None",
      "IrrigationBeginningFlag": 0,
      "CentralFertBeginningFlag": 0,
      "LocalFertBeginningFlag": 0,
      "CentralFertChannelBeginningFlag": "None",
      "LocalFertChannelBeginningFlag": "None",
      "BeginningTime": "0",
      "ProgramDuration": 0.0,
      "Factor": 100,
    },
    {
      "ScheduleId": 63,
      "Date": "04-01-2024",
      "ProgramCategory": "IL.1",
      "ProgramS_No": 1,
      "ProgramName": "TOM AND JERRY",
      "ZoneS_No": 3,
      "ZoneName": "Group_3",
      "RtcNumber": 1,
      "CycleNumber": 2,
      "RtcOnTime": "04:00:00",
      "ProgramStopMethod": 1,
      "RtcOffTime": "06:00:00",
      "Priority": 1,
      "SkipFlag": 0,
      "Status": 6,
      "Pump": "Irrigation Pump 1",
      "SequenceData": "VL.1.4",
      "MainValve": "Main Valve 1",
      "IrrigationMethod": 1,
      "ScheduledStartTime": "15:00:00",
      "PlannedStartTime": "12:02:00",
      "ActualStartTime": "None",
      "ActualStopTime": "None",
      "IrrigationDuration_Quantity": "02:00:00",
      "IrrigationDurationCompleted": "00:30:00",
      "IrrigationQuantityCompleted": 0,
      "ValveFlowrate": 5000,
      "CentralFilterSite": "None",
      "LocalFilterSite": "None",
      "CentralFilterSiteOperationMode": "None",
      "LocalFilterSiteOperationMode": "None",
      "CentralFilterSelection": "None",
      "LocalFilterSelection": "None",
      "CentralFilterBeginningOnly": "None",
      "LocalFilterBeginningOnly": "None",
      "CentralFilterLimit": "None",
      "LocalFilterLimit": "None",
      "CentralFertOnOff": "0",
      "LocalFertOnOff": "0",
      "CentralFertilizerSite": "Central Fertilizer Site 2",
      "LocalFertilizerSite": "Local Fertilizer Site 1",
      "PrePostMethod": "None",
      "Pretime": "None",
      "PostTime": "None",
      "PreQty": "None",
      "PostQty": "None",
      "CentralFertMethod": "None",
      "LocalFertMethod": "None",
      "CentralFertChannelSelection": "0",
      "LocalFertChannelSelection": "0",
      "CentralFertilizerChannelDuration": "None",
      "LocalFertilizerChannelDuration": "None",
      "CentralFertilizerChannelQuantity": "None",
      "LocalFertilizerChannelQuantity": "None",
      "CentralFertilizerTankSelection": "0",
      "LocalFertilizerTankSelection": "0",
      "EcBasedOnOff": 0,
      "EcSetValue": 7.0,
      "PhBasedOnOff": 0,
      "CentralFertilizerChannelDurationCompleted": "None",
      "LocalFertilizerChannelDurationCompleted": "None",
      "PhSetValue": 8.0,
      "CentralFertilizerChannelOnDuration": "None",
      "CentralFertilizerChannelOffDuration": "None",
      "CentralFertilizerChannelOnPulseCount": "None",
      "LocalFertilizerChannelOnDuration": "None",
      "LocalFertilizerChannelOffDuration": "None",
      "LocalFertilizerChannelOnPulseCount": "None",
      "CentralFertilizerChannelOnDurationCompleted": "None",
      "CentralFertilizerChannelOffDurationCompleted": "None",
      "CentralFertilizerChannelOnPulseCountCompleted": "None",
      "LocalFertilizerChannelOnDurationCompleted": "None",
      "LocalFertilizerChannelOffDurationCompleted": "None",
      "LocalFertilizerChannelOnPulseCountCompleted": "None",
      "CentralFertChannelSelectionCompleted": "None",
      "LocalFertChannelSelectionCompleted": "None",
      "CentralBoosterDurationCompleted": "None",
      "LocalBoosterDurationCompleted": "None",
      "IrrigationBeginningFlag": 0,
      "CentralFertBeginningFlag": 0,
      "LocalFertBeginningFlag": 0,
      "CentralFertChannelBeginningFlag": "None",
      "LocalFertChannelBeginningFlag": "None",
      "BeginningTime": "0",
      "ProgramDuration": 0.0,
      "Factor": 100,
    },
    {
      "ScheduleId": 64,
      "Date": "04-01-2024",
      "ProgramCategory": "IL.1",
      "ProgramS_No": 1,
      "ProgramName": "TOM AND JERRY",
      "ZoneS_No": 4,
      "ZoneName": "Group_4",
      "RtcNumber": 1,
      "CycleNumber": 2,
      "RtcOnTime": "04:00:00",
      "ProgramStopMethod": 1,
      "RtcOffTime": "06:00:00",
      "Priority": 1,
      "SkipFlag": 0,
      "Status": 7,
      "Pump": "Irrigation Pump 1",
      "SequenceData": "VL.1.1+VL.1.2+VL.1.3+VL.1.4",
      "MainValve": "Main Valve 1",
      "IrrigationMethod": 1,
      "ScheduledStartTime": "17:00:00",
      "PlannedStartTime": "12:03:00",
      "ActualStartTime": "None",
      "ActualStopTime": "None",
      "IrrigationDuration_Quantity": "01:00:00",
      "IrrigationDurationCompleted": "00:20:00",
      "IrrigationQuantityCompleted": 0,
      "ValveFlowrate": 10000,
      "CentralFilterSite": "None",
      "LocalFilterSite": "None",
      "CentralFilterSiteOperationMode": "None",
      "LocalFilterSiteOperationMode": "None",
      "CentralFilterSelection": "None",
      "LocalFilterSelection": "None",
      "CentralFilterBeginningOnly": "None",
      "LocalFilterBeginningOnly": "None",
      "CentralFilterLimit": "None",
      "LocalFilterLimit": "None",
      "CentralFertOnOff": "0",
      "LocalFertOnOff": "0",
      "CentralFertilizerSite": "Central Fertilizer Site 1",
      "LocalFertilizerSite": "-",
      "PrePostMethod": "None",
      "Pretime": "None",
      "PostTime": "None",
      "PreQty": "None",
      "PostQty": "None",
      "CentralFertMethod": "None",
      "LocalFertMethod": "None",
      "CentralFertChannelSelection": "0",
      "LocalFertChannelSelection": "0",
      "CentralFertilizerChannelDuration": "None",
      "LocalFertilizerChannelDuration": "None",
      "CentralFertilizerChannelQuantity": "None",
      "LocalFertilizerChannelQuantity": "None",
      "CentralFertilizerTankSelection": "0",
      "LocalFertilizerTankSelection": "0",
      "EcBasedOnOff": 0,
      "EcSetValue": 7.0,
      "PhBasedOnOff": 0,
      "CentralFertilizerChannelDurationCompleted": "None",
      "LocalFertilizerChannelDurationCompleted": "None",
      "PhSetValue": 8.0,
      "CentralFertilizerChannelOnDuration": "None",
      "CentralFertilizerChannelOffDuration": "None",
      "CentralFertilizerChannelOnPulseCount": "None",
      "LocalFertilizerChannelOnDuration": "None",
      "LocalFertilizerChannelOffDuration": "None",
      "LocalFertilizerChannelOnPulseCount": "None",
      "CentralFertilizerChannelOnDurationCompleted": "None",
      "CentralFertilizerChannelOffDurationCompleted": "None",
      "CentralFertilizerChannelOnPulseCountCompleted": "None",
      "LocalFertilizerChannelOnDurationCompleted": "None",
      "LocalFertilizerChannelOffDurationCompleted": "None",
      "LocalFertilizerChannelOnPulseCountCompleted": "None",
      "CentralFertChannelSelectionCompleted": "None",
      "LocalFertChannelSelectionCompleted": "None",
      "CentralBoosterDurationCompleted": "None",
      "LocalBoosterDurationCompleted": "None",
      "IrrigationBeginningFlag": 0,
      "CentralFertBeginningFlag": 0,
      "LocalFertBeginningFlag": 0,
      "CentralFertChannelBeginningFlag": "None",
      "LocalFertChannelBeginningFlag": "None",
      "BeginningTime": "0",
      "ProgramDuration": 0.0,
      "Factor": 100,
    },
  ];
  var reorderedList = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    reorderedList = data;
  }

  Future<void> initiateData() async {
    // await mqttServiceWeb.onPressMQTTTest();

    var data = {
      "2600": [
        {"2601": "2024-01-05"}
      ]
    }.toString();

  }
  String changeToValue = '';
  bool start = false;
  bool pause = false;
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Scaffold(
            // backgroundColor: Colors.white,
            body: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      children: [
                        Text("Select a Date"),
                        SizedBox(width: 20,),
                        Card(
                            surfaceTintColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: DatePickerField(
                                value: DateTime.now(),
                                onChanged: (DateTime) {},
                              ),
                            )),
                      ],
                    ),
                    Row(
                      children: [
                        Text("Change To"),
                        SizedBox(width: 20,),
                        Card(
                          surfaceTintColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: SizedBox(
                              height: 40,
                              width: 50,
                              child: CustomDropdownWidget(
                                dropdownItems: data.map((e) => e["ScheduleId"].toString()).toList(),
                                selectedValue: changeToValue != "" ? changeToValue : data[0]["ScheduleId"].toString(),
                                onChanged: (newValue) {
                                  setState(() {
                                    changeToValue = newValue!;
                                    int changeToIndex = data.indexWhere((element) => element["ScheduleId"].toString() == changeToValue);
                                    reorderedList = [
                                      ...data.sublist(changeToIndex),
                                      ...data.sublist(0, changeToIndex)
                                    ];
                                  });
                                },
                                includeNoneOption: false,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
                Expanded(
                  child: ReorderableListView.builder(
                      scrollDirection: Axis.vertical,
                      // padding: EdgeInsets.symmetric(horizontal: 10),
                      itemCount: reorderedList.length,
                      onReorder: (int oldIndex, int newIndex) {
                        setState(() {
                          if (oldIndex < newIndex) {
                            newIndex -= 1;
                          }
                          final item = reorderedList.removeAt(oldIndex);
                          reorderedList.insert(newIndex, item);
                        });
                        changeToValue = reorderedList[0]["ScheduleId"].toString();
                      },
                      proxyDecorator: (widget, animation, index) {
                        return Transform.scale(
                          scale: 0.95,
                          child: widget,
                        );
                      },
                      itemBuilder: (BuildContext context, int index) {
                        String sno = reorderedList[index]["ScheduleId"].toString();
                        String programName = reorderedList[index]["ProgramName"].toString();
                        String zoneName = reorderedList[index]["ZoneName"].toString();
                        String statusCode = reorderedList[index]["Status"].toString();
                        var method = reorderedList[index]["IrrigationMethod"].toString();
                        var fertMethod = reorderedList[index]["CentralFertMethod"].toString();
                        var inputValue = reorderedList[index]["IrrigationDuration_Quantity"].toString();
                        var completedValue = method == "1"
                            ? reorderedList[index]["IrrigationDurationCompleted"].toString()
                            : reorderedList[index]["IrrigationQuantityCompleted"].toString();
                        var pumps = reorderedList[index]['Pump'];
                        var mainValves = reorderedList[index]['MainValve'];
                        var valves = reorderedList[index]['SequenceData'];
                        var toLeftDuration;
                        var progressValue;
                        var fertTLeftDuration;
                        var fertProgressValue;
                        if (method == "1") {
                          List<String> inputTimeParts = inputValue.split(':');
                          int inHours = int.parse(inputTimeParts[0]);
                          int inMinutes = int.parse(inputTimeParts[1]);
                          int inSeconds = int.parse(inputTimeParts[2]);

                          List<String> timeComponents = completedValue.split(':');
                          int hours = int.parse(timeComponents[0]);
                          int minutes = int.parse(timeComponents[1]);
                          int seconds = int.parse(timeComponents[2]);

                          Duration inDuration =
                          Duration(hours: inHours, minutes: inMinutes, seconds: inSeconds);
                          Duration completedDuration =
                          Duration(hours: hours, minutes: minutes, seconds: seconds);

                          toLeftDuration = inDuration - completedDuration;
                          progressValue =
                              completedDuration.inMilliseconds / inDuration.inMilliseconds;
                        } else {
                          progressValue = int.parse(completedValue) / int.parse(inputValue);
                        }

                        return Column(
                          key: ValueKey<int>(
                              int.parse(reorderedList[index]["ScheduleId"].toString())),
                          children: [
                            buildScheduleList(
                                sno,
                                programName,
                                zoneName,
                                statusCode,
                                inputValue,
                                completedValue,
                                toLeftDuration,
                                progressValue,
                                pumps,
                                mainValves,
                                valves),
                            // SizedBox(
                            //   height: 10,
                            // )
                          ],
                        );
                      }),
                )
              ],
            ),
          );
        });
  }

  Widget buildScheduleList(
      String sno,
      String programName,
      String zoneName,
      String statusCode,
      String inputValue,
      String completedValue,
      toLeftDuration,
      progressValue,
      pumps,
      mainValves,
      valves) {
    StatusInfo getStatusInfo(code) {
      Color innerCircleColor;
      String statusString;

      switch (code) {
        case "0":
          innerCircleColor = Colors.grey;
          statusString = "Pending";
          break;
        case "1":
          innerCircleColor = Colors.orange;
          statusString = "Running";
          break;
        case "2":
          innerCircleColor = Colors.green;
          statusString = "Completed";
          break;
        case "3":
          innerCircleColor = Colors.yellow;
          statusString = "Skipped by user";
          break;
        case "4":
          innerCircleColor = Colors.orangeAccent;
          statusString = "Day schedule pending";
          break;
        case "5":
          innerCircleColor = Color(0xFF0D5D9A);
          statusString = "Day schedule running";
          break;
        case "6":
          innerCircleColor = Colors.yellowAccent;
          statusString = "Day schedule completed";
          break;
        case "7":
          innerCircleColor = Colors.red;
          statusString = "Day schedule skipped";
          break;
        case "8":
          innerCircleColor = Colors.redAccent;
          statusString = "Postponed partially to tomorrow";
          break;
        case "9":
          innerCircleColor = Colors.green;
          statusString = "Postponed fully to tomorrow";
          break;
        case "10":
          innerCircleColor = Colors.amberAccent;
          statusString = "RTC off time reached";
          break;
        case "11":
          innerCircleColor = Colors.amber;
          statusString = "RTC max time reached";
          break;
        default:
          throw Exception("Unsupported status code: $code");
      }

      return StatusInfo(innerCircleColor, statusString);
    }

    var status = getStatusInfo(statusCode);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          // border: Border.all(color: status.color)
        ),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Theme.of(context).primaryColor, width: 0.5),
                      color: Colors.white),
                  child: Center(
                      child: Text(
                        sno,
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ))),
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    programName,
                    style: TextStyle(fontSize: 10),
                  ),
                  Text(zoneName),
                  Row(
                    children: [
                      // Container(
                      //   width: 11,
                      //   height: 11,
                      //   decoration: const BoxDecoration(
                      //     shape: BoxShape.circle,
                      //     color: Colors.black,
                      //   ),
                      //   child: Center(
                      //     child: Container(
                      //       width: 10,
                      //       height: 10,
                      //       decoration: BoxDecoration(
                      //         shape: BoxShape.circle,
                      //         color: status.color, // Inner circle color
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      // SizedBox(
                      //   width: 5,
                      // ),
                      Expanded(
                        child: Text(
                          status.statusString,
                          style: TextStyle(fontSize: 10),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            SizedBox(
              width: 30,
            ),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Completed: $completedValue",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    "Actual: $inputValue",
                    style: TextStyle(
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    "To left: $toLeftDuration",
                    style: TextStyle(fontSize: 12),
                  ),
                  MouseRegion(
                    onHover: (onHover) {},
                    child: Tooltip(
                      message: completedValue,
                      child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        child: Container(
                          decoration: BoxDecoration(
                              border:
                              Border.all(width: 0.3, color: Colors.black),
                              borderRadius: BorderRadius.circular(10)),
                          child: LinearProgressIndicator(
                            value: progressValue.clamp(0.0, 1.0),
                            backgroundColor: Colors.grey[300],
                            valueColor:
                            AlwaysStoppedAnimation<Color>(status.color),
                            minHeight: 10,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 20,
            ),
            Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(pumps),
                    Text("Pumps", style: TextStyle(fontSize: 12),)
                  ],
                )),
            SizedBox(
              width: 10,
            ),
            Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(mainValves),
                    Text("Main Valves", style: TextStyle(fontSize: 12),)
                  ],
                )),
            Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(valves.split('+').join(', ').toString()),
                    Text("Valves", style: TextStyle(fontSize: 12),)
                  ],
                )),
            Expanded(
                flex: 2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                        onPressed: (){
                          setState(() {
                            start = !start;
                          });
                        },
                        child: Text(start ? "Start" : "Stop")),
                    TextButton(
                        onPressed: (){
                          setState(() {
                            pause = !pause;
                          });
                        },
                        child: Text(pause ? "Pause" : "Resume")),
                  ],
                )),
          ],
        ),
      ),
    );
  }
}

class StatusInfo {
  final Color color;
  final String statusString;

  StatusInfo(this.color, this.statusString);
}
