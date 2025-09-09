import 'package:file_picker/file_picker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:freedome_sphere_flutter/services/gif_service.dart';
import 'package:mockito/mockito.dart';

class MockFilePicker extends Mock implements FilePicker {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GifService', () {
    late GifService gifService;
    late MockFilePicker mockFilePicker;

    setUp(() {
      gifService = GifService();
      mockFilePicker = MockFilePicker();
    });

    test('pickGif sets gif when a file is picked', () async {
      const path = 'dummy/path/to/gif.gif';
      final filePickerResult = FilePickerResult([PlatformFile(path: path, name: 'gif.gif', size: 100)]);

      when(mockFilePicker.pickFiles(type: FileType.custom, allowedExtensions: ['gif']))
          .thenAnswer((_) async => filePickerResult);

      await gifService.pickGif();

      expect(gifService.gif, isNotNull);
      expect(gifService.gif!.path, path);
    });

    test('pickGif does not set gif when no file is picked', () async {
      when(mockFilePicker.pickFiles(type: FileType.custom, allowedExtensions: ['gif']))
          .thenAnswer((_) async => null);

      await gifService.pickGif();

      expect(gifService.gif, isNull);
    });
  });
}
