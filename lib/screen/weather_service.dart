import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  static const String apiKey = '87f69531164c4d75bc381c412367b0ae'; // Replace with your OpenWeatherMap API key

  Future<WeatherData> getWeatherData(double latitude, double longitude) async {
    final apiKey = '87f69531164c4d75bc381c412367b0ae'; // Replace with your OpenWeatherMap API key
    final latitude = 2.3113; // Replace with your desired latitude
    final longitude = 102.4309; // Replace with your desired longitude

final url = Uri.parse(
    'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=$apiKey&units=metric');


    final response = await http.get(url);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return WeatherData.fromJson(json);
    } else {
      throw Exception('Failed to fetch weather data');
    }
  }
}

class WeatherData {
  final String location;
  final double temperature;
  final String description;

  WeatherData({required this.location, required this.temperature, required this.description});

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final weather = json['weather'][0];
    final main = json['main'];

    return WeatherData(
      location: json['name'],
      temperature: main['temp'].toDouble(),
      description: weather['description'],
    );
  }
}
