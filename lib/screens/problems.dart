import 'package:av_fighters/screens/problem_seting.dart';
import 'package:av_fighters/screens/profile_setting.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';

//import 'package:url_launcher/url_launcher.dart';


class problemScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return FormScreenState();
  }
}

String address = '';
String email = '';
String pin = '';

class FormScreenState extends State<problemScreen> {
  
  bool isLoading = false;
  bool updated = false;
  bool notshown = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();


  
  TextEditingController controllerName;
  TextEditingController controllerphone;
  TextEditingController controllerfield;
  TextEditingController controllerPin ;

  SharedPreferences prefs;

  String id = '';
  String idv = '';
  String photoUrl = '';

  /////
  String phone = '';
  String name = '';
  //String field = '';
  
  String selectedbutton;
  String pdescription = '';
  Iterable<String> userdocid ;
  Iterable<String> userdocidv ;
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
      photoUrl = documents[0]['photoUrl'];
      pin = documents[0]['pincode'];

      if(phone==null||name==null||pin==null)
        updated = true;
      

      controllerName = new TextEditingController(text: name);
      controllerphone = new TextEditingController(text: phone);
      controllerPin = new TextEditingController(text: pin);
      }

      QuerySnapshot result1 =
        await Firestore.instance.collection('registered_problem').where('email', isEqualTo: currentUser.email).getDocuments();
      documents = result1.documents;
      if(documents.length == 0)
      {
        notshown = true;
      }
      else{
        final userdocidv=result1.documents.map((doc)=>doc.documentID);
      print(userdocidv);
      idv= userdocidv.first.toString();
      print(idv);
      }

      print(notshown);

    // Force refresh input
    setState(() {});
  }

    Widget _buildAddress() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Current Pincode'),
      keyboardType: TextInputType.emailAddress,
      validator: (String value) {
        if (value.isEmpty) {
          return 'pincode is Required';
        }

        if(value.length!=6)
         return 'pincode must be of 6 digits';

        return null;
      },
      onSaved: (String value) {
        address = value;
      },
    );
  }
 
  Widget _problemdescription() {
    return TextFormField(
      decoration: new InputDecoration(
                        labelText: "Your problem Description",
                        fillColor: Colors.white,
                        border: new OutlineInputBorder(
                          borderRadius: new BorderRadius.circular(25.0),
                          borderSide: new BorderSide(
                          ),
                        ),
      ),
      keyboardType: TextInputType.multiline,
      maxLines: null,
      validator: (String value) {
        if (value.isEmpty) {
          return 'descriptin is Required';
        }

        return null;
      },
      onSaved: (String value) {
        pdescription = value;
      },
    );
  }


  Widget _buildList(){
    return Center(
              child:  DropdownButton<String>(
            hint:  Text("Your Problem Type", style: TextStyle(color: Colors.deepPurple),),
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
     
    Firestore.instance.collection('registered_problem').document().setData({
          'Name': name,
          'address': address,
          'phone': phone,
          'email': email,
          'photoUrl':photoUrl,
          //'Father\'s Name': fathernameController.text,
          'pincode': pin,
          'problem_description': pdescription,
          'problem_area': selectedbutton,
        }).then((data) async{ 
           setState(() {
              isLoading = false;
            });
          Fluttertoast.showToast(msg: "Thank you for Registering");
          Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoadFirbaseStorageImage()),
                  );
        }).catchError((err) {
      setState(() {
        isLoading = false;
      });

      Fluttertoast.showToast(msg: err.toString());
      print(err.toString());
    });
      print("uploaded");
  }

     Future<void> _showChoiceDialog(BuildContext context){
    return showDialog(context: context,builder: (BuildContext context){
        return AlertDialog(
          title: Text("No problem Registered"),
          content: SingleChildScrollView(
            child: ListBody(children: <Widget>[
            ],),
          )
        ) ;   
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(title: Text("Your Problems") , centerTitle: true, backgroundColor: Colors.deepPurple),
      body:  Stack(
      children: <Widget>[
    
      Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/problem.jpeg"),
            fit: BoxFit.fill,
          ),
        ),
      ),
      Container(
          color: Color.fromRGBO(255, 255, 255, 0.85),
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
              SizedBox(height: 50),
              _problemdescription(),
              SizedBox(height: 50),
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
              ), 
              RaisedButton(
                child: Text(
                  'Reset your problems',
                  style: TextStyle(color: Colors.blue, fontSize: 16),
                ),
                onPressed: () {
                    if(notshown==false){
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProblemStorageImage()),
                        );
                   }
                   else{
                     _showChoiceDialog(context);
                   }
                },
              ),
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

