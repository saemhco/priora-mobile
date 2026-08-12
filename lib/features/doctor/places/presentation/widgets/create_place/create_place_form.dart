import 'package:flutter/material.dart';
import 'package:priora/features/doctor/places/data/ubigeo.dart';
import 'package:priora/features/doctor/places/presentation/controller/create_place_controller.dart';

/// Create/edit place form: name, country, department, province, district and
/// address.
class CreatePlaceForm extends StatelessWidget {
  const CreatePlaceForm({
    required this.controller, required this.formKey, super.key,
  });

  final CreatePlaceController controller;
  final GlobalKey<FormState> formKey;

  @override
  Widget build(BuildContext context) {
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
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel('Nombre del lugar (Clínica/Consultorio)'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: controller.nameController,
              hintText: 'Ej: Clinica San Borja',
              icon: Icons.medication_liquid_outlined,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Requerido' : null,
            ),
            const SizedBox(height: 18),
            _buildLabel('País'),
            const SizedBox(height: 8),
            _buildDisabledField(value: 'Perú', icon: Icons.language_outlined),
            const SizedBox(height: 18),
            _buildLabel('Departamento'),
            const SizedBox(height: 8),
            _buildDropdown(
              value: controller.selectedDepartment,
              hint: 'Seleccione Departamento',
              icon: Icons.account_balance_outlined,
              items: UbigeoData.getDepartments(),
              onChanged: controller.onDepartmentChanged,
            ),
            const SizedBox(height: 18),
            _buildLabel('Provincia'),
            const SizedBox(height: 8),
            _buildDropdown(
              value: controller.selectedProvince,
              hint: 'Seleccione Provincia',
              icon: Icons.location_city_outlined,
              items: controller.provinces,
              onChanged: controller.onProvinceChanged,
            ),
            const SizedBox(height: 18),
            _buildLabel('Distrito'),
            const SizedBox(height: 8),
            _buildDropdown(
              value: controller.selectedDistrict,
              hint: 'Seleccione Distrito',
              icon: Icons.map_outlined,
              items: controller.districts,
              onChanged: controller.onDistrictChanged,
            ),
            const SizedBox(height: 18),
            _buildLabel('Dirección'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: controller.addressController,
              hintText: 'Av. Javier Prado Este 1234',
              icon: Icons.location_on_outlined,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Requerido' : null,
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
          borderSide: const BorderSide(color: Color(0xFFEF4444)),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
      ),
    );
  }

  Widget _buildDisabledField({
    required String value,
    required IconData icon,
  }) {
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
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 15,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          style: const TextStyle(color: Color(0xFF1E293B), fontSize: 15),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Color(0xFF64748B),
          ),
          onChanged: items.isEmpty ? null : onChanged,
          items: items.isEmpty
              ? [
                  DropdownMenuItem<String>(
                    child: Row(
                      children: [
                        Icon(icon, color: const Color(0xFF64748B), size: 20),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Seleccione Departamento primero',
                            style: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 15,
                            ),
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
}
