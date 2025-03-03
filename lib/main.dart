
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intern_film/Screens/homeScreen.dart';
import 'package:intern_film/authPage/loginPage.dart';
import 'package:intern_film/firebase_options.dart';



Future<void> main() async
{
  
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: (FirebaseAuth.instance.currentUser==null)?LoginPage():Homescreen(),
  ));
}


