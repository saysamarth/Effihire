// class DocumentUploadCard extends StatefulWidget {
//   final DocumentType documentType;
//   final File? uploadedFile;
//   final VoidCallback onTap;

//   const DocumentUploadCard({
//     super.key,
//     required this.documentType,
//     required this.uploadedFile,
//     required this.onTap,
//   });

//   @override
//   State<DocumentUploadCard> createState() => _DocumentUploadCardState();
// }

// class _DocumentUploadCardState extends State<DocumentUploadCard> {
//   late DocumentResponse sampleData;
//   late TextEditingController nameController;
//   late TextEditingController dobController;
//   late TextEditingController numberController;
//   late TextEditingController addressController;
//   late TextEditingController genderController;
//   late TextEditingController bloodGroupController;
//   late TextEditingController validUptoController;
//   bool isEditing = false;

//   @override
//   void initState() {
//     super.initState();
//     sampleData = DocumentResponse.getSampleData();
//     _initializeControllers();
//   }

//   void _initializeControllers() {
//     final data = _getRelevantData();
//     nameController = TextEditingController(text: data?['name'] ?? '');
//     dobController = TextEditingController(text: data?['dob'] ?? '');
//     numberController = TextEditingController(text: data?['number'] ?? '');
//     addressController = TextEditingController(text: data?['address'] ?? '');
//     genderController = TextEditingController(text: data?['gender'] ?? '');
//     bloodGroupController = TextEditingController(text: data?['bloodGroup'] ?? '');
//     validUptoController = TextEditingController(text: data?['validUpto'] ?? '');
//   }

//   @override
//   void dispose() {
//     nameController.dispose();
//     dobController.dispose();
//     numberController.dispose();
//     addressController.dispose();
//     genderController.dispose();
//     bloodGroupController.dispose();
//     validUptoController.dispose();
//     super.dispose();
//   }

//   Map<String, String>? _getRelevantData() {
//     switch (widget.documentType.id) {
//       case 'aadhar_front':
//       case 'aadhar_back':
//         if (sampleData.aadhaar?.isValid == true) {
//           return {
//             'name': sampleData.aadhaar!.name ?? '',
//             'dob': sampleData.aadhaar!.dateOfBirth ?? '',
//             'number': sampleData.aadhaar!.aadhaarNumber ?? '',
//             'address': sampleData.aadhaar!.address?.fullAddress ?? '',
//             'gender': sampleData.aadhaar!.gender ?? '',
//           };
//         }
//         break;
//       case 'pan_card':
//         if (sampleData.pan?.isValid == true) {
//           return {
//             'name': sampleData.pan!.name ?? '',
//             'dob': sampleData.pan!.dateOfBirth ?? '',
//             'number': sampleData.pan!.panNumber ?? '',
//           };
//         }
//         break;
//       case 'driving_license':
//         if (sampleData.drivingLicense?.isValid == true) {
//           return {
//             'name': sampleData.drivingLicense!.name ?? '',
//             'dob': sampleData.drivingLicense!.dateOfBirth ?? '',
//             'number': sampleData.drivingLicense!.licenseNumber ?? '',
//             'address': sampleData.drivingLicense!.address?.fullAddress ?? '',
//             'bloodGroup': sampleData.drivingLicense!.bloodGroup ?? '',
//             'validUpto': sampleData.drivingLicense!.validUpto ?? '',
//           };
//         }
//         break;
//     }
//     return null;
//   }

