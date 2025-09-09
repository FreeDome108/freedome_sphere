import 'package:flutter/material.dart';
import 'package:freedome_sphere_flutter/models/freedome_learning_complex/lubomir_tutorial.dart';

class TutorialsScreen extends StatelessWidget {
  final List<LubomirTutorial> tutorials;

  const TutorialsScreen({super.key, required this.tutorials});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Туториалы'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: tutorials.length,
        itemBuilder: (context, index) {
          final tutorial = tutorials[index];
          return ListTile(
            title: Text(tutorial.name),
            subtitle: Text(tutorial.description),
            trailing: Icon(Icons.play_circle_outline),
            onTap: () {
              // Действие при нажатии на туториал
            },
          );
        },
      ),
    );
  }
}
