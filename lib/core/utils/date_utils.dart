class AppDateUtils {
  const AppDateUtils._();

  static String todayStr() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  static String formatDisplay(String dateStr) {
    final parts = dateStr.split('-');
    if (parts.length != 3) return dateStr;
    return '${parts[0]}年${int.parse(parts[1])}月${int.parse(parts[2])}日';
  }

  static String formatWeekday(DateTime date) {
    const weekdays = ['一', '二', '三', '四', '五', '六', '日'];
    return '星期${weekdays[date.weekday - 1]}';
  }
}
