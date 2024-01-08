class SentAndReceivedModel
{
  SentAndReceivedModel({
    this.date = '',
    this.time = '',
    this.messageType = '',
    this.message = '',
  });

  String date, time, messageType, message;

  factory SentAndReceivedModel.fromJson(Map<String, dynamic> json) => SentAndReceivedModel(
    date: json['date'],
    time: json['time'],
    messageType: json['messageType'],
    message: json['message'],
  );

  Map<String, dynamic> toJson() => {
    'date': date,
    'time': time,
    'messageType': messageType,
    'message': message,
  };
}