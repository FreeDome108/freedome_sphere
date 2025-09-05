enum AppEdition {
  vaishnava,
  enterprise,
  education,
}

class EditionInfo {
  final AppEdition edition;
  final String name;
  final String description;
  final String logoPath;
  final String primaryColor;
  final String secondaryColor;
  final String backgroundColor;
  final String surfaceColor;
  final String textColor;
  final String accentColor;

  const EditionInfo({
    required this.edition,
    required this.name,
    required this.description,
    required this.logoPath,
    required this.primaryColor,
    required this.secondaryColor,
    required this.backgroundColor,
    required this.surfaceColor,
    required this.textColor,
    required this.accentColor,
  });

  static const Map<AppEdition, EditionInfo> editions = {
    AppEdition.vaishnava: EditionInfo(
      edition: AppEdition.vaishnava,
      name: 'Vaishnava Edition',
      description: 'Светлая тема для глубоких вопросов и духовного развития',
      logoPath: 'assets/logos/vaishnava_logo.svg',
      primaryColor: '0xFF87CEEB', // Светло-голубой (Sky Blue)
      secondaryColor: '0xFFB0E0E6', // Порошковый голубой (Powder Blue)
      backgroundColor: '0xFFF0F8FF', // Алиса Блю (Alice Blue)
      surfaceColor: '0xFFFFFFFF', // Белый
      textColor: '0xFF2F4F4F', // Темно-серый (Dark Slate Gray)
      accentColor: '0xFF4682B4', // Стальной голубой (Steel Blue)
    ),
    AppEdition.enterprise: EditionInfo(
      edition: AppEdition.enterprise,
      name: 'Enterprise Edition',
      description: 'Профессиональная тема для корпоративного использования',
      logoPath: 'assets/logos/enterprise_logo.svg',
      primaryColor: '0xFF1E3A8A', // Темно-синий
      secondaryColor: '0xFF3B82F6', // Синий
      backgroundColor: '0xFF0F172A', // Очень темный синий
      surfaceColor: '0xFF1E293B', // Темно-серый
      textColor: '0xFFF8FAFC', // Светло-серый
      accentColor: '0xFF10B981', // Зеленый
    ),
    AppEdition.education: EditionInfo(
      edition: AppEdition.education,
      name: 'Education Edition',
      description: 'Образовательная тема для обучения и исследований',
      logoPath: 'assets/logos/education_logo.svg',
      primaryColor: '0xFF7C3AED', // Фиолетовый
      secondaryColor: '0xFFA855F7', // Светло-фиолетовый
      backgroundColor: '0xFFFEF3C7', // Светло-желтый
      surfaceColor: '0xFFFFFFFF', // Белый
      textColor: '0xFF1F2937', // Темно-серый
      accentColor: '0xFF059669', // Зеленый
    ),
  };

  static EditionInfo getEditionInfo(AppEdition edition) {
    return editions[edition] ?? editions[AppEdition.vaishnava]!;
  }
}
