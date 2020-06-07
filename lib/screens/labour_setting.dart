import 'dart:async';
import 'dart:io';
import 'package:av_fighters/screens/personal_problem.dart';
import 'package:path/path.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Settings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(
          'Your skills details',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: new SettingsScreen(),
    );
  }
}

class SettingsScreen extends StatefulWidget {

  @override
  State createState() => new SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {

 
  TextEditingController controlleraddress;
  TextEditingController controllerbutton;
  TextEditingController controllerdescription;

  SharedPreferences prefs;

  String id = '';
  String nickname = '';
  String aboutMe = '';
  String photoUrl = '';

  /////
  String phone = '';
  String name = '';
  //String field = '';
  String pin = '';
  String selectedbutton;
  String pdescription='';
  String address = '';
  Iterable<String> userdocid ;
  /////

  bool isLoading = false;
  bool taken = false;
  bool delete = false;
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
    prefs = await SharedPreferences.getInstance();
    final QuerySnapshot result =
        await Firestore.instance.collection('skilled_labour').where('email', isEqualTo: currentUser.email).getDocuments();
      final List<DocumentSnapshot> documents = result.documents;

      if(documents.length==0){
        print(delete);
        if(delete == false)
           taken =true;
        else{
          address = '';
          selectedbutton = '';
          pdescription = '';
        }
      }else{
      final userdocid=result.documents.map((doc)=>doc.documentID);
      print(userdocid);
      id = userdocid.first.toString();
      print(id);
      }

      if (documents.length > 0) {
      address = documents[0]['address'];
      selectedbutton = documents[0]['field'];
      //photoUrl = documents[0]['photoUrl'];
      pdescription = documents[0]['problem_description'];
      //field = documents[0]['field'];

      print(selectedbutton);

      //controllerfield  = new TextEditingController(text: field);
      }
      controlleraddress = new TextEditingController(text: address);
      controllerdescription = new TextEditingController(text: pdescription);
      controllerbutton = new TextEditingController(text: selectedbutton);

    setState(() {});
  }


  void handleDeleteData() {
    setState(() {
      isLoading = true;
    });

    print(userdocid.toString());
    print(id);
    Firestore.instance
        .collection('skilled_labour')
        .document(id)
        .delete().then((data) async {
      
      setState(() {
        delete = true;
        isLoading = false;
      });
      readLocal();

      Fluttertoast.showToast(msg: "Delete success");
    }).catchError((err) {
      setState(() {
        isLoading = false;
      });

      Fluttertoast.showToast(msg: err.toString());
      print(err.toString());
    });
  }

    void handleUpdateData() {

    focusNodeNickname.unfocus();
    focusNodeAboutMe.unfocus();

    setState(() {
      isLoading = true;
    });

    print(userdocid.toString());
    print(id);
    Firestore.instance
        .collection('skilled_labour')
        .document(id)
        .updateData({'problem_description':pdescription, 'field': selectedbutton , 'address':address}).then((data) async {

      setState(() {
        isLoading = false;
      });

      Fluttertoast.showToast(msg: "Update success");
    }).catchError((err) {
      setState(() {
        isLoading = false;
      });

      Fluttertoast.showToast(msg: err.toString());
      print(err.toString());
    });
  }


  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Widget _problemdescriptrion() {
    return TextFormField(
      decoration: new InputDecoration(
                        labelText: "Your skills Description",
                        fillColor: Colors.white,
                        border: new OutlineInputBorder(
                          borderRadius: new BorderRadius.circular(25.0),
                          borderSide: new BorderSide(
                          ),
                        ),
      ),
      keyboardType: TextInputType.multiline,
      maxLines: null,
      controller: controllerdescription,
      validator: (String value) {
        if (value.isEmpty) {
          return 'description is Required';
        }

        return null;
      },
      onSaved: (String value) {
        pdescription = value;
      },
    );
  }

