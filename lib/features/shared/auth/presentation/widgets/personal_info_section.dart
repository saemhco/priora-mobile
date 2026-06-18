import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:priora/features/shared/auth/controller/complete_profile_controller.dart';

class PersonalInfoSection extends StatelessWidget {
  final CompleteProfileController controller;
  final bool isLoading;

  const PersonalInfoSection({
    super.key,
    required this.controller,
    required this.isLoading,
  });

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
    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) {
        return Container(
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
              const Row(
                children: [
                  Icon(Icons.person_outline, color: Color(0xFF0256C2), size: 20),
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
                controller: controller.nombreController,
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
                controller: controller.apellidoController,
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
                    value: controller.docType,
                    isExpanded: true,
                    style: const TextStyle(color: Color(0xFF1E293B), fontSize: 15),
                    icon: const Icon(Icons.keyboard_arrow_down_rounded,
                        color: Color(0xFF64748B)),
                    onChanged: isLoading ? null : controller.setDocType,
                    items: controller.docTypes
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
                controller: controller.docNumController,
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
                  controller.setPhoneNumber(number);
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
                initialValue: controller.initialPhoneNumber,
                textFieldController: controller.phoneInputController,
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
                controller: controller.dobController,
                readOnly: true,
                onTap: isLoading ? null : () => controller.selectDate(context),
                style: const TextStyle(color: Color(0xFF1E293B), fontSize: 15),
                decoration: _buildInputDecoration(
                  hintText: '15/05/1992',
                  suffixIcon: const Icon(Icons.calendar_today_outlined,
                      color: Color(0xFF64748B), size: 18),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
