import 'package:flutter/material.dart';
//import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Item {
  const Item(this.name);
  final String name;
  //final Icon icon;
}
class DropdownScreen extends StatefulWidget {
  State createState() =>  DropdownScreenState();
}
Item selectedUser = Item('None');
String selectedbutton ;
TextEditingController pincodeController= TextEditingController(text: "12345");
class DropdownScreenState extends State<DropdownScreen> {
  
  List<Item> users = <Item>[
    Item('Android'),
    Item('Flutter'),
    Item('ReactNative'),
    Item('iOS'),
  ];

  
  
  bool validate_pc = false;
  //SharedPreferences prefs;

  storeData(BuildContext context) async{
    print("inside data");
    //prefs = await SharedPreferences.getInstance();
    //prefs.setString('field', selectedUser.name);
    //prefs.setString('postalcode', pincodeController.text);
  }

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.title;
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      home:  Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.deepPurple,
          title: Text(
            'Search Skilled labour',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
        ),
        body: Padding(
        padding: EdgeInsets.only(top: 200.0, ),
        child: ListView(
          children: <Widget>[
           Center(
              child:  DropdownButton<String>(
            hint:  Text("Your problem area"),
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
        ),
        Center(
          child: Padding(
              padding: EdgeInsets.only(top: 20.0, left: 100.0, right: 100),
              child: TextField(
                controller: pincodeController,
                style: textStyle,
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  debugPrint('Something changed in pincode');
                  setState(() {
                      pincodeController.text.isEmpty
                        ? validate_pc = true
                        : validate_pc = false;
                  });
                },
                decoration: InputDecoration(
                    labelText: "Pincode",
                    labelStyle: textStyle,
                    
                    errorText:
                        validate_pc ? 'Value can\'nt be empty' : null,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0))),
              ),
            ),
        ),
        Center(
          child: Padding(
              padding: EdgeInsets.only(top: 20.0, left: 10.0, right: 10),
              child: Center(
                child: RaisedButton(
                      color: Theme.of(context).primaryColorDark,
                      textColor: Theme.of(context).primaryColorLight,
                      child: Text(
                        'Submit',
                        textScaleFactor: 1.5,
                      ),
                      onPressed: () {
                      storeData(context);
                       // Scaffold.of(context).showSnackBar(SnackBar(content: Text('Processing Data')));
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Displaypeople()),
                        );
                        
                      },
                    ),
              ),
            ),
        )
          ],
        ),
      ),
      ),
    );
  }
}


class Displaypeople extends StatefulWidget {
  @override
  _LoadFirbaseStorageImageState createState() =>
      _LoadFirbaseStorageImageState();
}

class _LoadFirbaseStorageImageState extends State<Displaypeople> {
 @override
  Widget build(BuildContext context) {
    return new Scaffold(
    appBar: new AppBar(
      backgroundColor: const Color(0xFF167F67),
      title: new Text("Region wise Labour list"),
      centerTitle: true,
    ),
    
    body: new StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection("skilled_labour").where( 'field', isEqualTo: selectedbutton).where('pincode',isEqualTo: pincodeController.text).snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) return const Text('Connecting...');
        final int cardLength = snapshot.data.documents.length;
        return ListView.builder(
          padding: EdgeInsets.all(10.0),
          itemBuilder: (context, index) => buildItem(context, snapshot.data.documents[index]),
          itemCount: snapshot.data.documents.length,
        ); 
      },
    ),
    );
  }
  
}


Widget fullimg(BuildContext context,DocumentSnapshot document)
  {
     return new Scaffold(
       appBar: AppBar(
         backgroundColor: const Color(0xFF167F67),
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
        
        child: new InkWell(
           onTap: () {
                },
        
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
                          style: TextStyle(color: Colors.grey),
                        ),
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                      ),
                      Container(
                        child: Text(
                          'Field of work: ${document['field']}',
                          style: TextStyle(color: Colors.grey),
                        ),
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                      ),
                      Container(
                        child: Text(
                          'Phone no.: ${document['phone'] ?? 'Not available'}',
                          style: TextStyle(color: Colors.grey),
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