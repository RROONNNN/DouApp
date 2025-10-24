import 'dart:math';

import 'package:duo_app/data/remote/learning_service.dart';
import 'package:duo_app/di/injection.dart';
import 'package:duo_app/pages/home/cubit/home_cubit.dart';
import 'package:duo_app/pages/home/elements/unit_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

const String defaultCourseId = '68cd5bd514e80cdf75770d9e';
const String defaultUnitId = '68e0b2497fb03278f10e8aaa';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  final int defaultLessonCount = 8;
  @override
  Widget build(BuildContext context) {
    final halfMaxWidth = MediaQuery.of(context).size.width / 3;
    return BlocProvider(
      create: (context) => getIt<HomeCubit>()..initialize(),
      child: Scaffold(
        appBar: AppBar(
          forceMaterialTransparency: true,
          actions: [
            IconButton(icon: const Icon(Icons.menu_book), onPressed: () {}),
          ],
        ),
        // floatingActionButton: FloatingActionButton(
        //   onPressed: () async {
        //     LearningService learningService = getIt<LearningService>();
        //     final theories = await learningService.getTheoriesByUnitId(
        //       defaultUnitId,
        //     );
        //     for (var t in theories) {
        //       print(t);
        //     }
        //   },
        //   child: const Icon(Icons.play_arrow),
        // ),
        body: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            return ListView.builder(
              itemCount: state.units.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    UnitTile(
                      title: state.units[index].title,
                      description: state.units[index].description,
                      unitNumber: state.units[index].displayOrder.toString(),
                      backgroundColor: const Color(0xFF58C5F1),
                    ),

                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, lessonIndex) {
                        final offset =
                            _offsetCalculator(lessonIndex) * halfMaxWidth;
                        return Padding(
                          padding: EdgeInsets.only(
                            left: offset < 0 ? -offset : 0,
                            right: offset > 0 ? offset : 0,
                            bottom: 8,
                          ),
                          child: Image.asset(
                            'assets/level.png',
                            width: 60,
                            height: 60,
                            fit: BoxFit.contain,
                          ),
                        );
                      },
                      itemCount: state.units[index].lessons.length,
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  double _offsetCalculator(int input) {
    return sin(pi / 4 * input);
  }
}
