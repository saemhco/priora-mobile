import 'package:flutter/material.dart';
import 'package:priora/features/doctor/profile/presentation/controller/edit_doctor_profile_controller.dart';

/// Profile editing form: personal data, document, phone, biography and save
/// button.
class EditDoctorProfileForm extends StatelessWidget {
  const EditDoctorProfileForm({
    required this.controller,
    required this.formKey,
    required this.onSave,
    super.key,
  });

  final EditDoctorProfileController controller;
  final GlobalKey<FormState> formKey;
  final Future<void> Function() onSave;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Form(
        key: formKey,
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
                  controller: controller.firstNameController,
                  enabled: !controller.isSubmitting,
                  validator: (val) =>
                      val == null || val.trim().isEmpty ? 'Requerido' : null,
                  style: const TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 15,
                  ),
                  decoration: _buildDecoration(hintText: 'Nombre'),
                ),
                const SizedBox(height: 18),
                _buildLabel('Apellido'),
                TextFormField(
                  controller: controller.lastNameController,
                  enabled: !controller.isSubmitting,
                  validator: (val) =>
                      val == null || val.trim().isEmpty ? 'Requerido' : null,
                  style: const TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 15,
                  ),
                  decoration: _buildDecoration(hintText: 'Apellido'),
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
                      value: controller.documentType,
                      isExpanded: true,
                      style: const TextStyle(
                        color: Color(0xFF1E293B),
                        fontSize: 15,
                      ),
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Color(0xFF64748B),
                      ),
                      onChanged: controller.isSubmitting
                          ? null
                          : (value) {
                              if (value != null) {
                                controller.setDocumentType(value);
                              }
                            },
                      items: EditDoctorProfileController.docTypes
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
                  controller: controller.documentIdController,
                  enabled: !controller.isSubmitting,
                  validator: (val) =>
                      val == null || val.trim().isEmpty ? 'Requerido' : null,
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
                  controller: controller.phoneController,
                  enabled: !controller.isSubmitting,
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
                  controller: controller.bioController,
                  enabled: !controller.isSubmitting,
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
            if (controller.submitError != null) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFECACA)),
                ),
                child: Text(
                  controller.submitError!,
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
                onPressed: controller.isSubmitting ? null : onSave,
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
                    if (controller.isSubmitting) ...[
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
                      const Icon(Icons.check_circle_outline, size: 20),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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

  InputDecoration _buildDecoration({
    required String hintText,
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
    );
  }
}
