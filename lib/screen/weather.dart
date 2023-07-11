import 'package:flutter/material.dart';
import 'weather_service.dart';
import 'login_screen.dart'; // Import the next page file
import 'destination.dart';

class WeatherPage extends StatefulWidget {
  @override
  _WeatherPageState createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final WeatherService weatherService = WeatherService();
  WeatherData? weatherData;
  bool isLoading = false;

  void fetchWeatherData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final data = await weatherService.getWeatherData(2.3113, 102.4309);
      print(data); // Add this line to print the weather data
      setState(() {
        weatherData = data;
        isLoading = false;
      });
    } catch (error, stackTrace) {
      setState(() {
        isLoading = false;
      });
      print('Error: $error');
      print('Stack Trace: $stackTrace');
    }
  }

  void navigateToNextPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DestinationSearchScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather Page'),
        backgroundColor: Colors.red[400],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: fetchWeatherData,
              child: Text('Get Weather'),
              style: ElevatedButton.styleFrom(
                primary: Colors.red[400],
              ),
            ),
            SizedBox(height: 16),
            if (isLoading)
              CircularProgressIndicator()
            else if (weatherData != null)
              Card(
                margin: EdgeInsets.all(16),
                color: Colors.red[400],
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'Location: ${weatherData!.location}',
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Temperature: ${weatherData!.temperature}',
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Description: ${weatherData!.description}',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              )
            else
              Text('Failed to fetch weather data'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: navigateToNextPage,
              child: Text('Next Page'),
              style: ElevatedButton.styleFrom(
                primary: Colors.red[400],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
