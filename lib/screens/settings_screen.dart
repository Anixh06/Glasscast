import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minimal_weather/providers/auth_provider.dart';
import 'package:minimal_weather/providers/weather_provider.dart';
import 'package:minimal_weather/theme/glass_theme.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final weatherProvider = Provider.of<WeatherProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Container(
        decoration: GlassTheme.dayBackground(),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    _buildSectionTitle('Preferences'),
                    _buildTemperatureUnitTile(weatherProvider),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Account'),
                    _buildAccountTile(authProvider, context),
                    const SizedBox(height: 24),
                    _buildSectionTitle('About'),
                    _buildAboutTile(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Text(
            'Settings',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: GlassColors.textTertiary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildTemperatureUnitTile(WeatherProvider weatherProvider) {
    return Container(
      decoration: GlassTheme.glassLightDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          SwitchListTile(
            value: weatherProvider.temperatureUnit == TemperatureUnit.fahrenheit,
            onChanged: (value) {
              weatherProvider.setTemperatureUnit(
                value ? TemperatureUnit.fahrenheit : TemperatureUnit.celsius,
              );
            },
            activeThumbColor: GlassColors.accent,
            inactiveThumbColor: GlassColors.textSecondary,
            inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
            title: Text(
              'Use Fahrenheit (°F)',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            secondary: Icon(
              weatherProvider.temperatureUnit == TemperatureUnit.fahrenheit
                  ? Icons.thermostat
                  : Icons.ac_unit,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountTile(AuthProvider authProvider, BuildContext context) {
    return Container(
      decoration: GlassTheme.glassLightDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.person_outline, color: Colors.white),
            title: Text(
              authProvider.user?.email ?? 'Not signed in',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            subtitle: Text(
              authProvider.isAuthenticated ? 'Signed in' : 'Sign in to sync favorites',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: GlassColors.textSecondary,
              ),
            ),
          ),
          if (authProvider.isAuthenticated)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await authProvider.signOut();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GlassColors.error.withValues(alpha: 0.2),
                    foregroundColor: GlassColors.error,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    'Sign Out',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAboutTile() {
    return Container(
      decoration: GlassTheme.glassLightDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.info_outline, color: Colors.white),
            title: Text(
              'Version',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            trailing: Text(
              '1.0.0',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: GlassColors.textSecondary,
              ),
            ),
          ),
          const Divider(color: Colors.white, indent: 56, height: 1),
          ListTile(
            leading: const Icon(Icons.code, color: Colors.white),
            title: Text(
              'Built with Flutter',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

