import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../common/resources/index.dart';
import '../../common/utils/widgets/spacing.dart';
import '../../di/injection.dart';
import '../../route/app_route.dart';
import '../../route/navigator.dart';
import 'bootstrap_cubit.dart';
import 'bootstrap_state.dart';

class BootstrapPage extends StatefulWidget {
  const BootstrapPage({super.key});

  @override
  State<BootstrapPage> createState() => _BootstrapPageState();
}

class _BootstrapPageState extends State<BootstrapPage> {
  final BootstrapCubit _bloc = getIt<BootstrapCubit>();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _bloc.initData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: AppColors.white,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(96.0),
            child: Center(child: Image.asset(AssetImages.logo)),
          ),
        ),
      ),
    );
  }
}
