import 'package:animate_do/animate_do.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intern_film/backendOperations/authenticationFirebase.dart';
import 'package:intern_film/backendOperations/notificationsBackend.dart';




class Registerpage extends StatefulWidget {

  @override
  State<Registerpage> createState() => _RegisterpageState();
}

class _RegisterpageState extends State<Registerpage> {
  bool isShown=true;

  final TextEditingController emailId=TextEditingController();
  final TextEditingController password=TextEditingController();


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    NotificationHandler.loadFCM();
    NotificationHandler.listenFCM();
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(



        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Container(
            child: Column(
              children: <Widget>[
                Container(
                  height: 400,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage('assets/images/background.png'),
                          fit: BoxFit.fill
                      )
                  ),
                  child: Stack(
                    children: <Widget>[
                      Positioned(
                        left: 30,
                        width: 80,
                        height: 200,
                        child: FadeInUp(duration: Duration(seconds: 1), child: Container(
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: AssetImage('assets/images/light-1.png')
                              )
                          ),
                        )),
                      ),
                      Positioned(
                        left: 140,
                        width: 80,
                        height: 150,
                        child: FadeInUp(duration: Duration(milliseconds: 1200), child: Container(
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: AssetImage('assets/images/light-2.png')
                              )
                          ),
                        )),
                      ),
                      Positioned(
                        right: 40,
                        top: 40,
                        width: 80,
                        height: 150,
                        child: FadeInUp(duration: Duration(milliseconds: 1300), child: Container(
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: AssetImage('assets/images/clock.png')
                              )
                          ),
                        )),
                      ),
                      Positioned(
                        child: FadeInUp(duration: Duration(milliseconds: 1600), child: Container(
                          margin: EdgeInsets.only(top: 50),
                          child: Center(
                            child: Text("Register", style: GoogleFonts.aBeeZee(
                                color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold
                            ),),
                          ),
                        )),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(30.0),
                  child: Column(
                    children: <Widget>[
                      FadeInUp(duration: Duration(milliseconds: 1800), child: Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Color.fromRGBO(143, 148, 251, 1)),
                            boxShadow: [
                              BoxShadow(
                                  color: Color.fromRGBO(143, 148, 251, .2),
                                  blurRadius: 20.0,
                                  offset: Offset(0, 10)
                              )
                            ]
                        ),
                        child: Column(
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                  border: Border(bottom: BorderSide(color:  Color.fromRGBO(143, 148, 251, 1)))
                              ),
                              child: TextField(
                                controller: emailId,
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "Email ",
                                    hintStyle: GoogleFonts.aBeeZee(color: Colors.grey)
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(8.0),
                              child: TextField(
                                controller: password,
                                obscureText: isShown,
                                decoration: InputDecoration(

                                    border: InputBorder.none,
                                    suffixIcon: InkWell(
                                        onTap: (){
                                          print("DDDDDDDDDD");

                                          isShown=!isShown;
                                          print(isShown);
                                          setState(() {

                                          });
                                        },

                                        child: (isShown)?Icon(Icons.remove_red_eye):Icon(Icons.visibility_off)),
                                    hintText: "Password",
                                    hintStyle:  GoogleFonts.aBeeZee(color: Colors.grey)
                                ),
                              ),
                            )
                          ],
                        ),
                      )),
                      SizedBox(height: 30,),
                      FadeInUp(duration: Duration(milliseconds: 1900), child: InkWell(
                        onTap: (){

                          FirebaseAuthentication.register(context: context, emailId: emailId.text, password: password.text);
                        },
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              gradient: LinearGradient(
                                  colors: [
                                    Color.fromRGBO(143, 148, 251, 1),
                                    Color.fromRGBO(143, 148, 251, .6),
                                  ]
                              )
                          ),
                          child: Center(
                            child: Text("Register", style: GoogleFonts.aBeeZee(
                                color: Colors.white, fontWeight: FontWeight.bold
                            ),),
                          ),
                        ),
                      )),
                      SizedBox(height: 40,),

                    ],
                  ),
                )
              ],
            ),
          ),
        )
    );
  }
}
