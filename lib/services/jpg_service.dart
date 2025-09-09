import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:freedome_sphere_flutter/models/jpg_model.dart';

class JpgService extends ChangeNotifier {
  Jpg? _jpg;

  Jpg? get jpg => _jpg;

  Future<void> pickJpg() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg'],
    );

    if (result != null) {
      _jpg = Jpg(path: result.files.single.path!);
      notifyListeners();
    }
  }
}
