import 'package:duo_app/di/injection.dart';
import 'package:duo_app/pages/profile/cubit/profile_cubit.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});
  final ProfileCubit _cubit = getIt<ProfileCubit>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            _cubit.logOut();
          },
          child: const Text('Log Out'),
        ),
      ),
    );
  }
}
