import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:intern_film/Screens/homeScreen.dart';
import 'package:intern_film/backendOperations/notificationsBackend.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:googleapis_auth/googleapis_auth.dart' as auth;

import 'package:shared_preferences/shared_preferences.dart';
class FirebaseAuthentication {
  static final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  static final FirebaseFirestore firestore = FirebaseFirestore.instance;

  static Future<void> login(
      {required BuildContext context,
      required String emailId,
      required String password}) async {
   // final SharedPreferences prefs= await SharedPreferences.getInstance();
    ProgressDialog progressDialog =
        ProgressDialog(context, type: ProgressDialogType.normal);
    progressDialog.style(
      message: 'Logging in...',
      borderRadius: 10.0,
      backgroundColor: Colors.white,
      progressWidget: CircularProgressIndicator(),
      elevation: 10.0,
      insetAnimCurve: Curves.easeInOut,
      messageTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 18.0,
        fontWeight: FontWeight.w600,
      ),
    );
    try {
      await progressDialog.show();
      User user = (await firebaseAuth.signInWithEmailAndPassword(
              email: emailId, password: password))
          .user!;

      print("USer is $user");
      if (user != null) {
        print("User is logged in: ${user.email}");




        WidgetsBinding.instance.addPostFrameCallback((_) {

        });
      } else {
        print("Login failed: User is null");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login InSuccessful!')),
        );
      }
    } on FirebaseAuthException catch (e) {


      if (e.code == 'user-not-found') {
        print("No user found for that email.");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('!No user found for that email')),
        );
      } else if (e.code == 'wrong-password') {
        print("Wrong password provided.");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Wrong password')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('!No user found for that email')),
        );
        print("An error occurred: ${e.message}");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An unexpected error occurred: $e')),
      );
    } finally {
      // Hide the progress dialog
      await progressDialog.hide();
    }
  }

  static Future<void> register(
      {required BuildContext context,
      required String emailId,
      required String password,
     }) async {
    final SharedPreferences prefs= await SharedPreferences.getInstance();
    ProgressDialog progressDialog =
        ProgressDialog(context, type: ProgressDialogType.normal);
    progressDialog.style(
      message: 'Registering...',
      borderRadius: 10.0,
      backgroundColor: Colors.white,
      progressWidget: CircularProgressIndicator(),
      elevation: 10.0,
      insetAnimCurve: Curves.easeInOut,
      messageTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 18.0,
        fontWeight: FontWeight.w600,
      ),
    );
    print("register called");

    try {
      // Show the progress dialog
      await progressDialog.show();

      User user = (await firebaseAuth.createUserWithEmailAndPassword(
        email: emailId,
        password: password,
      ))
          .user!;

      if (user != null) {




        print("User registered successfully: ${user.email}");





        await prefs.setString('email', emailId);

      await NotificationHandler.requestPermission(userID: user.uid);

        await firestore.collection("USER PROFILE").doc(user.uid).set({
          "emailId": emailId,

          "userId": user.uid
        }).whenComplete(() {
          progressDialog.hide();
          // Navigate to HomePage or another screen
        });

       await firebaseAuth.currentUser!.updateDisplayName(emailId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration Successful!')),
        );
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.push(context, MaterialPageRoute(builder: (context)=>Homescreen()));



        });
      } else {
        print("Registration failed: User is null");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration Failed! Please try again.')),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        print("The email address is already in use.");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Email is already in use. Please use a different email.')),
        );
      } else if (e.code == 'weak-password') {
        print("The password provided is too weak.");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Password is too weak. Please use a stronger password.')),
        );
      } else if (e.code == 'invalid-email') {
        print("The email address is invalid.");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Invalid email address. Please check and try again.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: ${e.message}')),
        );
        print("An error occurred: ${e.message}");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An unexpected error occurred: $e')),
      );
    } finally {
      // Hide the progress dialog
      await progressDialog.hide();
    }
  }




}
