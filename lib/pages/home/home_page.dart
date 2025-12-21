import 'dart:math';

import 'package:duo_app/di/injection.dart';
import 'package:duo_app/pages/bloc/app_bloc.dart';
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

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final HomeCubit homeCubit = getIt<HomeCubit>();
  late AnimationController _headerController;
  late Animation<double> _headerFadeAnimation;

  @override
  void initState() {
    super.initState();

    // Header animation
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _headerFadeAnimation = CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeIn,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      homeCubit.initialize();
      _headerController.forward();
    });
  }

  @override
  void dispose() {
    _headerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final halfMaxWidth = MediaQuery.of(context).size.width / 3;
    return BlocProvider.value(
      value: homeCubit,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFF5F9FF), // Very light blue
                Colors.white,
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Blue Gradient Header
                _buildHeader(context),
                // Units List
                Expanded(
                  child: BlocBuilder<HomeCubit, HomeState>(
                    builder: (context, state) {
                      if (state.units.isEmpty) {
                        return const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF1976D2),
                            ),
                          ),
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: () async {
                          await homeCubit.initialize();
                        },
                        color: const Color(0xFF1976D2),
                        child: ListView.builder(
                          itemCount: state.units.length,
                          itemBuilder: (context, index) {
                            return TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration: Duration(
                                milliseconds: 400 + (index * 100),
                              ),
                              curve: Curves.easeOut,
                              builder: (context, value, child) {
                                return Opacity(
                                  opacity: value,
                                  child: Transform.translate(
                                    offset: Offset(0, 30 * (1 - value)),
                                    child: child,
                                  ),
                                );
                              },
                              child: Column(
                                children: [
                                  UnitTile(
                                    title: state.units[index].title ?? '',
                                    description:
                                        state.units[index].description ?? '',
                                    unitNumber: state.units[index].displayOrder
                                        .toString(),
                                    thumbnail: state.units[index].thumbnail,
                                    backgroundColor: const Color(0xFF1976D2),
                                    unitId: state.units[index].id,
                                  ),
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, lessonIndex) {
                                      final offset =
                                          _offsetCalculator(lessonIndex) *
                                          halfMaxWidth;
                                      final lessonId = state
                                          .units[index]
                                          .lessons[lessonIndex]
                                          .id;
                                      final courseId =
                                          state.units[index].courseId;
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
                                          onTap: () async {
                                            await getIt<AppBloc>()
                                                .loadProfile();
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    AnswerPage(
                                                      lessonId: lessonId,
                                                      courseId: courseId,
                                                      unitId: unitId,
                                                      experiencePoint:
                                                          experiencePoint,
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
                                    itemCount:
                                        state.units[index].lessons.length,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        final selectedCourse = state.selectedCourse;
        final courseName = selectedCourse?.description ?? 'Learning Path';
        final unitsCount = state.units.length;
        final subtitle = selectedCourse != null
            ? '$unitsCount ${unitsCount == 1 ? 'Unit' : 'Units'} available'
            : 'Continue your journey';

        return FadeTransition(
          opacity: _headerFadeAnimation,
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1E88E5), // Blue 600
                  Color(0xFF42A5F5), // Blue 400
                ],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0x331976D2),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          courseName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.menu_book,
                        color: Colors.white,
                        size: 28,
                      ),
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
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  double _offsetCalculator(int input) {
    return sin(pi / 4 * input);
  }
}
