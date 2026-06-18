import 'package:flutter/material.dart';

class LocationCard extends StatelessWidget {
  const LocationCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row Header
          const Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                color: Color(0xFF0256C2),
                size: 22,
              ),
              SizedBox(width: 8),
              Text(
                'Ubicación',
                style: TextStyle(
                  color: Color(0xFF0256C2),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Av. Javier Prado Este 1250, San Isidro, Lima',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),

          // Map Container
          Stack(
            children: [
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: const Color(0xFFE2E8F0),
                  image: const DecorationImage(
                    image: NetworkImage(
                      'https://api.mapbox.com/styles/v1/mapbox/streets-v11/static/-77.0282,12.0858,14,0/600x300?access_token=mock',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.black.withOpacity(0.05),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.location_pin,
                      color: Color(0xFF0256C2),
                      size: 38,
                    ),
                  ),
                ),
              ),
              // Map badge overlay
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.fullscreen_rounded,
                          color: Color(0xFF64748B),
                          size: 18,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Ver pantalla completa',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
