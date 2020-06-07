import 'package:av_fighters/screens/labour_setting.dart';
//import 'package:av_fighters/screens/p_setting_first.dart';
import 'package:av_fighters/screens/personal_problem.dart';
import 'package:av_fighters/screens/problem_area.dart';
import 'package:av_fighters/screens/problem_seting.dart';
import 'package:av_fighters/screens/problems.dart';
import 'package:av_fighters/screens/profile_setting.dart';
import 'package:av_fighters/screens/signup_screen.dart';
import 'package:av_fighters/screens/skilled_labour.dart';
import 'package:av_fighters/screens/volunteer_from.dart';
import 'package:av_fighters/screens/volunteer_setting.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GridDashboard extends StatelessWidget {
  Items item1 = new Items(
      title: "Volunteer",
      subtitle: "Volunteer Registration",
      functcall: "FormScreen",
      img: "assets/volunteer.jpeg");

  Items item2 = new Items(
    title: "Covid19 related Problems",
    subtitle: "Register Problems related to Covid19",
    functcall: "problemScreen",
    img: "assets/problem.jpeg",
  );
  Items item3 = new Items(
    title: "Profiles",
    subtitle: "Your profile",
    functcall: "Pettings",
    img: "assets/map.png",
  );
  Items item4 = new Items(
    title: "Skilled Labour",
    subtitle: "Register about your skills",
    functcall: "skillsScreen",
    img: "assets/skilled.jpeg",
  );
  Items item5 = new Items(
    title: "General Problems",
    subtitle: "skilled labour for you",
    functcall: "DropdownScreen",
    img: "assets/problem.jpeg",
  );
  Items item6 = new Items(
    title: "Settings",
    subtitle: "",
    functcall: "Settings",
    img: "assets/setting.png",
  );
  Items item7 = new Items(
    title: "Problem in Your area",
    subtitle: "This will show all problems in your area related to covid19",
    functcall: "SettingsScreen1",
    img: "assets/problem.jpeg",
  );


    Future<void> _showChoiceDialog(BuildContext context){
    return showDialog(context: context,builder: (BuildContext context){
        return AlertDialog(
          title: Text("Make a choice"),
          content: SingleChildScrollView(
            child: ListBody(children: <Widget>[
              GestureDetector(
                child: Text("Volunteer Settings",
                style: TextStyle(color:Colors.blue)),
                onTap: (){
                  print("volunteer clicked");
                  Navigator.push(
                 context,
                 MaterialPageRoute(builder: (context) => Vsettings()),
                  );
                },
              ),
              Padding(padding: EdgeInsets.all(8.0),),

              GestureDetector(
                child: Text("Skilled_labour Settings",
                style: TextStyle(color:Colors.blue)),
                onTap: (){
                  print("button clicked");
                  Navigator.push(
                 context,
                 MaterialPageRoute(builder: (context) => Settings()),
                  );
                },
              )
            ],),
          )
        ) ;   
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Items> myList = [item1, item2, item3, item4, item5, item6,item7];
    var color = 0xff453658;
    //var color = Colors.blueAccent[50];
    return Flexible(
      child: GridView.count(
          childAspectRatio: 1.0,
          padding: EdgeInsets.only(left: 16, right: 16),
          crossAxisCount: 2,
          crossAxisSpacing: 18,
          mainAxisSpacing: 18,
          children: myList.map((data) {
            return new InkWell(
                onTap: () {
                  if(data.functcall=="FormScreen"){
                Navigator.push(
                 context,
                 MaterialPageRoute(builder: (context) => FormScreen()),
                  );
                  }

                   if(data.functcall=="problemScreen"){
                Navigator.push(
                 context,
                 MaterialPageRoute(builder: (context) => problemScreen()),
                  );
                  }

                   if(data.functcall=="skillsScreen"){
                Navigator.push(
                 context,
                 MaterialPageRoute(builder: (context) => skillsScreen()),
                  );
                  }

                   if(data.functcall=="DropdownScreen"){
                Navigator.push(
                 context,
                 MaterialPageRoute(builder: (context) => DropdownScreen()),
                  );
                  }

                  if(data.functcall=="Settings"){
                    _showChoiceDialog(context);
                  }

                   if(data.functcall=="Pettings"){
                Navigator.push(
                 context,
                 MaterialPageRoute(builder: (context) => Pettings()),
                  );
                  }

                   if(data.functcall=="SettingsScreen1"){
                Navigator.push(
                 context,
                 MaterialPageRoute(builder: (context) => SettingsScreen1()),
                  );
                  }
                },
            child:Container(
              decoration: BoxDecoration(
                  color: Color(color), borderRadius: BorderRadius.circular(10)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    data.img,
                    width: 42,
                  ),
                  SizedBox(
                    height: 14,
                  ),
                  Text(
                    data.title,
                    style: GoogleFonts.openSans(
                        textStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Text(
                    data.subtitle,
                    style: GoogleFonts.openSans(
                        textStyle: TextStyle(
                            color: Colors.white38,
                            fontSize: 10,
                            fontWeight: FontWeight.w600)),
                  ),
                  SizedBox(
                    height: 14,
                  ),
                 /* Text(
                    data.event,
                    style: GoogleFonts.openSans(
                        textStyle: TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                  ),*/
                ],
              ),
            ),
            );
          }).toList()),
    );
  }
}

class Items {
  String title;
  String subtitle;
  String functcall;
  String img;
  Items({this.title, this.subtitle, this.functcall, this.img});
}
