import 'package:cached_network_image/cached_network_image.dart';
import 'package:duo_app/common/resources/app_colors.dart';
import 'package:duo_app/common/resources/asset_images.dart';
import 'package:duo_app/common/resources/styles/text_styles.dart';
import 'package:duo_app/common/utils/widgets/loading_page.dart';
import 'package:duo_app/pages/home/elements/tap_lottie_widget.dart';
import 'package:duo_app/data/remote/learning_service.dart';
import 'package:duo_app/di/injection.dart';
import 'package:duo_app/entities/theory.dart';
import 'package:duo_app/pages/home/elements/flash_card.dart';
import 'package:flutter/material.dart';

class TheoryPage extends StatefulWidget {
  final String unitId;

  const TheoryPage({super.key, required this.unitId});

  @override
  State<TheoryPage> createState() => _TheoryPageState();
}

class _TheoryPageState extends State<TheoryPage> {
  late LearningService learningService;
  late PageController _pageController;
  int _currentPage = 0;
  List<Theory> _theories = [];
  late Future<List<Theory>> _theoriesFuture; // Cache the future

  Future<List<Theory>> _fetchTheories() async {
    debugPrint('🔄 _fetchTheories() called - This should only happen ONCE');
    await Future.delayed(const Duration(seconds: 2));
    // final theories = await learningService.getTheoriesByUnitId(widget.unitId);
    final sampleFlashCardTheory = Theory(
      id: '68ef5624d91997c2b4de7a5f',
      unitId: '68e0b2497fb03278f10e8aaa',
      audio:
          'https://stream-dict-laban.zdn.vn/us/93e02526ee97dadc301f910d4cc4b51b/199e6ea2d6f/H/house.mp3',
      translation: 'ngôi nhà',
      term: 'house',
      image:
          'https://kenh14cdn.com/203336854389633024/2023/6/3/photo-1-1685759770994199253949.jpg',
      ipa: '/haʊs/',
      partOfSpeech: 'noun',
      displayOrder: 2,
      typeTheory: 'flashcard',
    );
    final sampleGrammarTheory = Theory(
      id: '68ef5518d91997c2b4de7a5b',
      unitId: '68e0b2497fb03278f10e8aaa',
      title: 'Past Simple Tense',
      content:
          'We use the past simple tense to describe actions that happened and finished in the past.',
      example: 'She worked at a bank last year.',
      displayOrder: 1,
      typeTheory: 'grammar',
      // The following fields are omitted for grammar type
    );
    final samplePhraseTheory = Theory(
      id: '68ee203f93d4d63c9c29c966',
      unitId: '68e0b54135010339c4438f57',
      audio:
          'https://res.cloudinary.com/dlpyrgxgf/video/upload/v1760436467/how_are_you_doing_today_vsx9vk.mp3',
      translation: 'Hôm nay bạn thế nào?',
      phraseText: 'How are you doing today?',
      displayOrder: 5,
      typeTheory: 'phrase',
      // updatedAt, createdAt, __v typically not needed for local use
    );
    final theories = [
      sampleGrammarTheory,
      sampleFlashCardTheory,
      samplePhraseTheory,
    ]; // only for example
    return theories;
  }

