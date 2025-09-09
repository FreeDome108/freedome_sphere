import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:freedome_sphere_flutter/models/video_model.dart';

class VideoService extends ChangeNotifier {
  Video? _video;

  Video? get video => _video;

  Future<void> pickVideo() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp4'],
    );

    if (result != null) {
      _video = Video(path: result.files.single.path!);
      notifyListeners();
    }
  }
}
