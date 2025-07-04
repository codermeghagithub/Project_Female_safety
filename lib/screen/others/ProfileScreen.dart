import 'package:aura/screen/AuthScreens/LoginScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;
  final Map<String, dynamic> userData;

  const ProfileScreen({
    required this.userId,
    required this.userData,
    super.key,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final Map<String, TextEditingController> _controllers;
  final Map<String, bool> _editStates = {};
  List<Map<String, dynamic>> emergencyContacts = [];
  String? _idType;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controllers = {
      'fullName': TextEditingController(),
      'phoneNumber': TextEditingController(),
      'email': TextEditingController(),
      'address': TextEditingController(),
      'nationality': TextEditingController(),
      'idNumber': TextEditingController(),
      'dob': TextEditingController(),
      'issueDate': TextEditingController(),
      'expiryDate': TextEditingController(),
      'issuingCountry': TextEditingController(),
      'allergies': TextEditingController(),
      'bloodType': TextEditingController(),
      'medicalConditions': TextEditingController(),
    };
    _controllers.forEach((key, _) => _editStates[key] = false);
    _fetchUserData();
  }

  @override
  void dispose() {
    _controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _fetchUserData() async {
    try {
      setState(() => _isLoading = true);

      final userDoc =
          await _firestore.collection('users').doc(widget.userId).get();
      final kycDocs = await _firestore
          .collection('users')
          .doc(widget.userId)
          .collection('KYCData')
          .limit(1)
          .get();
      final safetyDocs = await _firestore
          .collection('users')
          .doc(widget.userId)
          .collection('SafetyInformation')
          .limit(1)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data() ?? {};
        _controllers['fullName']!.text = data['fullName'] ?? data['name'] ?? '';
        _controllers['phoneNumber']!.text = data['phoneNumber'] ?? '';
      }

      if (kycDocs.docs.isNotEmpty) {
        final kycData = kycDocs.docs.first.data();
        _controllers['email']!.text = kycData['email'] ?? '';
        _controllers['address']!.text = kycData['address'] ?? '';
        _controllers['nationality']!.text = kycData['nationality'] ?? '';
        _controllers['idNumber']!.text = kycData['idNumber'] ?? '';
        _controllers['dob']!.text = kycData['dob'] ?? '';
        _controllers['issueDate']!.text = kycData['issueDate'] ?? '';
        _controllers['expiryDate']!.text = kycData['expiryDate'] ?? '';
        _controllers['issuingCountry']!.text = kycData['issuingCountry'] ?? '';
        _idType = kycData['idType'] ?? 'ID Number';
      }

      if (safetyDocs.docs.isNotEmpty) {
        final safetyData = safetyDocs.docs.first.data();
        _controllers['allergies']!.text = safetyData['allergies'] ?? '';
        _controllers['bloodType']!.text = safetyData['bloodType'] ?? '';
        _controllers['medicalConditions']!.text =
            safetyData['medicalConditions'] ?? '';
        emergencyContacts = (safetyData['emergencyContacts'] as List<dynamic>?)
                ?.map((e) => Map<String, dynamic>.from(e as Map))
                .toList() ??
            [];
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching data: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateUserData() async {
    if (!_editStates.containsValue(true) && emergencyContacts.isEmpty) return;

    try {
      setState(() => _isLoading = true);
      final Map<String, dynamic> userUpdates = {};
      final Map<String, dynamic> kycUpdates = {};
      final Map<String, dynamic> safetyUpdates = {};

      _editStates.forEach((key, isEditing) {
        if (isEditing) {
          switch (key) {
            case 'fullName':
            case 'phoneNumber':
              userUpdates[key] = _controllers[key]!.text.trim();
              break;
            case 'email':
            case 'address':
            case 'nationality':
            case 'idNumber':
            case 'dob':
            case 'issueDate':
            case 'expiryDate':
            case 'issuingCountry':
              kycUpdates[key] = _controllers[key]!.text.isEmpty
                  ? null
                  : _controllers[key]!.text.trim();
              if (key == 'idNumber')
                kycUpdates['idType'] = _idType ?? 'ID Number';
              break;
            case 'allergies':
            case 'bloodType':
            case 'medicalConditions':
              safetyUpdates[key] = _controllers[key]!.text.trim();
              break;
          }
        }
      });

      final List<Future> updates = [];
      if (userUpdates.isNotEmpty) {
        userUpdates['updatedAt'] = FieldValue.serverTimestamp();
        updates.add(_firestore
            .collection('users')
            .doc(widget.userId)
            .update(userUpdates));
      }
      if (kycUpdates.isNotEmpty) {
        kycUpdates['uploadedAt'] = FieldValue.serverTimestamp();
        updates.add(_firestore
            .collection('users')
            .doc(widget.userId)
            .collection('KYCData')
            .doc('kycDetails')
            .set(kycUpdates, SetOptions(merge: true)));
      }
      if (safetyUpdates.isNotEmpty || emergencyContacts.isNotEmpty) {
        safetyUpdates['emergencyContacts'] = emergencyContacts;
        safetyUpdates['updatedAt'] = FieldValue.serverTimestamp();
        updates.add(_firestore
            .collection('users')
            .doc(widget.userId)
            .collection('SafetyInformation')
            .doc('info')
            .set(safetyUpdates, SetOptions(merge: true)));
      }

      if (updates.isNotEmpty) {
        await Future.wait(updates);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
          _editStates.updateAll((_, value) => false);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _addEmergencyContact() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final relationshipController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Emergency Contact'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Phone'),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: relationshipController,
              decoration: const InputDecoration(labelText: 'Relationship'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty &&
                  phoneController.text.trim().isNotEmpty) {
                setState(() {
                  emergencyContacts.add({
                    'name': nameController.text.trim(),
                    'phone': phoneController.text.trim(),
                    'relationship': relationshipController.text.trim().isEmpty
                        ? 'N/A'
                        : relationshipController.text.trim(),
                  });
                });
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Name and Phone are required')),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    try {
      setState(() => _isLoading = true);
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Get.offAll(() => const LoginScreen());
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error logging out: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.pinkAccent,
        actions: [
          if (_editStates.containsValue(true) || emergencyContacts.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.save, color: Colors.white),
              onPressed: _isLoading ? null : _updateUserData,
            ),
        ],
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _fetchUserData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileAvatar(),
                  const SizedBox(height: 20),
                  const Text('Personal Information',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  _buildProfileField('Full Name', 'fullName'),
                  _buildProfileField('Phone Number', 'phoneNumber'),
                  _buildProfileField('Email', 'email'),
                  _buildProfileField('Address', 'address'),
                  _buildProfileField('Nationality', 'nationality'),
                  _buildProfileField('Date of Birth', 'dob', isDate: true),
                  _buildProfileField(_idType ?? 'ID Number', 'idNumber'),
                  _buildProfileField('Issue Date', 'issueDate', isDate: true),
                  _buildProfileField('Expiry Date', 'expiryDate', isDate: true),
                  _buildProfileField('Issuing Country', 'issuingCountry'),
                  const SizedBox(height: 20),
                  const Text('Safety Information',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  _buildProfileField('Allergies', 'allergies'),
                  _buildProfileField('Blood Type', 'bloodType'),
                  _buildProfileField('Medical Conditions', 'medicalConditions'),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Emergency Contacts',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.add, color: Colors.pinkAccent),
                        onPressed: _isLoading ? null : _addEmergencyContact,
                      ),
                    ],
                  ),
                  if (emergencyContacts.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('No emergency contacts added'),
                    )
                  else
                    ...emergencyContacts
                        .map((contact) => _buildEmergencyContact(contact)),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _logout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 139, 3, 93),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 15),
                      ),
                      child: Text(
                        'Log Out',
                        style: GoogleFonts.comfortaa(
                            color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileField(String label, String controllerKey,
      {bool isDate = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _controllers[controllerKey],
              readOnly: !_editStates[controllerKey]!,
              decoration: InputDecoration(
                labelText: label,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.grey[200],
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[400]!),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.pinkAccent),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              keyboardType: (controllerKey == 'phoneNumber' ||
                      controllerKey == 'idNumber')
                  ? TextInputType.number
                  : isDate
                      ? TextInputType.datetime
                      : TextInputType.text,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(
              _editStates[controllerKey]! ? Icons.check : Icons.edit,
              color: Colors.pinkAccent,
            ),
            onPressed: _isLoading
                ? null
                : () => setState(() =>
                    _editStates[controllerKey] = !_editStates[controllerKey]!),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyContact(Map<String, dynamic> contact) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: const Icon(Icons.phone, color: Colors.pinkAccent),
        title: Text(contact['name'] ?? 'Unknown'),
        subtitle: Text(
            '${contact['phone'] ?? 'No Number'} (${contact['relationship'] ?? 'N/A'})'),
        trailing: IconButton(
          icon: const Icon(Icons.call, color: Colors.green),
          onPressed: _isLoading
              ? null
              : () {
                  // TODO: Implement phone call functionality
                },
        ),
      ),
    );
  }

  Widget _buildProfileAvatar() {
    return Center(
      child: CircleAvatar(
        radius: 60,
        backgroundColor: Colors.grey.shade300,
        child: ClipOval(
          child: Image.network(
            widget.userData['profileImage'] ??
                'https://www.pngall.com/wp-content/uploads/5/Profile-Avatar-PNG.png',
            fit: BoxFit.cover,
            width: 120,
            height: 120,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          (loadingProgress.expectedTotalBytes ?? 1)
                      : null,
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.person, size: 60, color: Colors.grey);
            },
          ),
        ),
      ),
    );
  }
}
