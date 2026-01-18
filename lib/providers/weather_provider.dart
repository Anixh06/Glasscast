import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:minimal_weather/config/weather_api_config.dart';
import 'package:minimal_weather/config/supabase_config.dart';
import 'package:minimal_weather/models/weather.dart';
import 'package:minimal_weather/models/forecast.dart';
import 'package:minimal_weather/models/city.dart';

enum TemperatureUnit { celsius, fahrenheit }

class WeatherProvider with ChangeNotifier {
  final SupabaseClient _supabase = SupabaseConfig.client;

  Weather? _currentWeather;
  Forecast? _forecast;
  List<City> _favoriteCities = [];
  String _selectedCity = 'London';
  TemperatureUnit _temperatureUnit = TemperatureUnit.celsius;
  bool _isLoading = false;
  bool _isRefreshing = false;
  String? _error;
  String? _searchError;

  Weather? get currentWeather => _currentWeather;
  Forecast? get forecast => _forecast;
  List<City> get favoriteCities => _favoriteCities;
  String get selectedCity => _selectedCity;
  TemperatureUnit get temperatureUnit => _temperatureUnit;
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  String? get error => _error;
  String? get searchError => _searchError;

  String get temperatureSymbol {
    return _temperatureUnit == TemperatureUnit.celsius ? '°C' : '°F';
  }

  Future<void> initialize() async {
    await _loadPreferences();
    await _loadFavoriteCities();
    await fetchWeatherForCity(_selectedCity);
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final unitIndex = prefs.getInt('temperature_unit') ?? 0;
    _temperatureUnit = TemperatureUnit.values[unitIndex];
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('temperature_unit', _temperatureUnit.index);
  }

  void setTemperatureUnit(TemperatureUnit unit) {
    _temperatureUnit = unit;
    _savePreferences();
    notifyListeners();
    fetchWeatherForCity(_selectedCity);
  }

