import 'package:fit_post/ui/places_screen.dart';
import 'package:flutter/material.dart';
// import 'ui/post_screen.dart';
import 'ui/post_screen.dart';
import 'ui/location_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        primarySwatch: Colors.blue,
      ),
      initialRoute: "/",
      routes: {
        "/": (context) => PostForm(),
        "/second": (context) => PlacesScreen(),
        // "/": (context) => TestForm(),
        // "/": (context) => LocationForm(),
        // "/": (context) => PlacesScreen(),
      },
    );
  }
}