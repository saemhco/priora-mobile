import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:priora/features/shared/auth/data/auth_bloc.dart';
import 'package:priora/features/shared/auth/data/auth_event.dart';
import 'package:priora/features/shared/auth/data/auth_state.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _docNumController = TextEditingController();
  final _dobController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneInputController = TextEditingController();

  PhoneNumber _phoneNumber = PhoneNumber(isoCode: 'PE');
  final PhoneNumber _initialPhoneNumber = PhoneNumber(isoCode: 'PE');

  String _docType = 'DNI';
  String? _biologicalSex;
  String? _genderIdentity;
  String? _occupation;

  double _latitude = -12.046374;
  double _longitude = -77.042793;
  bool _fetchingLocation = false;

  final List<String> _docTypes = ['DNI', 'Pasaporte', 'CEX'];
  final List<String> _occupations = [
    'Estudiante',
    'Empleado',
    'Independiente',
    'Desempleado',
    'Jubilado'
  ];

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _docNumController.dispose();
    _dobController.dispose();
    _addressController.dispose();
    _phoneInputController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _fetchingLocation = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Los servicios de ubicación están desactivados.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Los permisos de ubicación fueron denegados.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception(
            'Los permisos de ubicación están denegados permanentemente.');
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _addressController.text =
            'Lat: ${position.latitude.toStringAsFixed(6)}, Lng: ${position.longitude.toStringAsFixed(6)}';
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ubicación obtenida correctamente'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() {
        _fetchingLocation = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0256C2),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1E293B),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dobController.text =
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  void _onSavePressed() {
    if (_formKey.currentState!.validate()) {
      if (_biologicalSex == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor selecciona el sexo biológico'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }
      if (_genderIdentity == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor selecciona tu identidad de género'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      final authState = context.read<AuthBloc>().state;
      if (authState is! AuthAuthenticated) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: No autenticado'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      // Convert dateOfBirth to yyyy-mm-dd
      String dateOfBirth = "1990-05-15";
      if (_dobController.text.isNotEmpty) {
        final parts = _dobController.text.split('/');
        if (parts.length == 3) {
          dateOfBirth = "${parts[2]}-${parts[1]}-${parts[0]}";
        }
      }

      // Convert Gender Identity to uppercase/enum formats
      String genderIdentityEnum = "PREFER_NOT_TO_SAY";
      if (_genderIdentity == 'Mujer') {
        genderIdentityEnum = "WOMAN";
      } else if (_genderIdentity == 'Hombre') {
        genderIdentityEnum = "MAN";
      } else if (_genderIdentity == 'No binario') {
        genderIdentityEnum = "NON_BINARY";
      } else if (_genderIdentity == 'Otro') {
        genderIdentityEnum = "OTHER";
      }

      final body = {
        "firstName": _nombreController.text.trim(),
        "lastName": _apellidoController.text.trim(),
        "documentType": _docType,
        "documentId": _docNumController.text.trim(),
        "phone": _phoneNumber.phoneNumber ?? "",
        "dateOfBirth": dateOfBirth,
        "biologicalSex": _biologicalSex == 'Femenino' ? 'FEMALE' : 'MALE',
        "genderIdentity": genderIdentityEnum,
        "genderIdentityOther": _genderIdentity == 'Otro' ? 'Género fluido' : null,
        "occupation": _occupation ?? "Empleado",
        "profilePhotoUrl": "",
        "latitude": _latitude,
        "longitude": _longitude,
        "description": _addressController.text.trim(),
      };

      context.read<AuthBloc>().add(
            AuthUpdateProfileRequested(
              profileData: body,
              accessToken: authState.accessToken,
              role: authState.role,
            ),
          );
    }
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
    IconData? icon,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 24.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)),
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
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: const Color(0xFF0256C2), size: 20),
                const SizedBox(width: 8),
              ],
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF0256C2),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ...children,
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration({required String hintText, Widget? suffixIcon}) {
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

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state is AuthAuthenticated && state.profileComplete) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Perfil completado exitosamente'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          if (state.role == 'doctor') {
            context.go('/doctor');
          } else {
            context.go('/patient');
          }
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
            onPressed: () => context.go('/login'),
          ),
        ),
        body: SafeArea(
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              final isLoading = state is AuthLoading;

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
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

                      // Card 1: Información Personal
                      _buildSectionCard(
                        title: 'Información Personal',
                        icon: Icons.person_outline,
                        children: [
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
                            controller: _nombreController,
                            enabled: !isLoading,
                            validator: (val) => val == null || val.trim().isEmpty
                                ? 'Requerido'
                                : null,
                            style: const TextStyle(color: Color(0xFF1E293B), fontSize: 15),
                            decoration: _buildInputDecoration(hintText: 'Ricardo'),
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
                            controller: _apellidoController,
                            enabled: !isLoading,
                            validator: (val) => val == null || val.trim().isEmpty
                                ? 'Requerido'
                                : null,
                            style: const TextStyle(color: Color(0xFF1E293B), fontSize: 15),
                            decoration: _buildInputDecoration(hintText: 'Díaz'),
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
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _docType,
                                isExpanded: true,
                                style: const TextStyle(color: Color(0xFF1E293B), fontSize: 15),
                                icon: const Icon(Icons.keyboard_arrow_down_rounded,
                                    color: Color(0xFF64748B)),
                                onChanged: isLoading
                                    ? null
                                    : (value) {
                                        if (value != null) {
                                          setState(() => _docType = value);
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
                            controller: _docNumController,
                            enabled: !isLoading,
                            keyboardType: TextInputType.number,
                            validator: (val) => val == null || val.trim().isEmpty
                                ? 'Requerido'
                                : null,
                            style: const TextStyle(color: Color(0xFF1E293B), fontSize: 15),
                            decoration: _buildInputDecoration(hintText: '70654321'),
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
                            onInputChanged: (PhoneNumber number) {
                              _phoneNumber = number;
                            },
                            selectorConfig: const SelectorConfig(
                              selectorType: PhoneInputSelectorType.DROPDOWN,
                              showFlags: true,
                              useEmoji: false,
                              setSelectorButtonAsPrefixIcon: true,
                            ),
                            ignoreBlank: false,
                            autoValidateMode: AutovalidateMode.disabled,
                            selectorTextStyle: const TextStyle(color: Color(0xFF1E293B), fontSize: 15),
                            initialValue: _initialPhoneNumber,
                            textFieldController: _phoneInputController,
                            formatInput: false,
                            isEnabled: !isLoading,
                            keyboardType: const TextInputType.numberWithOptions(
                              signed: true,
                              decimal: false,
                            ),
                            textStyle: const TextStyle(color: Color(0xFF1E293B), fontSize: 15),
                            inputDecoration: _buildInputDecoration(hintText: '987654321'),
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
                            controller: _dobController,
                            readOnly: true,
                            onTap: isLoading ? null : () => _selectDate(context),
                            style: const TextStyle(color: Color(0xFF1E293B), fontSize: 15),
                            decoration: _buildInputDecoration(
                              hintText: '15/05/1992',
                              suffixIcon: const Icon(Icons.calendar_today_outlined,
                                  color: Color(0xFF64748B), size: 18),
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
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: isLoading
                                      ? null
                                      : () => setState(() => _biologicalSex = 'Femenino'),
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: _biologicalSex == 'Femenino'
                                        ? const Color(0xFFEEF2F6)
                                        : Colors.white,
                                    side: BorderSide(
                                      color: _biologicalSex == 'Femenino'
                                          ? const Color(0xFF0256C2)
                                          : const Color(0xFFE2E8F0),
                                      width: 1.5,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                  child: Text(
                                    'Femenino',
                                    style: TextStyle(
                                      color: _biologicalSex == 'Femenino'
                                          ? const Color(0xFF0256C2)
                                          : const Color(0xFF1E293B),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: isLoading
                                      ? null
                                      : () => setState(() => _biologicalSex = 'Masculino'),
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: _biologicalSex == 'Masculino'
                                        ? const Color(0xFFEEF2F6)
                                        : Colors.white,
                                    side: BorderSide(
                                      color: _biologicalSex == 'Masculino'
                                          ? const Color(0xFF0256C2)
                                          : const Color(0xFFE2E8F0),
                                      width: 1.5,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                  child: Text(
                                    'Masculino',
                                    style: TextStyle(
                                      color: _biologicalSex == 'Masculino'
                                          ? const Color(0xFF0256C2)
                                          : const Color(0xFF1E293B),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
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
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              'Mujer',
                              'Hombre',
                              'No binario',
                              'Otro',
                              'Prefiero no decir'
                            ].map((gender) {
                              final isSelected = _genderIdentity == gender;
                              return OutlinedButton(
                                onPressed: isLoading
                                    ? null
                                    : () => setState(() => _genderIdentity = gender),
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: isSelected ? const Color(0xFFEEF2F6) : Colors.white,
                                  side: BorderSide(
                                    color: isSelected ? const Color(0xFF0256C2) : const Color(0xFFE2E8F0),
                                    width: 1.5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                ),
                                child: Text(
                                  gender,
                                  style: TextStyle(
                                    color: isSelected ? const Color(0xFF0256C2) : const Color(0xFF1E293B),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 18),

                          const Text(
                            'Ocupación (opcional)',
                            style: TextStyle(
                              color: Color(0xFF475569),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _occupation,
                                hint: const Text('Seleccionar...'),
                                isExpanded: true,
                                style: const TextStyle(color: Color(0xFF1E293B), fontSize: 15),
                                icon: const Icon(Icons.keyboard_arrow_down_rounded,
                                    color: Color(0xFF64748B)),
                                onChanged: isLoading
                                    ? null
                                    : (value) {
                                        if (value != null) {
                                          setState(() => _occupation = value);
                                        }
                                      },
                                items: _occupations
                                    .map(
                                      (o) => DropdownMenuItem(
                                        value: o,
                                        child: Text(o),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Card 2: Ubicación
                      _buildSectionCard(
                        title: 'Ubicación (opcional)',
                        icon: Icons.location_on_outlined,
                        children: [
                          const Text(
                            'Referencia de tu zona o dirección. Útil para orientar la atención presencial.',
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Buscar dirección o lugar',
                            style: TextStyle(
                              color: Color(0xFF475569),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _addressController,
                            enabled: !isLoading,
                            style: const TextStyle(color: Color(0xFF1E293B), fontSize: 15),
                            decoration: InputDecoration(
                              hintText: 'Buscar...',
                              hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 15),
                              prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8)),
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
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            height: 160,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF2F6),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFCBD5E1)),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.map_outlined,
                                  size: 36,
                                  color: const Color(0xFF64748B).withOpacity(0.5),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Visualización del Mapa',
                                  style: TextStyle(
                                    color: Color(0xFF64748B),
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              TextButton.icon(
                                onPressed: isLoading || _fetchingLocation
                                    ? null
                                    : _getCurrentLocation,
                                icon: _fetchingLocation
                                    ? const SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 1.5,
                                          color: Color(0xFF0256C2),
                                        ),
                                      )
                                    : const Icon(Icons.my_location, size: 16, color: Color(0xFF0256C2)),
                                label: Text(
                                  _fetchingLocation ? 'Obteniendo...' : 'Mi ubicación actual',
                                  style: const TextStyle(
                                    color: Color(0xFF0256C2),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              TextButton(
                                onPressed: isLoading ? null : () {},
                                child: const Text(
                                  'Editar coordenadas',
                                  style: TextStyle(
                                    color: Color(0xFF64748B),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _onSavePressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0256C2),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Guardar y continuar',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
