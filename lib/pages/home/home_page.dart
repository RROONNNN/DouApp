import 'dart:math';

import 'package:duo_app/data/remote/learning_service.dart';
import 'package:duo_app/di/injection.dart';
import 'package:duo_app/pages/home/answer_page.dart';
import 'package:duo_app/pages/home/choose_course.dart';
import 'package:duo_app/pages/home/cubit/home_cubit.dart';
import 'package:duo_app/pages/home/elements/animated_button.dart';
import 'package:duo_app/pages/home/elements/unit_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

const String defaultCourseId = '68cd5bd514e80cdf75770d9e';
const String defaultUnitId = '68e0b2497fb03278f10e8aaa';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeCubit homeCubit = getIt<HomeCubit>();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      homeCubit.initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final halfMaxWidth = MediaQuery.of(context).size.width / 3;
    return BlocProvider(
      create: (context) => homeCubit,
      child: Scaffold(
        appBar: AppBar(
          forceMaterialTransparency: true,
          actions: [
            // choose course
            IconButton(
              icon: const Icon(Icons.menu_book),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlocProvider.value(
                      value: homeCubit,
                      child: const ChooseCourse(),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
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
                      unitId: state.units[index].id,
                    ),

                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, lessonIndex) {
                        final offset =
                            _offsetCalculator(lessonIndex) * halfMaxWidth;
                        final lessonId =
                            state.units[index].lessons[lessonIndex].id;
                        final courseId = state.units[index].courseId;
                        final unitId = state.units[index].id;
                        final experiencePoint = state
                            .units[index]
                            .lessons[lessonIndex]
                            .experiencePoint;
                        return Padding(
                          padding: EdgeInsets.only(
                            left: offset < 0 ? -offset : 0,
                            right: offset > 0 ? offset : 0,
                            bottom: 18,
                          ),
                          child: AnimatedButton(
                            height: 60,
                            width: 60,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AnswerPage(
                                    lessonId: lessonId,
                                    courseId: courseId,
                                    unitId: unitId,
                                    experiencePoint: experiencePoint,
                                  ),
                                ),
                              );
                            },
                            child: Image.asset(
                              'assets/level.png',
                              fit: BoxFit.contain,
                            ),
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
