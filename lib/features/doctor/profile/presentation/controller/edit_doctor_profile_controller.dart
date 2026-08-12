import 'package:flutter/widgets.dart';
import 'package:priora/features/doctor/profile/domain/models/doctor_profile.dart';
import 'package:priora/features/doctor/profile/presentation/controller/doctor_profile_cubit.dart';

/// Controller of the professional's profile editing form. Manage text
/// controllers, document type and save via [DoctorProfileCubit]. The view only
/// listens.
class EditDoctorProfileController extends ChangeNotifier {
  EditDoctorProfileController({
    required this._cubit,
    this._profile,
  }) {
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _documentIdController = TextEditingController();
    _phoneController = TextEditingController();
    _bioController = TextEditingController();
    _loadProfile();
  }

  static const List<String> docTypes = [
    'DNI',
    'CARNET_EXTRANJERIA',
    'PASAPORTE',
  ];

  final DoctorProfileCubit _cubit;
  final DoctorProfile? _profile;

  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _documentIdController;
  late final TextEditingController _phoneController;
  late final TextEditingController _bioController;

  String _documentType = 'DNI';
  bool _isSubmitting = false;
  String? _submitError;

  TextEditingController get firstNameController => _firstNameController;
  TextEditingController get lastNameController => _lastNameController;
  TextEditingController get documentIdController => _documentIdController;
  TextEditingController get phoneController => _phoneController;
  TextEditingController get bioController => _bioController;
  String get documentType => _documentType;
  bool get isSubmitting => _isSubmitting;
  String? get submitError => _submitError;

  void setDocumentType(String value) {
    _documentType = value;
    notifyListeners();
  }

  void _loadProfile() {
    // El backend puede enviar solo `name` (ej. "Edgar Porras") sin
    // firstName/lastName separados. Derivar de displayName como respaldo.
    final fullName = _profile?.displayName ?? '';
    final nameParts = fullName.trim().isEmpty
        ? const <String>[]
        : fullName.trim().split(RegExp(r'\s+'));

    var firstName = _profile?.firstName;
    var lastName = _profile?.lastName;
    if ((firstName == null || firstName.isEmpty) && nameParts.isNotEmpty) {
      firstName = nameParts.first;
    }
    if ((lastName == null || lastName.isEmpty) && nameParts.length > 1) {
      lastName = nameParts.sublist(1).join(' ');
    }

    _firstNameController.text = firstName ?? '';
    _lastNameController.text = lastName ?? '';
    _documentIdController.text = _profile?.documentId ?? '';
    _phoneController.text = _profile?.phone ?? '';
    _bioController.text = _profile?.bio ?? '';
    _documentType = _profile?.documentType ?? 'DNI';
    if (!docTypes.contains(_documentType)) {
      _documentType = 'DNI';
    }
  }

  /// Please submit your profile update. Returns` true `if successful, otherwise
  /// leaves the error in [submitError].
  Future<bool> save() async {
    _isSubmitting = true;
    _submitError = null;
    notifyListeners();

    final data = <String, dynamic>{
      'firstName': _firstNameController.text.trim(),
      'lastName': _lastNameController.text.trim(),
      'documentType': _documentType,
      'documentId': _documentIdController.text.trim(),
      'phone': _phoneController.text.trim(),
      'bio': _bioController.text.trim(),
    };

    final result = await _cubit.updateProfile(data: data);

    _isSubmitting = false;
    if (!result.success) {
      _submitError =
          result.message ??
          'Error al actualizar el perfil. Inténtalo de nuevo.';
    }
    notifyListeners();
    return result.success;
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
}
