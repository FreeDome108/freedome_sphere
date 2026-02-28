import 'package:flutter/material.dart';

class ComicsEditorPage extends StatefulWidget {
  const ComicsEditorPage({super.key});

  @override
  State<ComicsEditorPage> createState() => _ComicsEditorPageState();
}

class _ComicsEditorPageState extends State<ComicsEditorPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Comics Editor')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Comics Editor временно недоступен',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              'Модуль находится в разработке',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
