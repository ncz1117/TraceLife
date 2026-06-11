import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

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
    Locale('en'),
    Locale('zh'),
  ];

  /// No description provided for @appName.
  ///
  /// In zh, this message translates to:
  /// **'迹录'**
  String get appName;

  /// No description provided for @save.
  ///
  /// In zh, this message translates to:
  /// **'保存'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get delete;

  /// No description provided for @confirmDelete.
  ///
  /// In zh, this message translates to:
  /// **'确定要删除吗？'**
  String get confirmDelete;

  /// No description provided for @confirmDeleteItem.
  ///
  /// In zh, this message translates to:
  /// **'确定要删除「{name}」吗？'**
  String confirmDeleteItem(String name);

  /// No description provided for @diary.
  ///
  /// In zh, this message translates to:
  /// **'日记'**
  String get diary;

  /// No description provided for @writeDiary.
  ///
  /// In zh, this message translates to:
  /// **'写日记'**
  String get writeDiary;

  /// No description provided for @todayDiary.
  ///
  /// In zh, this message translates to:
  /// **'今日日记'**
  String get todayDiary;

  /// No description provided for @emptyDiary.
  ///
  /// In zh, this message translates to:
  /// **'记录今天'**
  String get emptyDiary;

  /// No description provided for @noDiaryToday.
  ///
  /// In zh, this message translates to:
  /// **'今天还没有日记'**
  String get noDiaryToday;

  /// No description provided for @diarySaved.
  ///
  /// In zh, this message translates to:
  /// **'日记已保存'**
  String get diarySaved;

  /// No description provided for @diaryDeleted.
  ///
  /// In zh, this message translates to:
  /// **'日记已删除'**
  String get diaryDeleted;

  /// No description provided for @dayCounter.
  ///
  /// In zh, this message translates to:
  /// **'纪念日'**
  String get dayCounter;

  /// No description provided for @addDayCounter.
  ///
  /// In zh, this message translates to:
  /// **'添加纪念日'**
  String get addDayCounter;

  /// No description provided for @editDayCounter.
  ///
  /// In zh, this message translates to:
  /// **'编辑纪念日'**
  String get editDayCounter;

  /// No description provided for @dayCounterTitle.
  ///
  /// In zh, this message translates to:
  /// **'标题'**
  String get dayCounterTitle;

  /// No description provided for @dayCounterDate.
  ///
  /// In zh, this message translates to:
  /// **'日期'**
  String get dayCounterDate;

  /// No description provided for @dayCounterEmoji.
  ///
  /// In zh, this message translates to:
  /// **'表情'**
  String get dayCounterEmoji;

  /// No description provided for @daysPassed.
  ///
  /// In zh, this message translates to:
  /// **'已过 {days} 天'**
  String daysPassed(int days);

  /// No description provided for @daysRemaining.
  ///
  /// In zh, this message translates to:
  /// **'剩余 {days} 天'**
  String daysRemaining(int days);

  /// No description provided for @today.
  ///
  /// In zh, this message translates to:
  /// **'今天'**
  String get today;

  /// No description provided for @settings.
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get settings;

  /// No description provided for @emptyDayCounter.
  ///
  /// In zh, this message translates to:
  /// **'还没有纪念日'**
  String get emptyDayCounter;

  /// No description provided for @addOneNow.
  ///
  /// In zh, this message translates to:
  /// **'添加一个吧'**
  String get addOneNow;

  /// No description provided for @saveSuccess.
  ///
  /// In zh, this message translates to:
  /// **'保存成功'**
  String get saveSuccess;

  /// No description provided for @deleteSuccess.
  ///
  /// In zh, this message translates to:
  /// **'删除成功'**
  String get deleteSuccess;

  /// No description provided for @confirm.
  ///
  /// In zh, this message translates to:
  /// **'确认'**
  String get confirm;

  /// No description provided for @selectDate.
  ///
  /// In zh, this message translates to:
  /// **'选择日期'**
  String get selectDate;

  /// No description provided for @pickEmoji.
  ///
  /// In zh, this message translates to:
  /// **'选个表情'**
  String get pickEmoji;

  /// No description provided for @eventName.
  ///
  /// In zh, this message translates to:
  /// **'事件名称'**
  String get eventName;

  /// No description provided for @eventNameHint.
  ///
  /// In zh, this message translates to:
  /// **'例如：认识你'**
  String get eventNameHint;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
