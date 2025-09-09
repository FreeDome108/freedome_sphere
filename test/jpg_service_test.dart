import 'package:file_picker/file_picker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:freedome_sphere_flutter/services/jpg_service.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

// Mock class for FilePicker
class MockFilePicker extends Fake with MockPlatformInterfaceMixin implements FilePicker {
  @override
  Future<FilePickerResult?> pickFiles({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Function(FilePickerStatus)? onFileLoading,
    bool allowMultiple = false,
    bool withData = false,
    bool withReadStream = false,
    bool lockParentWindow = false,
  }) async {
    return FilePickerResult([PlatformFile(path: 'dummy/path/to/jpg.jpg', name: 'jpg.jpg', size: 100)]);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('JpgService', () {
    late JpgService jpgService;

    setUp(() {
      jpgService = JpgService();
      FilePicker.platform = MockFilePicker();
    });

    test('pickJpg sets jpg when a file is picked', () async {
      await jpgService.pickJpg();

      expect(jpgService.jpg, isNotNull);
      expect(jpgService.jpg!.path, 'dummy/path/to/jpg.jpg');
    });
  });
}
