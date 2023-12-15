import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../state_management/irrigation_program_main_provider.dart';
import '../../../widgets/SCustomWidgets/custom_list_tile.dart';


class AlarmScreen extends StatefulWidget {
  final int userId;
  final int controllerId;
  final int serialNumber;
  const AlarmScreen({super.key, required this.userId, required this.controllerId, required this.serialNumber});

  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  @override
  Widget build(BuildContext context) {
    final alarmProvider = Provider.of<IrrigationProgramMainProvider>(context);

    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints){
          return ListView(
            padding: constraints.maxWidth > 550 ? EdgeInsets.symmetric(horizontal: constraints.maxWidth * 0.025) : const EdgeInsets.symmetric(horizontal: 10),
            children: [
              const SizedBox(height: 20,),
              const Text('General'),
              ...ListTile.divideTiles(
                  context: context,
                  tiles: alarmProvider.alarmData!.general.asMap().entries.map((entry) {
                    final generalAlarmIndex = entry.key;
                    final title = entry.value.notification;
                    final generalNotificationTypeId = entry.value.notificationTypeId;
                    final icon = entry.value.iconCodePoint;
                    final fontFamily = entry.value.iconFontFamily;
                    final value = entry.value.selected;
                    return Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: generalAlarmIndex == 0
                              ? const BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15))
                              : (generalAlarmIndex == alarmProvider.alarmData!.general.length - 1)
                              ? const BorderRadius.only(bottomRight: Radius.circular(15), bottomLeft: Radius.circular(15)) : BorderRadius.zero
                      ),
                      child: CustomSwitchTile(
                          title: title,
                          //icon: icon.length > 6 ? SvgPicture.asset('assets/images/ProgramAlarmIcons/$icon') : Icon(IconData(int.parse(icon), fontFamily: fontFamily), color: Colors.black,),
                          value: value,
                          onChanged: (newValue) {
                            alarmProvider.updateValueForGeneral(generalNotificationTypeId, newValue);
                          }
                      ),
                    );
                  })
              ),
              const SizedBox(height: 20,),
              const Text('EC/pH'),
              ...ListTile.divideTiles(
                  context: context,
                  tiles: alarmProvider.alarmData!.ecPh.asMap().entries.map((entry) {
                    final ecPhlAlarmIndex = entry.key;
                    final title = entry.value.notification;
                    final notificationTypeId = entry.value.notificationTypeId;
                    final icon = entry.value.iconCodePoint;
                    final fontFamily = entry.value.iconFontFamily;
                    final value = entry.value.selected;
                    return Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: ecPhlAlarmIndex == 0
                              ? const BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15))
                              : (ecPhlAlarmIndex == alarmProvider.alarmData!.ecPh.length - 1)
                              ? const BorderRadius.only(bottomRight: Radius.circular(15), bottomLeft: Radius.circular(15)) : BorderRadius.zero
                      ),
                      child: CustomSwitchTile(
                          title: title,
                          icon: icon.length > 6 ? Image.asset('assets/images/ProgramAlarmIcons/$icon') : Icon(IconData(int.parse(icon), fontFamily: fontFamily), color: Colors.black,),
                          value: value,
                          onChanged: (newValue) {
                            alarmProvider.updateValueForEcPh(notificationTypeId, newValue);
                          }
                      ),
                    );
                  })
              ),
              const SizedBox(height: 10,),
            ],
          );
        }
    );
  }
}
