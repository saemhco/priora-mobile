import 'package:flutter/material.dart';

class PersonalInfoCard extends StatelessWidget {
  final Map<String, dynamic>? profile;
  const PersonalInfoCard({super.key, this.profile});

  @override
  Widget build(BuildContext context) {
    final docType = profile?['documentType'] ?? 'DNI';
    final docNum = profile?['documentId'] ?? 'No registrado';
    final phone = profile?['phone'] ?? 'No registrado';
    final occupation = profile?['occupation'] ?? 'No registrada';
    
    // Format Biological Sex
    final rawSex = profile?['biologicalSex']?.toString().toUpperCase();
    final biologicalSex = rawSex == 'MALE'
        ? 'Masculino'
        : (rawSex == 'FEMALE' ? 'Femenino' : 'No registrado');

    // Format Gender Identity
    final rawGender = profile?['genderIdentity']?.toString().toUpperCase();
    final genderIdentity = rawGender == 'MAN'
        ? 'Hombre'
        : (rawGender == 'WOMAN' ? 'Mujer' : (profile?['genderIdentity'] ?? 'No registrado'));

    // Format DOB
    final dobStr = profile?['dateOfBirth'] ?? 'No registrada';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row Header
          const Row(
            children: [
              Icon(
                Icons.person_outline_rounded,
                color: Color(0xFF0256C2),
                size: 22,
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
          const SizedBox(height: 20),

          // Identity Doc
          _buildInfoRow(
            label: 'DOCUMENTO DE IDENTIDAD',
            value: '$docType $docNum',
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0),
            child: Divider(color: Color(0xFFF1F5F9), height: 1),
          ),

          // Birthdate
          _buildInfoRow(
            label: 'FECHA DE NACIMIENTO',
            value: dobStr,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0),
            child: Divider(color: Color(0xFFF1F5F9), height: 1),
          ),

          // Phone
          _buildInfoRow(
            label: 'TELÉFONO',
            value: phone,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0),
            child: Divider(color: Color(0xFFF1F5F9), height: 1),
          ),

          // Occupation
          _buildInfoRow(
            label: 'OCUPACIÓN',
            value: occupation,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0),
            child: Divider(color: Color(0xFFF1F5F9), height: 1),
          ),

          // Biological Sex
          _buildInfoRow(
            label: 'SEXO BIOLÓGICO',
            value: biologicalSex,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0),
            child: Divider(color: Color(0xFFF1F5F9), height: 1),
          ),

          // Gender Identity
          _buildInfoRow(
            label: 'IDENTIDAD DE GÉNERO',
            value: genderIdentity,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
