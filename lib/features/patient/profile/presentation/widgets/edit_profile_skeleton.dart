import 'package:flutter/material.dart';
import 'package:priora/core/widgets/shimmer.dart';

/// Loading skeleton for profile edit screen.
class EditProfileSkeleton extends StatelessWidget {
  const EditProfileSkeleton({super.key});

  Widget _block({double height = 16, double? width, double radius = 10}) {
    return Container(
      height: height,
      width: width ?? double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _fieldSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _block(height: 12, width: 100),
        const SizedBox(height: 8),
        _block(height: 48, radius: 14),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      duration: const Duration(milliseconds: 1100),
      begin: 0.3,
      end: 0.8,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar + title
            const Center(
              child: CircleAvatar(
                radius: 44,
                backgroundColor: Color(0xFFE2E8F0),
              ),
            ),
            const SizedBox(height: 8),
            Center(child: _block(height: 14, width: 140)),
            const SizedBox(height: 24),

            // Card 1: Personal info
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _block(height: 18, width: 160),
                  const SizedBox(height: 20),
                  _fieldSkeleton(),
                  const SizedBox(height: 18),
                  _fieldSkeleton(),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(child: _fieldSkeleton()),
                      const SizedBox(width: 16),
                      Expanded(child: _fieldSkeleton()),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _fieldSkeleton(),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Card 2: Contact info
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _block(height: 18, width: 140),
                  const SizedBox(height: 20),
                  _fieldSkeleton(),
                  const SizedBox(height: 18),
                  _fieldSkeleton(),
                  const SizedBox(height: 18),
                  _fieldSkeleton(),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Card 3: Gender / health
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _block(height: 18, width: 160),
                  const SizedBox(height: 20),
                  _fieldSkeleton(),
                  const SizedBox(height: 18),
                  _fieldSkeleton(),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Card 4: Location
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _block(height: 18, width: 120),
                  const SizedBox(height: 16),
                  _block(height: 140, radius: 16),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Save button placeholder
            _block(height: 50, radius: 16),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
