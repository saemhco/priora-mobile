import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:priora/features/doctor/profile/presentation/controller/doctor_profile_cubit.dart';
import 'package:priora/features/doctor/profile/presentation/controller/edit_doctor_profile_controller.dart';
import 'package:priora/features/doctor/profile/presentation/widgets/edit_doctor_profile_form.dart';

/// Profile editing screen of the professional. It only composes the widget
/// tree; the status and logic live in [EditDoctorProfileController].
class EditDoctorProfileScreen extends StatefulWidget {
  const EditDoctorProfileScreen({super.key, this.cubit});

  final DoctorProfileCubit? cubit;

  @override
  State<EditDoctorProfileScreen> createState() =>
      _EditDoctorProfileScreenState();
}

class _EditDoctorProfileScreenState extends State<EditDoctorProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  EditDoctorProfileController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller == null) {
      final cubit = widget.cubit ?? context.read<DoctorProfileCubit>();
      _controller = EditDoctorProfileController(
        cubit: cubit,
        profile: cubit.state.profile,
      );
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await _controller!.save();
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil actualizado correctamente'),
          backgroundColor: Color(0xFF059669),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller!,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: const Text(
              'Editar Perfil',
              style: TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            centerTitle: true,
          ),
          body: SafeArea(
            child: EditDoctorProfileForm(
              controller: _controller!,
              formKey: _formKey,
              onSave: _handleSave,
            ),
          ),
        );
      },
    );
  }
}
