class Payment {
  String PaymentId;
  String UserId;
  String BillId;
  String PayId;
  String Method;
  double HoursParking;
  int Price;
  String CreatedAt;

  Payment({
    required this.PaymentId,
    required this.UserId,
    required this.BillId,
    required this.PayId,
    required this.Method,
    required this.HoursParking,
    required this.Price,
    required this.CreatedAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      PaymentId: json['PaymentId'],
      UserId: json['UserId'],
      BillId: json['BillId'],
      PayId: json['PayId'],
      Method: json['Method'],
      HoursParking: json['HoursParking'],
      Price: json['Price'],
      CreatedAt: json['CreatedAt'],
    );
  }

  Map<String, dynamic> toJson() => {
    'PaymentId': PaymentId,
    'UserId': UserId,
    'BillId': BillId,
    'PayId': PayId,
    'Method': Method,
    'HoursParking': HoursParking,
    'Price': Price,
    'CreatedAt': CreatedAt,
  };
}
