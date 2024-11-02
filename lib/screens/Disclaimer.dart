import 'package:flutter/material.dart';
class Disclaimer extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About Us'),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "We do not affiliate with any content providers",
                style: TextStyle(
                  color: Colors.purple,
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Text(
                "We are the content providers.",
                style: TextStyle(
                    color: Colors.purple,
                    fontSize: 16,
                    fontWeight: FontWeight.bold
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
