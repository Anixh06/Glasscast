import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minimal_weather/models/forecast.dart';
import 'package:minimal_weather/models/city.dart';
import 'package:minimal_weather/providers/weather_provider.dart';
import 'package:minimal_weather/screens/settings_screen.dart';
import 'package:minimal_weather/theme/glass_theme.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showForecast = false;
  final TextEditingController _searchController = TextEditingController();
  List<City> _searchResults = [];
  bool _isSearching = false;
  bool _showSearchResults = false;
  bool _showFavoritesSection = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<WeatherProvider>(context, listen: false).initialize();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _searchCity(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
        _showSearchResults = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _showSearchResults = true;
    });

    final weatherProvider = Provider.of<WeatherProvider>(context, listen: false);
    final results = await weatherProvider.searchCities(query);
    
    if (mounted) {
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    }
  }

  void _selectCity(City city) {
    final weatherProvider = Provider.of<WeatherProvider>(context, listen: false);
    weatherProvider.selectCity('${city.name}, ${city.country}');
    _closeSearch();
  }

  void _closeSearch() {
    setState(() {
      _searchController.clear();
      _searchResults = [];
      _showSearchResults = false;
      _isSearching = false;
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final weatherProvider = Provider.of<WeatherProvider>(context);

    return Scaffold(
      body: Container(
        decoration: GlassTheme.dayBackground(),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: weatherProvider.refresh,
            color: Colors.white,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _buildHeader(weatherProvider),
                ),
                if (weatherProvider.error != null && !weatherProvider.isLoading)
                  SliverToBoxAdapter(
                    child: _buildErrorSection(weatherProvider),
                  ),
                SliverToBoxAdapter(
                  child: _buildCurrentWeather(weatherProvider),
                ),
                SliverToBoxAdapter(
                  child: _buildWeatherDetails(weatherProvider),
                ),
                SliverToBoxAdapter(
                  child: _buildForecastSection(weatherProvider),
                ),
                SliverToBoxAdapter(
                  child: _buildFavoriteCitiesSection(weatherProvider),
                ),
                SliverToBoxAdapter(
                  child: const SizedBox(height: 100),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _buildFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildHeader(WeatherProvider weatherProvider) {
    final cityDisplay = weatherProvider.selectedCity.isNotEmpty 
        ? weatherProvider.selectedCity 
        : (weatherProvider.currentWeather?.cityName ?? 'Loading...');
    final isFavorite = _isCityFavorite(weatherProvider);
    
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Favorite Button
          GestureDetector(
            onTap: () => _toggleFavorite(weatherProvider),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isFavorite 
                    ? GlassColors.error.withValues(alpha: 0.2)
                    : Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isFavorite 
                      ? GlassColors.error.withValues(alpha: 0.5)
                      : Colors.white.withValues(alpha: 0.2),
                ),
              ),
              child: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? GlassColors.error : GlassColors.textSecondary,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cityDisplay,
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  _getCurrentDateTime(),
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: GlassColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const SettingsScreen(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
              ),
            ),
            icon: const Icon(Icons.settings, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorSection(WeatherProvider weatherProvider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GlassColors.error.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GlassColors.error.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.error_outline, color: GlassColors.error),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  weatherProvider.error ?? 'Something went wrong',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => weatherProvider.fetchWeatherForCity(weatherProvider.selectedCity),
              style: ElevatedButton.styleFrom(
                backgroundColor: GlassColors.error.withValues(alpha: 0.3),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Retry'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentWeather(WeatherProvider weatherProvider) {
    final weather = weatherProvider.currentWeather;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: GlassTheme.glassHeavyDecoration(
        borderRadius: BorderRadius.circular(32),
      ),
      child: weatherProvider.isLoading && weather == null
          ? const Center(
              child: SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(color: Colors.white),
              ),
            )
          : Column(
              children: [
                Text(
                  weather?.condition ?? 'No data',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  weather?.description ?? '',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: GlassColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Text(
                  weather != null 
                      ? weatherProvider.formatTemperature(weather.temperature) 
                      : '--',
                  style: GoogleFonts.inter(
                    fontSize: 96,
                    fontWeight: FontWeight.w200,
                    color: Colors.white,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'H: ${weather != null ? weatherProvider.formatTemperature(weather.tempMax ?? weather.temperature + 5) : '--'}',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: GlassColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'L: ${weather != null ? weatherProvider.formatTemperature(weather.tempMin ?? weather.temperature - 5) : '--'}',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: GlassColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  bool _isCityFavorite(WeatherProvider weatherProvider) {
    if (weatherProvider.currentWeather == null) return false;
    
    final currentCityName = weatherProvider.currentWeather!.cityName.split(',')[0].trim().toLowerCase();
    
    for (final city in weatherProvider.favoriteCities) {
      if (city.name.trim().toLowerCase() == currentCityName) {
        return true;
      }
    }
    return false;
  }

  void _toggleFavorite(WeatherProvider weatherProvider) {
    if (weatherProvider.currentWeather == null) return;

    final isFavorite = _isCityFavorite(weatherProvider);

    if (isFavorite) {
      // Find and remove the city from favorites
      final currentCityName = weatherProvider.currentWeather!.cityName.split(',')[0].trim().toLowerCase();
      final cityToRemove = weatherProvider.favoriteCities.firstWhere(
        (city) => city.name.trim().toLowerCase() == currentCityName,
      );
      weatherProvider.removeFavoriteCity(cityToRemove.id);
    } else {
      // Add current city to favorites
      final cityName = weatherProvider.currentWeather!.cityName;
      final parts = cityName.split(',');
      
      final city = City(
        name: parts[0].trim(),
        country: parts.length > 1 ? parts[1].trim() : '',
      );
      
      weatherProvider.addFavoriteCity(city);
    }
    
    setState(() {});
  }

  Widget _buildWeatherDetails(WeatherProvider weatherProvider) {
    final weather = weatherProvider.currentWeather;

    if (weather == null) {
      return const SizedBox.shrink();
    }

    final details = [
      {'icon': Icons.water_drop, 'label': 'Humidity', 'value': '${weather.humidity}%'},
      {'icon': Icons.air, 'label': 'Wind', 'value': '${weather.windSpeed.toStringAsFixed(1)} m/s'},
      {'icon': Icons.cloud, 'label': 'Clouds', 'value': '${weather.clouds}%'},
    ];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ...details.map((detail) {
            return Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 6),
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                decoration: GlassTheme.glassLightDecoration(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Icon(
                      detail['icon'] as IconData,
                      color: Colors.white.withValues(alpha: 0.8),
                      size: 24,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      detail['label'] as String,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: GlassColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      detail['value'] as String,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildForecastSection(WeatherProvider weatherProvider) {
    final forecast = weatherProvider.forecast;

    if (forecast == null || forecast.daily.isEmpty) {
      return const SizedBox.shrink();
    }

    // Show 3 days by default, or 5 days when expanded
    final daysToShow = _showForecast ? 5 : 3;
    final displayDays = forecast.daily.take(daysToShow).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Forecast',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _showForecast = !_showForecast;
                  });
                },
                child: Text(
                  _showForecast ? 'Show Less' : 'Next 7 Days',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: GlassColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...displayDays.map((day) {
            return _buildForecastDay(day, weatherProvider);
          }),
        ],
      ),
    );
  }

  Widget _buildForecastDay(DailyForecast day, WeatherProvider weatherProvider) {
    final date = DateTime.fromMillisecondsSinceEpoch(day.dt * 1000);
    final dayName = _getDayName(date);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: GlassTheme.glassLightDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 110,
            height: 24,
            alignment: Alignment.centerRight,
            child: Text(
              dayName,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            weatherProvider.getWeatherIcon(day.iconCode),
            style: const TextStyle(fontSize: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  day.condition,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: GlassColors.textSecondary,
                  ),
                ),
                Text(
                  '${weatherProvider.formatTemperature(day.tempMin)} / ${weatherProvider.formatTemperature(day.tempMax)}',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteCitiesSection(WeatherProvider weatherProvider) {
    final favoriteCities = weatherProvider.favoriteCities;

    if (favoriteCities.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Favorite Cities',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _showFavoritesSection = !_showFavoritesSection;
                  });
                },
                icon: Icon(
                  _showFavoritesSection ? Icons.expand_less : Icons.expand_more,
                  color: GlassColors.textSecondary,
                ),
              ),
            ],
          ),
          if (_showFavoritesSection || favoriteCities.length <= 3)
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: favoriteCities.length,
                itemBuilder: (context, index) {
                  final city = favoriteCities[index];
                  return _buildFavoriteCityCard(city, weatherProvider);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFavoriteCityCard(City city, WeatherProvider weatherProvider) {
    final isCurrentCity = weatherProvider.selectedCity.toLowerCase().contains(city.name.toLowerCase());
    final currentWeather = weatherProvider.currentWeather;
    final temp = currentWeather != null && isCurrentCity 
        ? weatherProvider.formatTemperature(currentWeather.temperature) 
        : '--';

    return GestureDetector(
      onTap: () {
        final cityName = '${city.name}, ${city.country}';
        weatherProvider.selectCity(cityName);
        setState(() {
          _showFavoritesSection = false;
        });
      },
      onLongPress: () => _showRemoveFavoriteDialog(city),
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isCurrentCity
                ? [
                    Colors.white.withValues(alpha: 0.25),
                    Colors.white.withValues(alpha: 0.15),
                  ]
                : [
                    Colors.white.withValues(alpha: 0.15),
                    Colors.white.withValues(alpha: 0.05),
                  ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isCurrentCity 
                ? Colors.white.withValues(alpha: 0.3)
                : Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  isCurrentCity ? Icons.location_on : Icons.location_on_outlined,
                  color: isCurrentCity ? GlassColors.accent : GlassColors.textSecondary,
                  size: 16,
                ),
                GestureDetector(
                  onTap: () => _showRemoveFavoriteDialog(city),
                  child: Icon(
                    Icons.close,
                    color: GlassColors.textTertiary,
                    size: 16,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  city.name,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  temp,
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w300,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showRemoveFavoriteDialog(City city) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        title: Text(
          'Remove ${city.name}?',
          style: GoogleFonts.inter(color: Colors.white),
        ),
        content: Text(
          'This city will be removed from your favorites.',
          style: GoogleFonts.inter(color: GlassColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: GlassColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Provider.of<WeatherProvider>(context, listen: false)
                  .removeFavoriteCity(city.id);
              Navigator.pop(context);
              setState(() {});
            },
            child: Text(
              'Remove',
              style: GoogleFonts.inter(color: GlassColors.error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFab() {
    return FloatingActionButton(
      onPressed: () => _showCitySearchBottomSheet(context),
      backgroundColor: Colors.white.withValues(alpha: 0.2),
      foregroundColor: Colors.white,
      elevation: 0,
      child: const Icon(Icons.add_location_alt),
    );
  }

  void _showCitySearchBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1a1a2e).withValues(alpha: 0.95),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          autofocus: true,
                          style: GoogleFonts.inter(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Search for a city...',
                            hintStyle: GoogleFonts.inter(color: GlassColors.textTertiary),
                            prefixIcon: const Icon(Icons.search, color: GlassColors.textSecondary),
                            filled: true,
                            fillColor: Colors.white.withValues(alpha: 0.1),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onChanged: (value) {
                            _searchCity(value);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        onPressed: _closeSearch,
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                if (_isSearching)
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                else if (_showSearchResults && _searchResults.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'No cities found. Try a different search.',
                      style: GoogleFonts.inter(
                        color: GlassColors.textTertiary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                else if (_searchResults.isNotEmpty)
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final city = _searchResults[index];
                        return ListTile(
                          leading: const Icon(Icons.location_on, color: GlassColors.textSecondary),
                          title: Text(
                            '${city.name}, ${city.country}',
                            style: GoogleFonts.inter(color: Colors.white),
                          ),
                          onTap: () {
                            _selectCity(city);
                          },
                        );
                      },
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'Search for a city to see weather',
                      style: GoogleFonts.inter(
                        color: GlassColors.textTertiary,
                      ),
                    ),
                  ),
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
              ],
            ),
          );
        },
      ),
    );
  }

  String _getCurrentDateTime() {
    final now = DateTime.now();
    return '${_getDayName(now)}, ${_getMonthName(now.month)} ${now.day}';
  }

  String _getDayName(DateTime date) {
    final days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    return days[date.weekday % 7];
  }

  String _getMonthName(int month) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}

