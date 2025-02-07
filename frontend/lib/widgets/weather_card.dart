import 'package:flutter/material.dart';
import 'package:frontend/models/weather_model.dart';
import 'package:frontend/services/weather_service.dart';
import 'package:lottie/lottie.dart';

class WeatherCard extends StatefulWidget {
  const WeatherCard({super.key});

  @override
  State<WeatherCard> createState() => _WeatherCardState();
}

class _WeatherCardState extends State<WeatherCard> {
  final _weatherService = WeatherService('220c4c0c89bc6ffbcd0d52e1e63df148');
  Weather? _weather;

  Future<void> _fetchWeather() async {
    try {
      String cityName = await _weatherService.getCurrentCity();
      Weather weatherData = await _weatherService.getWeather(cityName);
      setState(() {
        _weather = weatherData;
      });
    } catch (e) {
      print('Error fetching weather: $e');
    }
  }

  String getWeatherAnimation(String? mainCondition) {
    if (mainCondition == null) return 'assets/images/sunny.json';
    
    switch (mainCondition.toLowerCase()) {
      case 'thunderstorm':
        return 'assets/images/thunderstorm.json';
      case 'drizzle':
      case 'shower rain':
      case 'rain':
        return 'assets/images/rainy.json';
      case 'snow':
        return 'assets/images/snow.json';
      case 'dust':
      case 'clouds':
        return 'assets/images/cloudy.json';
      case 'fog':
      case 'smoke':
      case 'mist':
        return 'assets/images/mist.json';
      case 'haze':
      case 'clear':
        return 'assets/images/sunny.json';
      default:
        return 'assets/images/sunny.json';
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,  // Adjusted height
      // margin: const EdgeInsets.only(bottom: 8.0), // Reduced bottom margin
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: _weather == null
          ? const Center(child: CircularProgressIndicator())
          : Row(
              mainAxisAlignment: MainAxisAlignment.center, // Centers the row
              crossAxisAlignment: CrossAxisAlignment.center, // Centers the children vertically
              
              children: [
                Lottie.asset(
                  getWeatherAnimation(_weather?.mainCondition),
                  width: 150,
                  height: 150,
                ),
                const SizedBox(width: 10), 
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,  // Centers text horizontally
                  mainAxisAlignment: MainAxisAlignment.center,  // Centers text vertically
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      "${_weather!.temperature.round()} ℃",
                      style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _weather!.cityName,
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      _weather?.mainCondition ?? "",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}

