import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:priora/features/doctor/profile/controller/doctor_profile_cubit.dart';
import 'package:priora/features/doctor/profile/controller/doctor_profile_state.dart';
import 'package:priora/features/doctor/profile/data/models/doctor_profile_model.dart';

class EditDoctorProfileScreen extends StatefulWidget {
  final DoctorProfileCubit? cubit;

  const EditDoctorProfileScreen({super.key, this.cubit});

  @override
  State<EditDoctorProfileScreen> createState() => _EditDoctorProfileScreenState();
}

class _EditDoctorProfileScreenState extends State<EditDoctorProfileScreen> {
  static const List<String> _docTypes = [
    'DNI',
    'CARNET_EXTRANJERIA',
    'PASAPORTE',
  ];

  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _documentIdController;
  late final TextEditingController _phoneController;
  late final TextEditingController _bioController;

  String _documentType = 'DNI';
  bool _isLoadingProfile = true;
  bool _isSubmitting = false;
  String? _submitError;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _documentIdController = TextEditingController();
    _phoneController = TextEditingController();
    _bioController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isLoadingProfile) {
      _loadProfile();
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _documentIdController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _loadProfile() {
    DoctorProfileModel? profile = widget.cubit?.state.profile;
    if (profile == null) {
      try {
        profile = context.read<DoctorProfileCubit>().state.profile;
      } catch (_) {
        profile = null;
      }
    }

    // El backend puede enviar solo `name` (ej. "Edgar Porras") sin
    // firstName/lastName separados. Derivar de displayName como respaldo.
    final fullName = profile?.displayName ?? '';
    final nameParts = fullName.trim().isEmpty
        ? const <String>[]
        : fullName.trim().split(RegExp(r'\s+'));

    String? firstName = profile?.firstName;
    String? lastName = profile?.lastName;
    if ((firstName == null || firstName.isEmpty) && nameParts.isNotEmpty) {
      firstName = nameParts.first;
    }
    if ((lastName == null || lastName.isEmpty) && nameParts.length > 1) {
      lastName = nameParts.sublist(1).join(' ');
    }

    _firstNameController.text = firstName ?? '';
    _lastNameController.text = lastName ?? '';
    _documentIdController.text = profile?.documentId ?? '';
    _phoneController.text = profile?.phone ?? '';
    _bioController.text = profile?.bio ?? '';
    _documentType = profile?.documentType ?? 'DNI';
    if (!_docTypes.contains(_documentType)) {
      _documentType = 'DNI';
    }

    if (mounted) {
      setState(() => _isLoadingProfile = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _submitError = null;
    });

    final data = <String, dynamic>{
      'firstName': _firstNameController.text.trim(),
      'lastName': _lastNameController.text.trim(),
      'documentType': _documentType,
      'documentId': _documentIdController.text.trim(),
      'phone': _phoneController.text.trim(),
      'bio': _bioController.text.trim(),
    };

    final result = await (widget.cubit ?? context.read<DoctorProfileCubit>())
        .updateProfile(data: data);
    if (!mounted) return;

    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil actualizado correctamente'),
          backgroundColor: Color(0xFF059669),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop();
    } else {
      setState(() {
        _isSubmitting = false;
        _submitError = result.message ??
            'Error al actualizar el perfil. Inténtalo de nuevo.';
      });
    }
  }

  InputDecoration _buildDecoration({
    required String hintText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 15),
      fillColor: const Color(0xFFF1F5F9),
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF0256C2), width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      suffixIcon: suffixIcon,
    );
  }

  @override
  Widget build(BuildContext context) {
    final Widget screen = Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Editar Perfil',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoadingProfile
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF0256C2)),
              )
            : BlocBuilder<DoctorProfileCubit, DoctorProfileState>(
                builder: (context, state) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          _buildFieldCard(
                            children: [
                              const Text(
                                'Información Personal',
                                style: TextStyle(
                                  color: Color(0xFF0256C2),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 18),
                              _buildLabel('Nombre'),
                              TextFormField(
                                controller: _firstNameController,
                                enabled: !_isSubmitting,
                                validator: (val) =>
                                    val == null || val.trim().isEmpty
                                    ? 'Requerido'
                                    : null,
                                style: const TextStyle(
                                  color: Color(0xFF1E293B),
                                  fontSize: 15,
                                ),
                                decoration: _buildDecoration(
                                  hintText: 'Nombre',
                                ),
                              ),
                              const SizedBox(height: 18),
                              _buildLabel('Apellido'),
                              TextFormField(
                                controller: _lastNameController,
                                enabled: !_isSubmitting,
                                validator: (val) =>
                                    val == null || val.trim().isEmpty
                                    ? 'Requerido'
                                    : null,
                                style: const TextStyle(
                                  color: Color(0xFF1E293B),
                                  fontSize: 15,
                                ),
                                decoration: _buildDecoration(
                                  hintText: 'Apellido',
                                ),
                              ),
                              const SizedBox(height: 18),
                              _buildLabel('Tipo de Documento'),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _documentType,
                                    isExpanded: true,
                                    style: const TextStyle(
                                      color: Color(0xFF1E293B),
                                      fontSize: 15,
                                    ),
                                    icon: const Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: Color(0xFF64748B),
                                    ),
                                    onChanged: _isSubmitting
                                        ? null
                                        : (value) {
                                            if (value != null) {
                                              setState(
                                                () => _documentType = value,
                                              );
                                            }
                                          },
                                    items: _docTypes
                                        .map(
                                          (t) => DropdownMenuItem(
                                            value: t,
                                            child: Text(t),
                                          ),
                                        )
                                        .toList(),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),
                              _buildLabel('Número de Documento'),
                              TextFormField(
                                controller: _documentIdController,
                                enabled: !_isSubmitting,
                                validator: (val) =>
                                    val == null || val.trim().isEmpty
                                    ? 'Requerido'
                                    : null,
                                style: const TextStyle(
                                  color: Color(0xFF1E293B),
                                  fontSize: 15,
                                ),
                                decoration: _buildDecoration(
                                  hintText: 'Número de Documento',
                                ),
                              ),
                              const SizedBox(height: 18),
                              _buildLabel('Teléfono de contacto'),
                              TextFormField(
                                controller: _phoneController,
                                enabled: !_isSubmitting,
                                keyboardType: TextInputType.phone,
                                style: const TextStyle(
                                  color: Color(0xFF1E293B),
                                  fontSize: 15,
                                ),
                                decoration: _buildDecoration(
                                  hintText: '+51 987 654 321',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          _buildFieldCard(
                            children: [
                              const Text(
                                'Biografía',
                                style: TextStyle(
                                  color: Color(0xFF0256C2),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Esta presentación la verán los pacientes al reservar una cita contigo.',
                                style: TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _bioController,
                                enabled: !_isSubmitting,
                                maxLines: 6,
                                minLines: 4,
                                maxLength: 1000,
                                textCapitalization: TextCapitalization.sentences,
                                style: const TextStyle(
                                  color: Color(0xFF1E293B),
                                  fontSize: 15,
                                ),
                                decoration: _buildDecoration(
                                  hintText:
                                      'Cuéntales a tus pacientes sobre tu experiencia y especialidad…',
                                ),
                              ),
                            ],
                          ),
                          if (_submitError != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF2F2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFFECACA),
                                ),
                              ),
                              child: Text(
                                _submitError!,
                                style: const TextStyle(
                                  color: Color(0xFFB91C1C),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _isSubmitting ? null : _save,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0256C2),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (_isSubmitting) ...[
                                    const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    const Text(
                                      'Guardando…',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ] else ...[
                                    const Text(
                                      'Guardar Cambios',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.check_circle_outline,
                                      size: 20,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );

    final cubit = widget.cubit;
    if (cubit == null) return screen;
    return BlocProvider<DoctorProfileCubit>.value(
      value: cubit,
      child: screen,
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF475569),
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildFieldCard({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x050F172A),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}
