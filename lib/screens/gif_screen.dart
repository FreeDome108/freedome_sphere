import 'dart:io';

import 'package:flutter/material.dart';
import 'package:freedome_sphere_flutter/services/gif_service.dart';
import 'package:provider/provider.dart';

class GifScreen extends StatelessWidget {
  const GifScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GifService(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('GIF Importer'),
        ),
        body: Consumer<GifService>(
          builder: (context, gifService, child) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  if (gifService.gif != null)
                    Image.file(
                      File(gifService.gif!.path),
                      width: 300,
                      height: 300,
                    ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => gifService.pickGif(),
                    child: const Text('Pick GIF'),
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
