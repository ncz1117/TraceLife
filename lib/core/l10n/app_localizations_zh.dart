// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => '迹录';

  @override
  String get save => '保存';

  @override
  String get cancel => '取消';

  @override
  String get delete => '删除';

  @override
  String get confirmDelete => '确定要删除吗？';

  @override
  String confirmDeleteItem(String name) {
    return '确定要删除「$name」吗？';
  }

  @override
  String get diary => '日记';

  @override
  String get writeDiary => '写日记';

  @override
  String get todayDiary => '今日日记';

  @override
  String get emptyDiary => '记录今天';

  @override
  String get noDiaryToday => '今天还没有日记';

  @override
  String get diarySaved => '日记已保存';

  @override
  String get diaryDeleted => '日记已删除';

  @override
  String get dayCounter => '纪念日';

  @override
  String get addDayCounter => '添加纪念日';

  @override
  String get editDayCounter => '编辑纪念日';

  @override
  String get dayCounterTitle => '标题';

  @override
  String get dayCounterDate => '日期';

  @override
  String get dayCounterEmoji => '表情';

  @override
  String daysPassed(int days) {
    return '已过 $days 天';
  }

  @override
  String daysRemaining(int days) {
    return '剩余 $days 天';
  }

  @override
  String get today => '今天';

  @override
  String get settings => '设置';

  @override
  String get emptyDayCounter => '还没有纪念日';

  @override
  String get addOneNow => '添加一个吧';

  @override
  String get saveSuccess => '保存成功';

  @override
  String get deleteSuccess => '删除成功';

  @override
  String get confirm => '确认';

  @override
  String get selectDate => '选择日期';

  @override
  String get pickEmoji => '选个表情';

  @override
  String get eventName => '事件名称';

  @override
  String get eventNameHint => '例如：认识你';
}
