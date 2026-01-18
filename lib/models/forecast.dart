
class Forecast {
  final List<DailyForecast> daily;
  final List<HourlyForecast> hourly;

  Forecast({required this.daily, required this.hourly});

  factory Forecast.fromJson(Map<String, dynamic> json) {
    final daily = (json['daily'] as List)
        .map((e) => DailyForecast.fromJson(e))
        .toList();
    
    final hourly = (json['hourly'] as List)
        .map((e) => HourlyForecast.fromJson(e))
        .toList();

    return Forecast(daily: daily, hourly: hourly);
  }
}

class DailyForecast {
  final int dt;
  final double tempMin;
  final double tempMax;
  final String condition;
  final String iconCode;
  final int humidity;
  final double windSpeed;

  DailyForecast({
    required this.dt,
    required this.tempMin,
    required this.tempMax,
    required this.condition,
    required this.iconCode,
    required this.humidity,
    required this.windSpeed,
  });

  factory DailyForecast.fromJson(Map<String, dynamic> json) {
    return DailyForecast(
      dt: json['dt'],
      tempMin: (json['temp']['min'] as num).toDouble(),
      tempMax: (json['temp']['max'] as num).toDouble(),
      condition: json['weather'][0]['main'],
      iconCode: json['weather'][0]['icon'],
      humidity: json['humidity'],
      windSpeed: (json['wind_speed'] as num).toDouble(),
    );
  }
}

class HourlyForecast {
  final int dt;
  final double temperature;
  final String condition;
  final String iconCode;

  HourlyForecast({
    required this.dt,
    required this.temperature,
    required this.condition,
    required this.iconCode,
  });

  factory HourlyForecast.fromJson(Map<String, dynamic> json) {
    return HourlyForecast(
      dt: json['dt'],
      temperature: (json['temp'] as num).toDouble(),
      condition: json['weather'][0]['main'],
      iconCode: json['weather'][0]['icon'],
    );
  }
}

