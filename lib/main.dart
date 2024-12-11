import 'package:flutter/material.dart';
import 'pages/home_screen.dart';
import 'pages/login_screen.dart';
import 'pages/renew_membership_screen.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gym Management',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),
        '/renew': (context) => RenewMembershipScreen(),
      },
    );
  }
}
