// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Thai (`th`).
class AppLocalizationsTh extends AppLocalizations {
  AppLocalizationsTh([String locale = 'th']) : super(locale);

  @override
  String get appTitle => 'Freedome Sphere';

  @override
  String get newButton => 'ใหม่';

  @override
  String get open => 'เปิด';

  @override
  String get save => 'บันทึก';

  @override
  String get play => 'เล่น';

  @override
  String get stop => 'หยุด';

  @override
  String get reset => 'รีเซ็ต';

  @override
  String get ready => 'พร้อม';

  @override
  String get loadingProject => 'กำลังโหลดโปรเจค...';

  @override
  String get projectLoaded => 'โหลดโปรเจคแล้ว';

  @override
  String get noProject => 'ไม่มีโปรเจค';

  @override
  String errorLoadingProject(String error) {
    return 'เกิดข้อผิดพลาดในการโหลดโปรเจค: $error';
  }

  @override
  String get creatingNewProject => 'กำลังสร้างโปรเจคใหม่...';

  @override
  String get newProjectCreated => 'สร้างโปรเจคใหม่แล้ว';

  @override
  String errorCreatingProject(String error) {
    return 'เกิดข้อผิดพลาดในการสร้างโปรเจค: $error';
  }

  @override
  String get openingProject => 'กำลังเปิดโปรเจค...';

  @override
  String get savingProject => 'กำลังบันทึกโปรเจค...';

  @override
  String get projectSaved => 'บันทึกโปรเจคแล้ว';

  @override
  String get saveFailed => 'บันทึกไม่สำเร็จ';

  @override
  String errorSavingProject(String error) {
    return 'เกิดข้อผิดพลาดในการบันทึกโปรเจค: $error';
  }

  @override
  String get playingPreview => 'กำลังเล่นตัวอย่าง...';

  @override
  String get previewStopped => 'หยุดตัวอย่างแล้ว';

  @override
  String get viewReset => 'รีเซ็ตมุมมองแล้ว';

  @override
  String get newProject => 'โปรเจคใหม่';

  @override
  String get projectName => 'ชื่อโปรเจค';

  @override
  String get enterProjectName => 'ใส่ชื่อโปรเจค';

  @override
  String get pleaseEnterProjectName => 'กรุณาใส่ชื่อโปรเจค';

  @override
  String get descriptionOptional => 'คำอธิบาย (ไม่บังคับ)';

  @override
  String get enterProjectDescription => 'ใส่คำอธิบายโปรเจค';

  @override
  String get tagsOptional => 'แท็ก (ไม่บังคับ)';

  @override
  String get enterTagsSeparatedByCommas => 'ใส่แท็กแยกด้วยจุลภาค';

  @override
  String get cancel => 'ยกเลิก';

  @override
  String get create => 'สร้าง';

  @override
  String get project => 'โปรเจค';

  @override
  String get currentProject => 'โปรเจคปัจจุบัน';

  @override
  String created(String date) {
    return 'สร้างเมื่อ: $date';
  }

  @override
  String modified(String date) {
    return 'แก้ไขเมื่อ: $date';
  }

  @override
  String get import => 'นำเข้า';

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
  String get barankoComics => 'การ์ตูน Baranko';

  @override
  String get unrealEngine => 'Unreal Engine';

  @override
  String get blenderModel => 'โมเดล Blender';

  @override
  String get audio => 'เสียง';

  @override
  String get anantaSoundSetup => 'การตั้งค่า anAntaSound';

  @override
  String get threeDPositioning => 'การจัดตำแหน่ง 3D';

  @override
  String get loadDagaFile => 'โหลดไฟล์ .daga';

  @override
  String get threeDContent => 'เนื้อหา 3D';

  @override
  String get loadZelimFile => 'โหลดไฟล์ .zelim';

  @override
  String get domeSettings => 'การตั้งค่ากระจก';

  @override
  String get domeConfiguration => 'การกำหนดค่ากระจก';

  @override
  String radius(String radius) {
    return 'รัศมี: $radiusม.';
  }

  @override
  String get projectionType => 'ประเภทการฉาย:';

  @override
  String get spherical => 'ทรงกลม';

  @override
  String get fisheye => 'ตาปลา';

  @override
  String get equirectangular => 'Equirectangular';

  @override
  String get export => 'ส่งออก';

  @override
  String get mbharataClient => 'mbharata_client';

  @override
  String get domeProjection => 'การฉายกระจก';

  @override
  String get pleaseCreateOrOpenProject => 'กรุณาสร้างหรือเปิดโปรเจคก่อน';

  @override
  String get importingBarankoComics => 'กำลังนำเข้าการ์ตูน Baranko...';

  @override
  String get importingUnrealEngineScene => 'กำลังนำเข้าฉาก Unreal Engine...';

  @override
  String get importingBlenderModel => 'กำลังนำเข้าโมเดล Blender...';

  @override
  String get settingUpAnantaSound => 'กำลังตั้งค่า anAntaSound...';

  @override
  String get opening3dAudioEditor => 'กำลังเปิดโปรแกรมแก้ไขเสียง 3D...';

  @override
  String get loadingDagaFile => 'กำลังโหลดไฟล์ .daga...';

  @override
  String get loadingZelimFile => 'กำลังโหลดไฟล์ .zelim...';

  @override
  String get exportingToMbharata => 'กำลังส่งออกไปยัง mbharata_client...';

  @override
  String get exportingDomeProjection => 'กำลังส่งออกการฉายกระจก...';

  @override
  String get language => 'ภาษา';

  @override
  String get english => 'English';

  @override
  String get russian => 'Русский';

  @override
  String get thai => 'ไทย';

  @override
  String get hindi => 'हिन्दी';
}
