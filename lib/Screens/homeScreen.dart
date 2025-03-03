import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intern_film/backendOperations/DataOperations.dart';

import '../backendOperations/notificationsBackend.dart';



class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  final TextEditingController value=TextEditingController();

  final TextEditingController updateText=TextEditingController();


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    NotificationHandler.loadFCM();
    NotificationHandler.listenFCM();
  }

  @override
  Widget build(BuildContext context) {



    AlertDialog addDialog=new AlertDialog(
      title: Text("ADD DATA"),
      actions: [

        TextButton(onPressed: (){


          Navigator.of(context).pop();
        }, child: Text("LEAVE")),
        TextButton(onPressed: (){

          Operations.addData(field:value.text , context: context).whenComplete((){

            value.text="";
          });

        }, child: Text("ADD")),
      ],
      content: Container(
        child: TextField(
          controller: value,
          maxLines: 2,
          decoration: InputDecoration(

              border: OutlineInputBorder(

              )
          ),
        ),

      ),
    );




    return Scaffold(
      appBar: AppBar(
        title: Text("Home Page"),
      ),
        drawer: Drawer(

          child: DrawerHeader(child: Column(

            children: [
              Text("Welcome",style: GoogleFonts.aBeeZee(),),

              Expanded(child: Text(FirebaseAuth.instance.currentUser!.displayName?? "Dhinesh2004saravanan@gmail.com",style: GoogleFonts.aBeeZee(),))

            ],
          )),
        ),

      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Colors.deepPurple.shade100,
        onPressed: () {
          showDialog<void>(
              context: context,
              barrierDismissible: true,
              // false = user must tap button, true = tap outside dialog
              builder: (BuildContext dialogContext) {
                return  addDialog;

              },


            );
          }


            
      


      
      
      ),


      body:
    StreamBuilder(stream: FirebaseFirestore.instance.collection("INTERN DATA").snapshots(

    ), builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {

      if (snapshot.hasError) {
        return Center(child: Text('Something went wrong'));
      }

      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: CircularProgressIndicator());
      }

      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
        return Center(child: Text('No Notes Found'));
      }


      return ListView.builder(itemBuilder: (context,index){
        final fetchedValue=snapshot.data!.docs[index];
        
        return Container(
          margin: EdgeInsets.fromLTRB(30,15,30,15),
          child: Card(

            
            

            child: ListTile(
              trailing: SizedBox(
                width: 80,
                child: Row(
                  children: [
                    InkWell(

                        onTap: (){

                          showDialog<void>(
                            context: context,
                            barrierDismissible: true,
                            // false = user must tap button, true = tap outside dialog
                            builder: (BuildContext dialogContext) {
                              return   AlertDialog(
                                title: Text("UPDATE DATA"),
                                actions: [

                                  TextButton(onPressed: (){


                                    Navigator.of(context).pop();
                                  }, child: Text("LEAVE"))
                                  ,

                                  TextButton(onPressed: (){

                                    Operations.updateTask(taskId: fetchedValue.id.toString(), newTitle: updateText.text, context: context).whenComplete((){

                                      // set the field to null
                                      updateText.text="";
                                    });
                                    // Operations.addData(field:value.text , context: context);

                                  }, child: Text("UPDATE")),
                                ],
                                content: Container(
                                  child: TextField(
                                    controller: updateText,
                                    maxLines: 2,
                                    decoration: InputDecoration(

                                        border: OutlineInputBorder(

                                        )
                                    ),
                                  ),

                                ),
                              );

                            },


                          );



                        },
                        child: Icon(HeroIcons.pencil_square)),
                    SizedBox(width: 30,),
                    InkWell(

                        onTap: (){

                          Operations.deleteTask(taskId: fetchedValue.id, context: context);

                        },

                        child: Icon(AntDesign.delete_fill)),
                  ],
                ),
              ),

              title: Text(fetchedValue['udata'],style: GoogleFonts.aBeeZee(),),

              subtitle: Text(fetchedValue['createdAt'].toString().split(" ")[0]),
            ),




          ),
        );
      },itemCount: snapshot.data!.docs.length,);
    }, )


    );

  }
}
