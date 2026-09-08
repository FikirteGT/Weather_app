// lib/widgets/favorites_dialog.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Model representing a bookmarked favorite city.
class FavoriteCity {
  final String name;
  final String country;
  final double latitude;
  final double longitude;

  const FavoriteCity({
    required this.name,
    required this.country,
    required this.latitude,
    required this.longitude,
  });
}

/// Default list of popular initial favorite locations.
const List<FavoriteCity> defaultFavoriteCities = [
  FavoriteCity(name: 'Addis Ababa', country: 'Ethiopia', latitude: 8.9806, longitude: 38.7578),
  FavoriteCity(name: 'Hawassa', country: 'Ethiopia', latitude: 7.0621, longitude: 38.4763),
  FavoriteCity(name: 'Dire Dawa', country: 'Ethiopia', latitude: 9.5931, longitude: 41.8661),
  FavoriteCity(name: 'Bahir Dar', country: 'Ethiopia', latitude: 11.5742, longitude: 37.3614),
  FavoriteCity(name: 'London', country: 'United Kingdom', latitude: 51.5074, longitude: -0.1278),
  FavoriteCity(name: 'Tokyo', country: 'Japan', latitude: 35.6762, longitude: 139.6503),
];

/// FavoritesWidget displays a glass overlay listing saved favorite cities,
/// allowing the user to select any city to view its live weather.
class FavoritesWidget extends StatelessWidget {
  final List<FavoriteCity> favoriteCities;
  final FavoriteCity currentCity;
  final Function(FavoriteCity city) onCitySelected;
  final Function(FavoriteCity city) onRemoveFavorite;
  final VoidCallback onClose;

  const FavoritesWidget({
    super.key,
    required this.favoriteCities,
    required this.currentCity,
    required this.onCitySelected,
    required this.onRemoveFavorite,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          color: const Color(0xFF0A0914).withValues(alpha: 0.8),
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.favorite_rounded,
                          color: Color(0xFF38BDF8),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Favorite Cities',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: onClose,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Colors.white70,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Favorites List
              Expanded(
                child: favoriteCities.isEmpty
                    ? Center(
                        child: Text(
                          'No favorite cities added yet.\nTap the heart icon on top to bookmark cities!',
                          style: GoogleFonts.inter(
                            color: Colors.white60,
                            fontSize: 14,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        itemCount: favoriteCities.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final city = favoriteCities[index];
                          final bool isSelected = city.name.toLowerCase() == currentCity.name.toLowerCase();

                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => onCitySelected(city),
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF38BDF8).withValues(alpha: 0.18)
                                      : Colors.white.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF38BDF8).withValues(alpha: 0.6)
                                        : Colors.white.withValues(alpha: 0.08),
                                    width: isSelected ? 1.5 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.location_city_rounded,
                                      color: isSelected ? const Color(0xFF38BDF8) : Colors.white70,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            city.name,
                                            style: GoogleFonts.inter(
                                              color: Colors.white,
                                              fontSize: 15,
                                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            city.country,
                                            style: GoogleFonts.inter(
                                              color: Colors.white60,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (isSelected)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF38BDF8).withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          'Active',
                                          style: GoogleFonts.inter(
                                            color: const Color(0xFF38BDF8),
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      )
                                    else
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline_rounded, color: Colors.white38, size: 20),
                                        onPressed: () => onRemoveFavorite(city),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
