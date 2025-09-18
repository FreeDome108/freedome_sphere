import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/theme_service.dart';
import '../widgets/edition_selector.dart';
import '../widgets/language_selector.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _backgroundController;
  late AnimationController _logoController;
  late AnimationController _fadeController;

  Animation<double>? _backgroundAnimation;
  Animation<double>? _logoAnimation;
  Animation<double>? _fadeAnimation;

  int _currentPage = 0;
  final int _totalPages = 5;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    _backgroundController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );

    _logoController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _backgroundAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _backgroundController, curve: Curves.easeInOut),
    );

    _logoAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _backgroundController.repeat(reverse: true);
    _logoController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _backgroundController.dispose();
    _logoController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenOnboarding', true);

    if (mounted) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ThemeService>(
        builder: (context, themeService, child) {
          final editionInfo = themeService.currentEditionInfo;
          final primaryColor = Color(int.parse(editionInfo.primaryColor));
          final backgroundColor = Color(int.parse(editionInfo.backgroundColor));
          final textColor = Color(int.parse(editionInfo.textColor));

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  backgroundColor,
                  backgroundColor.withOpacity(0.8),
                  primaryColor.withOpacity(0.1),
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Верхняя панель с пропуском
                  _buildTopBar(textColor),

                  // Основной контент
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: _onPageChanged,
                      children: [
                        _buildWelcomePage(primaryColor, textColor),
                        _buildFeaturesPage(primaryColor, textColor),
                        _buildCapabilitiesPage(primaryColor, textColor),
                        _buildEditionPage(primaryColor, textColor),
                        _buildReadyPage(primaryColor, textColor),
                      ],
                    ),
                  ),

                  // Нижняя панель навигации
                  _buildBottomNavigation(primaryColor, textColor),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopBar(Color textColor) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Логотип
          AnimatedBuilder(
            animation: _logoAnimation!,
            builder: (context, child) {
              return Transform.scale(
                scale: _logoAnimation!.value,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.threesixty,
                        color: Colors.blue,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'FreeDome Sphere',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Кнопка пропуска
          TextButton(
            onPressed: _skipOnboarding,
            child: Text(
              'Пропустить',
              style: TextStyle(
                color: textColor.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomePage(Color primaryColor, Color textColor) {
    return AnimatedBuilder(
      animation: _fadeAnimation!,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation!.value,
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Анимированная иконка
                AnimatedBuilder(
                  animation: _backgroundAnimation!,
                  builder: (context, child) {
                    return Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            primaryColor.withOpacity(
                              0.1 + _backgroundAnimation!.value * 0.2,
                            ),
                            primaryColor.withOpacity(0.05),
                          ],
                        ),
                      ),
                      child: const Icon(
                        Icons.threesixty,
                        size: 100,
                        color: Colors.blue,
                      ),
                    );
                  },
                ),

                const SizedBox(height: 48),

                // Заголовок
                Text(
                  'Добро пожаловать в\nFreeDome Sphere',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    height: 1.2,
                  ),
                ),

                const SizedBox(height: 24),

                // Описание
                Text(
                  'Профессиональный редактор сферического 3D и 2D контента с системой понимания Любомира для создания иммерсивных купольных проекций.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: textColor.withOpacity(0.8),
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 32),

                // Ключевые особенности
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildFeatureChip(
                      '3D Редактор',
                      Icons.view_in_ar,
                      primaryColor,
                    ),
                    _buildFeatureChip(
                      'AI Понимание',
                      Icons.psychology,
                      primaryColor,
                    ),
                    _buildFeatureChip('Купол', Icons.threesixty, primaryColor),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeatureChip(String title, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesPage(Color primaryColor, Color textColor) {
    final features = [
      {
        'icon': Icons.view_in_ar,
        'title': '3D Редактор',
        'description':
            'Создавайте сложные 3D сцены с поддержкой различных форматов моделей',
        'color': Colors.blue,
      },
      {
        'icon': Icons.music_note,
        'title': 'AnantaSound',
        'description':
            'Квантовое аудио с пространственным позиционированием и резонансом',
        'color': Colors.purple,
      },
      {
        'icon': Icons.psychology,
        'title': 'Система Любомира',
        'description':
            'AI-понимание контента для автоматической оптимизации и анализа',
        'color': Colors.green,
      },
      {
        'icon': Icons.analytics,
        'title': 'Unreal Optimizer',
        'description':
            'Интеграция с Unreal Engine для профессиональной разработки',
        'color': Colors.orange,
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ключевые возможности',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Откройте для себя мощные инструменты для создания купольного контента',
            style: TextStyle(fontSize: 16, color: textColor.withOpacity(0.7)),
          ),

          const SizedBox(height: 32),

          Expanded(
            child: ListView.builder(
              itemCount: features.length,
              itemBuilder: (context, index) {
                final feature = features[index];
                return _buildFeatureCard(
                  feature['icon'] as IconData,
                  feature['title'] as String,
                  feature['description'] as String,
                  feature['color'] as Color,
                  textColor,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    IconData icon,
    String title,
    String description,
    Color color,
    Color textColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 24, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: textColor.withOpacity(0.7),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCapabilitiesPage(Color primaryColor, Color textColor) {
    final capabilities = [
      {
        'icon': Icons.book,
        'title': 'Импорт комиксов',
        'desc': '.boranko, .comics форматы',
      },
      {
        'icon': Icons.code,
        'title': 'AIBASIC IDE',
        'desc': 'Встроенная среда разработки',
      },
      {
        'icon': Icons.video_library,
        'title': 'Видео редактор',
        'desc': 'Обработка 360° контента',
      },
      {
        'icon': Icons.image,
        'title': 'Изображения',
        'desc': 'JPG, GIF поддержка',
      },
      {
        'icon': Icons.extension,
        'title': 'Плагины',
        'desc': 'Расширяемость системы',
      },
      {
        'icon': Icons.school,
        'title': 'Туториалы',
        'desc': 'Интерактивное обучение',
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Расширенные возможности',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Полный набор инструментов для профессиональной работы',
            style: TextStyle(fontSize: 16, color: textColor.withOpacity(0.7)),
          ),

          const SizedBox(height: 32),

          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
              ),
              itemCount: capabilities.length,
              itemBuilder: (context, index) {
                final capability = capabilities[index];
                return _buildCapabilityCard(
                  capability['icon'] as IconData,
                  capability['title'] as String,
                  capability['desc'] as String,
                  primaryColor,
                  textColor,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCapabilityCard(
    IconData icon,
    String title,
    String description,
    Color primaryColor,
    Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor.withOpacity(0.2), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: primaryColor),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(fontSize: 11, color: textColor.withOpacity(0.6)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEditionPage(Color primaryColor, Color textColor) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Выберите издание',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Выберите подходящую версию для ваших потребностей',
            style: TextStyle(fontSize: 16, color: textColor.withOpacity(0.7)),
          ),

          const SizedBox(height: 32),

          Expanded(
            child: Column(
              children: [
                const EditionSelector(),
                const SizedBox(height: 24),
                const LanguageSelector(),
                const Spacer(),

                // Дополнительная информация
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: primaryColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: primaryColor, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Настройки можно изменить в любое время в меню приложения',
                          style: TextStyle(
                            color: textColor.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadyPage(Color primaryColor, Color textColor) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Анимированная иконка готовности
          AnimatedBuilder(
            animation: _backgroundAnimation!,
            builder: (context, child) {
              return Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.green.withOpacity(
                        0.2 + _backgroundAnimation!.value * 0.1,
                      ),
                      Colors.green.withOpacity(0.1),
                    ],
                  ),
                ),
                child: const Icon(
                  Icons.rocket_launch,
                  size: 80,
                  color: Colors.green,
                ),
              );
            },
          ),

          const SizedBox(height: 48),

          Text(
            'Готовы начать?',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),

          const SizedBox(height: 24),

          Text(
            'Вы настроили FreeDome Sphere и готовы создавать удивительные купольные проекции. Давайте начнем ваше путешествие в мир иммерсивного контента!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              color: textColor.withOpacity(0.8),
              height: 1.5,
            ),
          ),

          const SizedBox(height: 48),

          // Статистика возможностей
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatCard('3D', 'Редактор', Icons.view_in_ar, primaryColor),
              _buildStatCard('AI', 'Понимание', Icons.psychology, primaryColor),
              _buildStatCard(
                '360°',
                'Поддержка',
                Icons.threesixty,
                primaryColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String number,
    String label,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 8),
          Text(
            number,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: color.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation(Color primaryColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          // Индикаторы страниц
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _totalPages,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == index ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? primaryColor
                      : primaryColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Кнопки навигации
          Row(
            children: [
              // Кнопка "Назад"
              if (_currentPage > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: _previousPage,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: textColor,
                      side: BorderSide(color: primaryColor.withOpacity(0.5)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Назад'),
                  ),
                ),

              if (_currentPage > 0) const SizedBox(width: 16),

              // Кнопка "Далее/Готово"
              Expanded(
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    _currentPage == _totalPages - 1 ? 'Начать' : 'Далее',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
