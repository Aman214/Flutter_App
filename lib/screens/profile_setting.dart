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

class Pettings extends StatelessWidget {
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
}

class SettingsScreen extends StatefulWidget {
  @override
  State createState() => new SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
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
  //String field = '';
  String pin = '';
  Iterable<String> userdocid ;
  Iterable<String> userdocidv ;
  Iterable<String> userdocids ;
  List<String> lidv = [];
  List<String> lids = [];
  /////

  bool isLoading = false;
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
        Firestore.instance.collection('volunteer_data').document().setData({
          'email': email
        });
      }
      result =
          await Firestore.instance.collection('volunteer_data').where('email', isEqualTo: currentUser.email).getDocuments();
        documents = result.documents;

      final userdocid=result.documents.map((doc)=>doc.documentID);
      print(userdocid);
      id = userdocid.first.toString();
      print(id);

      if (documents.length > 0) {
      phone = documents[0]['phone'];
      name = documents[0]['Name'];
      photoUrl = documents[0]['photoUrl'];
      pin = documents[0]['pincode'];
      //field = documents[0]['field'];

      if(photoUrl==null)
       photoUrl = '';

      controllerName = new TextEditingController(text: name);
      controllerphone = new TextEditingController(text: phone);
      controllerPin = new TextEditingController(text: pin);
      //controllerfield  = new TextEditingController(text: field);
      }

      QuerySnapshot result1 =
          await Firestore.instance.collection('registered_problem').where('email', isEqualTo: currentUser.email).getDocuments();
        documents = result1.documents;

        if(documents.length >0){

      final userdocidv=result1.documents.map((doc)=>doc.documentID);
      print(userdocidv);
      lidv = userdocidv.toList();
      idv = lidv[0];
      print(idv);
        }

      QuerySnapshot result2 =
          await Firestore.instance.collection('skilled_labour').where('email', isEqualTo: currentUser.email).getDocuments();
        documents = result2.documents;
       
       if(documents.length>0){
      final userdocids=result2.documents.map((doc)=>doc.documentID);
      print(userdocids);
      lids = userdocids.toList();
      ids = userdocids.first.toString();
      print(ids);
       }