  @override
  void initState() {
    super.initState();
    learningService = getIt<LearningService>();
    _pageController = PageController();
    // Initialize the future ONCE in initState - this prevents multiple calls
    _theoriesFuture = _fetchTheories();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Theory'),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1E88E5), Color(0xFF42A5F5)],
            ),
          ),
        ),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Theory>>(
        future: _theoriesFuture, // Use cached future - no more repeated calls!
        builder: (context, asyncSnapshot) {
          if (asyncSnapshot.connectionState == ConnectionState.waiting) {
            return const LoadingPage();
          }

          if (asyncSnapshot.hasError) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: AppColors.red),
                  SizedBox(height: 16),
                  Text(
                    'Error loading theories',
                    style: TextStyles.blackNormalBold,
                  ),
                ],
              ),
            );
          }

          _theories = asyncSnapshot.data ?? [];

          if (_theories.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.book_outlined, size: 64, color: AppColors.gray200),
                  SizedBox(height: 16),
                  Text(
                    'No theories available',
                    style: TextStyles.greyNormalRegular,
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: _theories.length,
                  itemBuilder: (context, index) {
                    final theory = _theories[index];
                    return _buildTheoryContent(theory, size);
                  },
                ),
              ),
              _buildPageIndicator(),
              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTheoryContent(Theory theory, Size size) {
    debugPrint(
      '📄 Building theory: ${theory.typeTheory} (displayOrder: ${theory.displayOrder})',
    );
    // Wrap with KeepAliveWrapper to prevent unnecessary rebuilds when swiping
    return KeepAliveWrapper(child: _buildTheoryContentInternal(theory, size));
  }

  Widget _buildTheoryContentInternal(Theory theory, Size size) {
    switch (theory.typeTheory) {
      case 'flashcard':
        return _buildFlashCardView(theory, size);
      case 'grammar':
        return _buildGrammarView(theory);
      case 'phrase':
        return _buildPhraseView(theory);
      default:
        return const Center(
          child: Text(
            'Unknown theory type',
            style: TextStyles.greyNormalRegular,
          ),
        );
    }
  }

  Widget _buildPageIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Previous button
          IconButton(
            onPressed: _currentPage > 0
                ? () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                : null,
            icon: Icon(
              Icons.arrow_back_ios,
              color: _currentPage > 0
                  ? const Color(0xFF1976D2)
                  : AppColors.gray200,
            ),
          ),
          const SizedBox(width: 8),
          // Page dots
          ...List.generate(
            _theories.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 8,
              width: _currentPage == index ? 24 : 8,
              decoration: BoxDecoration(
                color: _currentPage == index
                    ? const Color(0xFF1976D2)
                    : AppColors.gray200,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Next button
          IconButton(
            onPressed: _currentPage < _theories.length - 1
                ? () {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                : null,
            icon: Icon(
              Icons.arrow_forward_ios,
              color: _currentPage < _theories.length - 1
                  ? const Color(0xFF1976D2)
                  : AppColors.gray200,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlashCardView(Theory theory, Size size) {
    return Center(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: FlashCard(
            frontWidget: _buildFlashCardFront(theory),
            backWidget: _buildFlashCardBack(theory),
            flipDuration: const Duration(milliseconds: 600),
            height: size.height * 0.5,
            width: size.width * 0.85,
          ),
        ),
      ),
    );
  }

  Widget _buildGrammarView(Theory theory) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Grammar badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.blue.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.menu_book, size: 16, color: AppColors.blue),
                const SizedBox(width: 6),
                Text(
                  'GRAMMAR',
                  style: TextStyles.blueNormalBold.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Title
          if (theory.title != null && theory.title!.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.blue.withOpacity(0.1),
                    AppColors.blueLight.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.blue.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Text(
                theory.title!,
                style: TextStyles.blackBigBold.copyWith(
                  fontSize: 26,
                  color: AppColors.blue,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          const SizedBox(height: 24),
          // Content section
          if (theory.content != null && theory.content!.isNotEmpty) ...[
            _buildSectionHeader('Explanation', Icons.lightbulb_outline),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                theory.content!,
                style: TextStyles.blackNormalRegular.copyWith(
                  fontSize: 16,
                  height: 1.6,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
          // Example section
          if (theory.example != null && theory.example!.isNotEmpty) ...[
            _buildSectionHeader('Example', Icons.format_quote),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primaryColorGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primaryColorGreen.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.primaryColorGreen,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      theory.example!,
                      style: TextStyles.blackNormalRegular.copyWith(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPhraseView(Theory theory) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Phrase badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.orange.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.chat_bubble_outline,
                    size: 16,
                    color: AppColors.orange,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'PHRASE',
                    style: TextStyles.blackNormalBold.copyWith(
                      fontSize: 12,
                      color: AppColors.orange,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Main phrase card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.orange.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Phrase text
                  if (theory.phraseText != null &&
                      theory.phraseText!.isNotEmpty)
                    Text(
                      theory.phraseText!,
                      style: TextStyles.blackBigBold.copyWith(
                        fontSize: 24,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  const SizedBox(height: 24),
                  // Divider
                  Container(
                    height: 2,
                    width: 60,
                    decoration: BoxDecoration(
                      color: AppColors.orange.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Translation
                  if (theory.translation != null &&
                      theory.translation!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        theory.translation!,
                        style: TextStyles.blackNormalRegular.copyWith(
                          fontSize: 18,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Audio player
            if (theory.audio != null && theory.audio!.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.volume_up,
                      color: AppColors.primaryColor,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    TapLottieWidget(
                      animationPath: AssetImages.lineSoundIconAnimations,
                      width: 60,
                      height: 60,
                      audioPath: theory.audio!,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Listen',
                      style: TextStyles.blackNormalBold.copyWith(fontSize: 16),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primaryColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyles.blackNormalBold.copyWith(
            fontSize: 18,
            color: const Color(0xFF1976D2),
          ),
        ),
      ],
    );
  }

  Widget _buildFlashCardFront(Theory theory) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Image Container with professional styling
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CachedNetworkImage(
                imageUrl: theory.image ?? '',
                width: 140,
                height: 140,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: AppColors.backgroundColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF1976D2),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: AppColors.gray,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.image_not_supported_outlined,
                    size: 48,
                    color: AppColors.gray200,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Sound animation with better styling
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1976D2).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TapLottieWidget(
              animationPath: AssetImages.lineSoundIconAnimations,
              width: 60,
              height: 60,
              audioPath: theory.audio ?? '',
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Tap to reveal',
            style: TextStyles.greySmallRegular.copyWith(
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlashCardBack(Theory theory) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Main term with emphasis
          if (theory.term != null && theory.term!.isNotEmpty)
            Text(
              theory.term!,
              style: TextStyles.blackBigBold.copyWith(
                fontSize: 28,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: 16),
          // Translation with label
          if (theory.translation != null && theory.translation!.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1976D2).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'Translation',
                    style: TextStyles.greySmallRegular.copyWith(
                      fontSize: 11,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    theory.translation!,
                    style: TextStyles.blackNormalBold.copyWith(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          // IPA and Part of Speech in a row
          if (theory.ipa != null || theory.partOfSpeech != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (theory.ipa != null && theory.ipa!.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.blueLight.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.volume_up,
                          size: 16,
                          color: AppColors.blue,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          theory.ipa!,
                          style: TextStyles.blueNormalRegular.copyWith(
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (theory.ipa != null &&
                    theory.ipa!.isNotEmpty &&
                    theory.partOfSpeech != null &&
                    theory.partOfSpeech!.isNotEmpty)
                  const SizedBox(width: 12),
                if (theory.partOfSpeech != null &&
                    theory.partOfSpeech!.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColorGreen.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      theory.partOfSpeech!.toUpperCase(),
                      style: TextStyles.primarySmallBold.copyWith(
                        fontSize: 12,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
              ],
            ),
          const SizedBox(height: 12),
          Text(
            'Tap to flip',
            style: TextStyles.greySmallRegular.copyWith(
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

/// KeepAliveWrapper - Giữ widget không bị dispose khi vuốt sang trang khác
/// Prevents unnecessary rebuilds and audio re-initialization when swiping between pages
class KeepAliveWrapper extends StatefulWidget {
  final Widget child;

  const KeepAliveWrapper({super.key, required this.child});

  @override
  State<KeepAliveWrapper> createState() => _KeepAliveWrapperState();
}

class _KeepAliveWrapperState extends State<KeepAliveWrapper>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // Keep this widget alive!

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required when using AutomaticKeepAliveClientMixin
    return widget.child;
  }
}
