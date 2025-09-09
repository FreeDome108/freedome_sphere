import 'dart:io';

import 'package:flutter/material.dart';
import 'package:freedome_sphere_flutter/services/jpg_service.dart';
import 'package:provider/provider.dart';

class JpgScreen extends StatelessWidget {
  const JpgScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => JpgService(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('JPG Importer'),
        ),
        body: Consumer<JpgService>(
          builder: (context, jpgService, child) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  if (jpgService.jpg != null)
                    Image.file(
                      File(jpgService.jpg!.path),
                      width: 300,
                      height: 300,
                    ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => jpgService.pickJpg(),
                    child: const Text('Pick JPG'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
