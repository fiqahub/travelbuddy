import 'package:flutter/material.dart';
import 'destination.dart';
import 'weather.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Travelbuddy'),
      ),
      body: Container(
        color: Colors.red[400],
        child: Center(
          child: Text(
            'Welcome to the Travel Buddy!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => WeatherPage()),
              );
            },
            child: Icon(Icons.pageview),
          ),
          SizedBox(width: 16),
          FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DestinationSearchScreen()),
              );
            },
            child: Icon(Icons.pages),
          ),
        ],
      ),
    );
  }
}
