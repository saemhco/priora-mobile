import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:priora/core/widgets/static_map_preview.dart';
import 'package:priora/features/patient/profile/presentation/controller/edit_profile_controller.dart';
import 'package:priora/features/patient/profile/presentation/controller/profile_cubit.dart';
import 'package:priora/features/patient/profile/presentation/controller/profile_state.dart';
import 'package:priora/features/patient/profile/presentation/widgets/edit_profile_skeleton.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final EditProfileController _controller;

  @override
  void initState() {
    super.initState();
    _controller = EditProfileController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.loadProfile(context);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _selectLocationFromMap() async {
    final result = await context.push<Map<String, double>>(
      '/map-picker',
      extra: {
        'latitude': _controller.latitude ?? -12.046374,
        'longitude': _controller.longitude ?? -77.042793,
      },
    );
    if (result != null) {
      final lat = result['latitude'];
      final lng = result['longitude'];
      if (lat != null && lng != null) {
        _controller.setCoordinates(lat, lng);
      }
    }
  }

  InputDecoration _buildInputDecoration({
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
    final theme = Theme.of(context);

    return BlocListener<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state is ProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state is ProfileUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Perfil actualizado exitosamente'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          context.pop(); // Return to previous profile screen
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
            onPressed: () => context.pop(),
          ),
        ),
        body: SafeArea(
          child: ListenableBuilder(
            listenable: _controller,
            builder: (context, child) {
              if (_controller.loadingProfile) {
                return const EditProfileSkeleton();
              }

              return BlocBuilder<ProfileCubit, ProfileState>(
                builder: (context, state) {
                  final isLoading = state is ProfileUpdating;

                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header section
                          Text(
                            'Editar Perfil',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: const Color(0xFF0F172A),
                              fontWeight: FontWeight.w800,
                              fontSize: 26,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Actualiza tu información personal para una atención personalizada.',
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 28),

                          // Personal Info Card
                          Container(
                            margin: const EdgeInsets.only(bottom: 24),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: const Color(0xFFF1F5F9),
                              ),
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
                              children: [
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.person,
                                      color: Color(0xFF0256C2),
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Información Personal',
                                      style: TextStyle(
                                        color: Color(0xFF0256C2),
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 18),

                                const Text(
                                  'Nombre',
                                  style: TextStyle(
                                    color: Color(0xFF475569),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _controller.nombreController,
                                  enabled: !isLoading,
                                  validator: (val) =>
                                      val == null || val.trim().isEmpty
                                      ? 'Requerido'
                                      : null,
                                  style: const TextStyle(
                                    color: Color(0xFF1E293B),
                                    fontSize: 15,
                                  ),
                                  decoration: _buildInputDecoration(
                                    hintText: 'Nombre',
                                  ),
                                ),
                                const SizedBox(height: 18),

                                const Text(
                                  'Apellido',
                                  style: TextStyle(
                                    color: Color(0xFF475569),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _controller.apellidoController,
                                  enabled: !isLoading,
                                  validator: (val) =>
                                      val == null || val.trim().isEmpty
                                      ? 'Requerido'
                                      : null,
                                  style: const TextStyle(
                                    color: Color(0xFF1E293B),
                                    fontSize: 15,
                                  ),
                                  decoration: _buildInputDecoration(
                                    hintText: 'Apellido',
                                  ),
                                ),
                                const SizedBox(height: 18),

                                const Text(
                                  'Tipo de Documento',
                                  style: TextStyle(
                                    color: Color(0xFF475569),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 8),
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
                                      value: _controller.docType,
                                      isExpanded: true,
                                      style: const TextStyle(
                                        color: Color(0xFF1E293B),
                                        fontSize: 15,
                                      ),
                                      icon: const Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        color: Color(0xFF64748B),
                                      ),
                                      onChanged: isLoading
                                          ? null
                                          : _controller.setDocType,
                                      items: _controller.docTypes
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

                                const Text(
                                  'Número de Documento',
                                  style: TextStyle(
                                    color: Color(0xFF475569),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _controller.docNumController,
                                  enabled: !isLoading,
                                  keyboardType: TextInputType.number,
                                  validator: (val) =>
                                      val == null || val.trim().isEmpty
                                      ? 'Requerido'
                                      : null,
                                  style: const TextStyle(
                                    color: Color(0xFF1E293B),
                                    fontSize: 15,
                                  ),
                                  decoration: _buildInputDecoration(
                                    hintText: 'Número de Documento',
                                  ),
                                ),
                                const SizedBox(height: 18),

                                const Text(
                                  'Teléfono de contacto',
                                  style: TextStyle(
                                    color: Color(0xFF475569),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                InternationalPhoneNumberInput(
                                  onInputChanged: (number) {
                                    _controller.setPhoneNumber(number);
                                  },
                                  selectorConfig: const SelectorConfig(
                                    setSelectorButtonAsPrefixIcon: true,
                                  ),
                                  selectorTextStyle: const TextStyle(
                                    color: Color(0xFF1E293B),
                                    fontSize: 15,
                                  ),
                                  initialValue: _controller.initialPhoneNumber,
                                  textFieldController:
                                      _controller.phoneInputController,
                                  formatInput: false,
                                  isEnabled: !isLoading,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        signed: true,
                                      ),
                                  textStyle: const TextStyle(
                                    color: Color(0xFF1E293B),
                                    fontSize: 15,
                                  ),
                                  inputDecoration: _buildInputDecoration(
                                    hintText: 'Número de Teléfono',
                                  ),
                                ),
                                const SizedBox(height: 18),

                                const Text(
                                  'Fecha de Nacimiento',
                                  style: TextStyle(
                                    color: Color(0xFF475569),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _controller.dobController,
                                  readOnly: true,
                                  onTap: isLoading
                                      ? null
                                      : () => _controller.selectDate(context),
                                  style: const TextStyle(
                                    color: Color(0xFF1E293B),
                                    fontSize: 15,
                                  ),
                                  decoration: _buildInputDecoration(
                                    hintText: 'Fecha de Nacimiento',
                                    suffixIcon: const Icon(
                                      Icons.calendar_today_outlined,
                                      color: Color(0xFF64748B),
                                      size: 18,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 18),

                                const Text(
                                  'Sexo Biológico',
                                  style: TextStyle(
                                    color: Color(0xFF475569),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 8),
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
                                      value: _controller.biologicalSex,
                                      isExpanded: true,
                                      style: const TextStyle(
                                        color: Color(0xFF1E293B),
                                        fontSize: 15,
                                      ),
                                      icon: const Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        color: Color(0xFF64748B),
                                      ),
                                      onChanged: isLoading
                                          ? null
                                          : _controller.setBiologicalSex,
                                      items: _controller.biologicalSexes
                                          .map(
                                            (s) => DropdownMenuItem(
                                              value: s,
                                              child: Text(s),
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 18),

                                const Text(
                                  'Identidad de Género',
                                  style: TextStyle(
                                    color: Color(0xFF475569),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 8),
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
                                      value: _controller.genderIdentity,
                                      isExpanded: true,
                                      style: const TextStyle(
                                        color: Color(0xFF1E293B),
                                        fontSize: 15,
                                      ),
                                      icon: const Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        color: Color(0xFF64748B),
                                      ),
                                      onChanged: isLoading
                                          ? null
                                          : _controller.setGenderIdentity,
                                      items: _controller.genderIdentities
                                          .map(
                                            (g) => DropdownMenuItem(
                                              value: g,
                                              child: Text(g),
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 18),

                                const Text(
                                  'Ocupación',
                                  style: TextStyle(
                                    color: Color(0xFF475569),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _controller.occupationController,
                                  enabled: !isLoading,
                                  style: const TextStyle(
                                    color: Color(0xFF1E293B),
                                    fontSize: 15,
                                  ),
                                  decoration: _buildInputDecoration(
                                    hintText: 'Analista Comercial',
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Location Card
                          Container(
                            margin: const EdgeInsets.only(bottom: 24),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: const Color(0xFFF1F5F9),
                              ),
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
                              children: [
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.location_on_outlined,
                                      color: Color(0xFF0256C2),
                                      size: 20,
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
                                const SizedBox(height: 18),

                                // Map representation
                                if (_controller.latitude == null ||
                                    _controller.longitude == null)
                                  GestureDetector(
                                    onTap: isLoading
                                        ? null
                                        : _selectLocationFromMap,
                                    child: Container(
                                      height: 140,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: const Color(0xFFE2E8F0),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: const Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.location_off_rounded,
                                            color: Color(0xFF94A3B8),
                                            size: 36,
                                          ),
                                          SizedBox(height: 12),
                                          Text(
                                            'No tienes coordenadas configuradas',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF64748B),
                                            ),
                                          ),
                                          SizedBox(height: 6),
                                          Text(
                                            'Toca aquí para configurar tu ubicación',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF0256C2),
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                else
                                  GestureDetector(
                                    onTap: isLoading
                                        ? null
                                        : _selectLocationFromMap,
                                    child: Container(
                                      height: 180,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF2D4A53),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Stack(
                                        children: [
                                          StaticMapPreview(
                                            latitude:
                                                _controller.latitude ??
                                                -12.046374,
                                            longitude:
                                                _controller.longitude ??
                                                -77.042793,
                                            height: 180,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          const Center(
                                            child: Icon(
                                              Icons.location_pin,
                                              color: Color(0xFF0256C2),
                                              size: 40,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),

                          // Save Changes Button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: isLoading
                                  ? null
                                  : () => _controller.saveProfile(
                                      context,
                                      _formKey,
                                      isLoading,
                                    ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0256C2),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (isLoading)
                                    const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  else ...[
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
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
