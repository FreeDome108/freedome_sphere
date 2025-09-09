import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:freedome_sphere_flutter/models/gif_model.dart';

class GifService extends ChangeNotifier {
  Gif? _gif;

  Gif? get gif => _gif;

  Future<void> pickGif() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['gif'],
    );

    if (result != null) {
      _gif = Gif(path: result.files.single.path!);
      notifyListeners();
    }
  }
}
