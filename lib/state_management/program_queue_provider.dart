import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';

import '../Models/Customer/program_queue_model.dart';


class ProgramQueueProvider extends ChangeNotifier{
  ProgramQueueModel? _programQueueResponse;
  ProgramQueueModel? get programQueueResponse => _programQueueResponse;

  updateData(convertedJson) {
    _programQueueResponse = ProgramQueueModel.fromJson(convertedJson);
    notifyListeners();
  }




// void updateValues(newValue, index, type) {
//   switch()
//   _programQueueResponse!.data[index].startTime = newValue;
// }
}