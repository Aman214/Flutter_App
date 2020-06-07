import 'package:av_fighters/screens/personal_problem.dart';
import 'package:av_fighters/screens/profile_setting.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';


class Vsettings extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return FormScreenState();
  }
}

class FormScreenState extends State<Vsettings> {
  
  bool isLoading = false;
  bool updated = false;
  bool taken = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();


  
  TextEditingController controllerName;
  TextEditingController controllerphone;
  TextEditingController controllerfield;
  TextEditingController controllerbutton ;

  SharedPreferences prefs;

  String id = '';
  String photoUrl = '';
  String email = '';

  /////
  String phone = '';
  String address = '';
  String name = '';
  //String field = '';
  String pin = '';
  String field = '';
  String selectedbutton;
  Iterable<String> userdocid ;
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
      //photoUrl = documents[0]['photoUrl'];
      pin = documents[0]['pincode'];
      field = documents[0]['field'];
      selectedbutton = documents[0]['field'];

      if(phone==null||name==null||pin==null)
        updated = true;
      

      controllerName = new TextEditingController(text: name);
      controllerphone = new TextEditingController(text: phone);
      controllerbutton = new TextEditingController(text: selectedbutton);
      }

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
            hint:  Text("Change in volunteer settings", style: TextStyle(color: Colors.deepPurple),),
            value: selectedbutton,
            onChanged: (String value) {
              setState(() {
                selectedbutton = value;
              });
            },
                    items: [
                    
                  DropdownMenuItem<String>(
                    value: "Yes",
                    child: Text(
                      "Yes",
                    ),
                  ),

                  DropdownMenuItem<String>(
                    value: "No",
                    child: Text(
                      "No",
                    ),
                  ),
                ],
          ),
        );
  }




  storeData(BuildContext context) async{

     setState(() {
      isLoading = true;
    });
     
    Firestore.instance.collection('volunteer_data').document(id).updateData({
          'Name': name,
          'address': address,
          'phone': phone,
          //'Father\'s Name': fathernameController.text,
          'pincode': pin,
          'field': selectedbutton,
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
      appBar: AppBar(title: Text("Volunteer Settings") , centerTitle: true, backgroundColor: Colors.deepPurple),
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
              //_buildAddress(),
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
              ),

               RaisedButton(
                child: Text(
                  'Select No if you dont want to be volunteer',
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
                onPressed: () {
                  //Send to API
                },
              ),

              /*StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance.collection("volunteer_data").where('pincode', isEqualTo: address).snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) return const Text('Connecting...');

                return ListView.builder(
                  padding: EdgeInsets.all(10.0),
                  itemBuilder: (context, index) => buildItem(context, snapshot.data.documents[index]),
                  itemCount: snapshot.data.documents.length,
                ); 
              },
            ),*/
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

      ],
      ),
    );
  }
}

