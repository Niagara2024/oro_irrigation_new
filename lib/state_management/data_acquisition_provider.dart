import 'dart:convert';
import 'package:flutter/cupertino.dart';

import '../Models/DataAcquisitionModel/data_acquisition_model.dart';
import '../constants/http_service.dart';


/// A provider class for handling data acquisition and related functionality.
class DataAcquisitionProvider extends ChangeNotifier {
  final HttpService httpService = HttpService();
  DataModel? _dataModel;
  bool _isLoading = false;

  DataModel? get dataModel => _dataModel;
  bool get isLoading => _isLoading;

  Future<void> dataAcquisitionFromApi(int customerId, int controllerId) async {
    try {
      _isLoading = true;
      final userData = {
        "userId": customerId,
        "controllerId": controllerId,
      };

      final getDataAcquisition = await httpService.postRequest('getUserDataAcquisition', userData);

      if (getDataAcquisition.statusCode == 200) {
        final responseJson = getDataAcquisition.body;
        print(responseJson);
        final convertedJson = jsonDecode(responseJson);
        _dataModel = DataModel.fromJson(convertedJson);

        _isLoading = false;
        notifyListeners();
      } else {
        print("HTTP Request failed or received an unexpected response.");
        _isLoading = false;
        notifyListeners();
      }
    } catch (error) {
      _isLoading = false;
      notifyListeners();
      print("Error: $error");
    }
  }

  int _selectedTabIndex = 0;
  int get selectedTabIndex => _selectedTabIndex;

  void updateTabIndex(int newIndex) {
    _selectedTabIndex = newIndex;
    notifyListeners();
  }

  static const List<String> durationList = ['None', '1 min', '5 mins', '10 mins', '30 mins', '1 hour', 'Daily'];

  void updateSelectedValue(int index, int rowIndex, String newValue) {
    _dataModel?.data[index].dataAcquisition[rowIndex].sampleRate = newValue;
    notifyListeners();
  }
}
