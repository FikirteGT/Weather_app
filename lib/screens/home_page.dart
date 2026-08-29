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
    });

    try {
      final data = await _weatherService.fetchCurrentWeather();
      setState(() {
        _weatherData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Unable to load weather data. Please check your internet connection.';
        _isLoading = false;
      });
    }
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

  /// Error State UI with Retry Button
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
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
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: GoogleFonts.inter(
                color: Colors.white60,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadWeather,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF38BDF8),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
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
