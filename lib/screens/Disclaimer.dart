import 'package:flutter/material.dart';

class Disclaimer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white), // Sets drawer icon color to white
        backgroundColor: Color(0xFF212121), // Set the background color for the area
        title: Text('Disclaimer', style: TextStyle(color: Colors.white),),
      ),
      body: Container(
        color: Color(0xFF212121), // Set the background color for the area
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "This app is powered by the Gemini API. Responses are AI-generated and may not always be accurate or reliable.",
                  style: TextStyle(
                    color: Color(0xffea80fc),
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Text(
                  "Always verify critical information.",
                  style: TextStyle(
                    color: Color(0xffea80fc),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
