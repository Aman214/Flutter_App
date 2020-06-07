import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../griddashboard.dart';

/*class Pettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(
          'Your Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: new SettingsScreen(),
    );
  }
}*/

class SettingsScreen1 extends StatefulWidget {
  @override
  State createState() => new SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen1> {

  TextEditingController controllerNickname;
  TextEditingController controllerAboutMe;
  TextEditingController controllerName;
  TextEditingController controllerphone;
  TextEditingController controllerfield;
  TextEditingController controllerPin ;

  SharedPreferences prefs;

  String id = '';
  String nickname = '';
  String aboutMe = '';
  String photoUrl = '';
  String email = '';
  String idv = '';
  String ids = '';

  /////
  String phone = '';
  String name = '';
  String field = '';
  String pin = '';
  Iterable<String> userdocid ;
  Iterable<String> userdocidv ;
  Iterable<String> userdocids ;
  List<String> lidv = [];
  List<String> lids = [];
  /////

  bool isLoading = false;
  bool nvseen = false;
  bool updated = false;
  File avatarImageFile;

  final FocusNode focusNodeNickname = new FocusNode();
  final FocusNode focusNodeAboutMe = new FocusNode();

  @override
  void initState() {
    super.initState();
    readLocal();
  }

  FirebaseAuth _auth = FirebaseAuth.instance;
  void readLocal() async {
////////////
    final FirebaseUser currentUser = await _auth.currentUser();
    print(currentUser.email);
    email = currentUser.email;
    prefs = await SharedPreferences.getInstance();
     QuerySnapshot result =
        await Firestore.instance.collection('volunteer_data').where('email', isEqualTo: currentUser.email).getDocuments();
     List<DocumentSnapshot> documents = result.documents;
     if(documents.length == 0)
     {
       nvseen  = true;
     }
      final userdocid=result.documents.map((doc)=>doc.documentID);
      print(userdocid);
      id = userdocid.first.toString();
      print(id);

      if (documents.length > 0) {
      phone = documents[0]['phone'];
      name = documents[0]['Name'];
      photoUrl = documents[0]['photoUrl'];
      pin = documents[0]['address'];
      field = documents[0]['field'];

      if(photoUrl==null)
       photoUrl = '';

      if(field==null || field =="No")
        nvseen = true;

      controllerName = new TextEditingController(text: name);
      controllerphone = new TextEditingController(text: phone);
      controllerPin = new TextEditingController(text: pin);
      //controllerfield  = new TextEditingController(text: field);
      }

      print(pin);

      /*QuerySnapshot result1 =
          await Firestore.instance.collection('registered_problem').where('email', isEqualTo: currentUser.email).getDocuments();
        documents = result1.documents;

        if(documents.length >0){

      final userdocidv=result1.documents.map((doc)=>doc.documentID);
      print(userdocidv);
      lidv = userdocidv.toList();
      idv = lidv[0];
      print(idv);
        }*/

    setState(() {});
  }


   @override
  Widget build(BuildContext context) {
    return new Scaffold(
    appBar: new AppBar(
      title: new Text("Problems in Your Region wise" , ),
      backgroundColor: Colors.white12,
      centerTitle: true,
    ),
    backgroundColor: Colors.orangeAccent,
    
    body: Stack(
      children: <Widget>[

        Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/covid.jpeg"),
            fit: BoxFit.fill,
          ),
        ),
      ),
      Container(
          color: Color.fromRGBO(255, 255, 255, 0.6),
        ),
    new StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection("registered_problem").where('address', isEqualTo: pin).snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) return const Text('Connecting...');

        return ListView.builder(
          padding: EdgeInsets.all(10.0),
          itemBuilder: (context, index) => buildItem(context, snapshot.data.documents[index]),
          itemCount: snapshot.data.documents.length,
        ); 
      },
    ),

    Positioned(
                    child: nvseen
                        ? Container(
                            child: Center(
                              child: AlertDialog(
                                      title: Text('You have to be volunteer to see all problems in your area' ,
                                      style: TextStyle(color:Colors.black)),
                                      content: SingleChildScrollView(
                                        child: ListBody(
                                          children: <Widget>[
                                            GestureDetector(
                                                child: Text("",style: TextStyle(color:Colors.blue),textAlign: TextAlign.right,),
                                                onTap: (){
                                                  /*Navigator.push(
                                                context,
                                                MaterialPageRoute(builder: (context) => Vsettings()),
                                                  );*/
                                                },
                                              ),
                                          ],
                                        ),
                                      ),
                                                            ),
                            ),
                            color: Colors.white.withOpacity(0.8),
                          )
                        : Container(),
                  ),

      ],

    ),
    );
  }
}

Widget fullimg(BuildContext context,DocumentSnapshot document)
  {
     return new Scaffold(
       appBar: AppBar(
        centerTitle: true,
        title: Text("Your Pic of problem "),
        ),
        body: document['photoUrl'] != null
                    ? CachedNetworkImage(
                        placeholder: (context, url) => Container(
                          child: CircularProgressIndicator(
                            strokeWidth: 1.0,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.purpleAccent),
                          ),
                          height: double.infinity,
                        width: double.infinity,
                          padding: EdgeInsets.all(15.0),
                        ),
                        imageUrl: document['photoUrl'],
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        
                        alignment: Alignment.center,
                      )
                    : Icon(
                        Icons.account_circle,
                        size: 50.0,
                        color: Colors.grey,
                      ),
      
      );
  }


Widget buildItem(BuildContext context, DocumentSnapshot document) {
      return Container(
        color: Colors.white10,
        child: new InkWell(
           onTap: () {},
          child: FlatButton(
          child: Row(
            children: <Widget>[
              Material(
                child: new InkWell(
                onTap: () {
                  Navigator.push(
                 context,
                 MaterialPageRoute(builder: (context) => fullimg(context  ,document)),
                  );
                },
                child: document['photoUrl'] != null
                    ? CachedNetworkImage(
                        placeholder: (context, url) => Container(
                          child: CircularProgressIndicator(
                            strokeWidth: 1.0,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.purpleAccent),
                          ),
                          width: 50.0,
                          height: 50.0,
                          padding: EdgeInsets.all(15.0),
                        ),
                        imageUrl: document['photoUrl'],
                        width: 50.0,
                        height: 50.0,
                        fit: BoxFit.cover,
                      )
                    : Icon(
                        Icons.account_circle,
                        size: 50.0,
                        color: Colors.grey,
                      ),
                borderRadius: BorderRadius.all(Radius.circular(25.0)),
                ),
                clipBehavior: Clip.hardEdge,
              ),
              Flexible(
                child: Container(
                  child: Column(
                    children: <Widget>[
                      Container(
                        child: Text(
                          'Name: ${document['Name']}',
                          style: TextStyle(color: Colors.black),
                        ),
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                      ),
                      Container(
                        child: Text(
                          'Problem: ${document['problem_description']}',
                          style: TextStyle(color: Colors.brown),
                        ),
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                      ),
                      Container(
                        child: Text(
                          'Phone no.: ${document['phone'] ?? 'Not available'}',
                          style: TextStyle(color: Colors.brown),
                        ),
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                      )
                    ],
                  ),
                  margin: EdgeInsets.only(left: 20.0),
                ),
              ),
            ],
          ),
         
          color: Colors.lightBlue,
          padding: EdgeInsets.fromLTRB(25.0, 10.0, 25.0, 10.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        ),
      ),
      margin: EdgeInsets.only(bottom: 10.0, left: 5.0, right: 5.0),
      );  
}