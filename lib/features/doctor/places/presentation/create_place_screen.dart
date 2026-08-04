import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:priora/core/di/injection.dart';
import 'package:priora/features/doctor/places/controller/places_cubit.dart';
import 'package:priora/features/doctor/places/data/models/place_model.dart';
import 'package:priora/features/doctor/places/data/ubigeo.dart';
import 'package:priora/features/shared/auth/data/auth_state.dart';
import 'package:priora/features/shared/auth/data/auth_bloc.dart';

class CreatePlaceScreen extends StatefulWidget {
  final PlaceModel? place;

  const CreatePlaceScreen({super.key, this.place});

  bool get isEditing => place != null;

  @override
  State<CreatePlaceScreen> createState() => _CreatePlaceScreenState();
}

class _CreatePlaceScreenState extends State<CreatePlaceScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;

  String? _selectedDepartment;
  String? _selectedProvince;
  String? _selectedDistrict;
  double? _latitude;
  double? _longitude;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.place?.name ?? '');
    _addressController = TextEditingController(text: widget.place?.address ?? '');
    _selectedDepartment = widget.place?.department;
    _selectedProvince = widget.place?.province;
    _selectedDistrict = widget.place?.district;
    _latitude = widget.place?.latitude;
    _longitude = widget.place?.longitude;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  List<String> get _provinces {
    if (_selectedDepartment == null) return [];
    return UbigeoData.getProvinces(_selectedDepartment!);
  }

  List<String> get _districts {
    if (_selectedDepartment == null || _selectedProvince == null) return [];
    return UbigeoData.getDistricts(_selectedDepartment!, _selectedProvince!);
  }

  void _onDepartmentChanged(String? value) {
    setState(() {
      _selectedDepartment = value;
      _selectedProvince = null;
      _selectedDistrict = null;
    });
  }

  void _onProvinceChanged(String? value) {
    setState(() {
      _selectedProvince = value;
      _selectedDistrict = null;
    });
  }

  Future<void> _selectOnMap() async {
    final result = await context.push<Map<String, double>>(
      '/map-picker',
      extra: {'latitude': _latitude ?? -12.046374, 'longitude': _longitude ?? -77.042793},
    );
    if (result != null && mounted) {
      setState(() {
        _latitude = result['latitude'];
        _longitude = result['longitude'];
      });
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    setState(() => _isLoading = true);

    try {
      final cubit = getIt<PlacesCubit>();
      final data = {
        'name': _nameController.text.trim(),
        'country': 'Perú',
        'department': _selectedDepartment,
        'province': _selectedProvince,
        'district': _selectedDistrict,
        'address': _addressController.text.trim(),
        if (_latitude != null) 'latitude': _latitude,
        if (_longitude != null) 'longitude': _longitude,
      };

      late bool success;
      if (widget.isEditing) {
        success = await cubit.updatePlace(
          accessToken: authState.accessToken,
          placeId: widget.place!.id,
          data: data,
        );
      } else {
        success = await cubit.createPlace(
          accessToken: authState.accessToken,
          data: data,
        );
      }

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.isEditing
                  ? 'Lugar actualizado exitosamente'
                  : 'Lugar creado exitosamente'),
            ),
          );
          context.pop(true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al guardar el lugar. Intente nuevamente.'),
              backgroundColor: Color(0xFFEF4444),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Color(0xFFEF4444),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E293B), size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.isEditing
                          ? 'Editar lugar de atención'
                          : 'Nuevo lugar de atención',
                      style: const TextStyle(
                        color: Color(0xFF1E293B),
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.isEditing
                          ? 'Modifica los datos del centro médico o consultorio.'
                          : 'Complete los datos para registrar un nuevo centro médico o consultorio.',
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildBanner(),
              const SizedBox(height: 24),
              _buildForm(),
              const SizedBox(height: 24),
              _buildMapButton(),
              const SizedBox(height: 32),
              _buildActionButtons(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF0256C2), Color(0xFF0D9488)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            bottom: -10,
            child: Icon(
              Icons.local_hospital_rounded,
              size: 130,
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
          Positioned(
            left: 24,
            bottom: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.business_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      widget.isEditing ? 'Editar Sede' : 'Registro de Sedes',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  widget.isEditing
                      ? 'Actualiza la información de tu consultorio o clínica.'
                      : 'Añade los consultorios o clínicas\ndonde brindas atención médica.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
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
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel('Nombre del lugar (Clínica/Consultorio)'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _nameController,
              hintText: 'Ej: Clinica San Borja',
              icon: Icons.medication_liquid_outlined,
              validator: (v) => v == null || v.trim().isEmpty ? 'Requerido' : null,
            ),
            const SizedBox(height: 18),
            _buildLabel('País'),
            const SizedBox(height: 8),
            _buildDisabledField(value: 'Perú', icon: Icons.language_outlined),
            const SizedBox(height: 18),
            _buildLabel('Departamento'),
            const SizedBox(height: 8),
            _buildDropdown(
              value: _selectedDepartment,
              hint: 'Seleccione Departamento',
              icon: Icons.account_balance_outlined,
              items: UbigeoData.getDepartments(),
              onChanged: _onDepartmentChanged,
            ),
            const SizedBox(height: 18),
            _buildLabel('Provincia'),
            const SizedBox(height: 8),
            _buildDropdown(
              value: _selectedProvince,
              hint: 'Seleccione Provincia',
              icon: Icons.location_city_outlined,
              items: _provinces,
              onChanged: _onProvinceChanged,
            ),
            const SizedBox(height: 18),
            _buildLabel('Distrito'),
            const SizedBox(height: 8),
            _buildDropdown(
              value: _selectedDistrict,
              hint: 'Seleccione Distrito',
              icon: Icons.map_outlined,
              items: _districts,
              onChanged: (v) => setState(() => _selectedDistrict = v),
            ),
            const SizedBox(height: 18),
            _buildLabel('Dirección'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _addressController,
              hintText: 'Av. Javier Prado Este 1234',
              icon: Icons.location_on_outlined,
              validator: (v) => v == null || v.trim().isEmpty ? 'Requerido' : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF475569),
        fontWeight: FontWeight.bold,
        fontSize: 13,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      style: const TextStyle(color: Color(0xFF1E293B), fontSize: 15),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 15),
        prefixIcon: Icon(icon, color: const Color(0xFF64748B), size: 20),
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      ),
    );
  }

  Widget _buildDisabledField({required String value, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF94A3B8), size: 20),
          const SizedBox(width: 12),
          Text(
            value,
            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String hint,
    required IconData icon,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          hint: Row(
            children: [
              Icon(icon, color: const Color(0xFF64748B), size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  hint,
                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 15),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          style: const TextStyle(color: Color(0xFF1E293B), fontSize: 15),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
          onChanged: items.isEmpty ? null : onChanged,
          items: items.isEmpty
              ? [
                  DropdownMenuItem<String>(
                    value: null,
                    child: Row(
                      children: [
                        Icon(icon, color: const Color(0xFF64748B), size: 20),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Seleccione Departamento primero',
                            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 15),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ]
              : items.map((item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Row(
                      children: [
                        Icon(icon, color: const Color(0xFF64748B), size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            item,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
        ),
      ),
    );
  }

  Widget _buildMapButton() {
    final hasLocation = _latitude != null && _longitude != null;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: OutlinedButton.icon(
        onPressed: _selectOnMap,
        icon: Icon(
          hasLocation ? Icons.check_circle : Icons.explore_outlined,
          color: const Color(0xFF0256C2),
          size: 20,
        ),
        label: Text(
          hasLocation ? 'Ubicación seleccionada' : 'Seleccionar en mapa',
          style: const TextStyle(
            color: Color(0xFF0256C2),
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 52),
          side: BorderSide(
            color: const Color(0xFF0256C2).withValues(alpha: 0.3),
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: const Color(0xFFF8FAFC),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0256C2),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(widget.isEditing ? 'Actualizar' : 'Guardar'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              onPressed: () => context.pop(),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF0D9488),
                side: const BorderSide(color: Color(0xFFCBD5E1)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              child: const Text('Cancelar'),
            ),
          ),
        ],
      ),
    );
  }
}
