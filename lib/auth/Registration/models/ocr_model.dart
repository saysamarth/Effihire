class Address {
  final String? line1;
  final String? pincode;

  Address({this.line1, this.pincode});

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(line1: json['line1'], pincode: json['pincode']);
  }

  Map<String, dynamic> toJson() {
    return {'line1': line1, 'pincode': pincode};
  }

  String get fullAddress {
    List<String> parts = [];
    if (line1?.isNotEmpty == true) parts.add(line1!);
    if (pincode?.isNotEmpty == true) parts.add(pincode!);
    return parts.join(', ');
  }
}

// Aadhaar Card Model
class AadhaarCard {
  final String? name;
  final String? dateOfBirth;
  final String? gender;
  final Address? address;
  final String? aadhaarNumber;
  final bool isValid;

  AadhaarCard({
    this.name,
    this.dateOfBirth,
    this.gender,
    this.address,
    this.aadhaarNumber,
    this.isValid = false,
  });

  factory AadhaarCard.fromJson(Map<String, dynamic> json) {
    return AadhaarCard(
      name: json['name'],
      dateOfBirth: json['dateOfBirth'],
      gender: json['gender'],
      address: json['address'] != null
          ? Address.fromJson(json['address'])
          : null,
      aadhaarNumber: json['aadhaarNumber'],
      isValid: json['isValid'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'address': address?.toJson(),
      'aadhaarNumber': aadhaarNumber,
      'isValid': isValid,
    };
  }
}

// PAN Card Model
class PanCard {
  final String? name;
  final String? dateOfBirth;
  final String? panNumber;
  final String? fatherName;

  PanCard({this.name, this.dateOfBirth, this.panNumber, this.fatherName});

  factory PanCard.fromJson(Map<String, dynamic> json) {
    return PanCard(
      name: json['name'],
      dateOfBirth: json['dateOfBirth'],
      panNumber: json['panNumber'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dateOfBirth': dateOfBirth,
      'panNumber': panNumber,
      'fatherName': fatherName,
    };
  }
}

// Main Document Response Model
class DocumentResponse {
  final AadhaarCard? aadhaar;
  final PanCard? pan;

  DocumentResponse({this.aadhaar, this.pan});

  factory DocumentResponse.fromJson(Map<String, dynamic> json) {
    return DocumentResponse(
      aadhaar: json['aadhaar'] != null
          ? AadhaarCard.fromJson(json['aadhaar'])
          : null,
      pan: json['pan'] != null ? PanCard.fromJson(json['pan']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'aadhaar': aadhaar?.toJson(), 'pan': pan?.toJson()};
  }
}
