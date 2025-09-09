import 'package:file_picker/file_picker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:freedome_sphere_flutter/services/video_service.dart';
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
    bool? allowCompression,
    bool? readSequential,
    int? compressionQuality,
  }) async {
    return FilePickerResult([PlatformFile(path: 'dummy/path/to/video.mp4', name: 'video.mp4', size: 100)]);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('VideoService', () {
    late VideoService videoService;

    setUp(() {
      videoService = VideoService();
      FilePicker.platform = MockFilePicker();
    });

    test('pickVideo sets video when a file is picked', () async {
      await videoService.pickVideo();

      expect(videoService.video, isNotNull);
      expect(videoService.video!.path, 'dummy/path/to/video.mp4');
    });
  });
}
