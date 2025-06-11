import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/registration_model.dart';
import 'common.dart';

class PersonalInfoStepWidget extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController currentAddressController;
  final TextEditingController permanentAddressController;
  final TextEditingController qualificationController;
  final TextEditingController languagesController;
  final String? selectedGender;
  final bool sameAsCurrentAddress;
  final Function(String) onGenderSelected;
  final Function(bool) onSameAddressChanged;

  const PersonalInfoStepWidget({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.currentAddressController,
    required this.permanentAddressController,
    required this.qualificationController,
    required this.languagesController,
    required this.selectedGender,
    required this.sameAsCurrentAddress,
    required this.onGenderSelected,
    required this.onSameAddressChanged,
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
              title: 'Personal Information',
              subtitle: 'Tell us about yourself',
            ),
            const SizedBox(height: 24),

            CustomTextField(
              controller: nameController,
              label: 'Full Name',
              hint: 'Enter your full name',
              icon: Icons.person_outline,
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Name is required' : null,
            ),
            const SizedBox(height: 16),

            CustomTextField(
              controller: currentAddressController,
              label: 'Current Address',
              hint: 'Enter your current address',
              icon: Icons.location_on_outlined,
              maxLines: 2,
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Current address is required' : null,
            ),
            const SizedBox(height: 16),

            CustomTextField(
              controller: permanentAddressController,
              label: 'Permanent Address',
              hint: 'Enter your permanent address',
              icon: Icons.home_outlined,
              maxLines: 2,
              enabled: !sameAsCurrentAddress,
              validator: (value) => value?.isEmpty ?? true
                  ? 'Permanent address is required'
                  : null,
            ),

            const SizedBox(height: 12),
            _buildAddressCheckbox(),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: qualificationController,
                    label: 'Qualification',
                    hint: 'e.g., Graduate',
                    icon: Icons.school_outlined,
                    validator: (value) => value?.isEmpty ?? true
                        ? 'Qualification is required'
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomTextField(
                    controller: languagesController,
                    label: 'Languages',
                    hint: 'e.g., English, Hindi',
                    icon: Icons.language_outlined,
                    validator: (value) => value?.isEmpty ?? true
                        ? 'Languages are required'
                        : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            GenderSelectionWidget(
              selectedGender: selectedGender,
              onGenderSelected: onGenderSelected,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressCheckbox() {
    return Row(
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: Checkbox(
            value: sameAsCurrentAddress,
            onChanged: (value) {
              onSameAddressChanged(value ?? false);
            },
            activeColor: AppConstants.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'Same as current address',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: Colors.grey.shade700,
          ),
        ),
      ],
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