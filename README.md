# Glasscast -Minimal Weather Application 

A beautiful minimal weather app with glass-morphism design, built with Flutter.

![Flutter](https://img.shields.io/badge/Flutter-3.0%2B-blue?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.0%2B-blue?logo=dart)
![License](https://img.shields.io/badge/License-MIT-green)

## ✨ Features

- **🌡️ Real-time Weather** - Current weather conditions for any city worldwide
- **📅 5-Day Forecast** - Extended weather predictions with daily breakdowns
- **🔍 City Search** - Search and add cities to your favorites
- **🌙 Glass-morphism UI** - Beautiful, modern design with translucent effects
- **🔐 User Authentication** - Secure sign in/up with Supabase
- **🌡️ Temperature Units** - Toggle between Celsius and Fahrenheit
- **🔄 Pull-to-Refresh** - Refresh weather data with a simple gesture
- **🎨 Dynamic Backgrounds** - Gradient backgrounds that adapt to time of day

## 🛠️ Tech Stack

| Category | Technology |
|----------|------------|
| Framework | Flutter 3.0+ |
| State Management | Provider |
| Backend | Supabase |
| Weather API | OpenWeatherMap |
| Storage | SharedPreferences (local), Supabase (cloud) |
| Design | Glass-morphism, Material 3 |


## 📁 Project Structure

```
lib/
├── main.dart                 # App entry point
├── config/
│   ├── supabase_config.dart  # Supabase configuration
│   └── weather_api_config.dart # Weather API settings
├── models/
│   ├── city.dart             # City model
│   ├── forecast.dart         # Weather forecast models
│   └── weather.dart          # Weather data models
├── providers/
│   ├── auth_provider.dart    # Authentication state
│   └── weather_provider.dart # Weather data state
├── screens/
│   ├── auth_screen.dart      # Sign in/up screen
│   ├── home_screen.dart      # Main weather display
│   └── settings_screen.dart  # App settings
└── theme/
    └── glass_theme.dart      # Glass-morphism theme
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.0 or higher
- Dart SDK 3.0 or higher
- An OpenWeatherMap API key
- A Supabase project (for authentication)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/minimal_weather.git
   cd minimal_weather
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure API Keys**

   Open `lib/config/weather_api_config.dart` and add your OpenWeatherMap API key:
   ```dart
   class WeatherApiConfig {
     static const String apiKey = 'YOUR_API_KEY_HERE';
     // ... rest of config
   }
   ```

4. **Configure Supabase**

   Open `lib/config/supabase_config.dart` and add your Supabase credentials:
   ```dart
   class SupabaseConfig {
     static const String supabaseUrl = 'YOUR_SUPABASE_URL';
     static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
     // ... rest of config
   }
   ```

5. **Set up Supabase Database**

   Run the following SQL in your Supabase SQL Editor to create the necessary table:

   ```sql
   -- Create favorite_cities table
   CREATE TABLE favorite_cities (
     id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
     user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
     name TEXT NOT NULL,
     country TEXT,
     latitude DOUBLE PRECISION NOT NULL,
     longitude DOUBLE PRECISION NOT NULL,
     added_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
   );

   -- Enable RLS
   ALTER TABLE favorite_cities ENABLE ROW LEVEL SECURITY;

   -- Create policy for users to see only their own favorites
   CREATE POLICY "Users can CRUD their own favorite cities"
     ON favorite_cities
     FOR ALL
     USING (auth.uid() = user_id);
   ```

6. **Run the app**
   ```bash
   flutter run
   ```

## 📱 Screenshots

<div align="center">
  <img width="25%"  alt="Screenshot 2026-01-18 at 3 47 48 PM" src="https://github.com/user-attachments/assets/767be088-e899-4426-897f-e2c3a4ca73de" />
  <img width="25%"  alt="Screenshot 2026-01-18 at 3 46 19 PM" src="https://github.com/user-attachments/assets/ab320320-6be4-4fee-b586-8c9333168516" />
  <img width="25%"  alt="Screenshot 2026-01-18 at 3 46 44 PM" src="https://github.com/user-attachments/assets/ab136887-c55b-4096-acef-6a973b7d9231" />

</div>

## 🎨 Design Features

### Glass-morphism Theme

The app features a stunning glass-morphism design with:

- **Translucent Cards** - Glass-like containers with blur effects
- **Gradient Backgrounds** - Purple-to-pink day gradient, dark night gradient
- **Subtle Shadows** - Soft shadows for depth perception
- **Smooth Animations** - Fluid transitions between screens


## 🔧 Configuration

### Temperature Units

The app supports both Celsius and Fahrenheit. Users can toggle between units in the settings screen. The preference is saved locally using SharedPreferences.

### Weather API

The app uses OpenWeatherMap API for:
- Current weather data (`/weather` endpoint)
- 5-day / 3-hour forecast (`/forecast` endpoint)
- Geocoding for city search (`/geo/1.0/direct` endpoint)

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  provider: ^6.0.5
  
  # Supabase
  supabase_flutter: ^2.3.0
  
  # Weather API
  http: ^1.1.0
  
  # Utilities
  intl: ^0.18.1
  shared_preferences: ^2.2.2
  uuid: ^4.2.1
  
  # UI/UX
  google_fonts: ^6.1.0
  flutter_svg: ^2.0.9
```

## 🧪 Testing

Run the test suite:

```bash
flutter test
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [OpenWeatherMap](https://openweathermap.org/) for providing weather data
- [Supabase](https://supabase.io/) for the excellent backend services
- [Google Fonts](https://fonts.google.com/) for the Inter font family
- Flutter team for the amazing framework

---

<div align="center">
  Made with ❤️ and ☕
</div>

