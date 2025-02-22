class Admin {
  final String id;
  final String name;
  final String mobileNumber;
  final String pincode;
  final String residentialAddress;

  Admin({
    required this.id,
    required this.name,
    required this.mobileNumber,
    required this.pincode,
    required this.residentialAddress,
  });

  factory Admin.fromJson(Map<String, dynamic> json) {
    return Admin(
      id: json['_id']?.toString() ?? '',
      name: json['name'] ?? '',
      mobileNumber: json['mobileNumber'] ?? '',
      pincode: json['pincode'] ?? '',
      residentialAddress: json['residentialAddress'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'name': name,
        'mobileNumber': mobileNumber,
        'pincode': pincode,
        'residentialAddress': residentialAddress,
      };
}
