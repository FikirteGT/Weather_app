import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/weather_models.dart';
import '../services/weather_service.dart';
import '../widgets/weather_info_item.dart';
import '../widgets/past_day_card.dart';

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

  @override
  void initState() {
    super.initState();
    _fetchWeatherData();
  }

  Future<void> _fetchWeatherData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _service.fetchWeather();
      setState(() {
        _weather = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load weather data';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C0B18), // Deep premium dark background
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF19182C),
              Color(0xFF0F0E1E),
              Color(0xFF0A0914),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white))
              : _error != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _error!,
                            style: GoogleFonts.inter(
                                color: Colors.red, fontSize: 16),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _fetchWeatherData,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white24,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Try Again'),
                          ),
                        ],
                      ),
                    )
                  : _buildContent(_weather!),
        ),
      ),
    );
  }

  Widget _buildContent(WeatherData weather) {
    return Stack(
      children: [
        // Glowing orange radial background behind the central weather image
        Positioned(
          top: 70,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFE58843).withOpacity(0.28),
                    const Color(0xFFE58843).withOpacity(0.0),
                  ],
                  radius: 0.75,
                ),
              ),
            ),
          ),
        ),

        // Scrollable content area with padding at the bottom for the floating nav bar
        LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 90),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Custom Top Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildMenuIcon(),
                            _buildLocationHeader(),
                            Icon(
                              Icons.calendar_month_outlined,
                              color: Colors.white.withOpacity(0.9),
                              size: 22,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Main Weather Illustration
                        Center(
                          child: Image.asset(
                            weather.weatherImage,
                            width: 160,
                            height: 160,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Temperature Display
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${weather.temperature.round()}',
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

                        // Weather Expectation/Condition
                        Center(
                          child: Text(
                            weather.weatherCondition,
                            style: GoogleFonts.inter(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Stats Row (Wind, Humidity, Daylight hours)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            WeatherInfoItem(
                              icon: Icons.air_rounded,
                              value: '${weather.windSpeed.round()}km/hr',
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
                        const SizedBox(height: 30),

                        // Past Days Weather Header
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              color: Colors.white.withOpacity(0.9),
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Past Days Weather',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Responsive Past Days Cards Layout
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final availableWidth = constraints.maxWidth;
                            final totalMargins = (weather.pastDays.length - 1) * 8; // margins
                            final minRequiredWidth = (weather.pastDays.length * 90) + totalMargins;

                            if (availableWidth > minRequiredWidth) {
                              // Maximized/Wide Screen: stretch cards evenly
                              return Row(
                                children: weather.pastDays.map((p) {
                                  return Expanded(
                                    child: PastDayCard(
                                      dayLabel: p.dateLabel,
                                      temperature: '${p.maxTemp.round()}°',
                                      imagePath: p.weatherImage,
                                      width: null, // Let Expanded control the width
                                    ),
                                  );
                                }).toList(),
                              );
                            } else {
                              // Narrow Screen: Horizontal scrolling list
                              return SizedBox(
                                height: 112,
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                  children: weather.pastDays.map((p) {
                                    return PastDayCard(
                                      dayLabel: p.dateLabel,
                                      temperature: '${p.maxTemp.round()}°',
                                      imagePath: p.weatherImage,
                                      width: 90, // Fixed width for scrollable view
                                    );
                                  }).toList(),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),

        // Floating Capsule Bottom Navigation Bar
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
                _buildNavButton(Icons.home_rounded, true),
                _buildNavButton(Icons.search_rounded, false),
                _buildNavButton(Icons.notifications_none_rounded, false),
                _buildNavButton(Icons.map_outlined, false),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuIcon() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 22,
          height: 2.5,
          decoration: BoxDecoration(
            color: const Color(0xFF38BDF8),
            borderRadius: BorderRadius.circular(1.5),
          ),
        ),
        const SizedBox(height: 5),
        Container(
          width: 14,
          height: 2.5,
          decoration: BoxDecoration(
            color: const Color(0xFF38BDF8),
            borderRadius: BorderRadius.circular(1.5),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationHeader() {
    return RichText(
      text: TextSpan(
        style: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 16,
        ),
        children: [
          const TextSpan(
            text: 'Addis Ababa',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          TextSpan(
            text: ', Ethiopia',
            style: TextStyle(
              fontWeight: FontWeight.w400,
              color: Colors.white.withOpacity(0.75),
            ),
          ),
        ],
      ),
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
