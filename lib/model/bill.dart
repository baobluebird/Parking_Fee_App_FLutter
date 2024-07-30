class Bill {
  String BillId;
  String FeeId;
  String LicensePlate;
  String Location;
  String AddressParking;
  bool IsPayment;
  String ImageName;
  int Price;
  double HoursParking;
  String CreatedAt;
  String? UpdatedAt;

  Bill({
    required this.BillId,
    required this.FeeId,
    required this.LicensePlate,
    required this.Location,
    required this.AddressParking,
    required this.IsPayment,
    required this.ImageName,
    required this.Price,
    required this.HoursParking,
    required this.CreatedAt,
    this.UpdatedAt,
  });

  factory Bill.fromJson(Map<String, dynamic> json) {
    return Bill(
      BillId: json['BillId'],
      FeeId: json['FeeId'],
      LicensePlate: json['LicensePlate'],
      Location: json['Location'],
      AddressParking: json['AddressParking'],
      IsPayment: json['IsPayment'],
      ImageName: json['ImageName'],
      Price: json['Price'],
      HoursParking: json['HoursParking'],
      CreatedAt: json['CreatedAt'],
      UpdatedAt: json['UpdatedAt'],
    );
  }

  Map<String, dynamic> toJson() => {
    'BillId': BillId,
    'FeeId': FeeId,
    'LicensePlate': LicensePlate,
    'Location': Location,
    'AddressParking': AddressParking,
    'IsPayment': IsPayment,
    'ImageName': ImageName,
    'Price': Price,
    'HoursParking': HoursParking,
    'CreatedAt': CreatedAt,
    'UpdatedAt': UpdatedAt,
  };
}
