import 'package:duo_app/common/enums/request_status.dart';
import 'package:duo_app/pages/home/cubit/home_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChooseCourse extends StatefulWidget {
  const ChooseCourse({super.key});

  @override
  State<ChooseCourse> createState() => _ChooseCourseState();
}

class _ChooseCourseState extends State<ChooseCourse> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final homeCubit = context.read<HomeCubit>();
      if (homeCubit.state.courses.isEmpty) {
        homeCubit.loadCourses();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose Course')),
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          if (state.coursesStatus == RequestStatus.requesting) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
            itemCount: state.courses.length,
            itemBuilder: (context, index) {
              return Text(state.courses[index].description);
            },
          );
        },
      ),
    );
  }
}
