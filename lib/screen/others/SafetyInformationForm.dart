

// myself 


import 'package:aura/screen/others/Dashboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class SafetyInformationForm extends StatefulWidget {
  final String userId;

  const SafetyInformationForm({Key? key, required this.userId})
      : super(key: key);

  @override
  _SafetyInformationFormState createState() => _SafetyInformationFormState();
}

class _SafetyInformationFormState extends State<SafetyInformationForm> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final TextEditingController bloodTypeController = TextEditingController();
  final TextEditingController allergiesController = TextEditingController();
  final TextEditingController medicalConditionsController =
      TextEditingController();

  List<Map<String, TextEditingController>> emergencyContacts = [];

  @override
  void initState() {
    super.initState();
    _addEmergencyContact(); // Start with one emergency contact
  }

  void _addEmergencyContact() {
    if (emergencyContacts.length < 4) {
      setState(() {
        emergencyContacts.add({
          'name': TextEditingController(),
          'relationship': TextEditingController(),
          'phone': TextEditingController(),
        });
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('You can add a maximum of 4 emergency contacts.')),
      );
    }
  }

  void _removeEmergencyContact(int index) {
    setState(() {
      emergencyContacts[index]['name']!.dispose();
      emergencyContacts[index]['relationship']!.dispose();
      emergencyContacts[index]['phone']!.dispose();
      emergencyContacts.removeAt(index);
    });
  }

  Future<void> _submitSafetyInformation() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      CollectionReference safetyInfoCollection = firestore
          .collection('users')
          .doc(widget.userId)
          .collection('SafetyInformation');

      List<Map<String, String>> emergencyContactsList =
          emergencyContacts.map((contact) {
        return {
          'name': contact['name']!.text,
          'relationship': contact['relationship']!.text,
          'phone': contact['phone']!.text,
        };
      }).toList();

      await safetyInfoCollection.doc('info').set({
        'bloodType': bloodTypeController.text.trim(),
        'allergies': allergiesController.text.trim(),
        'medicalConditions': medicalConditionsController.text.trim(),
        'emergencyContacts': emergencyContactsList,
        'submittedAt': FieldValue.serverTimestamp(),
      });

      Get.snackbar("Success", "Safety information submitted successfully!",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM);

      DocumentSnapshot userDoc =
          await firestore.collection('users').doc(widget.userId).get();
      Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;

      Get.to(() => Dashboard(userId: widget.userId, userData: userData ?? {}));
    } catch (e) {
      Get.snackbar(
          "Error", "Failed to submit safety information. Please try again.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      setState(() => isLoading = false);
    }
  }

  Widget buildInputField(
    TextEditingController controller,
    String hintText,
    String? labelText, {
    bool noneeditable = false,
    TextInputType keyboardType = TextInputType.text,
    required String? Function(String?) validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        readOnly: noneeditable,
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.comfortaa(
            color: const Color(0xFFb2b7bf),
            fontSize: 18.0,
          ),
          filled: true,
          fillColor: const Color(0xFFedf0f8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide.none,
          ),
        ),
        validator: validator,
      ),
    );
  }

  Widget buildEmergencyContactField(int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Emergency Contact ${index + 1}',
              style: GoogleFonts.comfortaa(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (emergencyContacts.length > 1)
              IconButton(
                onPressed: () => _removeEmergencyContact(index),
                icon: const Icon(Icons.remove_circle, color: Colors.red),
              ),
          ],
        ),
        buildInputField(
          emergencyContacts[index]['name']!,
          'Enter Contact Name',
          null,
          validator: (value) => value!.isEmpty ? 'Please enter a name' : null,
        ),
        buildInputField(
          emergencyContacts[index]['relationship']!,
          'Enter Relationship',
          null,
          validator: (value) =>
              value!.isEmpty ? 'Please enter relationship' : null,
        ),
        buildInputField(
          emergencyContacts[index]['phone']!,
          'Enter Phone Number',
          null,
          keyboardType: TextInputType.phone,
          validator: (value) =>
              value!.isEmpty ? 'Please enter phone number' : null,
        ),
      ],
    );
  }

  @override
  void dispose() {
    for (var contact in emergencyContacts) {
      contact['name']?.dispose();
      contact['relationship']?.dispose();
      contact['phone']?.dispose();
    }
    bloodTypeController.dispose();
    allergiesController.dispose();
    medicalConditionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: GoogleFonts.comfortaa(
              fontSize: 28.0,
              color: Colors.black,
            ),
            children: const <TextSpan>[
              TextSpan(
                text: 'Safety ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFfba7fc),
                ),
              ),
              TextSpan(
                text: 'Information',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ],
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 248, 237, 247),
        actions: [
          TextButton(
            onPressed: () {
              Get.to(Dashboard(
                userId: widget.userId,
                userData: {},
              ));
            },
            child: Text(
              'Skip',
              style: GoogleFonts.comfortaa(
                color: const Color(0xFFfba7fc),
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Emergency Contact Details',
                      style: GoogleFonts.comfortaa(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...List.generate(emergencyContacts.length,
                        (index) => buildEmergencyContactField(index)),
                    if (emergencyContacts.length < 4)
                      Center(
                        child: TextButton(
                          onPressed: _addEmergencyContact,
                          child: Text(
                            'Add Another Emergency Contact',
                            style: GoogleFonts.comfortaa(
                              color: const Color(0xFFfba7fc),
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                    Text(
                      'Medical Information',
                      style: GoogleFonts.comfortaa(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    buildInputField(
                      bloodTypeController,
                      'Enter Blood Type',
                      null,
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter blood type' : null,
                    ),
                    buildInputField(
                      allergiesController,
                      'Enter Allergies',
                      null,
                      validator: (value) => null, // Optional field
                    ),
                    buildInputField(
                      medicalConditionsController,
                      'Enter Medical Conditions',
                      null,
                      validator: (value) => null, // Optional field
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: GestureDetector(
                        onTap: isLoading ? null : _submitSafetyInformation,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 50.0, vertical: 15.0),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 139, 3, 93),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : Text(
                                  "Next",
                                  style: GoogleFonts.comfortaa(
                                    color: Colors.white,
                                    fontSize: 16.0,
                                  ),
                                ),
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