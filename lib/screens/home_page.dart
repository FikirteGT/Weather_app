// lib/screens/home_page.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';
import '../utils/weather_utils.dart';
import '../widgets/weather_header.dart';
import '../widgets/weather_info_card.dart';
import '../widgets/weather_advice_card.dart';
import '../widgets/outfit_card.dart';
import '../widgets/activity_score_card.dart';
import '../widgets/hourly_forecast.dart';

/// HomePage is the main screen of the "Weather Companion" application.
/// It coordinates fetching live data, managing loading/error states,
/// and building the weather-responsive UI dashboard.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final WeatherService _weatherService = WeatherService();

  WeatherModel? _weatherData;
  String? _errorMessage;
  bool _isLoading = true;
  bool _isOfflineDemo = false;

  // Selected bottom navigation index
  int _currentNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  /// Asynchronously loads live weather data using WeatherService.
  Future<void> _loadWeather() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _isOfflineDemo = false;
    });

    try {
      final data = await _weatherService.fetchCurrentWeather();
      setState(() {
        _weatherData = data;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading weather: $e');
      setState(() {
        _errorMessage = 'Unable to connect to weather API ($e). Check your internet connection or browser CORS settings.';
        _isLoading = false;
      });
    }
  }

  /// Fallback loader for offline / restricted network environments.
  void _loadOfflineDemoData() {
    setState(() {
      _weatherData = WeatherService.getFallbackWeather();
      _errorMessage = null;
      _isLoading = false;
      _isOfflineDemo = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeColors = WeatherUtils.getWeatherThemeGradients(_weatherData);

    return Scaffold(
      backgroundColor: themeColors.last,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: themeColors,
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? _buildLoadingState()
              : _errorMessage != null
                  ? _buildErrorState()
                  : _buildWeatherDashboard(_weatherData!),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  /// Loading State UI
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: Color(0xFF38BDF8),
            strokeWidth: 3,
          ),
          const SizedBox(height: 20),
          Text(
            'Getting the latest weather...',
            style: GoogleFonts.inter(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  /// Error State UI with Retry & Demo Mode Buttons
  Widget _buildErrorState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              color: Colors.redAccent,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Unable to load weather data',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              _errorMessage!,
              style: GoogleFonts.inter(
                color: Colors.white60,
                fontSize: 13,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _loadWeather,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF38BDF8),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: _loadOfflineDemoData,
                  icon: const Icon(Icons.offline_bolt_outlined, size: 18),
                  label: const Text('Offline Demo'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white30),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Main Weather Dashboard Content View
  Widget _buildWeatherDashboard(WeatherModel weather) {
    return RefreshIndicator(
      onRefresh: _loadWeather,
      color: const Color(0xFF38BDF8),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_isOfflineDemo)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.withOpacity(0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.wifi_off_rounded, color: Colors.amber, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Offline Demo Mode Active. Pull down to refresh live API.',
                        style: GoogleFonts.inter(color: Colors.amber, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),

            // Top Section: City Name, Weather Icon, Temperature & Mood
            WeatherHeader(weather: weather, locationName: 'Addis Ababa'),
            const SizedBox(height: 24),

            // Live Weather Info Cards: Wind, Humidity, Feels Like, Precip
            WeatherInfoCard(weather: weather),
            const SizedBox(height: 20),

            // Core Feature: Weather Advice Engine Card
            WeatherAdviceCard(weather: weather),
            const SizedBox(height: 20),

            // Today's Outfit Recommendation Card
            OutfitCard(weather: weather),
            const SizedBox(height: 20),

            // Outdoor Activity Score Card (0–100)
            ActivityScoreCard(weather: weather),
            const SizedBox(height: 24),

            // Horizontally Scrollable Hourly Forecast List
            const HourlyForecastWidget(),
          ],
        ),
      ),
    );
  }

  /// Bottom Navigation Bar (Home, Search, Favorites)
  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D0C1A),
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.06),
            width: 1,
          ),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          setState(() {
            _currentNavIndex = index;
          });
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: const Color(0xFF38BDF8),
        unselectedItemColor: Colors.white38,
        selectedLabelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.inter(fontSize: 12),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_rounded),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline_rounded),
            label: 'Favorites',
          ),
        ],
      ),
    );
  }
}
