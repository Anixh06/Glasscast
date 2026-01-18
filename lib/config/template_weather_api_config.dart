// Template for Weather API Configuration
// Copy this file to weather_api_config.dart and fill in your actual values
// DO NOT commit this template with real API keys!

class WeatherApiConfig {
  // Get your API key from: https://openweathermap.org/api
  static const String apiKey = 'YOUR_OPENWEATHERMAP_API_KEY';
  static const String baseUrl = 'https://api.openweathermap.org/data/2.5';
  static const String oneCallUrl = 'https://api.openweathermap.org/data/3.0/onecall';
  
  // Units: 'metric' for Celsius, 'imperial' for Fahrenheit
  static const String defaultUnits = 'metric';
}

