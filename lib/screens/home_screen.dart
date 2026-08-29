import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/weather_models.dart';
import '../services/weather_service.dart';
import '../widgets/weather_info_item.dart';
import '../widgets/hourly_forecast_card.dart';
import '../widgets/aqi_recommendation_card.dart';
import '../widgets/search_overlay.dart';
import '../widgets/radar_map_dialog.dart';
import '../widgets/weather_alerts_dialog.dart';
import '../widgets/forecast_dialogs.dart';
import '../widgets/past_day_card_wrapper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _service = WeatherService();
  WeatherData? _weather;
  String? _error;
  bool _isLoading = true;
  bool _isOffline = false;

  // Selected Location State
  String _cityName = 'Addis Ababa';
  String _countryName = 'Ethiopia';
  double _latitude = 8.9806;
  double _longitude = 38.7578;

  // Search UI State
  bool _isSearching = false;
  bool _isSearchingLoading = false;
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];

  // Toggle for daily: Forecast vs History
  bool _showForecast = true;

  // Hourly selection state
  int? _selectedHourlyIndex;

  @override
  void initState() {
    super.initState();
    _loadLocationAndFetch();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Load last searched location, then pull weather
  Future<void> _loadLocationAndFetch() async {
    try {
      final savedCity = await _service.getSavedCity();
      setState(() {
        _cityName = savedCity['name'];
        _countryName = savedCity['country'] ?? '';
        _latitude = savedCity['latitude'];
        _longitude = savedCity['longitude'];
      });
    } catch (e) {
      debugPrint('Error loading saved location: $e');
    }
    _fetchWeatherData();
  }

  // Fetch weather data, falling back to cache if offline
  Future<void> _fetchWeatherData() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _selectedHourlyIndex = null;
    });

    try {
      final data = await _service.fetchWeather(latitude: _latitude, longitude: _longitude);
      setState(() {
        _weather = data;
        _isOffline = false;
        _isLoading = false;
      });
    } catch (networkError) {
      debugPrint('Network weather fetch failed: $networkError. Checking cache...');
      
      final cachedData = await _service.getCachedWeather();
      if (cachedData != null) {
        setState(() {
          _weather = WeatherData.fromJson(cachedData);
          _isOffline = true;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Unable to fetch weather. Check your internet connection.';
          _isLoading = false;
        });
      }
    }
  }

  // Auto-complete geocoding lookup
  void _onSearchChanged(String query) async {
    if (query.trim().length < 2) {
      setState(() {
        _searchResults = [];
        _isSearchingLoading = false;
      });
      return;
    }

    setState(() {
      _isSearchingLoading = true;
    });

    try {
      final results = await _service.fetchLocations(query);
      if (mounted && _searchController.text == query) {
        setState(() {
          _searchResults = results;
          _isSearchingLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSearchingLoading = false;
        });
      }
    }
  }

  void _onCitySelected(Map<String, dynamic> city) async {
    final selectedCityName = city['name'];
    final selectedCountry = city['country'];
    final selectedLat = city['latitude'];
    final selectedLon = city['longitude'];

    setState(() {
      _isSearching = false;
      _cityName = selectedCityName;
      _countryName = selectedCountry;
      _latitude = selectedLat;
      _longitude = selectedLon;
      _isLoading = true;
    });

    _searchController.clear();
    _searchResults = [];

    await _service.saveSelectedCity(
      selectedCityName,
      selectedCountry,
      selectedLat,
      selectedLon,
    );

    _fetchWeatherData();
  }

  // Dynamic Theme Gradients and Accent Colors based on weather and time of day
  WeatherTheme _getWeatherTheme() {
    if (_weather == null) {
      return WeatherTheme(
        bgGradients: [const Color(0xFF19182C), const Color(0xFF0F0E1E), const Color(0xFF0A0914)],
        glowColor: const Color(0xFFE58843).withOpacity(0.22),
        accentColor: const Color(0xFF38BDF8),
      );
    }

    final bool isNight = _weather!.isNight;
    final int code = _weather!.weatherCode;

    if (isNight) {
      return WeatherTheme(
        bgGradients: [const Color(0xFF0B0A16), const Color(0xFF06050C), const Color(0xFF020105)],
        glowColor: const Color(0xFF8B5CF6).withOpacity(0.2),
        accentColor: const Color(0xFF8B5CF6),
      );
    }

    if (code == 61 || code == 63 || code == 65 || code == 80 || code == 81 || code == 82 || code >= 95) {
      return WeatherTheme(
        bgGradients: [const Color(0xFF151B29), const Color(0xFF0C1019), const Color(0xFF06080D)],
        glowColor: const Color(0xFF38BDF8).withOpacity(0.2),
        accentColor: const Color(0xFF38BDF8),
      );
    }

    if (code <= 3 || code == 45 || code == 48) {
      return WeatherTheme(
        bgGradients: [const Color(0xFF18202B), const Color(0xFF0D1219), const Color(0xFF06090D)],
        glowColor: const Color(0xFF64748B).withOpacity(0.22),
        accentColor: const Color(0xFF64748B),
      );
    }

    return WeatherTheme(
      bgGradients: [const Color(0xFF1B1936), const Color(0xFF0F0E20), const Color(0xFF090814)],
      glowColor: const Color(0xFFE58843).withOpacity(0.26),
      accentColor: const Color(0xFFE58843),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = _getWeatherTheme();

    return Scaffold(
      backgroundColor: theme.bgGradients.last,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: theme.bgGradients,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              if (!_isSearching && !_isLoading && _error == null)
                Positioned(
                  top: 70,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      width: 280,
                      height: 280,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            theme.glowColor,
                            theme.glowColor.withOpacity(0.0),
                          ],
                          radius: 0.75,
                        ),
                      ),
                    ),
                  ),
                ),

              _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.white))
                  : _error != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 48),
                              const SizedBox(height: 16),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 32),
                                child: Text(
                                  _error!,
                                  style: GoogleFonts.inter(color: Colors.red, fontSize: 16),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: _fetchWeatherData,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white24,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                                child: const Text('Try Again'),
                              ),
                            ],
                          ),
                        )
                      : Positioned.fill(
                          child: _buildContent(_weather!, theme),
                        ),

              if (_isSearching)
                SearchOverlayWidget(
                  searchController: _searchController,
                  onSearchChanged: _onSearchChanged,
                  isSearchingLoading: _isSearchingLoading,
                  searchResults: _searchResults,
                  onCancel: () {
                    _searchController.clear();
                    setState(() {
                      _isSearching = false;
                      _searchResults = [];
                    });
                  },
                  onCitySelected: _onCitySelected,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(WeatherData weather, WeatherTheme theme) {
    return Stack(
      children: [
        Positioned.fill(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 90),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => _isSearching = true),
                        child: _buildMenuIcon(theme.accentColor),
                      ),
                      _buildLocationHeader(),
                      GestureDetector(
                        onTap: () => ForecastDialogs.showDetailedCalendarForecast(context, weather),
                        child: Icon(
                          Icons.calendar_month_outlined,
                          color: Colors.white.withOpacity(0.9),
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Column(
                    children: [
                      if (_selectedHourlyIndex != null) ...[
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: theme.accentColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: theme.accentColor.withOpacity(0.4),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.access_time_filled_rounded,
                                  color: theme.accentColor,
                                  size: 14,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Hourly View: ${DateFormat('HH:mm').format(weather.hourlyForecast[_selectedHourlyIndex!].time)}',
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () => setState(() => _selectedHourlyIndex = null),
                                  child: Icon(
                                    Icons.cancel_rounded,
                                    color: Colors.white.withOpacity(0.6),
                                    size: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      Center(
                        child: Image.asset(
                          _selectedHourlyIndex != null
                              ? weather.hourlyForecast[_selectedHourlyIndex!].weatherImage
                              : weather.weatherImage,
                          width: 160,
                          height: 160,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${(_selectedHourlyIndex != null ? weather.hourlyForecast[_selectedHourlyIndex!].temperature : weather.temperature).round()}',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 68,
                          fontWeight: FontWeight.w700,
                          height: 1.0,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 6, left: 2),
                        child: Text(
                          '°',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w300,
                            height: 1.0,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10, left: 4),
                        child: Text(
                          'c',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 38,
                            fontWeight: FontWeight.w400,
                            height: 1.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  Center(
                    child: Text(
                      _selectedHourlyIndex != null
                          ? ForecastDialogs.getWeatherConditionFromCode(weather.hourlyForecast[_selectedHourlyIndex!].weatherCode)
                          : weather.weatherCondition,
                      style: GoogleFonts.inter(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      WeatherInfoItem(
                        icon: Icons.air_rounded,
                        value: '${weather.windSpeed.round()}km/h',
                      ),
                      WeatherInfoItem(
                        icon: Icons.opacity_rounded,
                        value: '${weather.humidity.round().toString().padLeft(2, '0')}%',
                      ),
                      WeatherInfoItem(
                        icon: Icons.wb_sunny_outlined,
                        value: '${weather.daylightHours.toStringAsFixed(1).replaceAll('.0', '')}hr',
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  _buildSectionHeader('Hourly Forecast', theme.accentColor),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: weather.hourlyForecast.length,
                      itemBuilder: (context, index) {
                        final hour = weather.hourlyForecast[index];
                        return HourlyForecastCard(
                          time: hour.time,
                          temperature: hour.temperature,
                          imagePath: hour.weatherImage,
                          isCurrent: index == 0,
                          isSelected: _selectedHourlyIndex == index,
                          onTap: () => setState(() => _selectedHourlyIndex = index),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 28),

                  AqiRecommendationCard(
                    aqi: weather.usAqi,
                    aqiStatus: weather.aqiStatus,
                    aqiColor: weather.aqiColor,
                    pm25: weather.pm25,
                    pm10: weather.pm10,
                    recommendation: weather.activitySuggestion,
                  ),
                  const SizedBox(height: 28),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            color: Colors.white.withOpacity(0.9),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _showForecast ? '7-Day Forecast' : 'Past Days Weather',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.08),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => setState(() => _showForecast = true),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: _showForecast ? theme.accentColor : Colors.transparent,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  'Forecast',
                                  style: GoogleFonts.inter(
                                    color: _showForecast ? Colors.black : Colors.white70,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => setState(() => _showForecast = false),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: !_showForecast ? theme.accentColor : Colors.transparent,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  'History',
                                  style: GoogleFonts.inter(
                                    color: !_showForecast ? Colors.black : Colors.white70,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  _buildDailyList(weather),
                ],
              ),
            ),
          ),
        ),

        Positioned(
          left: 20,
          right: 20,
          bottom: 12,
          child: Container(
            height: 62,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E203B).withOpacity(0.65),
              borderRadius: BorderRadius.circular(31),
              border: Border.all(
                color: Colors.white.withOpacity(0.08),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: () {
                    if (_isSearching) {
                      setState(() {
                        _isSearching = false;
                      });
                    }
                  },
                  child: _buildNavButton(Icons.home_rounded, !_isSearching),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isSearching = !_isSearching;
                    });
                  },
                  child: _buildNavButton(Icons.search_rounded, _isSearching),
                ),
                GestureDetector(
                  onTap: () => WeatherAlertsDialog.show(context, weather),
                  child: _buildNavButton(Icons.notifications_none_rounded, false),
                ),
                GestureDetector(
                  onTap: () => RadarMapDialog.show(context, _cityName),
                  child: _buildNavButton(Icons.map_outlined, false),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, Color accent) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: accent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildDailyList(WeatherData weather) {
    final listItems = _showForecast ? weather.dailyForecast : weather.pastDays;

    final screenWidth = MediaQuery.of(context).size.width;
    final availableWidth = screenWidth - 40;
    final totalMargins = (listItems.length - 1) * 8;
    final minRequiredWidth = (listItems.length * 90) + totalMargins;

    if (availableWidth > minRequiredWidth) {
      return SizedBox(
        height: 124,
        child: Row(
          children: listItems.map((p) {
            final dayLabel = p is DailyForecast ? p.dateLabel : (p as PastDayWeather).dateLabel;
            final temp = p is DailyForecast 
                ? '${p.maxTemp.round()}°' 
                : '${(p as PastDayWeather).maxTemp.round()}°';
            final img = p is DailyForecast ? p.weatherImage : (p as PastDayWeather).weatherImage;

            return Expanded(
              child: PastDayWeatherCardWrapper(
                dayLabel: dayLabel,
                temperature: temp,
                imagePath: img,
                width: null,
                onTap: () => ForecastDialogs.showDaySummaryDialog(context, p),
              ),
            );
          }).toList(),
        ),
      );
    } else {
      return SizedBox(
        height: 124,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: listItems.length,
          itemBuilder: (context, index) {
            final p = listItems[index];
            final dayLabel = p is DailyForecast ? p.dateLabel : (p as PastDayWeather).dateLabel;
            final temp = p is DailyForecast 
                ? '${p.maxTemp.round()}°' 
                : '${(p as PastDayWeather).maxTemp.round()}°';
            final img = p is DailyForecast ? p.weatherImage : (p as PastDayWeather).weatherImage;

            return PastDayWeatherCardWrapper(
              dayLabel: dayLabel,
              temperature: temp,
              imagePath: img,
              width: 90,
              onTap: () => ForecastDialogs.showDaySummaryDialog(context, p),
            );
          },
        ),
      );
    }
  }

  Widget _buildMenuIcon(Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 22,
          height: 2.5,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(1.5),
          ),
        ),
        const SizedBox(height: 5),
        Container(
          width: 14,
          height: 2.5,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(1.5),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationHeader() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        RichText(
          text: TextSpan(
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 16,
            ),
            children: [
              TextSpan(
                text: _cityName,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              if (_countryName.isNotEmpty)
                TextSpan(
                  text: ', $_countryName',
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withOpacity(0.75),
                  ),
                ),
            ],
          ),
        ),
        if (_isOffline) ...[
          const SizedBox(width: 8),
          Tooltip(
            message: 'Offline mode. Showing cached weather.',
            child: Icon(
              Icons.cloud_off_rounded,
              color: Colors.amberAccent.withOpacity(0.8),
              size: 16,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildNavButton(IconData icon, bool isActive) {
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      child: Icon(
        icon,
        color: isActive ? Colors.white : Colors.white.withOpacity(0.4),
        size: 24,
      ),
    );
  }
}
