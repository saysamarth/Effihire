import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/registration_model.dart';

class ReviewStepWidget extends StatefulWidget {
  final RegistrationData registrationData;
  final ValueChanged<bool> onConfirmationChanged;

  const ReviewStepWidget({
    super.key,
    required this.registrationData,
    required this.onConfirmationChanged,
  });

  @override
  State<ReviewStepWidget> createState() => _ReviewStepWidgetState();
}

class _ReviewStepWidgetState extends State<ReviewStepWidget> {
  bool _isDetailsConfirmed = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPersonalInfoSection(),
          const SizedBox(height: 20),
          _buildVehicleSection(),
          const SizedBox(height: 20),
          _buildDocumentsSection(),
          const SizedBox(height: 16),
          _buildConfirmationSection(),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return _buildSection(
      title: 'Personal Information',
      icon: Icons.person_outline,
      children: [
        _buildInfoCard([
          _buildInfoRow('Full Name', widget.registrationData.fullName),
          _buildInfoRow('Gender', widget.registrationData.gender ?? 'Not provided'),
        ]),
        const SizedBox(height: 8),
        _buildInfoCard([
          _buildInfoRow('Current Address', widget.registrationData.currentAddress),
          _buildInfoRow(
            'Permanent Address',
            widget.registrationData.sameAsCurrentAddress
                ? 'Same as current address'
                : widget.registrationData.permanentAddress,
          ),
        ]),
        const SizedBox(height: 8),
        _buildInfoCard([
          _buildInfoRow('Qualification', widget.registrationData.qualification),
          _buildInfoRow('Languages', widget.registrationData.languages),
        ]),
      ],
    );
  }

  Widget _buildVehicleSection() {
    return _buildSection(
      title: 'Vehicle Selection',
      icon: Icons.directions_car_outlined,
      children: [
        _buildInfoCard([
          _buildInfoRow('Selected Vehicle', widget.registrationData.selectedVehicle ?? 'Not selected'),
        ]),
      ],
    );
  }

  Widget _buildDocumentsSection() {
    return _buildSection(
      title: 'Documents',
      icon: Icons.description_outlined,
      children: [
        _buildDocumentsGrid(),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: AppConstants.primaryColor,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppConstants.primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...children,
      ],
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
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
        children: children,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsGrid() {
    final documents = [
      {'label': 'Aadhar Front', 'key': 'aadhar_front'},
      {'label': 'Aadhar Back', 'key': 'aadhar_back'},
      {'label': 'PAN Card', 'key': 'pan_card'},
      {'label': 'Driving License', 'key': 'driving_license'},
      {'label': 'Selfie', 'key': 'selfie'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.2,
      ),
      itemCount: documents.length,
      itemBuilder: (context, index) {
        final doc = documents[index];
        final file = widget.registrationData.getDocument(doc['key']!);
        return _buildDocumentTile(doc['label']!, file);
      },
    );
  }

  Widget _buildDocumentTile(String label, File? file) {
    return GestureDetector(
      onTap: file != null ? () => _showImagePreview(file, label) : null,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: file != null ? AppConstants.primaryColor.withOpacity(0.3) : Colors.grey.shade300,
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
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: file != null ? Colors.grey.shade50 : Colors.grey.shade100,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                child: file != null
                    ? Stack(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                            ),
                            child: Image.file(
                              file,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 6,
                            right: 6,
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: const Icon(
                                Icons.zoom_in,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      )
                    : const Center(
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          size: 28,
                          color: Colors.grey,
                        ),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 1),
                  Text(
                    file != null ? 'Tap to view' : 'Not uploaded',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      color: file != null ? AppConstants.primaryColor : Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmationSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: _isDetailsConfirmed,
          onChanged: (value) {
            setState(() {
              _isDetailsConfirmed = value ?? false;
              widget.onConfirmationChanged(_isDetailsConfirmed);
            });
          },
          activeColor: AppConstants.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 3.0),
            child: Text(
              'I confirm that all the information provided above is accurate and complete. These details cannot be modified once submitted.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: Colors.grey.shade700,
                height: 1.3,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showImagePreview(File imageFile, String title) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final cardWidth = screenWidth * 0.9;
        final cardHeight = (cardWidth * 4) / 3; // 4:3 aspect ratio
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: Container(
            width: cardWidth,
            height: cardHeight + 60, 
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppConstants.primaryColor.withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppConstants.primaryColor,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                        color: AppConstants.primaryColor,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                    child: InteractiveViewer(
                      panEnabled: true,
                      boundaryMargin: EdgeInsets.zero,
                      minScale: 0.5,
                      maxScale: 3.0,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                        child: Image.file(
                          imageFile,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}