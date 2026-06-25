import 'package:flutter_bloc/flutter_bloc.dart';

class PatientNavigationCubit extends Cubit<int> {
  PatientNavigationCubit() : super(0);

  void changeIndex(int newIndex) {
    if (state == newIndex) return;
    emit(newIndex);
  }
}