//   Widget _buildInfoField({
//     required String label,
//     required TextEditingController controller,
//     required IconData icon,
//     int maxLines = 1,
//   }) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       child: TextFormField(
//         controller: controller,
//         maxLines: maxLines,
//         enabled: isEditing,
//         style: GoogleFonts.plusJakartaSans(
//           fontSize: 14,
//           color: isEditing ? Colors.black87 : Colors.grey.shade700,
//         ),
//         decoration: InputDecoration(
//           labelText: label,
//           prefixIcon: Icon(
//             icon,
//             color: AppConstants.primaryColor,
//             size: 18,
//           ),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(8),
//             borderSide: BorderSide(
//               color: isEditing ? Colors.grey.shade400 : Colors.grey.shade200,
//             ),
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(8),
//             borderSide: BorderSide(color: Colors.grey.shade300),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(8),
//             borderSide: const BorderSide(color: AppConstants.primaryColor, width: 1.5),
//           ),
//           disabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(8),
//             borderSide: BorderSide(color: Colors.grey.shade200),
//           ),
//           filled: true,
//           fillColor: isEditing ? Colors.white : Colors.grey.shade50,
//           contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//           labelStyle: GoogleFonts.plusJakartaSans(
//             fontSize: 12,
//             color: Colors.grey.shade600,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildDocumentFields() {
//     switch (widget.documentType.id) {
//       case 'aadhar_front':
//       case 'aadhar_back':
//         return Column(
//           children: [
//             _buildInfoField(
//               label: 'Full Name',
//               controller: nameController,
//               icon: Icons.person,
//             ),
//             _buildInfoField(
//               label: 'Date of Birth',
//               controller: dobController,
//               icon: Icons.calendar_today,
//             ),
//             _buildInfoField(
//               label: 'Aadhaar Number',
//               controller: numberController,
//               icon: Icons.credit_card,
//             ),
//             _buildInfoField(
//               label: 'Gender',
//               controller: genderController,
//               icon: Icons.person_outline,
//             ),
//             _buildInfoField(
//               label: 'Address',
//               controller: addressController,
//               icon: Icons.location_on,
//               maxLines: 2,
//             ),
//           ],
//         );
//       case 'pan_card':
//         return Column(
//           children: [
//             _buildInfoField(
//               label: 'Full Name',
//               controller: nameController,
//               icon: Icons.person,
//             ),
//             _buildInfoField(
//               label: 'Date of Birth',
//               controller: dobController,
//               icon: Icons.calendar_today,
//             ),
//             _buildInfoField(
//               label: 'PAN Number',
//               controller: numberController,
//               icon: Icons.credit_card,
//             ),
//           ],
//         );
//       case 'driving_license':
//         return Column(
//           children: [
//             _buildInfoField(
//               label: 'Full Name',
//               controller: nameController,
//               icon: Icons.person,
//             ),
//             _buildInfoField(
//               label: 'Date of Birth',
//               controller: dobController,
//               icon: Icons.calendar_today,
//             ),
//             _buildInfoField(
//               label: 'License Number',
//               controller: numberController,
//               icon: Icons.credit_card,
//             ),
//             _buildInfoField(
//               label: 'Blood Group',
//               controller: bloodGroupController,
//               icon: Icons.bloodtype,
//             ),
//             _buildInfoField(
//               label: 'Valid Until',
//               controller: validUptoController,
//               icon: Icons.event_available,
//             ),
//             _buildInfoField(
//               label: 'Address',
//               controller: addressController,
//               icon: Icons.location_on,
//               maxLines: 2,
//             ),
//           ],
//         );
//       case 'selfie':
//         return Container(
//           padding: const EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             color: Colors.blue.shade50,
//             borderRadius: BorderRadius.circular(8),
//             border: Border.all(color: Colors.blue.shade200),
//           ),
//           child: Row(
//             children: [
//               Icon(
//                 Icons.camera_alt,
//                 size: 20,
//                 color: Colors.blue.shade600,
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Text(
//                   'Selfie captured successfully',
//                   style: GoogleFonts.plusJakartaSans(
//                     fontSize: 14,
//                     color: Colors.blue.shade700,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       default:
//         return const SizedBox.shrink();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isUploaded = widget.uploadedFile != null;
//     final isValidData = _getRelevantData() != null;

//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       child: Material(
//         color: Colors.transparent,
//         child: Container(
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(
//               color: isUploaded
//                   ? (isValidData ? Colors.green.shade400 : Colors.red.shade400)
//                   : Colors.grey.shade300,
//               width: 1.5,
//             ),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.grey.shade100,
//                 blurRadius: 4,
//                 offset: const Offset(0, 2),
//               ),
//             ],
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Header Section
//               InkWell(
//                 onTap: widget.onTap,
//                 borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
//                 child: Container(
//                   padding: const EdgeInsets.all(16),
//                   child: Row(
//                     children: [
//                       Container(
//                         width: 48,
//                         height: 48,
//                         decoration: BoxDecoration(
//                           color: isUploaded
//                               ? (isValidData ? Colors.green.shade100 : Colors.red.shade100)
//                               : Colors.grey.shade100,
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         child: Icon(
//                           isUploaded
//                               ? (isValidData ? widget.documentType.icon : Icons.error)
//                               : widget.documentType.icon,
//                           color: isUploaded
//                               ? (isValidData ? Colors.green.shade600 : Colors.red.shade600)
//                               : Colors.grey.shade500,
//                           size: 24,
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               isUploaded
//                                   ? (isValidData
//                                       ? '${widget.documentType.title} Verified'
//                                       : 'Document Invalid')
//                                   : 'Upload ${widget.documentType.title}',
//                               style: GoogleFonts.plusJakartaSans(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w600,
//                                 color: isUploaded
//                                     ? (isValidData ? Colors.green.shade800 : Colors.red.shade800)
//                                     : Colors.black87,
//                               ),
//                             ),
//                             const SizedBox(height: 2),
//                             Text(
//                               isUploaded
//                                   ? (isValidData
//                                       ? 'Information extracted successfully'
//                                       : 'Please upload a valid document')
//                                   : 'Tap to upload your document',
//                               style: GoogleFonts.plusJakartaSans(
//                                 fontSize: 12,
//                                 color: Colors.grey.shade600,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       if (isUploaded && isValidData)
//                         IconButton(
//                           onPressed: () {
//                             setState(() {
//                               isEditing = !isEditing;
//                             });
//                           },
//                           icon: Icon(
//                             isEditing ? Icons.save : Icons.edit,
//                             color: AppConstants.primaryColor,
//                             size: 20,
//                           ),
//                           tooltip: isEditing ? 'Save Changes' : 'Edit Information',
//                         ),
//                     ],
//                   ),
//                 ),
//               ),

//               // Document Information Section
//               if (isUploaded && isValidData) ...[
//                 Container(
//                   width: double.infinity,
//                   height: 1,
//                   color: Colors.grey.shade200,
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Icon(
//                             Icons.info_outline,
//                             size: 16,
//                             color: AppConstants.primaryColor,
//                           ),
//                           const SizedBox(width: 8),
//                           Text(
//                             'Extracted Information',
//                             style: GoogleFonts.plusJakartaSans(
//                               fontSize: 14,
//                               fontWeight: FontWeight.w600,
//                               color: AppConstants.primaryColor,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 16),
//                       _buildDocumentFields(),
//                       if (isEditing) ...[
//                         const SizedBox(height: 8),
//                         Container(
//                           padding: const EdgeInsets.all(12),
//                           decoration: BoxDecoration(
//                             color: Colors.blue.shade50,
//                             borderRadius: BorderRadius.circular(8),
//                             border: Border.all(color: Colors.blue.shade200),
//                           ),
//                           child: Row(
//                             children: [
//                               Icon(
//                                 Icons.lightbulb_outline,
//                                 size: 16,
//                                 color: Colors.blue.shade600,
//                               ),
//                               const SizedBox(width: 8),
//                               Expanded(
//                                 child: Text(
//                                   'Edit the information if OCR extracted something incorrectly',
//                                   style: GoogleFonts.plusJakartaSans(
//                                     fontSize: 12,
//                                     color: Colors.blue.shade700,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ],
//                   ),
//                 ),
//               ] else if (isUploaded && !isValidData) ...[
//                 Container(
//                   width: double.infinity,
//                   height: 1,
//                   color: Colors.grey.shade200,
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Container(
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: Colors.red.shade50,
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(color: Colors.red.shade200),
//                     ),
//                     child: Row(
//                       children: [
//                         Icon(
//                           Icons.warning_amber_rounded,
//                           color: Colors.red.shade600,
//                           size: 20,
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 'Document Verification Failed',
//                                 style: GoogleFonts.plusJakartaSans(
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.w600,
//                                   color: Colors.red.shade800,
//                                 ),
//                               ),
//                               const SizedBox(height: 4),
//                               Text(
//                                 'We couldn\'t verify this document. Please ensure the document is clear and upload a valid ${widget.documentType.title.toLowerCase()}.',
//                                 style: GoogleFonts.plusJakartaSans(
//                                   fontSize: 12,
//                                   color: Colors.red.shade700,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
