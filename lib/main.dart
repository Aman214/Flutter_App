import 'package:av_fighters/home.dart';
import 'package:flutter/material.dart';
import 'package:av_fighters/screens/login_screen.dart';
import 'package:av_fighters/screens/signup_screen.dart';

import 'package:av_fighters/root_page.dart';
import 'package:av_fighters/auth.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Login UI',
      debugShowCheckedModeBanner: false,
      home: new RootPage(auth: new Auth()),
    );
  }
}
