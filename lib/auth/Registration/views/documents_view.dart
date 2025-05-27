// views/documents_view.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/registration_model.dart';
import '../widgets/registration_widget.dart';
import '../../../config/media/image_picker_service.dart';

class DocumentsView extends StatelessWidget {
  final DocumentInfo documentInfo;
  final Function(DocumentInfo) onDocumentInfoChanged;

  const DocumentsView({
    super.key,
    required this.documentInfo,
    required this.onDocumentInfoChanged,
  });

  void _onVehicleSelected(String vehicle) {
    onDocumentInfoChanged(
      documentInfo.copyWith(selectedVehicle: vehicle),
    );
  }

  Future<void> _pickImage(BuildContext context, String documentType) async {
    final imagePickerService = ImagePickerService();
    File? image;
    
    if (documentType == 'selfie') {
      // For selfie, only camera option
      image = await imagePickerService.pickImage(
        context: context,
        sourceType: ImageSourceType.camera,
      );
    } else {
      // For other documents, give choice between camera and gallery
      image = await imagePickerService.pickImage(
        context: context,
        sourceType: ImageSourceType.both,
      );
    }
    
    if (image != null) {
      DocumentInfo updatedInfo;
      switch (documentType) {
        case 'aadhar_front':
          updatedInfo = documentInfo.copyWith(aadharFrontImage: image);
          break;
        case 'aadhar_back':
          updatedInfo = documentInfo.copyWith(aadharBackImage: image);
          break;
        case 'pan_card':
          updatedInfo = documentInfo.copyWith(panCardImage: image);
          break;
        case 'driving_license':
          updatedInfo = documentInfo.copyWith(drivingLicenseImage: image);
          break;
        case 'selfie':
          updatedInfo = documentInfo.copyWith(selfieImage: image);
          break;
        default:
          return;
      }
      onDocumentInfoChanged(updatedInfo);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Documents & Vehicle',
            subtitle: 'Upload required documents and select vehicle',
          ),
          const SizedBox(height: 24),
          
          VehicleSelection(
            selectedVehicle: documentInfo.selectedVehicle,
            onVehicleSelected: _onVehicleSelected,
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
          const SizedBox(height: 16),
          
          DocumentUploadCard(
            title: 'Aadhar Card (Front)',
            type: 'aadhar_front',
            uploadedFile: documentInfo.aadharFrontImage,
            icon: Icons.credit_card,
            onTap: () => _pickImage(context, 'aadhar_front'),
          ),
          
          DocumentUploadCard(
            title: 'Aadhar Card (Back)',
            type: 'aadhar_back',
            uploadedFile: documentInfo.aadharBackImage,
            icon: Icons.credit_card,
            onTap: () => _pickImage(context, 'aadhar_back'),
          ),
          
          DocumentUploadCard(
            title: 'PAN Card',
            type: 'pan_card',
            uploadedFile: documentInfo.panCardImage,
            icon: Icons.badge,
            onTap: () => _pickImage(context, 'pan_card'),
          ),
          
          DocumentUploadCard(
            title: 'Driving License',
            type: 'driving_license',
            uploadedFile: documentInfo.drivingLicenseImage,
            icon: Icons.drive_eta,
            onTap: () => _pickImage(context, 'driving_license'),
          ),
          
          DocumentUploadCard(
            title: 'Selfie Photo',
            type: 'selfie',
            uploadedFile: documentInfo.selfieImage,
            icon: Icons.camera_alt,
            onTap: () => _pickImage(context, 'selfie'),
            isSelfie: true,
          ),
        ],
      ),
    );
  }
}