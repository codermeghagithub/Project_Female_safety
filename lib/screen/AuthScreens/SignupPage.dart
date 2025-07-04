import 'package:aura/screen/others/KYCFormWithID.dart';
// import 'package:aura/service/notification_service.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Controllers
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  String? _selectedGender = "Female";
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  // Validation Methods
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != passwordController.text) {
      Fluttertoast.showToast(
        msg: "Passwords do not match",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return 'Passwords do not match'; // Return validation error
    }
    return null; // No error, passwords match
  }

  String? _validateField(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Please enter $fieldName';
    }
    return null;
  }

  /// Authentication Setup

  void _registerUser(BuildContext context) async {
    try {
      // Check if the email is already in use and create the user
      var userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: confirmPasswordController.text.trim(),
      );

      // Get the user from the userCredential
      User? user = userCredential.user;

      if (user != null) {
        // Registration successful
        // Save user info to Firestore
        await saveUserInfoToFirestore(user);

        Fluttertoast.showToast(
          msg: "User registered: ${user.email}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );

        // Navigate to the KYC Form
        Get.to(KYCFormWithID(
          userId: user.uid,
        ));
      } else {
        // If user is null, registration failed
        Fluttertoast.showToast(
          msg: "User registration failed.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } on FirebaseAuthException catch (e) {
      // Handle Firebase authentication errors
      if (e.code == 'email-already-in-use') {
        Fluttertoast.showToast(
          msg: "This email is already in use. Please try logging in.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.orange,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } else {
        Fluttertoast.showToast(
          msg: e.message ?? 'An error occurred. Please try again.',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (e) {
      // Handle other errors
      Fluttertoast.showToast(
        msg: e.toString(), // Convert the error to a string
        toastLength: Toast.LENGTH_LONG, // Duration of the toast
        gravity: ToastGravity.BOTTOM, // Position of the toast
        backgroundColor: Colors.red, // Background color
        textColor: Colors.white, // Text color
        fontSize: 16.0, // Font size
      );
    }
  }

  Future saveUserInfoToFirestore(User fuser) async {
    try {
      await FirebaseFirestore.instance.collection("users").doc(fuser.uid).set({
        "uid": fuser.uid,
        "email": emailController.text.trim(),
        "name":
            "${firstNameController.text.trim()} ${lastNameController.text.trim()}",
        "phoneNumber": phoneController.text.trim(),
        "gender": _selectedGender,
      });

      // Optionally, show a success message after saving to Firestore
      Fluttertoast.showToast(
        msg: "User info saved to Firestore",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } catch (e) {
      // Handle Firestore errors
      Fluttertoast.showToast(
        msg: "Failed to save user info to Firestore: $e",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // If the form is valid, register the user
      _registerUser(context);
    } else {
      Fluttertoast.showToast(
        msg: "Please fix the errors in the form",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 248, 237, 247),
        elevation: 0,
        // leading: IconButton(
        //   icon: const Icon(FontAwesomeIcons.chevronLeft),
        //   onPressed: () async {
        //     String Id = randomAlph aNumeric(10);
        //     Map<String, dynamic> SignupPageIdfoMap = {
        //       "firstName": firstNameController.text,
        //       "lastName": lastNameController.text,
        //       "id": Id,
        //       "phone": phoneController.text,
        //     };
        //     await DatabaseMethods()
        //         .addUsersDetails(SignupPageIdfoMap, Id)
        //         .then((Value) {
        //       Fluttertoast.showToast(
        //         msg: "User Details has been uploaded successfully",
        //         toastLength: Toast.LENGTH_SHORT,
        //         gravity: ToastGravity.CENTER,
        //         backgroundColor: Colors.red,
        //         textColor: Colors.white,
        //         fontSize: 16.0,
        //       );
        //     });

        //     // Get.back();
        //   },
        // ),
        title: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: GoogleFonts.comfortaa(
              fontSize: 28.0,
              color: Colors.black,
            ),
            children: const <TextSpan>[
              TextSpan(
                text: 'Aura',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFfba7fc),
                ),
              ),
              TextSpan(
                text: 'Secure',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ],
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildInputField(emailController, "Email Address",
                  "Enter Your Email", _validateEmail),
              buildPasswordField(
                  passwordController, "Password", _isPasswordVisible,
                  (visible) {
                setState(() {
                  _isPasswordVisible = visible;
                });
              }),
              buildPasswordField(confirmPasswordController, "Confirm Password",
                  _isConfirmPasswordVisible, (visible) {
                setState(() {
                  _isConfirmPasswordVisible = visible;
                });
              }),
              buildFirstAndLastNameFields(),
              buildInputField(
                  phoneController,
                  "Phone Number",
                  "Enter Your Phone Number",
                  (value) => _validateField(value, "Phone Number"),
                  keyboardType: TextInputType.phone),
              buildGenderDropdown(),
              const SizedBox(height: 15),
              GestureDetector(
                onTap: _submitForm, // Trigger form submission on tap
                // onTap: _signUp,
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
                        offset: Offset(0, 4), // Shadow position
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      "Sign Up",
                      style: GoogleFonts.comfortaa(
                        color: Colors.white,
                        fontSize: 16.0,
                      ),
                    ),

// myself

//  onPressed: () async {
                    // NotificationService notificationService = NotificationService();
//   await notificationService.requestPermission(); // Request permission
//   String? userDeviceToken = await notificationService.getDeviceToken();

                    // String name = username.text.trim();
                    // String email = userEmail.text.trim();
                    // String phone = userPhone.text.trim();
                    // String city = userCity.text.trim();
                    // String password = userPassword.text.trim();
                    //  String userDeviceToken = await notificationService.getDeviceToken();

                    // if (name.isEmpty || email.isEmpty || phone.isEmpty || city.isEmpty || password.isEmpty) {
                    //   Get.snackbar(
                    //     "Error",
                    //     "Please enter all details",
                    //     snackPosition: SnackPosition.BOTTOM,
                    //     backgroundColor: AppConstant.appScendoryColor,
                    //     colorText: AppConstant.appTextColor,
                    //   );
                    // } else {
                    // UserCredential? userCredential = await signUpController.signUpMethod(
//       name,
//       email,
//       phone,
//       city,
//       password,
                    //     userDeviceToken,
                    //   );
                    // }
//     if (userCredential != null) {
//       Get.snackbar(
//         "Verification email sent.",
//         "Please check your email.",
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: AppConstant.appScendoryColor,
//         colorText: AppConstant.appTextColor,
//       );

//       FirebaseAuth.instance.signOut();
//       Get.offAll(() => SignInScreen());
//     }
//   }
// }

//
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildInputField(
    TextEditingController controller,
    String labelText,
    String hintText,
    String? Function(String?) validator, {
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLength: maxLength,
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

  Widget buildPasswordField(TextEditingController controller, String labelText,
      bool isVisible, Function(bool) onVisibilityChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 10.0),
        decoration: BoxDecoration(
          color: const Color(0xFFedf0f8),
          borderRadius: BorderRadius.circular(8),
        ),
        child: TextFormField(
          controller: controller,
          obscureText: !isVisible,
          validator: labelText == "Confirm Password"
              ? _validateConfirmPassword
              : _validatePassword,
          decoration: InputDecoration(
            hintText: labelText,
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
            suffixIcon: IconButton(
              icon: Icon(isVisible ? Icons.visibility_off : Icons.visibility),
              onPressed: () => onVisibilityChanged(!isVisible),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildFirstAndLastNameFields() {
    return Row(
      children: [
        Expanded(
          child: buildInputField(
              firstNameController,
              "First Name",
              "Enter Your First Name",
              (value) => _validateField(value, "First Name")),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: buildInputField(
              lastNameController,
              "Last Name",
              "Enter Your Last Name",
              (value) => _validateField(value, "Last Name")),
        ),
      ],
    );
  }

  Widget buildGenderDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: DropdownButtonFormField<String>(
        value: _selectedGender,
        decoration: InputDecoration(
          labelText: "Gender",
          filled: true,
          fillColor: const Color(0xFFedf0f8),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        items: ["Male", "Female", "Other"]
            .map((gender) =>
                DropdownMenuItem(value: gender, child: Text(gender)))
            .toList(),
        onChanged: (value) => setState(() => _selectedGender = value),
        validator: (value) =>
            value == null ? "Please select your gender" : null,
      ),
    );
  }
}
