import 'dart:io';

import 'package:flutter/material.dart';
import 'package:freedome_sphere_flutter/services/video_service.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class VideoScreen extends StatefulWidget {
  const VideoScreen({super.key});

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  VideoPlayerController? _controller;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => VideoService(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Video Importer'),
        ),
        body: Consumer<VideoService>(
          builder: (context, videoService, child) {
            if (videoService.video != null && _controller == null) {
              _controller = VideoPlayerController.file(File(videoService.video!.path))
                ..initialize().then((_) {
                  setState(() {});
                  _controller!.play();
                });
            }
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  if (_controller != null && _controller!.value.isInitialized)
                    AspectRatio(
                      aspectRatio: _controller!.value.aspectRatio,
                      child: VideoPlayer(_controller!),
                    )
                  else
                    const Text('No video selected'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      await videoService.pickVideo();
                    },
                    child: const Text('Pick Video'),
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
