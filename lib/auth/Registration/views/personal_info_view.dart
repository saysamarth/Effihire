// views/personal_info_view.dart

import 'package:flutter/material.dart';
import '../models/registration_model.dart';
import '../widgets/registration_widget.dart';

class PersonalInfoView extends StatefulWidget {
  final PersonalInfo personalInfo;
  final Function(PersonalInfo) onPersonalInfoChanged;

  const PersonalInfoView({
    super.key,
    required this.personalInfo,
    required this.onPersonalInfoChanged,
  });

  @override
  State<PersonalInfoView> createState() => _PersonalInfoViewState();
}

class _PersonalInfoViewState extends State<PersonalInfoView> {
  late final TextEditingController _nameController;
  late final TextEditingController _currentAddressController;
  late final TextEditingController _permanentAddressController;
  late final TextEditingController _qualificationController;
  late final TextEditingController _languagesController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _setupListeners();
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: widget.personalInfo.name);
    _currentAddressController = TextEditingController(text: widget.personalInfo.currentAddress);
    _permanentAddressController = TextEditingController(text: widget.personalInfo.permanentAddress);
    _qualificationController = TextEditingController(text: widget.personalInfo.qualification);
    _languagesController = TextEditingController(text: widget.personalInfo.languages);
  }

  void _setupListeners() {
    _nameController.addListener(_updatePersonalInfo);
    _currentAddressController.addListener(_updatePersonalInfo);
    _permanentAddressController.addListener(_updatePersonalInfo);
    _qualificationController.addListener(_updatePersonalInfo);
    _languagesController.addListener(_updatePersonalInfo);
  }

  void _updatePersonalInfo() {
    widget.onPersonalInfoChanged(
      widget.personalInfo.copyWith(
        name: _nameController.text,
        currentAddress: _currentAddressController.text,
        permanentAddress: _permanentAddressController.text,
        qualification: _qualificationController.text,
        languages: _languagesController.text,
      ),
    );
  }

  void _onAddressCheckboxChanged(bool? value) {
    final sameAsCurrentAddress = value ?? false;
    if (sameAsCurrentAddress) {
      _permanentAddressController.text = _currentAddressController.text;
    } else {
      _permanentAddressController.clear();
    }
    
    widget.onPersonalInfoChanged(
      widget.personalInfo.copyWith(
        sameAsCurrentAddress: sameAsCurrentAddress,
        permanentAddress: sameAsCurrentAddress 
            ? _currentAddressController.text 
            : _permanentAddressController.text,
      ),
    );
  }

  void _onGenderSelected(String gender) {
    widget.onPersonalInfoChanged(
      widget.personalInfo.copyWith(gender: gender),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _currentAddressController.dispose();
    _permanentAddressController.dispose();
    _qualificationController.dispose();
    _languagesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Personal Information',
            subtitle: 'Tell us about yourself',
          ),
          const SizedBox(height: 24),
          
          CustomTextField(
            controller: _nameController,
            label: 'Full Name',
            hint: 'Enter your full name',
            icon: Icons.person_outline,
            validator: (value) => value?.isEmpty ?? true ? 'Name is required' : null,
          ),
          const SizedBox(height: 16),
          
          CustomTextField(
            controller: _currentAddressController,
            label: 'Current Address',
            hint: 'Enter your current address',
            icon: Icons.location_on_outlined,
            maxLines: 2,
            validator: (value) => value?.isEmpty ?? true ? 'Current address is required' : null,
          ),
          const SizedBox(height: 12),
          
          AddressCheckbox(
            value: widget.personalInfo.sameAsCurrentAddress,
            onChanged: _onAddressCheckboxChanged,
          ),
          const SizedBox(height: 16),
          
          CustomTextField(
            controller: _permanentAddressController,
            label: 'Permanent Address',
            hint: 'Enter your permanent address',
            icon: Icons.home_outlined,
            maxLines: 2,
            enabled: !widget.personalInfo.sameAsCurrentAddress,
            validator: (value) => value?.isEmpty ?? true ? 'Permanent address is required' : null,
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: _qualificationController,
                  label: 'Qualification',
                  hint: 'e.g., Graduate',
                  icon: Icons.school_outlined,
                  validator: (value) => value?.isEmpty ?? true ? 'Qualification is required' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomTextField(
                  controller: _languagesController,
                  label: 'Languages',
                  hint: 'e.g., English, Hindi',
                  icon: Icons.language_outlined,
                  validator: (value) => value?.isEmpty ?? true ? 'Languages are required' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          GenderSelection(
            selectedGender: widget.personalInfo.gender,
            onGenderSelected: _onGenderSelected,
          ),
        ],
      ),
    );
  }
}