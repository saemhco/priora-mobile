import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:priora/features/patient/navigation/controller/patient_navigation_controller.dart';
import 'package:priora/features/patient/triage/controller/triage_cubit.dart';
import 'package:priora/features/patient/triage/data/triage_history_item.dart';
import 'package:priora/features/patient/triage/data/triage_repository.dart';
import 'package:priora/features/patient/triage/presentation/triage_result_screen.dart';
import 'package:priora/features/patient/triage/presentation/triage_screen.dart';
import 'package:priora/features/shared/auth/data/auth_bloc.dart';
import 'package:priora/features/shared/auth/data/auth_state.dart';

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
      final accessToken = authState is AuthAuthenticated ? authState.accessToken : '';

      final repository = RepositoryProvider.of<TriageRepository>(context);
      final history = await repository.getTriageHistory(accessToken: accessToken);

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
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
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
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
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
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              if (_isLoading)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF0256C2),
                    ),
                  ),
                )
              else if (_errorMessage != null)
                SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline_rounded, size: 48, color: Colors.redAccent),
                          const SizedBox(height: 12),
                          Text(
                            _errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _fetchHistory,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0256C2),
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Reintentar'),
                          )
                        ],
                      ),
                    ),
                  ),
                )
              else if (_historyItems == null || _historyItems!.isEmpty)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  sliver: SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 40.0),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.assignment_outlined, size: 48, color: Color(0xFF94A3B8)),
                            SizedBox(height: 12),
                            Text(
                              'No tienes evaluaciones previas.',
                              style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item = _historyItems![index];
                        final priorityColor = _getPriorityColor(item.priority);
                        final priorityBg = _getPriorityBgColor(item.priority);
                        final priorityLabel = _getPriorityLabel(item.priority);

                        return GestureDetector(
                          onTap: () async {
                            showDialog(
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
                                        color: Colors.black.withOpacity(0.08),
                                        blurRadius: 24,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const SizedBox(
                                        height: 40,
                                        width: 40,
                                        child: CircularProgressIndicator(
                                          color: Color(0xFF0256C2),
                                          strokeWidth: 4,
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      const Text(
                                        'Cargando',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1E293B),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      const Text(
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
                            );

                            try {
                              final authState = context.read<AuthBloc>().state;
                              final accessToken = authState is AuthAuthenticated ? authState.accessToken : '';

                              final repository = RepositoryProvider.of<TriageRepository>(context);
                              final result = await repository.getTriageResult(
                                accessToken: accessToken,
                                id: item.id,
                              );

                              if (context.mounted) {
                                Navigator.pop(context); // Close loading dialog

                                final rawSpecialties = result['suggestedSpecialties'];
                                List<String> specs = [];
                                if (rawSpecialties is List) {
                                  specs = rawSpecialties.map((s) => s.toString()).toList();
                                } else if (result['suggestedSpecialty'] != null) {
                                  specs = [result['suggestedSpecialty'].toString()];
                                }

                                final state = TriageState(
                                  priority: result['priority']?.toString(),
                                  suggestedSpecialty: result['suggestedSpecialty']?.toString(),
                                  suggestedSpecialties: specs,
                                  patientSafeMessage: result['patientSafeMessage']?.toString(),
                                  isCompleted: true,
                                  currentStep: 4,
                                );

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TriageResultScreen(state: state),
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
                            margin: const EdgeInsets.only(bottom: 16.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.02),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                                width: 1,
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
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: priorityBg,
                                                  borderRadius: BorderRadius.circular(12),
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
                                            item.symptoms ?? 'Evaluación de síntomas',
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
                      },
                      childCount: _historyItems?.length ?? 0,
                    ),
                  ),
                ),
              SliverPadding(
                padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0, top: 10.0),
                sliver: SliverToBoxAdapter(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFF76F2E3), // Solid bright cyan from mockup
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '¿Deseas una nueva evaluación?',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF084B48), // Dark teal/green
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Nuestro asistente virtual te guiará en el proceso preventivo.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF084B48), // Dark teal/green
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () async {
                            showDialog(
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
                                        color: Colors.black.withOpacity(0.08),
                                        blurRadius: 24,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const SizedBox(
                                        height: 40,
                                        width: 40,
                                        child: CircularProgressIndicator(
                                          color: Color(0xFF0256C2),
                                          strokeWidth: 4,
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      const Text(
                                        'Verificando',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1E293B),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      const Text(
                                        'Buscando evaluaciones pendientes...',
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
                            );

                            Map<String, dynamic>? draftData;
                            try {
                              final authState = context.read<AuthBloc>().state;
                              final accessToken = authState is AuthAuthenticated ? authState.accessToken : '';

                              final repository = RepositoryProvider.of<TriageRepository>(context);
                              final result = await repository.getTriageDraft(accessToken: accessToken);
                              
                              if (result != null && result['draft'] != null) {
                                draftData = result['draft'] as Map<String, dynamic>?;
                              }
                            } catch (_) {
                              // If loading draft fails, just ignore and proceed
                            }

                            if (context.mounted) {
                              Navigator.pop(context); // Close loading spinner

                              if (draftData != null) {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext dialogContext) {
                                    return AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      title: const Row(
                                        children: [
                                          Icon(Icons.info_outline_rounded, color: Color(0xFF0256C2), size: 28),
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
                                          onPressed: () {
                                            Navigator.pop(dialogContext); // Close dialog
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => const TriageScreen(),
                                              ),
                                            ).then((_) => _fetchHistory());
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
                                          onPressed: () {
                                            Navigator.pop(dialogContext); // Close dialog
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => TriageScreen(initialDraft: draftData),
                                              ),
                                            ).then((_) => _fetchHistory());
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
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const TriageScreen(),
                                  ),
                                ).then((_) {
                                  _fetchHistory();
                                });
                              }
                            }
                          },
                          icon: const Icon(Icons.add, size: 18, color: Colors.white),
                          label: const Text(
                            'Nueva Evaluación',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0256C2), // Dark blue
                            foregroundColor: Colors.white,
                            shape: const StadiumBorder(), // Pill shaped button
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
