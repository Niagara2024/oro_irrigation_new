class CentralFilterSite {
  int sNo;
  String id;
  String name;
  String location;
  bool selected;

  CentralFilterSite({required this.sNo, required this.id, required this.name, required this.location, required this.selected});

  factory CentralFilterSite.fromJson(Map<String, dynamic> json) {
    return CentralFilterSite(
      sNo: json['sNo'],
      id: json['id'],
      name: json['name'],
      location: json['location'],
      selected: json['selected'],
    );
  }
}