import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:priora/features/shared/auth/data/auth_bloc.dart';
import 'package:priora/features/shared/auth/data/auth_state.dart';
import 'package:priora/features/patient/profile/presentation/blocs/profile_cubit/profile_cubit.dart';
import 'package:priora/features/patient/profile/presentation/blocs/profile_cubit/profile_state.dart';
import 'package:priora/features/patient/profile/data/models/patient_profile_model.dart';

class EditProfileController extends ChangeNotifier {
  final nombreController = TextEditingController();
  final apellidoController = TextEditingController();
  final docNumController = TextEditingController();
  final dobController = TextEditingController();
  final addressController = TextEditingController();
  final phoneInputController = TextEditingController();
  final occupationController = TextEditingController();
  final latController = TextEditingController();
  final lngController = TextEditingController();

  PhoneNumber phoneNumber = PhoneNumber(isoCode: 'PE');
  PhoneNumber initialPhoneNumber = PhoneNumber(isoCode: 'PE');

  String docType = 'DNI';
  String? biologicalSex;
  String? genderIdentity;

  double? latitude;
  double? longitude;
  bool fetchingLocation = false;
  bool loadingProfile = true;

  final List<String> docTypes = const ['DNI', 'Pasaporte', 'CEX'];
  final List<String> biologicalSexes = const ['Masculino', 'Femenino'];
  final List<String> genderIdentities = const [
    'Cisgénero',
    'Transgénero',
    'No binario',
    'Otro',
    'Prefiero no decir',
  ];

  VoidCallback? onLocationUpdated;

  void setDocType(String? value) {
    if (value != null) {
      docType = value;
      notifyListeners();
    }
  }

  void setBiologicalSex(String? value) {
    if (value != null) {
      biologicalSex = value;
      notifyListeners();
    }
  }

  void setGenderIdentity(String? value) {
    if (value != null) {
      genderIdentity = value;
      notifyListeners();
    }
  }

  void setPhoneNumber(PhoneNumber number) {
    phoneNumber = number;
  }

  void setCoordinates(double lat, double lng) {
    latitude = lat;
    longitude = lng;
    latController.text = lat.toStringAsFixed(6);
    lngController.text = lng.toStringAsFixed(6);
    notifyListeners();
  }

