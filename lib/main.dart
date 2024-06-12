import 'package:flutter/material.dart';
import 'login_page.dart';
import 'home_page.dart';
import 'delivery_form_page.dart';  // Import the DeliveryFormPage

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Login Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
      routes: {
        HomePage.routeName: (context) => HomePage(),
        DeliveryFormPage.routeName: (context) => DeliveryFormPage(), // Added route for DeliveryFormPage
      },
    );
  }
}
