import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import 'package:http/http.dart' as http;

import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:googleapis/servicecontrol/v1.dart' as serviceControl;
class NotificationHandler
{

 static Future<void> requestPermission({required String userID}) async
  {

    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized)
    {
      print('User granted permission');


      await FirebaseMessaging.instance.getToken().then((token)async{
        await FirebaseFirestore.instance.collection("NOTIFIED").doc(userID).set({

          'tokens':token

        });



      });



    }
    else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else
    {
      print('User declined or has not accepted permission');
    }

  }


  static late AndroidNotificationChannel channel;
 static late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

 static Future<void> listenFCM() async {
    print("Listen FCM");
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null && !kIsWeb) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              // TODO add a proper drawable resource to android, for now using
              //      one that already exists in example app.
              icon: 'launch_background',
            ),
          ),
        );
      }
    });
  }



 static Future<void> loadFCM() async
  {
    print("LOAD FCM");
    if (!kIsWeb) {
      channel = const AndroidNotificationChannel(
        'high_importance_channel', // id
        'High Importance Notifications', // title
        importance: Importance.high,
        enableVibration: true,
      );

      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

      /// Create an Android Notification Channel.
      ///
      /// We use this channel in the AndroidManifest.xml file to override the
      /// default FCM channel to enable heads up notifications.
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<

          AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      /// Update the iOS foreground notification presentation options to allow
      /// heads up notifications.
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions
        (
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }


 static Future<void> sendPushMessage({required String token,required String title}) async
  {
    try
    {

      final serviceAccountJson = {
        "type": "service_account",
        "project_id": "internproject-af1ca",
        "private_key_id": "f7c3cd54a67930b4c74e1323ee4706f9870a34fa",
        "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDGBz68W2p7L7eA\ntFt+9ugxT2wjigE7RnhZbH71XyXDq8wOsimGJT/sNHcCN0JlrOcTcufM/3AJwtai\n3qllauIxrkayM5dtsSY3wx0pqqs/fXeeAvhJbStLBCNIaVZiw8QVWy9oWA4dEV1l\nXqzcCULkZZc0r7l3eO1sIMEZkarMQ52lRqoI9C4JukDDo21R5o6P83HH7bzZyQXH\nxQ52RJDzj5FRARyAokwtitfnV7mTIegMnRgRq6FsE+rZdToMmXDg1XXrCJTrJIyF\n2aQP1BW8JmnMrX+8+yT0iPH1Lea3vwZhlq81+39cir77rh+eThtObj5SPzhQvnhs\nHQjPnfCZAgMBAAECggEABZGglwVvGiW+YFUyGYDyCKj2Ho27+SHDMqiVbWsOkdEb\n/PHPryEPCiJzklFhgaB6IxbhI+evC+c5x/zBAMQftkvzWwGOaZxIudq30Dsnc7Kg\nkYX923rBc+ua3mdv8XkV44/b5nBLfU/Gs5oU/F8aTXf555ZlfdGdw6OsKn7pMbNM\nY3HQYPWAb/bHUqKl0tpTDmtyw3nb6zNFmqOYMN+Dx/t0HcyYflDGO7UXV+6LJlLb\nEpKV9b7Cyp0x6liDA/LSODdzdLvzh2nqIKtaxlfy/cAkqATH7f0y9s71pUV8p3vY\nhHTBO1srwoZVdjTJ8fFFaKTcB8Q/tD2Vp4Ibzjk2AQKBgQDwxFtna1n/liNUqH2b\n+UTFJMuRkJKJg3Xsj6itN6oVJKPRFt4pjkFeJCpmRtMgZX1hX/bYfVjVbRVrXMPW\ntc7JVAQYaDizPI1HL3KEPqcNqREs2tHzI2wruVxf5xbQNPJ+119hdtqnTbJ+e94f\nyJ3zoWiZo0seGSBwT2rLBnp32QKBgQDSjqjjf3oKIgXd4V4mJaI3U7/zQbAEGgOI\noe2XxNNX5usue1KNa5rGzH3iafHD+qoG9lDjKYuItuek6oGxne7ilDm6RepgLDzE\n6L2ZifTeKtEeXQfd4/49/NEb0NCsiAIB31OLZ5AXBhStUzCEP10uN1VHzwBmRMXp\nZsPWrD6GwQKBgQDYyORIFUfess+zDVa0FthN7hiBQ7w9pymJy7wj4yf4i5oYzM9S\neWzwF/45QvIcjGU9RQvc19ghq2uK1Obcr6y2aDibxVOwRwgqHVWuLz95NE5rpcc+\ndhmSsP60tz06UUI65S9TcZHk7DeYXW2eDqPx1tZ456fePN+RYGCW14lz2QKBgQC0\nA1+E0FGoJBpb7feuKXKcVq++6yPu/caTo80beh0uA7CB1tFnMt3qpJ3jWqxl3wJK\nXYAeFkDDK4yzxAIJtnqroAoSpP+SJX/24PxoLjf5USXkDalSHUAaAvFMFKSzPLxq\nmWI1xt67sGkxHfRWvE2P26K/d8xhot6Jg2BfQndagQKBgBQMDJKulbtsRoGn+/L5\nKO1zadS30WqT0hNC4HdcpWwA5s+Pe+EV8bIVGedHnK+yQovHva4SjL4uKaqSJhF9\nWh7Iftw96b3uZZX2Un0UA6bbsBw2dHuSsK2oBgwri/kdACgiYjf+qOZSV+45sSRG\nUcgWNVivymmDGfeuKmL1hX2x\n-----END PRIVATE KEY-----\n",
        "client_email": "firebase-adminsdk-fbsvc@internproject-af1ca.iam.gserviceaccount.com",
        "client_id": "103337055817362847321",
        "auth_uri": "https://accounts.google.com/o/oauth2/auth",
        "token_uri": "https://oauth2.googleapis.com/token",
        "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
        "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-fbsvc%40internproject-af1ca.iam.gserviceaccount.com",
        "universe_domain": "googleapis.com"
      };

      List<String> scopes = [
        "https://www.googleapis.com/auth/userinfo.email",
        "https://www.googleapis.com/auth/firebase.database",
        "https://www.googleapis.com/auth/firebase.messaging"
      ];



      final client = await auth.clientViaServiceAccount (
        auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
        scopes,
      );

      // Extract the access token from the client's credentials
      final accessToken =await client.credentials.accessToken.data;

      // Log the access token
      print("Access Token: $accessToken");


      // Send the push notification
      dynamic res = await http.post(
        Uri.parse('https://fcm.googleapis.com/v1/projects/${serviceAccountJson['project_id']}/messages:send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          "message": {
            "token": token,
            "notification": {
              "body": title,
              "title": "INTERNSHIP PROJECT"
            },
            "data": {
              "click_action": "FLUTTER_NOTIFICATION_CLICK",
              "id": "1",
              "status": "done"
            },
            "android": {
              "priority": "high"
            }
          }
        }),
      );

      // Log the response
      print("Response: ${res.statusCode}");
      print("Response Body: ${res.body}");

      // Close the client after the request
      client.close();

      //
      //
      //
      //  print("send push notification function called");
      //
      //  final serviceAccountJson={
      //    "type": "service_account",
      //    "project_id": "quickchat-fc6da",
      //    "private_key_id": "5149cb9c8eda1aaeb12fe905b1bd5859f1afe516",
      //    "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC/NPcliFQKXjZi\nC3Pi0w65pxaC8ItPUdnJPtJ1/ZRlODXPylxXSovvzUa1ESzqsycAP6MFE46xrTNM\nc58ihfo7J4tM1ceGIdaxGHKq6EKtJ/5qc6CYgcwQlf38GwmrLis0MAJ+SI1unQ57\nYBbpgvfNQYV+z4te6NmcXMWORd566ogh6RqbxdB/05x0OCq0TS6PbFAgmos6RuM6\npEj4rEL7VvizphIRtIe+WRxgAR8dbEdk9EI5eyevwpKZj1pLcXDVqflVoI90yuSw\ncZVzX4WmNdUpT7beXIpg2uNYPNlFV8/JEFeZp+5IDRoLREJXHUW4iS/fTGNijATd\nHk0Oew1nAgMBAAECggEAQ+Hm+HE8/O1Tu107iETMDodOi7AglUmG21atW2xqmcDq\nAdpjDC6QHdOwDaqKWsy9xO3Sz4OQ/m1yL+tAjP4px4SThPTEwE8VLIx0cU7CFT2E\nqoBgfKRgMWc+45kpxpc+iWmeCP1zENk7gfusRrzTgxCG921xmoFqeIPLM2aExPgO\ne9uWYHllkVu+cUb5GkgPs2aGBj2D+rEfD9OV7JrN9tueAf7u9glxSyGekRD6Laii\nsXW4+kNMfxsaWQiH5A1jETQO2VNfWEr/1PJ6gODcvUDewiSndo39XzCy6abxj5Ie\n2NOqzKwOuDCsauocK6plkcX5l+ev/olDUxgxIcot6QKBgQD7SQh0RKEyup7g/rMP\ny8CsmjkDc2mxThLFeECI+21sei5EWDC89phWqv1hFgV7jS3N3+94Ts9QOokVAZs1\ntY7/quUP1hgc+OaG0AYidLYykaAQJkn5XuTIO76RG3usyA8DxumRcWHWQ0O/FPLs\nsYE1IXVKPYQgbVUCSqQgM5T5HQKBgQDCy12Mx8qPBLXOpcXzbYlqhFfYiNfK/V3f\nzbzA7CDTx5HnI5ZUfXV5nDMwoBWML8vd2izSoYiA6sr8RCiMtW0ebmP0ppREilLm\nBlTmUjvlU76wQrOZLPm78s4zbQZpVvcm9+b8BdkQTZZOnFTud0sBWXqD5W9RGAke\niYEdjO4dUwKBgAU0+DXgji6M62niHTfAkxeAgpnttEz2PzFUUpIEE7phtb+4zBm+\nSl3RYTq3yBlNTZusfjvR9j3FWL3UsLCmOHZXxjNTzmAbUDuO5/Gi1XuqxNRQ1suS\nCc+UXViIZ0GnS5hacNCQtuRHtImrF3WMIA9HyDRnnetGGLLZdRktuHKJAoGAcbLc\nVujjDZmVORo/sbe05sx6rfQp6Nz8pz5iN0VcX+D0A7Mc8xILuMD4jCBUk2/ukf7f\n/M22bHEfrCFofcEEASg0BcAZeOw4OPVnJszHEzNPcXhtdjHvTsoJm7C+dkwBlOhM\nFbygF0kCO746QLq2uAHvZf9Me0wJPp7KE2KINesCgYEAvSyMGEi1utVRbCWABE8E\nKLrJvl0Mk93aaxjaKJ0ylKiO1M1ExeVsOcG3obhzHWQ80jbM/fzZkH74UaWntEhZ\nLZDM6HuNIxwK3H3oKO2beHIjRFwvDuA1yXcnCABX1OO3rjHexEYcd1fQmY29Lr+c\nvkoKi29OZWlGpL+ENdwAd5E=\n-----END PRIVATE KEY-----\n",
      //    "client_email": "firebase-adminsdk-fak1p@quickchat-fc6da.iam.gserviceaccount.com",
      //    "client_id": "106140630150691548637",
      //    "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      //    "token_uri": "https://oauth2.googleapis.com/token",
      //    "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
      //    "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-fak1p%40quickchat-fc6da.iam.gserviceaccount.com",
      //    "universe_domain": "googleapis.com"
      //  };
      //
      //  List<String> scopes=[
      //    "https://www.googleapis.com/auth/userinfo.email",
      //    "https://www.googleapis.com/auth/firebase.database",
      //    "https://www.googleapis.com/auth/firebase.messaging"
      //  ];
      //
      //  final client = await auth.clientViaServiceAccount(
      //    auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      //    scopes,
      //  );
      //
      //  // Extract the access token from the client's credentials
      //  final accessToken = client.credentials.accessToken.data;
      //
      //  // Close the client after token retrieval
      //  print("access token");
      //  print(accessToken);
      //  print("access token ${accessToken}");
      //  client.close();
      //
      //
      //
      //
      //
      //
      //
      //
      //
      //
      //
      //
      //
      //
      //
      //
      //
      //  dynamic res= await http.post(
      //    Uri.parse('https://fcm.googleapis.com/v1/projects/quickchat-fc6da/messages:send'),
      //    // headers: denote the type of the contents like content type,application
      //
      //    headers: <String, String>{
      //      'Content-Type': 'application/json',
      //      'Authorization': 'Bearer ${accessToken}',
      //    },
      //
      //    body: jsonEncode(
      //      {
      //        "message": {
      //          "token": token,
      //          "notification": {
      //            "body": title,
      //            "title": "Digital Twin"
      //          },
      //          "data": {
      //            "click_action": "FLUTTER_NOTIFICATION_CLICK",
      //            "id": "1",
      //            "status": "done"
      //          },
      //          "android": {
      //            "priority": "high"
      //          }
      //        }
      //      },
      //    ),
      //  );
      //
      // print("response is ");
      // print(res.body);
    } catch (e) {

      print("error push notification"+e.toString());
    }
  }

}