import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../models/app_edition.dart';
import '../services/theme_service.dart';

class EditionSelector extends StatelessWidget {
  const EditionSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        return PopupMenuButton<AppEdition>(
          icon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                themeService.currentEditionInfo.logoPath,
                width: 20,
                height: 20,
              ),
              const SizedBox(width: 8),
              Text(
                themeService.currentEditionInfo.name,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
          onSelected: (AppEdition edition) {
            themeService.setEdition(edition);
          },
          itemBuilder: (BuildContext context) {
            return AppEdition.values.map((AppEdition edition) {
              final editionInfo = EditionInfo.getEditionInfo(edition);
              final isSelected = edition == themeService.currentEdition;
              
              return PopupMenuItem<AppEdition>(
                value: edition,
                child: Row(
                  children: [
                    SvgPicture.asset(
                      editionInfo.logoPath,
                      width: 16,
                      height: 16,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            editionInfo.name,
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? Theme.of(context).primaryColor : null,
                            ),
                          ),
                          Text(
                            editionInfo.description,
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Icon(
                        Icons.check,
                        color: Theme.of(context).primaryColor,
                        size: 16,
                      ),
                  ],
                ),
              );
            }).toList();
          },
        );
      },
    );
  }
}
