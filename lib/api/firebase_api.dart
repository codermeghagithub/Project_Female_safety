import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseApi {
  //create an instance of firebase Messaging
  final _firebaseMessaging = FirebaseMessaging.instance;

  //functionto initialize notifications
  Future<void> initNotifications() async {
    //requestpermission from user (will prompt user)
    await _firebaseMessaging.requestPermission();

    //fetch the fcm token for this device
    final FCMToken = await _firebaseMessaging.getToken();

    //print the token (normally you would send this to your server)
    print('Token: $FCMToken');
  }

  //function to handle received messages

  //function to initialize foreground and background settings
}
