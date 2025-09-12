import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_kk.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_th.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('hi'),
    Locale('kk'),
    Locale('pt'),
    Locale('ru'),
    Locale('th'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Freedome Sphere'**
  String get appTitle;

  /// New button text
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newButton;

  /// Open button text
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// Save button text
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Play button text
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// Stop button text
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// Reset button text
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// Ready status message
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get ready;

  /// Loading project status message
  ///
  /// In en, this message translates to:
  /// **'Loading project...'**
  String get loadingProject;

  /// Project loaded status message
  ///
  /// In en, this message translates to:
  /// **'Project loaded'**
  String get projectLoaded;

  /// No project status message
  ///
  /// In en, this message translates to:
  /// **'No project'**
  String get noProject;

  /// Error loading project message
  ///
  /// In en, this message translates to:
  /// **'Error loading project: {error}'**
  String errorLoadingProject(String error);

  /// Creating new project status message
  ///
  /// In en, this message translates to:
  /// **'Creating new project...'**
  String get creatingNewProject;

  /// New project created status message
  ///
  /// In en, this message translates to:
  /// **'New project created'**
  String get newProjectCreated;

  /// Error creating project message
  ///
  /// In en, this message translates to:
  /// **'Error creating project: {error}'**
  String errorCreatingProject(String error);

  /// Opening project status message
  ///
  /// In en, this message translates to:
  /// **'Opening project...'**
  String get openingProject;

  /// Saving project status message
  ///
  /// In en, this message translates to:
  /// **'Saving project...'**
  String get savingProject;

  /// Project saved status message
  ///
  /// In en, this message translates to:
  /// **'Project saved'**
  String get projectSaved;

  /// Save failed status message
  ///
  /// In en, this message translates to:
  /// **'Save failed'**
  String get saveFailed;

  /// Error saving project message
  ///
  /// In en, this message translates to:
  /// **'Error saving project: {error}'**
  String errorSavingProject(String error);

  /// Playing preview status message
  ///
  /// In en, this message translates to:
  /// **'Playing preview...'**
  String get playingPreview;

  /// Preview stopped status message
  ///
  /// In en, this message translates to:
  /// **'Preview stopped'**
  String get previewStopped;

  /// View reset status message
  ///
  /// In en, this message translates to:
  /// **'View reset'**
  String get viewReset;

  /// New project dialog title
  ///
  /// In en, this message translates to:
  /// **'New Project'**
  String get newProject;

  /// Project name field label
  ///
  /// In en, this message translates to:
  /// **'Project Name'**
  String get projectName;

  /// Project name field hint
  ///
  /// In en, this message translates to:
  /// **'Enter project name'**
  String get enterProjectName;

  /// Project name validation message
  ///
  /// In en, this message translates to:
  /// **'Please enter a project name'**
  String get pleaseEnterProjectName;

  /// Description field label
  ///
  /// In en, this message translates to:
  /// **'Description (Optional)'**
  String get descriptionOptional;

  /// Description field hint
  ///
  /// In en, this message translates to:
  /// **'Enter project description'**
  String get enterProjectDescription;

  /// Tags field label
  ///
  /// In en, this message translates to:
  /// **'Tags (Optional)'**
  String get tagsOptional;

  /// Tags field hint
  ///
  /// In en, this message translates to:
  /// **'Enter tags separated by commas'**
  String get enterTagsSeparatedByCommas;

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Create button text
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// Project section title
  ///
  /// In en, this message translates to:
  /// **'Project'**
  String get project;

  /// Current project label
  ///
  /// In en, this message translates to:
  /// **'Current Project'**
  String get currentProject;

  /// Created date label
  ///
  /// In en, this message translates to:
  /// **'Created: {date}'**
  String created(String date);

  /// Modified date label
  ///
  /// In en, this message translates to:
  /// **'Modified: {date}'**
  String modified(String date);

  /// Import section title
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get import;

  /// Import .boranko menu item
  ///
  /// In en, this message translates to:
  /// **'Import .boranko'**
  String get importBoranko;

  /// Import .comics (deprecated) menu item
  ///
  /// In en, this message translates to:
  /// **'Import .comics (deprecated)'**
  String get importComics;

  /// Title for the comics deprecated dialog
  ///
  /// In en, this message translates to:
  /// **'Legacy Format'**
  String get comicsDeprecatedTitle;

  /// Content for the comics deprecated dialog
  ///
  /// In en, this message translates to:
  /// **'The .comics format is deprecated and will be removed in a future version. Please use the modern .boranko format for all new 2D projects.'**
  String get comicsDeprecatedContent;

  /// OK button text
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// Status message for importing a Boranko project
  ///
  /// In en, this message translates to:
  /// **'Importing Boranko project...'**
  String get importingBorankoProject;

  /// Error message for importing a Boranko project
  ///
  /// In en, this message translates to:
  /// **'Error importing Boranko project: {error}'**
  String errorImportingBorankoProject(String error);

  /// Baranko Comics import button
  ///
  /// In en, this message translates to:
  /// **'Baranko Comics'**
  String get barankoComics;

  /// Unreal Engine import button
  ///
  /// In en, this message translates to:
  /// **'Unreal Engine'**
  String get unrealEngine;

  /// Blender Model import button
  ///
  /// In en, this message translates to:
  /// **'Blender Model'**
  String get blenderModel;

  /// Audio section title
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get audio;

  /// anAntaSound Setup button
  ///
  /// In en, this message translates to:
  /// **'anAntaSound Setup'**
  String get anantaSoundSetup;

  /// 3D Positioning button
  ///
  /// In en, this message translates to:
  /// **'3D Positioning'**
  String get threeDPositioning;

  /// Load .daga File button
  ///
  /// In en, this message translates to:
  /// **'Load .daga File'**
  String get loadDagaFile;

  /// 3D Content section title
  ///
  /// In en, this message translates to:
  /// **'3D Content'**
  String get threeDContent;

  /// Load .zelim File button
  ///
  /// In en, this message translates to:
  /// **'Load .zelim File'**
  String get loadZelimFile;

  /// Dome Settings section title
  ///
  /// In en, this message translates to:
  /// **'Dome Settings'**
  String get domeSettings;

  /// Dome Configuration label
  ///
  /// In en, this message translates to:
  /// **'Dome Configuration'**
  String get domeConfiguration;

  /// Dome radius label
  ///
  /// In en, this message translates to:
  /// **'Radius: {radius}m'**
  String radius(String radius);

  /// Projection type label
  ///
  /// In en, this message translates to:
  /// **'Projection Type:'**
  String get projectionType;

  /// Spherical projection type
  ///
  /// In en, this message translates to:
  /// **'Spherical'**
  String get spherical;

  /// Fisheye projection type
  ///
  /// In en, this message translates to:
  /// **'Fisheye'**
  String get fisheye;

  /// Equirectangular projection type
  ///
  /// In en, this message translates to:
  /// **'Equirectangular'**
  String get equirectangular;

  /// Export section title
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// mbharata_client export button
  ///
  /// In en, this message translates to:
  /// **'mbharata_client'**
  String get mbharataClient;

  /// Dome Projection export button
  ///
  /// In en, this message translates to:
  /// **'Dome Projection'**
  String get domeProjection;

  /// Error message when no project is selected
  ///
  /// In en, this message translates to:
  /// **'Please create or open a project first'**
  String get pleaseCreateOrOpenProject;

  /// Importing Baranko comics status
  ///
  /// In en, this message translates to:
  /// **'Importing Baranko comics...'**
  String get importingBarankoComics;

  /// Importing Unreal Engine scene status
  ///
  /// In en, this message translates to:
  /// **'Importing Unreal Engine scene...'**
  String get importingUnrealEngineScene;

  /// Importing Blender model status
  ///
  /// In en, this message translates to:
  /// **'Importing Blender model...'**
  String get importingBlenderModel;

  /// Setting up anAntaSound status
  ///
  /// In en, this message translates to:
  /// **'Setting up anAntaSound...'**
  String get settingUpAnantaSound;

  /// Opening 3D Audio editor status
  ///
  /// In en, this message translates to:
  /// **'Opening 3D Audio editor...'**
  String get opening3dAudioEditor;

  /// Loading .daga file status
  ///
  /// In en, this message translates to:
  /// **'Loading .daga file...'**
  String get loadingDagaFile;

  /// Loading .zelim file status
  ///
  /// In en, this message translates to:
  /// **'Loading .zelim file...'**
  String get loadingZelimFile;

  /// Exporting to mbharata_client status
  ///
  /// In en, this message translates to:
  /// **'Exporting to mbharata_client...'**
  String get exportingToMbharata;

  /// Exporting dome projection status
  ///
  /// In en, this message translates to:
  /// **'Exporting dome projection...'**
  String get exportingDomeProjection;

  /// Language selection label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// English language option
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Russian language option
  ///
  /// In en, this message translates to:
  /// **'Русский'**
  String get russian;

  /// Thai language option
  ///
  /// In en, this message translates to:
  /// **'ไทย'**
  String get thai;

  /// Hindi language option
  ///
  /// In en, this message translates to:
  /// **'हिन्दी'**
  String get hindi;

  /// German language option
  ///
  /// In en, this message translates to:
  /// **'Deutsch'**
  String get german;

  /// Harkonnen language option
  ///
  /// In en, this message translates to:
  /// **'Харконнены'**
  String get harkonnen;

  /// Atreides language option
  ///
  /// In en, this message translates to:
  /// **'Атрейдесы'**
  String get atreides;

  /// Petrosyan language option
  ///
  /// In en, this message translates to:
  /// **'Петросян'**
  String get petrosyan;

  /// The title of the Home Screen
  ///
  /// In en, this message translates to:
  /// **'FreeDome Sphere'**
  String get homeScreenTitle;

  /// Tooltip for the GIF importer icon button
  ///
  /// In en, this message translates to:
  /// **'GIF Importer'**
  String get gifImporterTooltip;

  /// Tooltip for the JPG importer icon button
  ///
  /// In en, this message translates to:
  /// **'JPG Importer'**
  String get jpgImporterTooltip;

  /// Tooltip for the video importer icon button
  ///
  /// In en, this message translates to:
  /// **'Video Importer'**
  String get videoImporterTooltip;

  /// Tooltip for the tutorials icon button
  ///
  /// In en, this message translates to:
  /// **'Tutorials'**
  String get tutorialsTooltip;

  /// Tooltip for the Lyubomir Learning System icon button
  ///
  /// In en, this message translates to:
  /// **'Lyubomir Learning System'**
  String get lyubomirLearningSystemTooltip;

  /// Tooltip for the anAntaSound icon button
  ///
  /// In en, this message translates to:
  /// **'anAntaSound Quantum Resonance Device'**
  String get anantaSoundTooltip;

  /// Tooltip for the Unreal Engine Optimizer icon button
  ///
  /// In en, this message translates to:
  /// **'Unreal Engine Optimizer'**
  String get unrealOptimizerTooltip;

  /// Success message when a Boranko project is imported
  ///
  /// In en, this message translates to:
  /// **'Boranko project imported successfully'**
  String get borankoImportSuccess;

  /// The title of the anAntaSound screen
  ///
  /// In en, this message translates to:
  /// **'anAntaSound Quantum Resonance Device'**
  String get anantaSoundScreenTitle;

  /// Status for when the device is active
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// Status for when the device is inactive
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// Message shown while the device is initializing
  ///
  /// In en, this message translates to:
  /// **'Initializing Quantum Resonance Device...'**
  String get initializingQuantumResonanceDevice;

  /// Title for the MP3 management section
  ///
  /// In en, this message translates to:
  /// **'MP3 Management'**
  String get mp3Management;

  /// Button text to load an MP3 file
  ///
  /// In en, this message translates to:
  /// **'Load MP3'**
  String get loadMp3;

  /// Label to show the name of the loaded file
  ///
  /// In en, this message translates to:
  /// **'Loaded file: {fileName}'**
  String loadedFile(String fileName);

  /// Title for the participant management section
  ///
  /// In en, this message translates to:
  /// **'Participant Management'**
  String get participantManagement;

  /// Button text to add a participant
  ///
  /// In en, this message translates to:
  /// **'Add Participant'**
  String get addParticipant;

  /// Button text to remove a participant
  ///
  /// In en, this message translates to:
  /// **'Remove Participant'**
  String get removeParticipant;

  /// Label for the list of active participants
  ///
  /// In en, this message translates to:
  /// **'Active Participants:'**
  String get activeParticipants;

  /// Label for a single participant in a list
  ///
  /// In en, this message translates to:
  /// **'Participant {index}'**
  String participant(int index);

  /// Details of a participant, including weight and position
  ///
  /// In en, this message translates to:
  /// **'Weight: {weight} | Position: ({r}, {theta}, {phi})'**
  String participantDetails(String weight, String r, String theta, String phi);

  /// Title for the real-time data section
  ///
  /// In en, this message translates to:
  /// **'Real-time Data'**
  String get realTimeData;

  /// Label for the frequency data point
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get frequency;

  /// Label for the intensity data point
  ///
  /// In en, this message translates to:
  /// **'Intensity'**
  String get intensity;

  /// Label for the participants data point
  ///
  /// In en, this message translates to:
  /// **'Participants'**
  String get participants;

  /// Label for the MIDI data point
  ///
  /// In en, this message translates to:
  /// **'MIDI'**
  String get midi;

  /// Status for when a connection is active
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connected;

  /// Status for when a connection is inactive
  ///
  /// In en, this message translates to:
  /// **'Disconnected'**
  String get disconnected;

  /// Label for the OSC data point
  ///
  /// In en, this message translates to:
  /// **'OSC'**
  String get osc;

  /// Label for the consciousness data point
  ///
  /// In en, this message translates to:
  /// **'Consciousness'**
  String get consciousness;

  /// Status for when consciousness is linked
  ///
  /// In en, this message translates to:
  /// **'Linked'**
  String get linked;

  /// Status for when consciousness is not linked
  ///
  /// In en, this message translates to:
  /// **'Not Linked'**
  String get notLinked;

  /// Unit for frequency in Hertz
  ///
  /// In en, this message translates to:
  /// **'{value} Hz'**
  String hzUnit(String value);

  /// Unit for percentage
  ///
  /// In en, this message translates to:
  /// **'{value}%'**
  String percentageUnit(String value);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'de',
    'en',
    'hi',
    'kk',
    'pt',
    'ru',
    'th',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'kk':
      return AppLocalizationsKk();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'th':
      return AppLocalizationsTh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
