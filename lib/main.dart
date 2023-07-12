import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';

void main() {
  runApp(WeatherApp());
}

class WeatherApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WeatherScreen(),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  bool isLoading = true;
  bool isError = false;
  late WeatherData weatherData;

  @override
  void initState() {
    super.initState();
    fetchWeatherData();
  }

  void fetchWeatherData() async {
    final apiKey = '17257df02cd515b0160aa0fd7968bd92';
    final url = 'https://api.openweathermap.org/data/2.5/weather?lat=LATITUDE&lon=LONGITUDE&appid=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        setState(() {
          weatherData = WeatherData.fromJson(jsonData);
          isLoading = false;
          isError = false;
        });
      } else {
        setState(() {
          isLoading = false;
          isError = true;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        isError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather App'),
      ),
      body: Center(
        child: isLoading
            ? CircularProgressIndicator()
            : isError
            ? Text('Error fetching weather data')
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${weatherData.location}',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 16),
            CachedNetworkImage(
              imageUrl: weatherData.weatherImageUrl,
              placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
            SizedBox(height: 16),
            Text(
              '${weatherData.temperature}°C',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              '${weatherData.weatherDescription}',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}

class WeatherData {
  final String location;
  final double temperature;
  final String weatherDescription;
  final String weatherImageUrl;

  WeatherData({
    required this.location,
    required this.temperature,
    required this.weatherDescription,
    required this.weatherImageUrl,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final weather = json['weather'][0];
    final iconCode = weather['icon'];
    final iconUrl = 'http://openweathermap.org/img/w/$iconCode.png';

    return WeatherData(
      location: json['name'],
      temperature: json['main']['temp'] - 273.15, // Convert from Kelvin to Celsius
      weatherDescription: weather['main'],
      weatherImageUrl: iconUrl,
    );
  }
}
