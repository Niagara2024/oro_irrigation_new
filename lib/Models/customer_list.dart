class CustomerListMDL
{
  CustomerListMDL({
    this.userId = 0,
    this.userName = '',
    this.countryCode = '',
    this.mobileNumber = '',
  });

  int userId;
  String userName, countryCode, mobileNumber;

  factory CustomerListMDL.fromJson(Map<String, dynamic> json) => CustomerListMDL(
    userId: json['userId'],
    userName: json['userName'],
    countryCode: json['countryCode'],
    mobileNumber: json['mobileNumber'],
  );

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'userName': userName,
    'countryCode': countryCode,
    'mobileNumber': mobileNumber,
  };
}