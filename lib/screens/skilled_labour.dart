
import 'package:av_fighters/screens/profile_setting.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'labour_setting.dart';


class skillsScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return FormScreenState();
  }
}

class FormScreenState extends State<skillsScreen> {
  
  bool isLoading = false;
  bool updated = false;
  bool taken = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();


  
  TextEditingController controllerName;
  TextEditingController controllerphone;
  TextEditingController controllerfield;
  TextEditingController controllerPin ;

  SharedPreferences prefs;

  String id = '';
  String ids = '';
  String photoUrl = '';
  String email = '';

  /////
  String phone = '';
  String address = '';
  String name = '';
  String field = '';
  String pin = '';
  String selectedbutton;
  String pdescription = '';
  Iterable<String> userdocid ;
  Iterable<String> userdocids ;
  /////


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
        updated = true;
        //taken = 
      }
      else{
      result =
          await Firestore.instance.collection('volunteer_data').where('email', isEqualTo: currentUser.email).getDocuments();
        documents = result.documents;
      final userdocid=result.documents.map((doc)=>doc.documentID);
      print(userdocid);
      id = userdocid.first.toString();
      print(id);
      }
      print(updated);
      if (documents.length > 0) {
      phone = documents[0]['phone'];
      name = documents[0]['Name'];
      photoUrl = documents[0]['photoUrl'];
      pin = documents[0]['pincode'];
      field = documents[0]['field'];

      if(phone==null||name==null||pin==null)
        updated = true;

      controllerName = new TextEditingController(text: name);
      controllerphone = new TextEditingController(text: phone);
      controllerPin = new TextEditingController(text: pin);
      }

      QuerySnapshot result1 =
          await Firestore.instance.collection('skilled_labour').where('email', isEqualTo: currentUser.email).getDocuments();
        documents = result1.documents;
       if(documents.length>0)
         taken =true;
      final userdocids=result.documents.map((doc)=>doc.documentID);
      print(userdocids);
      ids = userdocids.first.toString();
      print(ids);

    // Force refresh input
    setState(() {});
  }

    Widget _buildAddress() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Current Pin'),
      keyboardType: TextInputType.emailAddress,
      validator: (String value) {
        if (value.isEmpty) {
          return 'pincode is Required';
        }

        if(value.length!=6)
         return 'pincode must be 6 digit long';

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
            hint:  Text("What Skills do you have", style: TextStyle(color: Colors.deepPurple),),
            value: selectedbutton,
            onChanged: (String value) {
              setState(() {
                selectedbutton = value;
              });
            },
                    items: [
                    
                  DropdownMenuItem<String>(
                    value: "Electricity",
                    child: Text(
                      "Electricity Department",
                    ),
                  ),

                  DropdownMenuItem<String>(
                    value: "Drainage",
                    child: Text(
                      "Drainage System",
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
                  ),
                ],
          ),
        );
  }

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
      //controller: controllerdescription,
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



  storeData(BuildContext context) async{

     setState(() {
      isLoading = true;
    });
     
    Firestore.instance.collection('skilled_labour').document().setData({
          'Name': name,
          'address': address,
          'phone': phone,
          'photoUrl' : photoUrl,
          'email': email,
          'pincode': pin,
          'field': selectedbutton,
          'problem_description': pdescription,
        }).then((data) async{ 
           setState(() {
              isLoading = false;
            });
          Fluttertoast.showToast(msg: "Thank you for Registering");
        }).catchError((err) {
      setState(() {
        isLoading = false;
      });

      Fluttertoast.showToast(msg: err.toString());
      print(err.toString());
    });
      print("uploaded");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(title: Text("Your Skills") , centerTitle: true, backgroundColor: Colors.deepPurple),
      body:  Stack(
      children: <Widget>[
    
      Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/volunteer1.jpeg"),
            fit: BoxFit.fill,
          ),
        ),
      ),
      Container(
          color: Color.fromRGBO(255, 255, 255, 0.65),
        ),

      Container(
        margin: EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              //_buildName(),
              //_buildPhone(),
              //_buildPin(),
              _buildList(),
              SizedBox(height: 30),
              _problemdescriptrion(),
              SizedBox(height: 30),
              _buildAddress(),
              //_buildPhoneNumber(),
              //_buildCalories(),
              SizedBox(height: 100),
              RaisedButton(
                child: Text(
                  'Submit',
                  style: TextStyle(color: Colors.blue, fontSize: 16),
                ),
                onPressed: () {
                  if (!_formKey.currentState.validate()) {
                    return;
                  }

                  _formKey.currentState.save();

                  storeData(context);
                  //Send to API
                },
              )
            ],
          ),
        ),
      ),

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
                                      title: Text('Update Profile first'),
                                      content: SingleChildScrollView(
                                        child: ListBody(
                                          children: <Widget>[
                                            GestureDetector(
                                                child: Text("UPDATE",style: TextStyle(color:Colors.blue),),
                                                onTap: (){
                                                  Navigator.push(
                                                context,
                                                MaterialPageRoute(builder: (context) => Pettings()),
                                                  );
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

                  Positioned(
                    child: taken
                        ? Container(
                            child: Center(
                              child: AlertDialog(
                                      title: Text('You have already registered your skills ,to change go to settings',
                                      style: TextStyle(color:Colors.black)),
                                      content: SingleChildScrollView(
                                        child: ListBody(
                                          children: <Widget>[
                                            GestureDetector(
                                                child: Text("Click",style: TextStyle(color:Colors.blue),textAlign: TextAlign.right,),
                                                onTap: (){
                                                   Navigator.push(
                                                context,
                                                MaterialPageRoute(builder: (context) => Settings()),
                                                  );
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