class Secretary {
  final String id;
  final String name;
  final String mobileNumber;
  final String city;
  final String pincode;
  final String residentialAddress;
  // Optionally, include areaInControl if needed:
  final Map<String, String>? areaInControl;

  Secretary({
    required this.id,
    required this.name,
    required this.mobileNumber,
    required this.city,
    required this.pincode,
    required this.residentialAddress,
    this.areaInControl,
  });

  factory Secretary.fromJson(Map<String, dynamic> json) {
    return Secretary(
      id: json['_id']?.toString() ?? '',
      name: json['name'] ?? '',
      mobileNumber: json['mobileNumber'] ?? '',
      city: json['city'] ?? '',
      pincode: json['pincode'] ?? '',
      residentialAddress: json['residentialAddress'] ?? '',
      areaInControl: json['areaInControl'] != null
          ? {
              'pinCode': json['areaInControl']['pinCode'] ?? '',
              'areaName': json['areaInControl']['areaName'] ?? '',
            }
          : null,
    );
  }
}
