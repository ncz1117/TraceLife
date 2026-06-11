// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'TraceLife';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get confirmDelete => 'Are you sure you want to delete?';

  @override
  String confirmDeleteItem(String name) {
    return 'Are you sure you want to delete \"$name\"?';
  }

  @override
  String get diary => 'Diary';

  @override
  String get writeDiary => 'Write Diary';

  @override
  String get todayDiary => 'Today\'s Diary';

  @override
  String get emptyDiary => 'Record Today';

  @override
  String get noDiaryToday => 'No diary today';

  @override
  String get diarySaved => 'Diary saved';

  @override
  String get diaryDeleted => 'Diary deleted';

  @override
  String get dayCounter => 'Days Count';

  @override
  String get addDayCounter => 'Add Countdown';

  @override
  String get editDayCounter => 'Edit Countdown';

  @override
  String get dayCounterTitle => 'Title';

  @override
  String get dayCounterDate => 'Date';

  @override
  String get dayCounterEmoji => 'Emoji';

  @override
  String daysPassed(int days) {
    return '$days days passed';
  }

  @override
  String daysRemaining(int days) {
    return '$days days remaining';
  }

  @override
  String get today => 'Today';

  @override
  String get settings => 'Settings';

  @override
  String get emptyDayCounter => 'No countdowns yet';

  @override
  String get addOneNow => 'Add one now';

  @override
  String get saveSuccess => 'Saved successfully';

  @override
  String get deleteSuccess => 'Deleted successfully';

  @override
  String get confirm => 'Confirm';

  @override
  String get selectDate => 'Select Date';

  @override
  String get pickEmoji => 'Pick an Emoji';

  @override
  String get eventName => 'Event Name';

  @override
  String get eventNameHint => 'e.g. First met';
}