  Future<void> loadProfile(BuildContext context) async {
    loadingProfile = true;
    notifyListeners();

    try {
      final profileState = context.read<ProfileCubit>().state;
      PatientProfileModel? profile;
      if (profileState is ProfileLoaded) {
        profile = profileState.profile;
      }

      if (profile == null) {
        final authState = context.read<AuthBloc>().state;
        if (authState is AuthAuthenticated) {
          await context.read<ProfileCubit>().loadProfile(
            accessToken: authState.accessToken,
          );
          final newState = context.read<ProfileCubit>().state;
          if (newState is ProfileLoaded) {
            profile = newState.profile;
          }
        }
      }

      if (profile != null) {
        nombreController.text = profile.firstName;
        apellidoController.text = profile.lastName;
        docType = profile.documentType ?? 'DNI';
        docNumController.text = profile.documentId ?? '';

        final phoneStr = profile.phone ?? '';
        if (phoneStr.isNotEmpty) {
          try {
            final resolved = await PhoneNumber.getRegionInfoFromPhoneNumber(
              phoneStr,
            );
            phoneNumber = resolved;
            initialPhoneNumber = PhoneNumber(
              isoCode: resolved.isoCode ?? 'PE',
              phoneNumber: resolved.phoneNumber,
              dialCode: resolved.dialCode,
            );
            // Strip country code from text field so the user only sees the national number
            final dialCode = resolved.dialCode ?? '';
            if (dialCode.isNotEmpty && phoneStr.startsWith(dialCode)) {
              phoneInputController.text = phoneStr.substring(dialCode.length);
            } else {
              phoneInputController.text = phoneStr.replaceAll(
                RegExp(r'^\+\d+'),
                '',
              );
            }
          } catch (_) {
            initialPhoneNumber = PhoneNumber(isoCode: 'PE');
            phoneInputController.text = phoneStr.replaceAll(
              RegExp(r'^\+\d+'),
              '',
            );
          }
        }

        // Date of birth: yyyy-MM-dd -> dd/MM/yyyy
        final dobStr = profile.dateOfBirth ?? '';
        if (dobStr.isNotEmpty) {
          final parts = dobStr.split('-');
          if (parts.length == 3) {
            dobController.text = '${parts[2]}/${parts[1]}/${parts[0]}';
          }
        }

        final bioSexDb = profile.biologicalSex ?? '';
        biologicalSex = bioSexDb == 'FEMALE' ? 'Femenino' : 'Masculino';

        final genderDb = profile.genderIdentity ?? '';
        if (genderDb == 'WOMAN' || genderDb == 'MAN') {
          genderIdentity = 'Cisgénero';
        } else if (genderDb == 'NON_BINARY') {
          genderIdentity = 'No binario';
        } else if (genderDb == 'PREFER_NOT_TO_SAY') {
          genderIdentity = 'Prefiero no decir';
        } else if (genderDb == 'OTHER') {
          final otherStr = profile.genderIdentityOther ?? '';
          if (otherStr == 'Transgénero') {
            genderIdentity = 'Transgénero';
          } else {
            genderIdentity = 'Otro';
          }
        } else {
          genderIdentity = 'Cisgénero';
        }

        occupationController.text = profile.occupation ?? '';
        latitude = profile.latitude;
        longitude = profile.longitude;
        if (latitude != null && longitude != null) {
          latController.text = latitude!.toStringAsFixed(6);
          lngController.text = longitude!.toStringAsFixed(6);
        } else {
          latController.text = '';
          lngController.text = '';
        }
        addressController.text = profile.description ?? '';
        onLocationUpdated?.call();
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
    } finally {
      loadingProfile = false;
      notifyListeners();
    }
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
          'Los permisos de ubicación están denegados permanentemente.',
        );
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      latitude = position.latitude;
      longitude = position.longitude;
      latController.text = latitude!.toStringAsFixed(6);
      lngController.text = longitude!.toStringAsFixed(6);
      addressController.text =
          'Lat: ${position.latitude.toStringAsFixed(6)}, Lng: ${position.longitude.toStringAsFixed(6)}';
      onLocationUpdated?.call();
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

  void saveProfile(
    BuildContext context,
    GlobalKey<FormState> formKey,
    bool isLoading,
  ) {
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

      // Convert Gender Identity to enum format
      String genderIdentityEnum = "PREFER_NOT_TO_SAY";
      String? genderIdentityOther;

      if (genderIdentity == 'Cisgénero') {
        genderIdentityEnum = biologicalSex == 'Femenino' ? 'WOMAN' : 'MAN';
      } else if (genderIdentity == 'Transgénero') {
        genderIdentityEnum = 'OTHER';
        genderIdentityOther = 'Transgénero';
      } else if (genderIdentity == 'No binario') {
        genderIdentityEnum = 'NON_BINARY';
      } else if (genderIdentity == 'Otro') {
        genderIdentityEnum = 'OTHER';
        genderIdentityOther = 'Género fluido';
      } else if (genderIdentity == 'Prefiero no decir') {
        genderIdentityEnum = 'PREFER_NOT_TO_SAY';
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
        "genderIdentityOther": genderIdentityOther,
        "occupation": occupationController.text.trim(),
        "profilePhotoUrl": authState.profilePhotoUrl ?? "",
        "latitude": double.tryParse(latController.text) ?? latitude,
        "longitude": double.tryParse(lngController.text) ?? longitude,
        "description": addressController.text.trim(),
      };

      context.read<ProfileCubit>().updateProfile(
        accessToken: authState.accessToken,
        data: body,
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
    occupationController.dispose();
    latController.dispose();
    lngController.dispose();
    super.dispose();
  }
}