/////////////
    
     
    
    //id = prefs.getString('id') ?? '';
    nickname = prefs.getString('nickname') ?? '';
    aboutMe = prefs.getString('aboutMe') ?? '';
    //photoUrl = prefs.getString('photoUrl') ?? '';

    controllerNickname = new TextEditingController(text: nickname);
    controllerAboutMe = new TextEditingController(text: aboutMe);

    // Force refresh input
    setState(() {});
  }

  Future getImage() async {
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        avatarImageFile = image;
        isLoading = true;
      });
    }
    uploadFile();
  }

  Future uploadFile() async {
    String fileName = basename(avatarImageFile.path);
    StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = reference.putFile(avatarImageFile);
    StorageTaskSnapshot storageTaskSnapshot;
    uploadTask.onComplete.then((value) {
      if (value.error == null) {
        storageTaskSnapshot = value;
        storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
          photoUrl = downloadUrl;
          Firestore.instance
              .collection('volunteer_data')
              .document(id)
              .updateData({'pincode': pin, 'Name': name,'email':email, 'photoUrl': photoUrl, 'phone': phone}).then((data) async {
            await prefs.setString('photoUrl', photoUrl);
            setState(() {
              isLoading = false;
            });
            Fluttertoast.showToast(msg: "Photo updated,Please click on Update button");
          }).catchError((err) {
            setState(() {
              isLoading = false;
            });
            Fluttertoast.showToast(msg: err.toString());
          });
        }, onError: (err) {
          setState(() {
            isLoading = false;
          });
          Fluttertoast.showToast(msg: 'This file is not an image');
        });
      } else {
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(msg: 'This file is not an image');
      }
    }, onError: (err) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: err.toString());
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

    if(ids!=''){
      for(var i=0; i<lids.length ; i++){
      Firestore.instance
        .collection('skilled_labour')
        .document(lids[i])
        .updateData({'pincode': pin, 'Name': name, 'email':email, 'phone': phone,'photoUrl':photoUrl});
      }
    }

    if(idv!=''){

      for(var i=0; i<lidv.length ; i++){
      Firestore.instance
        .collection('registered_problem')
        .document(lidv[i])
        .updateData({'pincode': pin, 'Name': name, 'email':email, 'phone': phone , 'photoUrl': photoUrl});
      }
    }

    Firestore.instance
        .collection('volunteer_data')
        .document(id)
        .updateData({'pincode': pin, 'Name': name, 'email':email, 'phone': phone}).then((data) async {/////////////////////////////

      await prefs.setString('nickname', nickname);
      await prefs.setString('aboutMe', aboutMe);
      await prefs.setString('photoUrl', photoUrl);

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

  void handleDeleteData(BuildContext context) {
    setState(() {
      isLoading = true;
    });

    print(userdocid.toString());
    print(id);

    if(idv!=''){

      for(var i=0; i<lidv.length ; i++){
    Firestore.instance
        .collection('registered_problem')
        .document(lidv[i]).delete();
      }
    }

    if(ids!=''){
      for(var i=0; i<lids.length ; i++){
    Firestore.instance
        .collection('skilled_labour')
        .document(lids[i]).delete();
      }
    }

    Firestore.instance
        .collection('volunteer_data')
        .document(id)
        .delete().then((data) async {

      setState(() {
        isLoading = false;
      });

      Fluttertoast.showToast(msg: "Delete success");
    }).catchError((err) {
      setState(() {
        isLoading = false;
      });

      Fluttertoast.showToast(msg: err.toString());
      print(err.toString());
    });
  }


  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Widget _buildName() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Name'),
      //maxLength: 10,
      controller: controllerName,
      validator: (String value) {
        if (value.isEmpty) {
          return 'Name is Required';
        }

        return null;
      },
      onSaved: (String value) {
        name = value;
      },
    );
  }

    Widget _buildPin() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Pin code'),
      keyboardType: TextInputType.number,
      controller: controllerPin,
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
        pin = value;
      },
    );
  }

    Widget _buildPhone() {
    return TextFormField(
      decoration: InputDecoration(
       labelText: 'Phone',
       hintStyle: TextStyle(color: Colors.deepPurple),
       ),
      keyboardType: TextInputType.phone,
      controller: controllerphone,
      validator: (String value) {
        if (value.isEmpty) {
          return 'phone number is Required';
        }
        if (value.length!=10) {
          return 'Please enter a valid phone number';
        }


        return null;
      },
      onSaved: (String value) {
        phone = value;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        SingleChildScrollView(
          child: Column(
            children: <Widget>[
              // Avatar
              Container(
                child: Center(
                  child: Stack(
                    children: <Widget>[
                      (avatarImageFile == null)
                          ? (photoUrl != ''
                              ? Material(
                                  child: CachedNetworkImage(
                                    placeholder: (context, url) => Container(
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.0,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                                          ),
                                          width: 90.0,
                                          height: 90.0,
                                          padding: EdgeInsets.all(20.0),
                                        ),
                                    imageUrl: photoUrl,
                                    width: 90.0,
                                    height: 90.0,
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: BorderRadius.all(Radius.circular(45.0)),
                                  clipBehavior: Clip.hardEdge,
                                )
                              : Icon(
                                  Icons.account_circle,
                                  size: 90.0,
                                  color: Colors.grey,
                                ))
                          : Material(
                              child: Image.file(
                                avatarImageFile,
                                width: 90.0,
                                height: 90.0,
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.all(Radius.circular(45.0)),
                              clipBehavior: Clip.hardEdge,
                            ),
                      IconButton(
                        icon: Icon(
                          Icons.camera_alt,
                          color: Colors.grey.withOpacity(0.5),
                        ),
                        onPressed: getImage,
                        padding: EdgeInsets.all(30.0),
                        splashColor: Colors.transparent,
                        highlightColor: Colors.grey,
                        iconSize: 30.0,
                      ),
                    ],
                  ),
                ),
                width: double.infinity,
                margin: EdgeInsets.all(20.0),
              ),

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
                            _buildName(),
                            _buildPhone(),
                            _buildPin(),
                            //_builURL(),
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
                                
                                setState(() {
                                  updated = true;
                                });
                                //handleDeleteData();

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
                    child: updated
                        ? Container(
                            child: Center(
                              child: AlertDialog(
                                      title: Text('!Warning it will delete all your data related to app !',
                                       style: TextStyle(color:Colors.red)),
                                      content: SingleChildScrollView(
                                        child: ListBody(
                                          children: <Widget>[
                                            GestureDetector(
                                                child: Text("DELETE",style: TextStyle(color:Colors.blue),textAlign: TextAlign.right,),
                                                onTap: (){
                                                 handleDeleteData(context);
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
