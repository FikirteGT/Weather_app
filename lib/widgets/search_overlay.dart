import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchOverlayWidget extends StatelessWidget {
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final bool isSearchingLoading;
  final List<Map<String, dynamic>> searchResults;
  final VoidCallback onCancel;
  final Function(Map<String, dynamic> city) onCitySelected;

  const SearchOverlayWidget({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.isSearchingLoading,
    required this.searchResults,
    required this.onCancel,
    required this.onCitySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          color: const Color(0xFF0A0914).withOpacity(0.75),
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Search Input Row
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.12),
                          width: 1,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search_rounded,
                            color: Colors.white.withOpacity(0.6),
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: searchController,
                              onChanged: onSearchChanged,
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 15,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Search city...',
                                hintStyle: GoogleFonts.inter(
                                  color: Colors.white.withOpacity(0.35),
                                  fontSize: 15,
                                ),
                                border: InputBorder.none,
                              ),
                              autofocus: true,
                            ),
                          ),
                          if (searchController.text.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                searchController.clear();
                                onSearchChanged('');
                              },
                              child: Icon(
                                Icons.close_rounded,
                                color: Colors.white.withOpacity(0.6),
                                size: 20,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: onCancel,
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF38BDF8),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Search Results List
              Expanded(
                child: isSearchingLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white30),
                      )
                    : searchResults.isEmpty
                        ? Center(
                            child: Text(
                              searchController.text.length < 2
                                  ? 'Type a city name to search'
                                  : 'No matching cities found',
                              style: GoogleFonts.inter(
                                color: Colors.white.withOpacity(0.4),
                                fontSize: 14,
                              ),
                            ),
                          )
                        : ListView.separated(
                            physics: const BouncingScrollPhysics(),
                            itemCount: searchResults.length,
                            separatorBuilder: (context, index) => Divider(
                              color: Colors.white.withOpacity(0.05),
                              height: 1,
                            ),
                            itemBuilder: (context, index) {
                              final city = searchResults[index];
                              final String title = city['name'];
                              final String subtitle = [
                                if (city['admin1'].toString().isNotEmpty) city['admin1'],
                                if (city['country'].toString().isNotEmpty) city['country'],
                              ].join(', ');

                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                title: Text(
                                  title,
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(
                                  subtitle,
                                  style: GoogleFonts.inter(
                                    color: Colors.white.withOpacity(0.5),
                                    fontSize: 12,
                                  ),
                                ),
                                trailing: const Icon(
                                  Icons.location_on_outlined,
                                  color: Color(0xFF38BDF8),
                                  size: 20,
                                ),
                                onTap: () => onCitySelected(city),
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