    Widget _buildPin() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Current pin'),
      keyboardType: TextInputType.number,
      controller: controlleraddress,
      validator: (String value) {
        if (value.isEmpty) {
          return 'Pincode is Required';
        }

        if (value.length!=6) {
          return 'Please enter a valid pincode';
        }
        
        return null;
      },
      onSaved: (String value) {
        address = value;
      },
    );
  }

  Widget _buildList(){
    return Center(
              child:  DropdownButton<String>(
            hint:  Text("Change in volunteer settings", style: TextStyle(color: Colors.deepPurple),),
            value: selectedbutton,
            onChanged: (String value) {
              setState(() {
                selectedbutton = value;
              });
            },
                    items: [ 

                  DropdownMenuItem<String>(
                    value: '',
                    child: Text(
                      "Select your skills",
                       style: TextStyle(color:Colors.red),
                    ),
                  ),
                  DropdownMenuItem<String>(
                    value: "Electricity",
                    child: Text(
                      "Electricity departemet",
                    ),
                  ),

                  DropdownMenuItem<String>(
                    value: "Drainage",
                    child: Text(
                      "Drainage department",
                    ),
                  ),

                  DropdownMenuItem<String>(
                    value: "Buliding",
                    child: Text(
                      "Buliding COnstruction",
                    ),
                  ),

                  DropdownMenuItem<String>(
                    value: "Carpenter",
                    child: Text(
                      "Carpenter",
                    ),
                  )
                ],
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return  Stack(
      children: <Widget>[
        SingleChildScrollView(
          child: Column(
            children: <Widget>[
              // Input
              Column(
                children: <Widget>[
                  // Username
                      Container(
                      margin: EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(height: 100),
                            _buildList(),
                            SizedBox(height: 30),
                            _problemdescriptrion(),
                            SizedBox(height: 30),
                            _buildPin(),
                            //_buildPhoneNumber(),
                            //_buildCalories(),
                            SizedBox(height: 100),
                            RaisedButton(
                              child: Text(
                                'UPDATE',
                                style: TextStyle(color: Colors.white, fontSize: 16),
                              ),
                              color: Colors.deepPurple,
                              onPressed: () {
                                if (!_formKey.currentState.validate()) {
                                  return;
                                }

                                _formKey.currentState.save();

                                handleUpdateData();

                        },
                      ),
                        
                      RaisedButton(
                              child: Text(
                                'DELETE',
                                style: TextStyle(color: Colors.white, fontSize: 16),
                              ),
                              color: Colors.red,
                              onPressed: () {

                                handleDeleteData();

                        },
                      )

                    ],
                  ),
                ),
              ),
                        ],
                crossAxisAlignment: CrossAxisAlignment.start,
              ),

              // Button
              /*Container(
                child: FlatButton(
                  onPressed: handleUpdateData,
                  child: Text(
                    'UPDATE',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  color: Colors.deepPurple,
                  highlightColor: new Color(0xff8d93a0),
                  splashColor: Colors.transparent,
                  textColor: Colors.white,
                  padding: EdgeInsets.fromLTRB(30.0, 10.0, 30.0, 10.0),
                ),
                margin: EdgeInsets.only(top: 50.0, bottom: 50.0),
              )*/
            ],
          ),
          padding: EdgeInsets.only(left: 15.0, right: 15.0),
        ),

        // Loading
        Positioned(
          child: isLoading
              ? Container(
                  child: Center(
                    child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.grey)),
                  ),
                  color: Colors.white.withOpacity(0.8),
                )
              : Container(),
        ),

        Positioned(
                    child: taken
                        ? Container(
                            child: Center(
                              child: AlertDialog(
                                      title: Text('Firstly specify your skills',
                                      style: TextStyle(color:Colors.blue)),
                                      content: SingleChildScrollView(
                                        child: ListBody(
                                          children: <Widget>[
                                            GestureDetector(
                                                child: Text("",style: TextStyle(color:Colors.blue),),
                                                onTap: (){
                                                  
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
    );
  }
}
