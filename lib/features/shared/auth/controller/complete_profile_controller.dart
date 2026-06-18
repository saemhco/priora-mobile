import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:priora/features/shared/auth/data/auth_bloc.dart';
import 'package:priora/features/shared/auth/data/auth_event.dart';
import 'package:priora/features/shared/auth/data/auth_state.dart';

class CompleteProfileController extends ChangeNotifier {
  final nombreController = TextEditingController();
  final apellidoController = TextEditingController();
  final docNumController = TextEditingController();
  final dobController = TextEditingController();
  final addressController = TextEditingController();
  final phoneInputController = TextEditingController();

  PhoneNumber phoneNumber = PhoneNumber(isoCode: 'PE');
  final PhoneNumber initialPhoneNumber = PhoneNumber(isoCode: 'PE');

  String docType = 'DNI';
  String? biologicalSex;
  String? genderIdentity;
  String? occupation;

  double latitude = -12.046374;
  double longitude = -77.042793;
  bool fetchingLocation = false;

  final List<String> docTypes = const ['DNI', 'Pasaporte', 'CEX'];
  final List<String> occupationsList = const [
    'Estudiante',
    'Empleado',
    'Independiente',
    'Desempleado',
    'Jubilado'
  ];

  void setDocType(String? value) {
    if (value != null) {
      docType = value;
      notifyListeners();
    }
  }

  void setBiologicalSex(String? value) {
    biologicalSex = value;
    notifyListeners();
  }

  void setGenderIdentity(String? value) {
    genderIdentity = value;
    notifyListeners();
  }

  void setOccupation(String? value) {
    occupation = value;
    notifyListeners();
  }

  void setPhoneNumber(PhoneNumber number) {
    phoneNumber = number;
  }

  Future<void> getCurrentLocation(BuildContext context) async {
    fetchingLocation = true;
    notifyListeners();

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

      latitude = position.latitude;
      longitude = position.longitude;
      addressController.text =
          'Lat: ${position.latitude.toStringAsFixed(6)}, Lng: ${position.longitude.toStringAsFixed(6)}';
      notifyListeners();

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ubicación obtenida correctamente'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      fetchingLocation = false;
      notifyListeners();
    }
  }

  Future<void> selectDate(BuildContext context) async {
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
      dobController.text =
          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      notifyListeners();
    }
  }

  void saveProfile(BuildContext context, GlobalKey<FormState> formKey, bool isLoading) {
    if (isLoading) return;

    if (formKey.currentState!.validate()) {
      if (biologicalSex == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor selecciona el sexo biológico'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }
      if (genderIdentity == null) {
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
      if (dobController.text.isNotEmpty) {
        final parts = dobController.text.split('/');
        if (parts.length == 3) {
          dateOfBirth = "${parts[2]}-${parts[1]}-${parts[0]}";
        }
      }

      // Convert Gender Identity to uppercase/enum formats
      String genderIdentityEnum = "PREFER_NOT_TO_SAY";
      if (genderIdentity == 'Mujer') {
        genderIdentityEnum = "WOMAN";
      } else if (genderIdentity == 'Hombre') {
        genderIdentityEnum = "MAN";
      } else if (genderIdentity == 'No binario') {
        genderIdentityEnum = "NON_BINARY";
      } else if (genderIdentity == 'Otro') {
        genderIdentityEnum = "OTHER";
      }

      final body = {
        "firstName": nombreController.text.trim(),
        "lastName": apellidoController.text.trim(),
        "documentType": docType,
        "documentId": docNumController.text.trim(),
        "phone": phoneNumber.phoneNumber ?? "",
        "dateOfBirth": dateOfBirth,
        "biologicalSex": biologicalSex == 'Femenino' ? 'FEMALE' : 'MALE',
        "genderIdentity": genderIdentityEnum,
        "genderIdentityOther": genderIdentity == 'Otro' ? 'Género fluido' : null,
        "occupation": occupation ?? "Empleado",
        "profilePhotoUrl": "",
        "latitude": latitude,
        "longitude": longitude,
        "description": addressController.text.trim(),
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

  @override
  void dispose() {
    nombreController.dispose();
    apellidoController.dispose();
    docNumController.dispose();
    dobController.dispose();
    addressController.dispose();
    phoneInputController.dispose();
    super.dispose();
  }
}
