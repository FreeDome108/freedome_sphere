// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'Freedome Sphere';

  @override
  String get newButton => 'नया';

  @override
  String get open => 'खोलें';

  @override
  String get save => 'सहेजें';

  @override
  String get play => 'चलाएं';

  @override
  String get stop => 'रोकें';

  @override
  String get reset => 'रीसेट';

  @override
  String get ready => 'तैयार';

  @override
  String get loadingProject => 'प्रोजेक्ट लोड हो रहा है...';

  @override
  String get projectLoaded => 'प्रोजेक्ट लोड हो गया';

  @override
  String get noProject => 'कोई प्रोजेक्ट नहीं';

  @override
  String errorLoadingProject(String error) {
    return 'प्रोजेक्ट लोड करने में त्रुटि: $error';
  }

  @override
  String get creatingNewProject => 'नया प्रोजेक्ट बनाया जा रहा है...';

  @override
  String get newProjectCreated => 'नया प्रोजेक्ट बन गया';

  @override
  String errorCreatingProject(String error) {
    return 'प्रोजेक्ट बनाने में त्रुटि: $error';
  }

  @override
  String get openingProject => 'प्रोजेक्ट खोला जा रहा है...';

  @override
  String get savingProject => 'प्रोजेक्ट सहेजा जा रहा है...';

  @override
  String get projectSaved => 'प्रोजेक्ट सहेज गया';

  @override
  String get saveFailed => 'सहेजने में विफल';

  @override
  String errorSavingProject(String error) {
    return 'प्रोजेक्ट सहेजने में त्रुटि: $error';
  }

  @override
  String get playingPreview => 'पूर्वावलोकन चल रहा है...';

  @override
  String get previewStopped => 'पूर्वावलोकन रुक गया';

  @override
  String get viewReset => 'दृश्य रीसेट हो गया';

  @override
  String get newProject => 'नया प्रोजेक्ट';

  @override
  String get projectName => 'प्रोजेक्ट का नाम';

  @override
  String get enterProjectName => 'प्रोजेक्ट का नाम दर्ज करें';

  @override
  String get pleaseEnterProjectName => 'कृपया प्रोजेक्ट का नाम दर्ज करें';

  @override
  String get descriptionOptional => 'विवरण (वैकल्पिक)';

  @override
  String get enterProjectDescription => 'प्रोजेक्ट का विवरण दर्ज करें';

  @override
  String get tagsOptional => 'टैग (वैकल्पिक)';

  @override
  String get enterTagsSeparatedByCommas =>
      'टैग को अल्पविराम से अलग करके दर्ज करें';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get create => 'बनाएं';

  @override
  String get project => 'प्रोजेक्ट';

  @override
  String get currentProject => 'वर्तमान प्रोजेक्ट';

  @override
  String created(String date) {
    return 'बनाया गया: $date';
  }

  @override
  String modified(String date) {
    return 'संशोधित: $date';
  }

  @override
  String get import => 'आयात';

  @override
  String get importBoranko => 'Import .boranko';

  @override
  String get importComics => 'Import .comics (deprecated)';

  @override
  String get comicsDeprecatedTitle => 'Legacy Format';

  @override
  String get comicsDeprecatedContent =>
      'The .comics format is deprecated and will be removed in a future version. Please use the modern .boranko format for all new 2D projects.';

  @override
  String get ok => 'OK';

  @override
  String get importingBorankoProject => 'Importing Boranko project...';

  @override
  String errorImportingBorankoProject(String error) {
    return 'Error importing Boranko project: $error';
  }

  @override
  String get barankoComics => 'Baranko कॉमिक्स';

  @override
  String get unrealEngine => 'Unreal Engine';

  @override
  String get blenderModel => 'Blender मॉडल';

  @override
  String get audio => 'ऑडियो';

  @override
  String get anantaSoundSetup => 'anAntaSound सेटअप';

  @override
  String get threeDPositioning => '3D पोजिशनिंग';

  @override
  String get loadDagaFile => '.daga फाइल लोड करें';

  @override
  String get threeDContent => '3D सामग्री';

  @override
  String get loadZelimFile => '.zelim फाइल लोड करें';

  @override
  String get domeSettings => 'डोम सेटिंग्स';

  @override
  String get domeConfiguration => 'डोम कॉन्फ़िगरेशन';

  @override
  String radius(String radius) {
    return 'त्रिज्या: $radiusमी';
  }

  @override
  String get projectionType => 'प्रोजेक्शन प्रकार:';

  @override
  String get spherical => 'गोलाकार';

  @override
  String get fisheye => 'फिशआई';

  @override
  String get equirectangular => 'इक्विरेक्टैंगुलर';

  @override
  String get export => 'निर्यात';

  @override
  String get mbharataClient => 'mbharata_client';

  @override
  String get domeProjection => 'डोम प्रोजेक्शन';

  @override
  String get pleaseCreateOrOpenProject =>
      'कृपया पहले एक प्रोजेक्ट बनाएं या खोलें';

  @override
  String get importingBarankoComics => 'Baranko कॉमिक्स आयात हो रहे हैं...';

  @override
  String get importingUnrealEngineScene =>
      'Unreal Engine सीन आयात हो रहा है...';

  @override
  String get importingBlenderModel => 'Blender मॉडल आयात हो रहा है...';

  @override
  String get settingUpAnantaSound => 'anAntaSound सेटअप हो रहा है...';

  @override
  String get opening3dAudioEditor => '3D ऑडियो एडिटर खुल रहा है...';

  @override
  String get loadingDagaFile => '.daga फाइल लोड हो रही है...';

  @override
  String get loadingZelimFile => '.zelim फाइल लोड हो रही है...';

  @override
  String get exportingToMbharata => 'mbharata_client में निर्यात हो रहा है...';

  @override
  String get exportingDomeProjection => 'डोम प्रोजेक्शन निर्यात हो रहा है...';

  @override
  String get language => 'भाषा';

  @override
  String get english => 'English';

  @override
  String get russian => 'Русский';

  @override
  String get thai => 'ไทย';

  @override
  String get hindi => 'हिन्दी';

  @override
  String get german => 'Deutsch';

  @override
  String get harkonnen => 'Харконнены';

  @override
  String get atreides => 'Атрейдесы';

  @override
  String get petrosyan => 'Петросян';

  @override
  String get homeScreenTitle => 'FreeDome Sphere';

  @override
  String get gifImporterTooltip => 'GIF Importer';

  @override
  String get jpgImporterTooltip => 'JPG Importer';

  @override
  String get videoImporterTooltip => 'Video Importer';

  @override
  String get tutorialsTooltip => 'Tutorials';

  @override
  String get lyubomirUnderstandingTooltip => 'Lyubomir\'s Understanding';

  @override
  String get anantaSoundTooltip => 'anAntaSound Quantum Resonance Device';

  @override
  String get unrealOptimizerTooltip => 'Unreal Engine Optimizer';

  @override
  String get borankoImportSuccess => 'Boranko project imported successfully';

  @override
  String get anantaSoundScreenTitle => 'anAntaSound Quantum Resonance Device';

  @override
  String get active => 'Active';

  @override
  String get inactive => 'Inactive';

  @override
  String get initializingQuantumResonanceDevice =>
      'Initializing Quantum Resonance Device...';

  @override
  String get mp3Management => 'MP3 Management';

  @override
  String get loadMp3 => 'Load MP3';

  @override
  String loadedFile(String fileName) {
    return 'Loaded file: $fileName';
  }

  @override
  String get participantManagement => 'Participant Management';

  @override
  String get addParticipant => 'Add Participant';

  @override
  String get removeParticipant => 'Remove Participant';

  @override
  String get activeParticipants => 'Active Participants:';

  @override
  String participant(int index) {
    return 'Participant $index';
  }

  @override
  String participantDetails(String weight, String r, String theta, String phi) {
    return 'Weight: $weight | Position: ($r, $theta, $phi)';
  }

  @override
  String get realTimeData => 'Real-time Data';

  @override
  String get frequency => 'Frequency';

  @override
  String get intensity => 'Intensity';

  @override
  String get participants => 'Participants';

  @override
  String get midi => 'MIDI';

  @override
  String get connected => 'Connected';

  @override
  String get disconnected => 'Disconnected';

  @override
  String get osc => 'OSC';

  @override
  String get consciousness => 'Consciousness';

  @override
  String get linked => 'Linked';

  @override
  String get notLinked => 'Not Linked';

  @override
  String hzUnit(String value) {
    return '$value Hz';
  }

  @override
  String percentageUnit(String value) {
    return '$value%';
  }
}