  Future<void> _loadFavoriteCities() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        _favoriteCities = [];
        return;
      }

      final response = await _supabase
          .from(SupabaseConfig.favoriteCitiesTable)
          .select()
          .eq('user_id', user.id)
          .order('added_at', ascending: false);

      _favoriteCities = (response as List)
          .map((e) => City.fromJson(e))
          .toList();

      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('Error loading favorite cities: $e');
      _favoriteCities = [];
    }
  }

  Future<void> addFavoriteCity(City city) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        if (kDebugMode) print('Cannot add favorite: user not logged in');
        return;
      }

      if (_favoriteCities.any((c) => c.name.toLowerCase() == city.name.toLowerCase())) {
        return;
      }

      final cityWithUser = city.toJson(userId: user.id);
      await _supabase
          .from(SupabaseConfig.favoriteCitiesTable)
          .insert(cityWithUser);

      _favoriteCities.insert(0, city);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('Error adding favorite city: $e');
    }
  }

  Future<void> removeFavoriteCity(String cityId) async {
    try {
      await _supabase
          .from(SupabaseConfig.favoriteCitiesTable)
          .delete()
          .eq('id', cityId);

      _favoriteCities.removeWhere((city) => city.id == cityId);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('Error removing favorite city: $e');
    }
  }

  void selectCity(String city) {
    _selectedCity = city;
    _error = null;
    notifyListeners();
    fetchWeatherForCity(city);
  }

  Future<void> fetchWeatherForCity(String city) async {
    if (city.isEmpty) {
      _error = 'Please enter a city name';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (kDebugMode) {
        print('Fetching weather for: $city');
      }

      final weatherUrl = Uri.parse(
        '${WeatherApiConfig.baseUrl}/weather?q=$city&units=${_getUnitParameter()}&appid=${WeatherApiConfig.apiKey}',
      );

      final forecastUrl = Uri.parse(
        '${WeatherApiConfig.baseUrl}/forecast?q=$city&units=${_getUnitParameter()}&appid=${WeatherApiConfig.apiKey}',
      );

      if (kDebugMode) print('Weather URL: $weatherUrl');

      final weatherResponse = await http.get(weatherUrl);

      if (kDebugMode) {
        print('Weather response status: ${weatherResponse.statusCode}');
        print('Weather response body: ${weatherResponse.body}');
      }

      if (weatherResponse.statusCode == 200) {
        final weatherData = json.decode(weatherResponse.body);
        _currentWeather = Weather.fromJson(weatherData, city);
      } else if (weatherResponse.statusCode == 401) {
        _error = 'Invalid API key. Please check your OpenWeatherMap API key.';
      } else if (weatherResponse.statusCode == 404) {
        _error = 'City "$city" not found. Please try a different city.';
      } else {
        _error = 'Failed to load weather (Error: ${weatherResponse.statusCode})';
      }

      final forecastResponse = await http.get(forecastUrl);

      if (kDebugMode) {
        print('Forecast response status: ${forecastResponse.statusCode}');
      }

      if (forecastResponse.statusCode == 200) {
        final forecastData = json.decode(forecastResponse.body);
        _forecast = _parseForecast(forecastData);
      }

      _isLoading = false;
      _isRefreshing = false;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('Error fetching weather: $e');
      _error = 'Failed to connect to weather service. Please check your internet connection.';
      _isLoading = false;
      _isRefreshing = false;
      notifyListeners();
    }
  }

  Future<List<City>> searchCities(String query) async {
    if (query.isEmpty) return [];

    _searchError = null;
    notifyListeners();

    try {
      // Use the Geocoding API (more reliable than /find)
      final url = Uri.parse(
        'https://api.openweathermap.org/geo/1.0/direct?q=${Uri.encodeComponent(query)}&limit=10&appid=${WeatherApiConfig.apiKey}',
      );

      if (kDebugMode) print('Search URL: $url');

      final response = await http.get(url);

      if (kDebugMode) {
        print('Search response status: ${response.statusCode}');
        print('Search response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        if (data.isEmpty) {
          return [];
        }

        return data.map((c) => City(
          id: '${c['lat']}_${c['lon']}', // Create unique ID from coordinates
          name: c['name'],
          country: c['country'] ?? '',
          latitude: c['lat'].toDouble(),
          longitude: c['lon'].toDouble(),
        )).toList();
      } else if (response.statusCode == 401) {
        _searchError = 'Invalid API key';
        return [];
      } else if (response.statusCode == 404) {
        _searchError = 'No cities found';
        return [];
      } else {
        _searchError = 'Search failed (Error: ${response.statusCode})';
        return [];
      }
    } catch (e) {
      if (kDebugMode) print('Error searching cities: $e');
      _searchError = 'Failed to search cities. Please check your internet connection.';
      return [];
    }
  }

  String _getUnitParameter() {
    return _temperatureUnit == TemperatureUnit.celsius ? 'metric' : 'imperial';
  }

  Forecast _parseForecast(Map<String, dynamic> json) {
    final List<dynamic> list = json['list'];

    final dailyForecasts = <String, List<dynamic>>{};
    for (final item in list) {
      final date = DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);
      final dateKey = '${date.year}-${date.month}-${date.day}';

      if (!dailyForecasts.containsKey(dateKey)) {
        dailyForecasts[dateKey] = [];
      }
      dailyForecasts[dateKey]!.add(item);
    }

    final daily = dailyForecasts.entries.take(5).map((entry) {
      final dayItems = entry.value;
      final temps = dayItems.map((e) => (e['main']['temp'] as num).toDouble()).toList();

      return DailyForecast(
        dt: dayItems[0]['dt'] as int,
        tempMin: temps.reduce((a, b) => a < b ? a : b),
        tempMax: temps.reduce((a, b) => a > b ? a : b),
        condition: dayItems[0]['weather'][0]['main'] as String,
        iconCode: dayItems[0]['weather'][0]['icon'] as String,
        humidity: dayItems[0]['main']['humidity'] as int,
        windSpeed: (dayItems[0]['wind']['speed'] as num).toDouble(),
      );
    }).toList();

    final hourly = list.take(24).map((e) {
      return HourlyForecast(
        dt: e['dt'] as int,
        temperature: (e['main']['temp'] as num).toDouble(),
        condition: e['weather'][0]['main'] as String,
        iconCode: e['weather'][0]['icon'] as String,
      );
    }).toList();

    return Forecast(daily: daily, hourly: hourly);
  }

  Future<void> refresh() async {
    _isRefreshing = true;
    notifyListeners();
    await fetchWeatherForCity(_selectedCity);
  }

  String formatTemperature(double temp) {
    return '${temp.round()}$temperatureSymbol';
  }

  String getWeatherIcon(String iconCode) {
    final hour = DateTime.now().hour;
    final isNight = hour < 6 || hour > 18;

    switch (iconCode) {
      case '01d': return isNight ? '🌙' : '☀️';
      case '01n': return '🌙';
      case '02d': return isNight ? '☁️' : '⛅';
      case '02n': return '☁️';
      case '03d':
      case '03n':
      case '04d':
      case '04n':
        return '☁️';
      case '09d':
      case '09n':
        return '🌧️';
      case '10d':
      case '10n':
        return isNight ? '🌧️' : '🌦️';
      case '11d':
      case '11n':
        return '⛈️';
      case '13d':
      case '13n':
        return '❄️';
      case '50d':
      case '50n':
        return '🌫️';
      default:
        return '🌡️';
    }
  }

  void clearError() {
    _error = null;
    _searchError = null;
    notifyListeners();
  }
}
