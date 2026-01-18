class Weather {
  final String cityName;
  final double temperature;
  final double feelsLike;
  final String condition;
  final String description;
  final int humidity;
  final double windSpeed;
  final int clouds;
  final String iconCode;
  final DateTime timestamp;
  final double? tempMin;
  final double? tempMax;
  final int? sunrise;
  final int? sunset;

  Weather({
    required this.cityName,
    required this.temperature,
    required this.feelsLike,
    required this.condition,
    required this.description,
    required this.humidity,
    required this.windSpeed,
    required this.clouds,
    required this.iconCode,
    required this.timestamp,
    this.tempMin,
    this.tempMax,
    this.sunrise,
    this.sunset,
  });

  factory Weather.fromJson(Map<String, dynamic> json, String cityName) {
    return Weather(
      cityName: cityName,
      temperature: (json['main']['temp'] as num).toDouble(),
      feelsLike: (json['main']['feels_like'] as num).toDouble(),
      condition: json['weather'][0]['main'],
      description: json['weather'][0]['description'],
      humidity: json['main']['humidity'],
      windSpeed: (json['wind']['speed'] as num).toDouble(),
      clouds: json['clouds']['all'],
      iconCode: json['weather'][0]['icon'],
      timestamp: DateTime.now(),
      tempMin: (json['main']['temp_min'] as num).toDouble(),
      tempMax: (json['main']['temp_max'] as num).toDouble(),
    );
  }

  factory Weather.fromOneCallJson(Map<String, dynamic> json) {
    final current = json['current'];
    final weather = current['weather'][0];
    
    return Weather(
      cityName: 'Current Location',
      temperature: (current['temp'] as num).toDouble(),
      feelsLike: (current['feels_like'] as num).toDouble(),
      condition: weather['main'],
      description: weather['description'],
      humidity: current['humidity'],
      windSpeed: (current['wind_speed'] as num).toDouble(),
      clouds: current['clouds'],
      iconCode: weather['icon'],
      timestamp: DateTime.now(),
      tempMin: null,
      tempMax: null,
      sunrise: current['sunrise'],
      sunset: current['sunset'],
    );
  }
}

