import 'package:flutter_bloc/flutter_bloc.dart';

class DoctorNavigationCubit extends Cubit<int> {
  DoctorNavigationCubit() : super(0);

  void changeIndex(int newIndex) {
    if (state == newIndex) return;
    emit(newIndex);
  }
}