/* _launchURL(String toMailId, String subject, String body) async {
    var url = 'mailto:$toMailId?subject=$subject&body=$body';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }*/

class LoadFirbaseStorageImage extends StatefulWidget {
  @override
  _LoadFirbaseStorageImageState createState() =>
      _LoadFirbaseStorageImageState();
}

class _LoadFirbaseStorageImageState extends State<LoadFirbaseStorageImage> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
    appBar: new AppBar(
      title: new Text("Volunteers in Your Region wise" , ),
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
      stream: Firestore.instance.collection("volunteer_data").where('pincode', isEqualTo: address).where('field',isEqualTo: "Yes").snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) return const Text('Connecting...');
        return ListView.builder(
          padding: EdgeInsets.all(10.0),
          itemBuilder: (context, index) => buildItem(context, snapshot.data.documents[index]),
          itemCount: snapshot.data.documents.length,
        );
      },
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
                      /*Container(
                        child: Text(
                          'Address: ${document['address']}',
                          style: TextStyle(color: Colors.brown),
                        ),
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                      ),*/
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

class ProblemStorageImage extends StatefulWidget {
  @override
  _LoadFirbaseStorageImageStates createState() =>
      _LoadFirbaseStorageImageStates();
}



class _LoadFirbaseStorageImageStates extends State<ProblemStorageImage> {

 // String email;

  /* @override
  void initState() {
    super.initState();
    readLocal();
  }
  
  FirebaseAuth _auth = FirebaseAuth.instance;
  
  void readLocal() async {
///////////////
    final FirebaseUser currentUser = await _auth.currentUser();
    print(currentUser.email);
    email = currentUser.email;
    print(email);

  }*/

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
    appBar: new AppBar(
      title: new Text("Your Problems" , ),
      backgroundColor: Colors.white12,
      centerTitle: true,
    ),
    backgroundColor: Colors.orangeAccent,
    
    body: Stack(
      children: <Widget>[

        Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/problem.jpeg"),
            fit: BoxFit.fill,
          ),
        ),
      ),
      Container(
          color: Color.fromRGBO(255, 255, 255, 0.6),
        ),

    new StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection("registered_problem").where('email', isEqualTo: email).snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) return const Text('connecting..',style: TextStyle(color:Colors.red),);
        return ListView.builder(
          padding: EdgeInsets.all(10.0),
          itemBuilder: (context, index) => buildItems(context, snapshot.data.documents[index]),
          itemCount: snapshot.data.documents.length,
        ); 
      },
    ),   

      ],
    ),
    );
  }
}


Widget fullimgs(BuildContext context,DocumentSnapshot document)
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


Widget buildItems(BuildContext context, DocumentSnapshot document) {
      return Container(
        color: Colors.white10,
        child: new InkWell(
           onTap: () {
             Navigator.push(
                 context,
                 MaterialPageRoute(builder: (context) => PSettings(documents: document,)),
             );
           },
          child: FlatButton(
          child: Row(
            children: <Widget>[
              Material(
                child: new InkWell(
                onTap: () {
                  Navigator.push(
                 context,
                 MaterialPageRoute(builder: (context) => fullimgs(context, document)),
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
                          'Problem description: ${document['problem_description']}',
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