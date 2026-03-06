import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  String _selectedRole = "User";

  // Pick profile image
  Future<void> _pickImage() async {
    final XFile? pickedFile =
    await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null && mounted) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  // Pick date of birth
  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null && mounted) {
      setState(() {
        _dobController.text =
        "${pickedDate.day.toString().padLeft(2, '0')}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.year}";
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool readOnly = false,
    Function()? onTap,
    TextInputType keyboardType = TextInputType.text,
    bool isDarkMode = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        keyboardType: keyboardType,
        style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black87, fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(
                color: isDarkMode ? Colors.white54 : Colors.grey.shade400,
                width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(
                color: Colors.green.shade700, width: 2),
          ),
        ),
      ),
    );
  }

  Widget buildRoleDropdown(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: "Role",
          prefixIcon: const Icon(Icons.person_outline),
          filled: true,
          fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(
                color: isDarkMode ? Colors.white54 : Colors.grey.shade400,
                width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(
                color: Colors.green.shade700, width: 2),
          ),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selectedRole,
            icon: const Icon(Icons.arrow_drop_down),
            isExpanded: true,
            style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w500),
            onChanged: (String? newValue) {
              setState(() {
                _selectedRole = newValue!;
              });
            },
            items: <String>['User', 'Admin']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
        backgroundColor: Colors.green.shade700,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Profile Image
              Stack(
                children: [
                  ClipOval(
                    child: _profileImage != null && _profileImage!.existsSync()
                        ? Image.file(
                      _profileImage!,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    )
                        : Image.asset(
                      'assets/images/profile_placeholder.png',
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.green.shade700,
                        child: const Icon(Icons.camera_alt,
                            color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Name
              buildTextField(
                  controller: _nameController,
                  label: "Name",
                  icon: Icons.person,
                  isDarkMode: isDarkMode),

              // DOB
              buildTextField(
                  controller: _dobController,
                  label: "Date of Birth",
                  icon: Icons.calendar_today,
                  readOnly: true,
                  onTap: _pickDate,
                  isDarkMode: isDarkMode),

              // Phone
              buildTextField(
                  controller: _phoneController,
                  label: "Phone Number",
                  icon: Icons.phone,
                  keyboardType: TextInputType.number,
                  isDarkMode: isDarkMode),

              // Role
              buildRoleDropdown(isDarkMode),

              const SizedBox(height: 30),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context, {
                      'name': _nameController.text,
                      'dob': _dobController.text,
                      'phone': _phoneController.text,
                      'role': _selectedRole,
                      'image': _profileImage != null
                          ? File(_profileImage!.path)
                          : null,
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Profile Saved Successfully!")),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  icon: const Icon(Icons.save, color: Colors.white),
                  label: const Text(
                    "Save Profile",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
