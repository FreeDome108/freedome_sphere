import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../services/locale_service.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeService = Provider.of<LocaleService>(context);
    
    return PopupMenuButton<String>(
      icon: const Icon(
        Icons.language,
        color: Colors.white70,
        size: 20,
      ),
      tooltip: l10n.language,
      onSelected: (String languageCode) {
        localeService.setLocale(Locale(languageCode));
      },
      itemBuilder: (BuildContext context) {
        return LocaleService.supportedLocales.map((Locale locale) {
          final isSelected = locale.languageCode == localeService.currentLocale.languageCode;
          
          return PopupMenuItem<String>(
            value: locale.languageCode,
            child: Row(
              children: [
                if (isSelected)
                  const Icon(
                    Icons.check,
                    color: Color(0xFF4A9EFF),
                    size: 16,
                  )
                else
                  const SizedBox(width: 16),
                const SizedBox(width: 8),
                Text(
                  LocaleService.localeNames[locale.languageCode] ?? locale.languageCode,
                  style: TextStyle(
                    color: isSelected ? const Color(0xFF4A9EFF) : Colors.white,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          );
        }).toList();
      },
    );
  }
}
