import 'package:duo_app/common/enums/request_status.dart';
import 'package:duo_app/common/resources/app_design_system.dart';
import 'package:duo_app/di/injection.dart';
import 'package:duo_app/entities/question.dart';
import 'package:duo_app/entities/unit.dart';
import 'package:duo_app/pages/home/answer_page.dart';
import 'package:duo_app/pages/mistakes/cubit/mistake_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MistakesPage extends StatefulWidget {
  const MistakesPage({super.key});

  @override
  State<MistakesPage> createState() => _MistakesPageState();
}

class _MistakesPageState extends State<MistakesPage> {
  late final MistakeCubit _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = getIt<MistakeCubit>();
    _bloc.getMistakes();
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  void _navigateToMistakeQuiz(Unit unit, List<Question> questions) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AnswerPage(isMistake: true, questions: questions, unitId: unit.id),
      ),
    ).then((_) {
      if (mounted) {
        _bloc.getMistakes();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _bloc,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppDesignSystem.surfaceLight,
                AppDesignSystem.surfaceWhite,
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: BlocBuilder<MistakeCubit, MistakeState>(
                    builder: (context, state) {
                      return RefreshIndicator(
                        onRefresh: () async {
                          await _bloc.getMistakes();
                        },
                        color: AppDesignSystem.primaryGreen,
                        backgroundColor: AppDesignSystem.surfaceWhite,
                        child: Builder(
                          builder: (context) {
                            if (state.status == RequestStatus.requesting) {
                              return _buildLoadingState();
                            }

                            if (state.status == RequestStatus.failed) {
                              return _buildErrorState();
                            }

                            if (state.mistakes.isEmpty) {
                              return _buildEmptyState();
                            }

                            return _buildMistakesList(state);
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

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppDesignSystem.spacing20),
      decoration: BoxDecoration(
        color: AppDesignSystem.surfaceWhite,
        boxShadow: AppDesignSystem.shadowLow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppDesignSystem.spacing12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppDesignSystem.errorRed,
                  AppDesignSystem.errorRed.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(AppDesignSystem.radiusMedium),
              boxShadow: AppDesignSystem.shadowMedium,
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: AppDesignSystem.spacing16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Review Mistakes', style: AppDesignSystem.headlineMedium),
                const SizedBox(height: 2),
                Text(
                  'Practice questions you got wrong',
                  style: AppDesignSystem.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMistakesList(MistakeState state) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppDesignSystem.spacing16),
      itemCount: state.mistakes.length,
      itemBuilder: (context, index) {
        final mistakeMap = state.mistakes[index];
        final unit = mistakeMap.keys.first;
        final questions = mistakeMap.values.first;

        return _buildUnitCard(unit, questions, index);
      },
    );
  }

  Widget _buildUnitCard(Unit unit, List<Question> questions, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 100)),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppDesignSystem.spacing16),
        decoration: AppDesignSystem.cardDecoration(
          shadows: AppDesignSystem.shadowMedium,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _navigateToMistakeQuiz(unit, questions),
            borderRadius: BorderRadius.circular(AppDesignSystem.radiusMedium),
            child: Padding(
              padding: const EdgeInsets.all(AppDesignSystem.spacing16),
              child: Row(
                children: [
                  // Unit Icon
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppDesignSystem.warningOrange.withOpacity(0.8),
                          AppDesignSystem.warningOrange,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(
                        AppDesignSystem.radiusMedium,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${questions.length}',
                        style: AppDesignSystem.headlineMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDesignSystem.spacing16),

                  // Unit Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          unit.title,
                          style: AppDesignSystem.titleLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppDesignSystem.spacing4),
                        Row(
                          children: [
                            Icon(
                              Icons.quiz_outlined,
                              size: 16,
                              color: AppDesignSystem.textSecondary,
                            ),
                            const SizedBox(width: AppDesignSystem.spacing4),
                            Text(
                              '${questions.length} question${questions.length > 1 ? 's' : ''} to review',
                              style: AppDesignSystem.bodyMedium.copyWith(
                                color: AppDesignSystem.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Arrow Icon
                  Container(
                    padding: const EdgeInsets.all(AppDesignSystem.spacing8),
                    decoration: BoxDecoration(
                      color: AppDesignSystem.surfaceLight,
                      borderRadius: BorderRadius.circular(
                        AppDesignSystem.radiusSmall,
                      ),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      color: AppDesignSystem.primaryGreen,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: const [
        SizedBox(height: 200),
        Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              AppDesignSystem.primaryGreen,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppDesignSystem.spacing32),
      children: [
        const SizedBox(height: 100),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppDesignSystem.spacing32),
                decoration: BoxDecoration(
                  color: AppDesignSystem.successGreen.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle_outline_rounded,
                  size: 80,
                  color: AppDesignSystem.successGreen,
                ),
              ),
              const SizedBox(height: AppDesignSystem.spacing24),
              Text(
                'No Mistakes Yet!',
                style: AppDesignSystem.headlineLarge.copyWith(
                  color: AppDesignSystem.successGreen,
                ),
              ),
              const SizedBox(height: AppDesignSystem.spacing12),
              Text(
                'Keep up the great work!\nYou haven\'t made any mistakes.',
                textAlign: TextAlign.center,
                style: AppDesignSystem.bodyLarge.copyWith(
                  color: AppDesignSystem.textSecondary,
                ),
              ),
              const SizedBox(height: AppDesignSystem.spacing16),
              Text(
                'Pull down to refresh',
                style: AppDesignSystem.bodyMedium.copyWith(
                  color: AppDesignSystem.textTertiary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppDesignSystem.spacing32),
      children: [
        const SizedBox(height: 100),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppDesignSystem.spacing32),
                decoration: BoxDecoration(
                  color: AppDesignSystem.errorRed.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  size: 80,
                  color: AppDesignSystem.errorRed,
                ),
              ),
              const SizedBox(height: AppDesignSystem.spacing24),
              Text(
                'Failed to Load',
                style: AppDesignSystem.headlineLarge.copyWith(
                  color: AppDesignSystem.errorRed,
                ),
              ),
              const SizedBox(height: AppDesignSystem.spacing12),
              Text(
                'Unable to load your mistakes.\nPull down to refresh or tap retry.',
                textAlign: TextAlign.center,
                style: AppDesignSystem.bodyLarge.copyWith(
                  color: AppDesignSystem.textSecondary,
                ),
              ),
              const SizedBox(height: AppDesignSystem.spacing24),
              SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () => _bloc.getMistakes(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppDesignSystem.primaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppDesignSystem.radiusMedium,
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                  label: Text(
                    'Retry',
                    style: AppDesignSystem.titleMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
