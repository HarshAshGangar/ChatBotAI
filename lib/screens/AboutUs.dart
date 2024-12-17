import 'package:flutter/material.dart';

class AboutUs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white), // Sets drawer icon color to white
        backgroundColor: Color(0xFF212121), // Set the background color for the area
        title: Text('About Us', style: TextStyle(color: Colors.white),),
      ),
      body: Container(
        color: Color(0xFF212121), // Set the background color for the area
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Text(
              "This app is powered by the Gemini API to provide AI-generated responses. Built with a focus on innovation and usability.",
              style: TextStyle(
                color: Color(0xffea80fc),
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
