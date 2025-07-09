import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/ocr_model.dart';
import '../models/registration_model.dart';
import 'common.dart';

class DocumentsStepWidget extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final String? selectedVehicle;
  final RegistrationData registrationData;
  final Function(String) onVehicleSelected;
  final Function(String) onDocumentScan;
  final Map<String, bool> documentLoadingStates;
  final Map<String, DocumentResponse> documentResponses;

  const DocumentsStepWidget({
    super.key,
    required this.formKey,
    required this.selectedVehicle,
    required this.registrationData,
    required this.onVehicleSelected,
    required this.onDocumentScan,
    required this.documentLoadingStates,
    required this.documentResponses,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(
              title: 'Documents & Vehicle',
              subtitle: 'Scan required documents and select vehicle',
            ),
            const SizedBox(height: 24),

            VehicleSelectionGrid(
              selectedVehicle: selectedVehicle,
              onVehicleSelected: onVehicleSelected,
            ),
            const SizedBox(height: 32),

            Text(
              'Required Documents',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),

            _buildDocumentInfoCard(),
            const SizedBox(height: 16),

            ...DocumentType.requiredDocuments.map(
              (documentType) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: DocumentUploadCard(
                  documentType: documentType,
                  uploadedFile: registrationData.getDocument(documentType.id),
                  isLoading: documentLoadingStates[documentType.id] ?? false,
                  documentResponse: documentResponses[documentType.id],
                  onTap: () => onDocumentScan(documentType.id),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentInfoCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue.shade600, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Documents will be scanned automatically with proper alignment and cropping',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: Colors.blue.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
                    color: isSelected
                        ? AppConstants.primaryColor
                        : Colors.grey.shade300,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      vehicle.icon,
                      color: isSelected
                          ? Colors.white
                          : AppConstants.primaryColor,
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
  final bool isLoading;
  final DocumentResponse? documentResponse;
  final VoidCallback onTap;

  const DocumentUploadCard({
    super.key,
    required this.documentType,
    required this.uploadedFile,
    this.isLoading = false,
    this.documentResponse,
    required this.onTap,
  });

  @override
  State<DocumentUploadCard> createState() => _DocumentUploadCardState();
}

class _DocumentUploadCardState extends State<DocumentUploadCard> {
  Map<String, String>? _getRelevantData() {
    if (widget.documentResponse == null) return null;
    switch (widget.documentType.id) {
      case 'aadhar_front':
        if (widget.documentResponse?.aadhaar != null &&
            widget.documentResponse?.aadhaar?.isValid == true) {
          return {
            'name': widget.documentResponse!.aadhaar!.name ?? '',
            'dob': widget.documentResponse!.aadhaar!.dateOfBirth ?? '',
            'number': widget.documentResponse!.aadhaar!.aadhaarNumber ?? '',
            'gender': widget.documentResponse!.aadhaar!.gender ?? '',
          };
        }
        break;
      case 'aadhar_back':
        if (widget.documentResponse?.aadhaar != null &&
            widget.documentResponse?.aadhaar?.isValid == true) {
          return {
            'address':
                widget.documentResponse!.aadhaar!.address?.fullAddress ?? '',
          };
        }
        break;
      case 'pan_card':
        if (widget.documentResponse?.pan != null) {
          return {
            'name': widget.documentResponse!.pan!.name ?? '',
            'dob': widget.documentResponse!.pan!.dateOfBirth ?? '',
            'number': widget.documentResponse!.pan!.panNumber ?? '',
          };
        }
        break;
      case 'driving_license':
        return {'verification': 'Driving License is valid'};
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
          Icon(icon, color: AppConstants.primaryColor, size: 16),
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
              label: 'Verification',
              value: data['verification'] ?? 'Driving License is valid',
              icon: Icons.verified,
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
              Icon(Icons.check_circle, size: 16, color: Colors.green.shade600),
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
                  ? (isSelfie
                        ? Colors.green.shade400
                        : (isValidData
                              ? Colors.green.shade400
                              : Colors.red.shade400))
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
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(10),
                ),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isUploaded
                              ? (isSelfie
                                    ? Colors.green.shade100
                                    : (isValidData
                                          ? Colors.green.shade100
                                          : Colors.red.shade100))
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: widget.isLoading
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.grey.shade600,
                                  ),
                                ),
                              )
                            : Icon(
                                isUploaded
                                    ? (isSelfie
                                          ? Icons.done_all_outlined
                                          : (isValidData
                                                ? widget.documentType.icon
                                                : Icons.error))
                                    : widget.documentType.icon,
                                color: isUploaded
                                    ? (isSelfie
                                          ? Colors.green.shade600
                                          : (isValidData
                                                ? Colors.green.shade600
                                                : Colors.red.shade600))
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
                                          : (isValidData
                                                ? Colors.green.shade800
                                                : Colors.red.shade800))
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
