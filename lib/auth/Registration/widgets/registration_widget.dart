import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import '../models/registration_model.dart';
import '../models/ocr_model.dart';

class VehicleSelectionGrid extends StatelessWidget {
  final String? selectedVehicle;
  final Function(String) onVehicleSelected;
  
  const VehicleSelectionGrid({
    super.key,
    required this.selectedVehicle,
    required this.onVehicleSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose Your Vehicle',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: VehicleOption.options.length,
          itemBuilder: (context, index) {
            final vehicle = VehicleOption.options[index];
            final isSelected = selectedVehicle == vehicle.name;
            
            return GestureDetector(
              onTap: () => onVehicleSelected(vehicle.name),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? AppConstants.primaryColor : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppConstants.primaryColor : Colors.grey.shade300,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      vehicle.icon,
                      color: isSelected ? Colors.white : AppConstants.primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        vehicle.name,
                        style: GoogleFonts.plusJakartaSans(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class DocumentUploadCard extends StatefulWidget {
  final DocumentType documentType;
  final File? uploadedFile;
  final VoidCallback onTap;

  const DocumentUploadCard({
    super.key,
    required this.documentType,
    required this.uploadedFile,
    required this.onTap,
  });

  @override
  State<DocumentUploadCard> createState() => _DocumentUploadCardState();
}

class _DocumentUploadCardState extends State<DocumentUploadCard> {
  late DocumentResponse sampleData;

  @override
  void initState() {
    super.initState();
    sampleData = DocumentResponse.getSampleData();
  }

  Map<String, String>? _getRelevantData() {
    switch (widget.documentType.id) {
      case 'aadhar_front':
        if (sampleData.aadhaar?.isValid == true) {
          return {
            'name': sampleData.aadhaar!.name ?? '',
            'dob': sampleData.aadhaar!.dateOfBirth ?? '',
            'number': sampleData.aadhaar!.aadhaarNumber ?? '',
            'gender': sampleData.aadhaar!.gender ?? '',
          };
        }
        break;
      case 'aadhar_back':
        if (sampleData.aadhaar?.isValid == true) {
          return {
            'address': sampleData.aadhaar!.address?.fullAddress ?? '',
          };
        }
        break;
      case 'pan_card':
        if (sampleData.pan?.isValid == true) {
          return {
            'name': sampleData.pan!.name ?? '',
            'dob': sampleData.pan!.dateOfBirth ?? '',
            'number': sampleData.pan!.panNumber ?? '',
          };
        }
        break;
      case 'driving_license':
        if (sampleData.drivingLicense?.isValid == true) {
          return {
            'name': sampleData.drivingLicense!.name ?? '',
            'dob': sampleData.drivingLicense!.dateOfBirth ?? '',
            'number': sampleData.drivingLicense!.licenseNumber ?? '',
            'address': sampleData.drivingLicense!.address?.fullAddress ?? '',
            'bloodGroup': sampleData.drivingLicense!.bloodGroup ?? '',
            'validUpto': sampleData.drivingLicense!.validUpto ?? '',
          };
        }
        break;
      case 'selfie':
        // For selfie, don't return any data to avoid showing extracted information section
        return null;
    }
    return null;
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
    required IconData icon,
  }) {
    if (value.isEmpty) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: AppConstants.primaryColor,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentFields() {
    final data = _getRelevantData();
    if (data == null) return const SizedBox.shrink();

    switch (widget.documentType.id) {
      case 'aadhar_front':
        return Column(
          children: [
            _buildInfoRow(
              label: 'Full Name',
              value: data['name'] ?? '',
              icon: Icons.person,
            ),
            _buildInfoRow(
              label: 'Date of Birth',
              value: data['dob'] ?? '',
              icon: Icons.calendar_today,
            ),
            _buildInfoRow(
              label: 'Aadhaar Number',
              value: data['number'] ?? '',
              icon: Icons.credit_card,
            ),
            _buildInfoRow(
              label: 'Gender',
              value: data['gender'] ?? '',
              icon: Icons.person_outline,
            ),
          ],
        );
      case 'aadhar_back':
        return Column(
          children: [
            _buildInfoRow(
              label: 'Address',
              value: data['address'] ?? '',
              icon: Icons.location_on,
            ),
          ],
        );
      case 'pan_card':
        return Column(
          children: [
            _buildInfoRow(
              label: 'Full Name',
              value: data['name'] ?? '',
              icon: Icons.person,
            ),
            _buildInfoRow(
              label: 'Date of Birth',
              value: data['dob'] ?? '',
              icon: Icons.calendar_today,
            ),
            _buildInfoRow(
              label: 'PAN Number',
              value: data['number'] ?? '',
              icon: Icons.credit_card,
            ),
          ],
        );
      case 'driving_license':
        return Column(
          children: [
            _buildInfoRow(
              label: 'Full Name',
              value: data['name'] ?? '',
              icon: Icons.person,
            ),
            _buildInfoRow(
              label: 'Date of Birth',
              value: data['dob'] ?? '',
              icon: Icons.calendar_today,
            ),
            _buildInfoRow(
              label: 'License Number',
              value: data['number'] ?? '',
              icon: Icons.credit_card,
            ),
            _buildInfoRow(
              label: 'Blood Group',
              value: data['bloodGroup'] ?? '',
              icon: Icons.bloodtype,
            ),
            _buildInfoRow(
              label: 'Valid Until',
              value: data['validUpto'] ?? '',
              icon: Icons.event_available,
            ),
            _buildInfoRow(
              label: 'Address',
              value: data['address'] ?? '',
              icon: Icons.location_on,
            ),
          ],
        );
      case 'selfie':
        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: Row(
            children: [
              Icon(
                Icons.check_circle,
                size: 16,
                color: Colors.green.shade600,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Selfie uploaded successfully',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUploaded = widget.uploadedFile != null;
    final isValidData = _getRelevantData() != null;
    final isSelfie = widget.documentType.id == 'selfie';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isUploaded
                  ? (isSelfie ? Colors.green.shade400 : (isValidData ? Colors.green.shade400 : Colors.red.shade400))
                  : Colors.grey.shade300,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade100,
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              InkWell(
                onTap: widget.onTap,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isUploaded
                              ? (isSelfie ? Colors.green.shade100 : (isValidData ? Colors.green.shade100 : Colors.red.shade100))
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          isUploaded
                              ? (isSelfie 
                                  ? Icons.done_all_outlined 
                                  : (isValidData ? widget.documentType.icon : Icons.error))
                              : widget.documentType.icon,
                          color: isUploaded
                              ? (isSelfie 
                                  ? Colors.green.shade600 
                                  : (isValidData ? Colors.green.shade600 : Colors.red.shade600))
                              : Colors.grey.shade500,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isUploaded
                                  ? (isSelfie
                                      ? 'Selfie Uploaded'
                                      : (isValidData
                                          ? '${widget.documentType.title} Verified'
                                          : 'Document Invalid'))
                                  : 'Upload ${widget.documentType.title}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isUploaded
                                    ? (isSelfie 
                                        ? Colors.green.shade800 
                                        : (isValidData ? Colors.green.shade800 : Colors.red.shade800))
                                    : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              isUploaded
                                  ? (isSelfie
                                      ? 'Selfie captured successfully'
                                      : (isValidData
                                          ? 'Information extracted successfully'
                                          : 'Please upload a valid document'))
                                  : 'Tap to upload your document',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Document Information Section (exclude selfie)
              if (isUploaded && isValidData && !isSelfie) ...[
                Container(
                  width: double.infinity,
                  height: 1,
                  color: Colors.grey.shade200,
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 14,
                            color: AppConstants.primaryColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Extracted Information',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppConstants.primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildDocumentFields(),
                    ],
                  ),
                ),
              ] else if (isUploaded && !isValidData && !isSelfie) ...[
                Container(
                  width: double.infinity,
                  height: 1,
                  color: Colors.grey.shade200,
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.red.shade600,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Document Verification Failed',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red.shade800,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'We couldn\'t verify this document. Please ensure the document is clear and upload a valid ${widget.documentType.title.toLowerCase()}.',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  color: Colors.red.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class GenderSelectionWidget extends StatelessWidget {
  final String? selectedGender;
  final Function(String) onGenderSelected;
  
  const GenderSelectionWidget({
    super.key,
    required this.selectedGender,
    required this.onGenderSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: AppConstants.genderOptions.map((gender) {
              final isSelected = selectedGender == gender;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onGenderSelected(gender),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected ? AppConstants.primaryColor : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        gender,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isSelected ? Colors.white : Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  
  const SectionHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppConstants.primaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final int maxLines;
  final bool enabled;
  final String? Function(String?)? validator;
  
  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.maxLines = 1,
    this.enabled = true,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      enabled: enabled,
      validator: validator,
      style: GoogleFonts.plusJakartaSans(fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppConstants.primaryColor, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppConstants.primaryColor, width: 2),
        ),
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}