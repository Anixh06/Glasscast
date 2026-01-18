# Minimal Weather App

A beautiful Flutter weather app with glass-morphism design, featuring smooth animations and a clean, minimal UI.

## Features

- 🌤️ **Current Weather** - Real-time weather for any city
- 📅 **5-Day Forecast** - Extended weather predictions
- 🔐 **Authentication** - Sign up/Login with Supabase
- ⭐ **Favorite Cities** - Save and sync cities to your account
- ⚙️ **Settings** - Temperature unit toggle (°C/°F)
- 🎨 **Glass-morphism Design** - Beautiful blur effects and translucency

## Tech Stack

- **Flutter** - UI framework
- **Provider** - State management
- **Supabase** - Backend (Auth + Database)
- **OpenWeatherMap API** - Weather data
- **Google Fonts** - Typography

## Setup Instructions

### 1. Install Dependencies

```bash
flutter pub get
```

### 2. Configure Supabase

Create a Supabase project at [supabase.com](https://supabase.com) and create a table for favorite cities:

```sql
CREATE TABLE favorite_cities (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  country TEXT,
  latitude DOUBLE PRECISION,
  longitude DOUBLE PRECISION,
  added_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE favorite_cities ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Users can view own favorite cities"
  ON favorite_cities FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own favorite cities"
  ON favorite_cities FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own favorite cities"
  ON favorite_cities FOR DELETE
  USING (auth.uid() = user_id);
```

### 3. Configure OpenWeatherMap

Sign up at [openweathermap.org](https://openweathermap.org) and get your API key.

### 4. Update Configuration

Update the credentials in these files:
- `lib/config/supabase_config.dart`
- `lib/config/weather_api_config.dart`

### 5. Run the App

```bash
flutter run
```

## Project Structure

```
lib/
├── config/           # Configuration files
│   ├── supabase_config.dart
│   └── weather_api_config.dart
├── models/           # Data models
│   ├── city.dart
│   ├── forecast.dart
│   └── weather.dart
├── providers/        # State management
│   ├── auth_provider.dart
│   └── weather_provider.dart
├── screens/          # UI screens
│   ├── auth_screen.dart
│   ├── home_screen.dart
│   └── settings_screen.dart
├── theme/            # Theme and styling
│   └── glass_theme.dart
├── main.dart         # App entry point
└── utils/            # Utility functions
    └── date_formatter.dart
```

## Design System

The app uses a glass-morphism design with:
- Translucent containers with blur effects
- Gradient backgrounds
- Smooth animations and transitions
- Clean typography with Inter font
- White text on colorful gradients

## Screenshots

The app features three main screens:

1. **Auth Screen** - Clean login/signup with glass cards
2. **Home Screen** - Main weather display with current conditions and forecast
3. **Settings Screen** - Temperature unit toggle and account management

## License

MIT License

