import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:freedome_sphere_flutter/services/anantasound_service.dart';
import 'package:freedome_sphere_flutter/models/anantasound_device.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockAudioPlayer extends Mock implements AudioPlayer {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('AnantaSoundService', () {
    late AnantaSoundService anantaSoundService;
    late MockAudioPlayer mockAudioPlayer;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      mockAudioPlayer = MockAudioPlayer();
      anantaSoundService = AnantaSoundService(audioPlayer: mockAudioPlayer);

      when(mockAudioPlayer.setSourceDeviceFile(any)).thenAnswer((_) async => ());
      when(mockAudioPlayer.resume()).thenAnswer((_) async => ());
      when(mockAudioPlayer.pause()).thenAnswer((_) async => ());
      when(mockAudioPlayer.dispose()).thenAnswer((_) async => ());
    });

    test('initialize initializes the service', () async {
      final result = await anantaSoundService.initialize();
      expect(result, isTrue);
    });

    test('activateQuantumResonance activates the resonance', () async {
      await anantaSoundService.initialize();
      final result = await anantaSoundService.activateQuantumResonance();
      expect(result, isTrue);
      expect(anantaSoundService.isActive(), isTrue);
    });

    test('deactivateQuantumResonance deactivates the resonance', () async {
      await anantaSoundService.initialize();
      await anantaSoundService.activateQuantumResonance();
      await anantaSoundService.deactivateQuantumResonance();
      expect(anantaSoundService.isActive(), isFalse);
    });

    test('createConsciousnessField creates a new field', () async {
      await anantaSoundService.initialize();
      final field = ConsciousnessField(
        radius: 10.0,
        intensity: 0.5,
        frequency: 7.83,
        participantWeights: [],
        participantPositions: [],
        coherenceRatio: 0.0,
      );
      final result = await anantaSoundService.createConsciousnessField(field);
      expect(result, isTrue);
    });

    test('addParticipant adds a participant', () async {
      await anantaSoundService.initialize();
      final initialParticipants = anantaSoundService.device!.consciousnessField.participantWeights.length;
      await anantaSoundService.addParticipant(const SphericalCoord(r: 1, theta: 1, phi: 1, height: 1), 1.0);
      final finalParticipants = anantaSoundService.device!.consciousnessField.participantWeights.length;
      expect(finalParticipants, initialParticipants + 1);
    });

    test('removeParticipant removes a participant', () async {
      await anantaSoundService.initialize();
      await anantaSoundService.addParticipant(const SphericalCoord(r: 1, theta: 1, phi: 1, height: 1), 1.0);
      final initialParticipants = anantaSoundService.device!.consciousnessField.participantWeights.length;
      await anantaSoundService.removeParticipant(0);
      final finalParticipants = anantaSoundService.device!.consciousnessField.participantWeights.length;
      expect(finalParticipants, initialParticipants - 1);
    });

    test('connectMIDI connects to MIDI', () async {
      await anantaSoundService.initialize();
      final result = await anantaSoundService.connectMIDI();
      expect(result, isTrue);
      expect(anantaSoundService.device!.status.midiConnected, isTrue);
    });

    test('disconnectMIDI disconnects from MIDI', () async {
      await anantaSoundService.initialize();
      await anantaSoundService.connectMIDI();
      await anantaSoundService.disconnectMIDI();
      expect(anantaSoundService.device!.status.midiConnected, isFalse);
    });

    test('connectOSC connects to OSC', () async {
      await anantaSoundService.initialize();
      final result = await anantaSoundService.connectOSC();
      expect(result, isTrue);
      expect(anantaSoundService.device!.status.oscConnected, isTrue);
    });

    test('disconnectOSC disconnects from OSC', () async {
      await anantaSoundService.initialize();
      await anantaSoundService.connectOSC();
      await anantaSoundService.disconnectOSC();
      expect(anantaSoundService.device!.status.oscConnected, isFalse);
    });
  });
}
