
class Address {
  final String? line1;
  final String? line2;
  final String? city;
  final String? state;
  final String? pincode;

  Address({
    this.line1,
    this.line2,
    this.city,
    this.state,
    this.pincode,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      line1: json['line1'],
      line2: json['line2'],
      city: json['city'],
      state: json['state'],
      pincode: json['pincode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'line1': line1,
      'line2': line2,
      'city': city,
      'state': state,
      'pincode': pincode,
    };
  }

  String get fullAddress {
    List<String> parts = [];
    if (line1?.isNotEmpty == true) parts.add(line1!);
    if (line2?.isNotEmpty == true) parts.add(line2!);
    if (city?.isNotEmpty == true) parts.add(city!);
    if (state?.isNotEmpty == true) parts.add(state!);
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
      address: json['address'] != null ? Address.fromJson(json['address']) : null,
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
  final bool isValid;

  PanCard({
    this.name,
    this.dateOfBirth,
    this.panNumber,
    this.isValid = false 
  });

  factory PanCard.fromJson(Map<String, dynamic> json) {
    return PanCard(
      name: json['name'],
      dateOfBirth: json['dateOfBirth'],
      panNumber: json['panNumber'],
      isValid: json['isValid'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dateOfBirth': dateOfBirth,
      'panNumber': panNumber,
      'isValid' : isValid
    };
  }
}

// Driving License Model
class DrivingLicense {
  final String? name;
  final String? dateOfBirth;
  final String? licenseNumber;
  final Address? address;
  final String? bloodGroup;
  final String? validUpto;
  final List<String> vehicleClasses;
  final bool isValid;

  DrivingLicense({
    this.name,
    this.dateOfBirth,
    this.licenseNumber,
    this.address,
    this.bloodGroup,
    this.validUpto,
    this.vehicleClasses = const [],
    this.isValid = false 
  });

  factory DrivingLicense.fromJson(Map<String, dynamic> json) {
    return DrivingLicense(
      name: json['name'],
      dateOfBirth: json['dateOfBirth'],
      licenseNumber: json['licenseNumber'],
      address: json['address'] != null ? Address.fromJson(json['address']) : null,
      bloodGroup: json['bloodGroup'],
      validUpto: json['validUpto'],
      vehicleClasses: List<String>.from(json['vehicleClasses'] ?? []),
      isValid: json['isValid'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dateOfBirth': dateOfBirth,
      'licenseNumber': licenseNumber,
      'address': address?.toJson(),
      'bloodGroup': bloodGroup,
      'validUpto': validUpto,
      'vehicleClasses': vehicleClasses,
      'isValid' : isValid
    };
  }
}

// Main Document Response Model
class DocumentResponse {
  final AadhaarCard? aadhaar;
  final PanCard? pan;
  final DrivingLicense? drivingLicense;

  DocumentResponse({
    this.aadhaar,
    this.pan,
    this.drivingLicense,
  });

  factory DocumentResponse.fromJson(Map<String, dynamic> json) {
    return DocumentResponse(
      aadhaar: json['aadhaar'] != null ? AadhaarCard.fromJson(json['aadhaar']) : null,
      pan: json['pan'] != null ? PanCard.fromJson(json['pan']) : null,
      drivingLicense: json['drivingLicense'] != null ? DrivingLicense.fromJson(json['drivingLicense']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'aadhaar': aadhaar?.toJson(),
      'pan': pan?.toJson(),
      'drivingLicense': drivingLicense?.toJson(),
    };
  }

  // Sample data for testing
  static DocumentResponse getSampleData() {
    return DocumentResponse(
      aadhaar: AadhaarCard(
        name: "Rajesh Kumar Sharma",
        dateOfBirth: "15/08/1985",
        gender: "Male",
        address: Address(
          line1: "House No. 123, Sector 15",
          line2: "Near Central Park",
          city: "Gurgaon",
          state: "Haryana",
          pincode: "122001",
        ),
        aadhaarNumber: "1234 5678 9012",
        isValid: true,
      ),
      pan: PanCard(
        name: "RAJESH KUMAR SHARMA",
        dateOfBirth: "15/08/1985",
        panNumber: "ABCDE1234F",
        isValid: true,
      ),
      drivingLicense: DrivingLicense(
        name: "RAJESH KUMAR SHARMA",
        dateOfBirth: "15/08/1985",
        licenseNumber: "DL-0720123456789",
        address: Address(
          line1: "House No. 123, Sector 15",
          line2: "Near Central Park",
          city: "Gurgaon",
          state: "Haryana",
          pincode: "122001",
        ),
        bloodGroup: "B+",
        validUpto: "19/03/2038",
        vehicleClasses: ["LMV", "MCWG"],
        isValid: true,
      ),
    );
  }
}