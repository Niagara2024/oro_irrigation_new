class SentAndReceivedModel
{
  SentAndReceivedModel({
    this.date = '',
    this.time = '',
    this.messageType = '',
    this.message = '',
    this.sentUser = '',
    this.sentMobileNumber = '',
  });

  String date, time, messageType, message, sentUser, sentMobileNumber;

  factory SentAndReceivedModel.fromJson(Map<String, dynamic> json) => SentAndReceivedModel(
    date: json['date'],
    time: json['time'],
    messageType: json['messageType'],
    message: json['message'],
    sentUser: json['sentUser'],
    sentMobileNumber: json['sentMobileNumber'],
  );

  Map<String, dynamic> toJson() => {
    'date': date,
    'time': time,
    'messageType': messageType,
    'message': message,
    'sentUser': sentUser,
    'sentMobileNumber': sentMobileNumber,
  };
}