import 'package:flutter/material.dart';

class CustomerDataProvider with ChangeNotifier {

  //no of site to customer............
  List<Site> _sites = [];
  List<Site> get site => _sites;

  void addSite(Site site) {
    _sites.add(site);
    notifyListeners();
  }

  void setSite(List<Site> site) {
    _sites = site;
    notifyListeners();
  }

  void clearSite() {
    _sites = [];
    notifyListeners();
  }

  //no of controller to site...........
  List<Controller> _controllers = [];
  List<Controller> get controllers => _controllers;

  void addController(Controller controller) {
    _controllers.add(controller);
    notifyListeners();
  }

  void setControllers(List<Controller> controllers) {
    _controllers = controllers;
    notifyListeners();
  }

}

class Site {
  final String id;
  final String name;
  Site({required this.id, required this.name});
}

class Controller {
  final String id;
  final String name;
  Controller({required this.id, required this.name});
}