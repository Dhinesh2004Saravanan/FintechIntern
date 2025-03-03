import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intern_film/backendOperations/notificationsBackend.dart';

class Operations
{
  static FirebaseFirestore firestore=FirebaseFirestore.instance;


  static Future<void> addData({required String field,required BuildContext context}) async
  {
    await firestore.collection("INTERN DATA").doc().set({

    'udata':field,
      'createdAt':DateTime.now().toString()
    }).whenComplete((){

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data Added')),
      );
      Navigator.of(context).pop();
    });



    await firestore
        .collection('NOTIFIED')
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        NotificationHandler.sendPushMessage(token: doc['tokens'], title: "A NEW MESSAGE HAS BEEN ADDED");
      });
    });

  }


 static Future<void> updateTask({required String taskId,required String newTitle,required BuildContext context}) async {



    await firestore.collection("INTERN DATA").doc(taskId).update({
      'udata': newTitle,

    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Data Updated')),
    );
    Navigator.of(context).pop();
  }

  // Delete Task
static  Future<void> deleteTask({required String taskId,required BuildContext context}) async {
    await firestore.collection("INTERN DATA").doc(taskId).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Data Deleted')),
    );

  }
}