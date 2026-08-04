import 'package:flutter/material.dart';

/// Base widget que provee la animación de "shimmer" (pulso de opacidad)
/// usada por todos los skeletons de la agenda.
class _ShimmerSkeleton extends StatefulWidget {
  final Widget child;

  const _ShimmerSkeleton({required this.child});

  @override
  State<_ShimmerSkeleton> createState() => _ShimmerSkeletonState();
}

class _ShimmerSkeletonState extends State<_ShimmerSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.35, end: 0.85).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(opacity: _animation.value, child: child);
      },
      child: widget.child,
    );
  }
}

/// Bloque base con la paleta de skeletons del proyecto.
class _SkeletonBlock extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;
  final Color color;

  const _SkeletonBlock({
    this.width,
    this.height = 14,
    this.radius = 6,
    this.color = const Color(0xFFE2E8F0),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

// ─── Today appointments skeleton ─────────────────────────────────────────────

/// Skeleton para la sección "Citas de hoy" (con tarjetas de citas y próximas).
class TodayAppointmentsSkeleton extends StatelessWidget {
  const TodayAppointmentsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return _ShimmerSkeleton(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(),
          const SizedBox(height: 10),
          _buildAppointmentCard(compact: false),
          const SizedBox(height: 10),
          _buildAppointmentCard(compact: false),
          const SizedBox(height: 16),
          _SkeletonBlock(
            width: 110,
            height: 12,
            color: const Color(0xFFF1F5F9),
          ),
          const SizedBox(height: 10),
          _buildAppointmentCard(compact: true),
          const SizedBox(height: 10),
          _buildAppointmentCard(compact: true),
        ],
      ),
    );
  }

  Widget _buildSectionTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _SkeletonBlock(width: 110, height: 16, radius: 8),
        _SkeletonBlock(
          width: 60,
          height: 12,
          color: const Color(0xFFF1F5F9),
        ),
      ],
    );
  }

  Widget _buildAppointmentCard({required bool compact}) {
    final avatarSize = compact ? 36.0 : 44.0;
    final nameSize = compact ? 13.0 : 15.0;
    final metaSize = compact ? 12.0 : 13.0;

    return Container(
      padding: EdgeInsets.all(compact ? 12 : 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          _SkeletonBlock(
            width: avatarSize,
            height: avatarSize,
            radius: avatarSize / 2,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _SkeletonBlock(width: 130, height: nameSize, radius: 6),
                    const SizedBox(width: 8),
                    _SkeletonBlock(
                      width: 52,
                      height: 14,
                      radius: 4,
                      color: const Color(0xFFEFF6FF),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _SkeletonBlock(width: 60, height: metaSize, radius: 4),
                    const SizedBox(width: 10),
                    _SkeletonBlock(
                      width: 70,
                      height: 16,
                      radius: 10,
                      color: const Color(0xFFECFDF5),
                    ),
                  ],
                ),
                if (!compact) ...[
                  const SizedBox(height: 6),
                  _SkeletonBlock(
                    width: 150,
                    height: metaSize,
                    radius: 4,
                    color: const Color(0xFFF1F5F9),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Location selector skeleton ───────────────────────────────────────────────

/// Skeleton compacto para el selector de "Filtrar por" cuando cargan los
/// lugares.
class LocationSelectorSkeleton extends StatelessWidget {
  const LocationSelectorSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return _ShimmerSkeleton(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            const _SkeletonBlock(
              width: 20,
              height: 20,
              radius: 4,
              color: Color(0xFFCBD5E1),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SkeletonBlock(width: 140, height: 14, radius: 6),
                  const SizedBox(height: 6),
                  _SkeletonBlock(
                    width: 90,
                    height: 10,
                    radius: 5,
                    color: const Color(0xFFF1F5F9),
                  ),
                ],
              ),
            ),
            const _SkeletonBlock(
              width: 14,
              height: 14,
              radius: 4,
              color: Color(0xFFCBD5E1),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Calendar grid skeleton ──────────────────────────────────────────────────

/// Skeleton del calendario semanal (encabezado de días + filas de horas).
class AgendaCalendarSkeleton extends StatelessWidget {
  const AgendaCalendarSkeleton({super.key});

  static const int _rowCount = 5;

  @override
  Widget build(BuildContext context) {
    return _ShimmerSkeleton(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        clipBehavior: Clip.antiAlias,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              for (int i = 0; i < _rowCount; i++) _buildRow(i),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const SizedBox(width: 60),
        for (int i = 0; i < 7; i++)
          Container(
            width: 100,
            height: 44,
            decoration: BoxDecoration(
              color: i == DateTime.now().weekday - 1
                  ? const Color(0xFFEFF6FF)
                  : const Color(0xFFF8FAFC),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 0.5,
              ),
            ),
            child: Center(
              child: _SkeletonBlock(
                width: 28,
                height: 10,
                radius: 4,
                color: i == DateTime.now().weekday - 1
                    ? const Color(0xFFBFDBFE)
                    : const Color(0xFFE2E8F0),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRow(int rowIndex) {
    return Row(
      children: [
        SizedBox(
          width: 60,
          height: 60,
          child: Center(
            child: _SkeletonBlock(width: 32, height: 10, radius: 4),
          ),
        ),
        for (int col = 0; col < 7; col++) _buildCell(rowIndex, col),
      ],
    );
  }

  Widget _buildCell(int rowIndex, int colIndex) {
    final hasBlock = (rowIndex + colIndex) % 3 == 0;
    return Container(
      width: 100,
      height: 60,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFF1F5F9), width: 0.5),
        color: const Color(0xFFF8FAFC),
      ),
      child: hasBlock
          ? Container(
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border(
                  left: BorderSide(
                    color: const Color(0xFFBFDBFE),
                    width: 3,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const _SkeletonBlock(
                    width: 12,
                    height: 12,
                    radius: 6,
                    color: Color(0xFFCBD5E1),
                  ),
                  const SizedBox(width: 4),
                  _SkeletonBlock(
                    width: 38,
                    height: 9,
                    radius: 4,
                    color: const Color(0xFFE2E8F0),
                  ),
                ],
              ),
            )
          : null,
    );
  }
}
