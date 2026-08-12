import 'package:flutter/widgets.dart';
import 'package:priora/features/doctor/places/data/ubigeo.dart';
import 'package:priora/features/doctor/places/domain/models/place.dart';
import 'package:priora/features/doctor/places/presentation/controller/places_cubit.dart';

/// Controller of the form to create/edit a point of care. Manage form status
/// (name, location, coordinates) and creation/update via [PlacesCubit]. The
/// view only listens.
class CreatePlaceController extends ChangeNotifier {
  CreatePlaceController({
    required this._placesCubit,
    required this._accessToken,
    Place? place,
  }) : _place = place {
    _nameController = TextEditingController(text: place?.name ?? '');
    _addressController = TextEditingController(text: place?.address ?? '');
    _selectedDepartment = place?.department;
    _selectedProvince = place?.province;
    _selectedDistrict = place?.district;
    _latitude = place?.latitude;
    _longitude = place?.longitude;
  }

  final PlacesCubit _placesCubit;
  final String _accessToken;
  final Place? _place;

  late final TextEditingController _nameController;
  late final TextEditingController _addressController;

  String? _selectedDepartment;
  String? _selectedProvince;
  String? _selectedDistrict;
  double? _latitude;
  double? _longitude;

  bool _isLoading = false;

  bool get isEditing => _place != null;
  TextEditingController get nameController => _nameController;
  TextEditingController get addressController => _addressController;
  String? get selectedDepartment => _selectedDepartment;
  String? get selectedProvince => _selectedProvince;
  String? get selectedDistrict => _selectedDistrict;
  double? get latitude => _latitude;
  double? get longitude => _longitude;
  bool get isLoading => _isLoading;

  List<String> get provinces {
    if (_selectedDepartment == null) return [];
    return UbigeoData.getProvinces(_selectedDepartment!);
  }

  List<String> get districts {
    if (_selectedDepartment == null || _selectedProvince == null) return [];
    return UbigeoData.getDistricts(_selectedDepartment!, _selectedProvince!);
  }

  void onDepartmentChanged(String? value) {
    _selectedDepartment = value;
    _selectedProvince = null;
    _selectedDistrict = null;
    notifyListeners();
  }

  void onProvinceChanged(String? value) {
    _selectedProvince = value;
    _selectedDistrict = null;
    notifyListeners();
  }

  void onDistrictChanged(String? value) {
    _selectedDistrict = value;
    notifyListeners();
  }

  void setLocation(double? latitude, double? longitude) {
    _latitude = latitude;
    _longitude = longitude;
    notifyListeners();
  }

  /// Create or update the venue based on [isEditing]. Returns` true `if
  /// successful.
  Future<bool> save() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = <String, dynamic>{
        'name': _nameController.text.trim(),
        'country': 'Perú',
        'department': _selectedDepartment,
        'province': _selectedProvince,
        'district': _selectedDistrict,
        'address': _addressController.text.trim(),
        if (_latitude != null) 'latitude': _latitude,
        if (_longitude != null) 'longitude': _longitude,
      };

      if (isEditing) {
        return await _placesCubit.updatePlace(
          accessToken: _accessToken,
          placeId: _place!.id,
          data: data,
        );
      }
      return await _placesCubit.createPlace(
        accessToken: _accessToken,
        data: data,
      );
    } catch (e) {
      debugPrint('Error saving place: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}
