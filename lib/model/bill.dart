class Bill {
  String BillId;
  String FeeId;
  String LicensePlate;
  String TypeCar;
  String Location;
  String AddressParking;
  bool IsPayment;
  String ImageName;
  String QrCode;
  int Price;
  double HoursParking;
  String CreatedAt;
  String? UpdatedAt;

  Bill({
    required this.BillId,
    required this.FeeId,
    required this.LicensePlate,
    required this.TypeCar,
    required this.Location,
    required this.AddressParking,
    required this.IsPayment,
    required this.ImageName,
    required this.QrCode,
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
      TypeCar: json['TypeCar'],
      Location: json['Location'],
      AddressParking: json['AddressParking'],
      IsPayment: json['IsPayment'],
      ImageName: json['ImageName'],
      QrCode: json['QrCode'],
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
    'TypeCar': TypeCar,
    'Location': Location,
    'AddressParking': AddressParking,
    'IsPayment': IsPayment,
    'ImageName': ImageName,
    'QrCode': QrCode,
    'Price': Price,
    'HoursParking': HoursParking,
    'CreatedAt': CreatedAt,
    'UpdatedAt': UpdatedAt,
  };
}
