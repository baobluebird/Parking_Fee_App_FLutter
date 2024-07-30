class Fee {
  String FeeId;
  String UserId;
  String LicensePlate;
  String TypeCar;
  String CreatedAt;
  String? UpdatedAt;

  Fee({
    required this.FeeId,
    required this.UserId,
    required this.LicensePlate,
    required this.TypeCar,
    required this.CreatedAt,
    this.UpdatedAt,
  });

  factory Fee.fromJson(Map<String, dynamic> json) {
    return Fee(
      FeeId: json['FeeId'],
      UserId: json['UserId'],
      LicensePlate: json['LicensePlate'],
      TypeCar: json['TypeCar'],
      CreatedAt: json['CreatedAt'],
      UpdatedAt: json['UpdatedAt'],
    );
  }

  Map<String, dynamic> toJson() => {
    'FeeId': FeeId,
    'UserId': UserId,
    'LicensePlate': LicensePlate,
    'TypeCar': TypeCar,
    'CreatedAt': CreatedAt,
    'UpdatedAt': UpdatedAt,
  };
}
