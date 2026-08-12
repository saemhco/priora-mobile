import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:priora/features/patient/navigation/controller/patient_navigation_controller.dart';
import 'package:priora/features/patient/triage/domain/interfaces/triage_repository.dart';
import 'package:priora/features/patient/triage/domain/models/triage_history_item.dart';
import 'package:priora/features/patient/triage/presentation/controller/triage_state.dart';
import 'package:priora/features/patient/triage/presentation/triage_result_screen.dart';
import 'package:priora/features/patient/triage/presentation/triage_screen.dart';
import 'package:priora/features/patient/triage/presentation/widgets/triage_history_skeleton.dart';
import 'package:priora/features/shared/auth/presentation/controller/auth_bloc.dart';
import 'package:priora/features/shared/auth/presentation/controller/auth_state.dart';

class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key});

  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  List<TriageHistoryItem>? _historyItems;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authState = context.read<AuthBloc>().state;
      final accessToken = authState is AuthAuthenticated
          ? authState.accessToken
          : '';

      final repository = RepositoryProvider.of<TriageRepository>(context);
      final history = await repository.getTriageHistory(
        accessToken: accessToken,
      );

      if (mounted) {
        setState(() {
          _historyItems = history;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final difference = now.difference(dt);

    if (difference.inDays == 0 && now.day == dt.day) {
      final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
      final period = dt.hour >= 12 ? 'PM' : 'AM';
      final minute = dt.minute.toString().padLeft(2, '0');
      return 'Hoy, $hour:$minute $period';
    }

    final months = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  Color _getPriorityColor(String priority) {
    final upper = priority.toUpperCase();
    if (upper == 'CRITICAL' || upper == 'HIGH') {
      return const Color(0xFFEF4444); // Red
    } else if (upper == 'MEDIUM') {
      return const Color(0xFF0E5FD9); // Blue
    } else {
      return const Color(0xFF10B981); // Green
    }
  }

  Color _getPriorityBgColor(String priority) {
    final upper = priority.toUpperCase();
    if (upper == 'CRITICAL' || upper == 'HIGH') {
      return const Color(0xFFFEE2E2);
    } else if (upper == 'MEDIUM') {
      return const Color(0xFFEFF6FF);
    } else {
      return const Color(0xFFD1FAE5);
    }
  }

  String _getPriorityLabel(String priority) {
    final upper = priority.toUpperCase();
    if (upper == 'CRITICAL' || upper == 'HIGH') {
      return 'Urgente';
    } else if (upper == 'MEDIUM') {
      return 'Prioridad Media';
    } else {
      return 'Riesgo Bajo';
    }
  }

  Future<void> _handleNewEvaluation() async {
    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 40,
                  width: 40,
                  child: CircularProgressIndicator(
                    color: Color(0xFF0256C2),
                    strokeWidth: 4,
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  'Verificando',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Buscando evaluaciones pendientes...',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    Map<String, dynamic>? draftData;
    try {
      final authState = context.read<AuthBloc>().state;
      final accessToken = authState is AuthAuthenticated
          ? authState.accessToken
          : '';

      final repository = RepositoryProvider.of<TriageRepository>(context);
      final result = await repository.getTriageDraft(accessToken: accessToken);

      if (result != null && result['draft'] != null) {
        draftData = result['draft'] as Map<String, dynamic>?;
      }
    } catch (_) {
      // If loading draft fails, just ignore and proceed
    }

    if (mounted) {
      Navigator.pop(context); // Close loading spinner

      if (draftData != null) {
        unawaited(
          showDialog<void>(
            context: context,
            builder: (dialogContext) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                title: const Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: Color(0xFF0256C2),
                      size: 28,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Evaluación pendiente',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
                content: const Text(
                  'Tienes una evaluación de síntomas en progreso. ¿Deseas continuarla o iniciar una nueva desde cero?',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                    height: 1.4,
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () async {
                      Navigator.pop(dialogContext); // Close dialog
                      final navigationCubit = context
                          .read<PatientNavigationCubit>();
                      await Navigator.push<void>(
                        context,
                        MaterialPageRoute<void>(
                          builder: (context) =>
                              TriageScreen(navigationCubit: navigationCubit),
                        ),
                      );
                      await _fetchHistory();
                    },
                    child: const Text(
                      'Iniciar nueva',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(dialogContext); // Close dialog
                      final navigationCubit = context
                          .read<PatientNavigationCubit>();
                      await Navigator.push<void>(
                        context,
                        MaterialPageRoute<void>(
                          builder: (context) => TriageScreen(
                            initialDraft: draftData,
                            navigationCubit: navigationCubit,
                          ),
                        ),
                      );
                      await _fetchHistory();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0256C2),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Continuar',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      } else {
        final navigationCubit = context.read<PatientNavigationCubit>();
        await Navigator.push<void>(
          context,
          MaterialPageRoute<void>(
            builder: (context) =>
                TriageScreen(navigationCubit: navigationCubit),
          ),
        );
        await _fetchHistory();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchHistory,
          color: const Color(0xFF0256C2),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Historial de Triajes',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Revisa tus evaluaciones preventivas anteriores.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: _handleNewEvaluation,
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFEFF6FF), // extremely light blue
                                Color(0xFFECFDF5), // extremely light mint/teal
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(
                                0xFFBFDBFE,
                              ), // Soft blue border
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withValues(alpha: 0.02),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF0256C2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '¿Deseas una nueva evaluación?',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                    SizedBox(height: 1),
                                    Text(
                                      'Inicia una evaluación de síntomas con IA.',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right_rounded,
                                color: Color(0xFF64748B),
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 13),
                    ],
                  ),
                ),
              ),
              if (_isLoading)
                const SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverToBoxAdapter(child: TriageHistorySkeleton()),
                )
              else if (_errorMessage != null)
                SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline_rounded,
                            size: 48,
                            color: Colors.redAccent,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _fetchHistory,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0256C2),
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else if (_historyItems == null || _historyItems!.isEmpty)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.assignment_outlined,
                              size: 48,
                              color: Color(0xFF94A3B8),
                            ),
                            SizedBox(height: 12),
                            Text(
                              'No tienes evaluaciones previas.',
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final item = _historyItems![index];
                      final priorityColor = _getPriorityColor(item.priority);
                      final priorityBg = _getPriorityBgColor(item.priority);
                      final priorityLabel = _getPriorityLabel(item.priority);

                      return GestureDetector(
                        onTap: () async {
                          unawaited(
                            showDialog<void>(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => Dialog(
                                elevation: 0,
                                backgroundColor: Colors.transparent,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 28,
                                    horizontal: 24,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.08,
                                        ),
                                        blurRadius: 24,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: const Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        height: 40,
                                        width: 40,
                                        child: CircularProgressIndicator(
                                          color: Color(0xFF0256C2),
                                          strokeWidth: 4,
                                        ),
                                      ),
                                      SizedBox(height: 24),
                                      Text(
                                        'Cargando',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1E293B),
                                        ),
                                      ),
                                      SizedBox(height: 6),
                                      Text(
                                        'Obteniendo resultados del triaje...',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );

                          try {
                            final authState = context.read<AuthBloc>().state;
                            final accessToken = authState is AuthAuthenticated
                                ? authState.accessToken
                                : '';

                            final repository =
                                RepositoryProvider.of<TriageRepository>(
                                  context,
                                );
                            final result = await repository.getTriageResult(
                              accessToken: accessToken,
                              id: item.id,
                            );

                            if (context.mounted) {
                              Navigator.pop(context); // Close loading dialog

                              final rawSpecialties =
                                  result['suggestedSpecialties'];
                              var specs = <String>[];
                              if (rawSpecialties is List) {
                                specs = rawSpecialties
                                    .map((s) => s.toString())
                                    .toList();
                              } else if (result['suggestedSpecialty'] != null) {
                                specs = [
                                  result['suggestedSpecialty'].toString(),
                                ];
                              }

                              final state = TriageState(
                                priority: result['priority']?.toString(),
                                suggestedSpecialty: result['suggestedSpecialty']
                                    ?.toString(),
                                suggestedSpecialties: specs,
                                patientSafeMessage: result['patientSafeMessage']
                                    ?.toString(),
                                isCompleted: true,
                                currentStep: 4,
                              );

                              final navigationCubit = context
                                  .read<PatientNavigationCubit>();
                              await Navigator.push<void>(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (context) => TriageResultScreen(
                                    state: state,
                                    navigationCubit: navigationCubit,
                                  ),
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              Navigator.pop(context); // Close loading dialog
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error al cargar detalle: $e'),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                            }
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            border: Border.all(
                              color: const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Container(
                                  width: 5,
                                  decoration: BoxDecoration(
                                    color: priorityColor,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(16),
                                      bottomLeft: Radius.circular(16),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              _formatDate(item.createdAt),
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Color(0xFF64748B),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: priorityBg,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                priorityLabel,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  color: priorityColor,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          item.symptoms ??
                                              'Evaluación de síntomas',
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1E293B),
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.medical_services_outlined,
                                              size: 14,
                                              color: priorityColor,
                                            ),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                'Sugerencia: ${item.suggestedSpecialty ?? "Evaluación general"}',
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  color: Color(0xFF64748B),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const Icon(
                                              Icons.chevron_right_rounded,
                                              size: 18,
                                              color: Color(0xFF64748B),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }, childCount: _historyItems?.length ?? 0),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
