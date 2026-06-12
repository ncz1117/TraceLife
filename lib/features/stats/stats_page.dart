import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/stats_providers.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../../shared/extensions/context_extensions.dart';
import '../../core/theme/app_spacing.dart';

class StatsPage extends ConsumerStatefulWidget {
  const StatsPage({super.key});

  @override
  ConsumerState<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends ConsumerState<StatsPage> {
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final appColors = context.appColors;
    final trendAsync = ref.watch(moodTrendProvider);
    final monthAsync = ref.watch(monthStatsProvider(_selectedMonth));
    final streakAsync = ref.watch(streakProvider);

    return AppScaffold(
      title: '数据统计',
      showBack: true,
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          // 月份切换
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  setState(() {
                    _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
                  });
                },
              ),
              Expanded(
                child: Text(
                  '${_selectedMonth.year}年${_selectedMonth.month}月',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: _selectedMonth.month == DateTime.now().month &&
                        _selectedMonth.year == DateTime.now().year
                    ? null
                    : () {
                        setState(() {
                          _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
                        });
                      },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // 心情趋势
          Text('近 7 天心情',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: colorScheme.primary,
                  )),
          const SizedBox(height: AppSpacing.sm),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: SizedBox(
                height: 180,
                child: trendAsync.when(
                  data: (data) => _MoodLineChart(data: data),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('加载失败: $e')),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // 概览区（重做：1 大 + 3 小，打破 4 等分 SaaS 模板）
          Text('本月概览',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: colorScheme.primary,
                  )),
          const SizedBox(height: AppSpacing.sm),
          monthAsync.when(
            data: (stats) => Column(
              mainAxisSize: MainAxisSize.min, // ListView 无限高度 → 必须 min
              children: [
                // 1 大卡：核心指标 + 一句话洞察
                _HeadlineStatCard(
                  stats: stats,
                  color: colorScheme.primary,
                ),
                const SizedBox(height: AppSpacing.sm),
                // 3 小卡（不等宽，width 1.1 : 1 : 1.1 让中间窄一点打破节奏）
                // IntrinsicHeight 让 3 张卡按最高那张对齐
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 11,
                        child: _SmallStatCard(
                          label: '平均心情',
                          value: stats.avgMood != null
                              ? stats.avgMood!.toStringAsFixed(1)
                              : '—',
                          icon: Icons.mood_rounded,
                          color: appColors.moodHappy,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        flex: 10,
                        child: _SmallStatCard(
                          label: '总字数',
                          value: _formatCount(stats.totalWords),
                          icon: Icons.text_fields_rounded,
                          color: appColors.info,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                      flex: 11,
                      child: streakAsync.when(
                        data: (streak) => _SmallStatCard(
                          label: '连续天数',
                          value: '$streak',
                          icon: Icons.local_fire_department_rounded,
                          color: appColors.warning,
                        ),
                        loading: () => const _SmallStatCard(
                          label: '连续天数', value: '...',
                          icon: Icons.local_fire_department_rounded,
                          color: AppColorsPalette.warningLoading,
                        ),
                        error: (e, _) => _SmallStatCard(
                          label: '连续天数', value: '—',
                          icon: Icons.local_fire_department_rounded,
                          color: appColors.warning,
                        ),
                      ),
                    ),
                  ],
                  ),
                ),
              ],
            ),
            loading: () => const Center(child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            )),
            error: (e, _) => Text('加载失败: $e'),
          ),
          const SizedBox(height: AppSpacing.lg),

          // 热力图
          Text('日历热力图',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: colorScheme.primary,
                  )),
          const SizedBox(height: AppSpacing.sm),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: monthAsync.when(
                data: (stats) => _HeatmapGrid(
                  year: stats.year,
                  month: stats.month,
                  dailyCount: stats.dailyCount,
                ),
                loading: () => const SizedBox(
                    height: 200, child: Center(child: CircularProgressIndicator())),
                error: (e, _) => Text('加载失败: $e'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 简短数字格式（1000+ → 1.2k）
  String _formatCount(int n) {
    if (n >= 10000) return '${(n / 10000).toStringAsFixed(1)}w';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return '$n';
  }
}

/// 静态 const 给 const 构造器用（loading 状态需要 const）
class AppColorsPalette {
  static const warningLoading = Color(0xFFF59E0B);
}

/// 大卡：核心指标 + 一句话洞察
/// 打破 4 等分 SaaS 模板：1 张大卡 + 3 张小卡，大小不同，节奏不同
class _HeadlineStatCard extends StatelessWidget {
  final MonthStats stats;
  final Color color;

  const _HeadlineStatCard({required this.stats, required this.color});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final count = stats.diaryCount;

    // 一句话洞察：根据数据动态生成
    final insight = _insightFor(count);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 左侧：图标 + 大数字
            Icon(Icons.book_rounded, color: color, size: 32),
            const SizedBox(width: AppSpacing.md),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Semantics(
                  label: '本月已写日记 $count 篇',
                  child: Text(
                    '$count',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: color,
                          height: 1.0,
                        ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '本月日记',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
            const Spacer(),
            // 右侧：洞察文本（隐藏在数据为 0 时）
            if (count > 0)
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    insight,
                    textAlign: TextAlign.right,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _insightFor(int count) {
    if (count == 0) return '本月还没写\n动笔吧';
    if (count <= 3) return '刚刚开始\n继续坚持';
    if (count <= 7) return '一周一篇\n稳定节奏';
    if (count <= 15) return '高频记录\n本月达人';
    return '日记达人\n生活充实';
  }
}

/// 小卡：紧凑
class _SmallStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _SmallStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 6),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: color,
                    height: 1.1,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 11,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoodLineChart extends StatelessWidget {
  final List<DailyMood> data;

  const _MoodLineChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final spots = <FlSpot>[];
    for (int i = 0; i < data.length; i++) {
      final mood = data[i].mood;
      if (mood != null) {
        spots.add(FlSpot(i.toDouble(), mood));
      }
    }

    if (spots.isEmpty) {
      return Center(
        child: Text('近 7 天还没写日记',
            style: TextStyle(color: colorScheme.onSurfaceVariant)),
      );
    }

    return LineChart(
      LineChartData(
        minY: 0.5,
        maxY: 5.5,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (v) => FlLine(
            color: colorScheme.outlineVariant,
            strokeWidth: 0.5,
          ),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              reservedSize: 28,
              getTitlesWidget: (v, _) {
                if (v < 1 || v > 5 || v != v.roundToDouble()) return const SizedBox.shrink();
                return Text('${v.toInt()}',
                    style: TextStyle(
                      fontSize: 10,
                      color: colorScheme.onSurfaceVariant,
                    ));
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (v, _) {
                final i = v.toInt();
                if (i < 0 || i >= data.length) return const SizedBox.shrink();
                final d = data[i].date;
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text('${d.month}/${d.day}',
                      style: TextStyle(
                        fontSize: 10,
                        color: data[i].mood == null
                            ? colorScheme.outline
                            : colorScheme.onSurfaceVariant,
                      )),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.3,
            color: colorScheme.primary,
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, _, __, ___) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: colorScheme.primary,
                  strokeWidth: 2,
                  strokeColor: colorScheme.surface,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: colorScheme.primary.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeatmapGrid extends StatelessWidget {
  final int year;
  final int month;
  final Map<int, int> dailyCount;

  const _HeatmapGrid({
    required this.year,
    required this.month,
    required this.dailyCount,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final firstDay = DateTime(year, month, 1).weekday; // 1=Mon

    return Column(
      mainAxisSize: MainAxisSize.min, // 卡片内 Column → min 让 GridView shrinkWrap 起作用
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 周标签
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['一', '二', '三', '四', '五', '六', '日']
              .map((d) => SizedBox(
                    width: 32,
                    child: Center(
                      child: Text(d,
                          style: TextStyle(
                            fontSize: 11,
                            color: colorScheme.onSurfaceVariant,
                          )),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 4),
        // 日历格
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            childAspectRatio: 1,
          ),
          itemCount: daysInMonth + firstDay - 1,
          itemBuilder: (context, index) {
            if (index < firstDay - 1) {
              return const SizedBox.shrink();
            }
            final day = index - firstDay + 2;
            final count = dailyCount[day] ?? 0;
            final bg = _heatColor(count, colorScheme);
            final fg = _heatTextColor(count, colorScheme);
            return Container(
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(6),
              ),
              alignment: Alignment.center,
              child: Text(
                '$day',
                style: TextStyle(
                  fontSize: 11,
                  color: fg,
                  fontWeight: count > 0 ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        // 图例
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text('少',
                style: TextStyle(fontSize: 10, color: colorScheme.onSurfaceVariant)),
            const SizedBox(width: 4),
            ...[
              ('0', _heatColor(0, colorScheme)),
              ('1', _heatColor(1, colorScheme)),
              ('2', _heatColor(2, colorScheme)),
              ('3+', _heatColor(3, colorScheme)),
            ].map((entry) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1),
                  child: Container(
                    width: 16,
                    height: 14,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: entry.$2,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Text(
                      entry.$1,
                      style: TextStyle(
                        fontSize: 8,
                        color: _heatTextColor(int.parse(entry.$1.replaceAll('+', '')), colorScheme),
                      ),
                    ),
                  ),
                )),
            const SizedBox(width: 4),
            Text('多',
                style: TextStyle(fontSize: 10, color: colorScheme.onSurfaceVariant)),
          ],
        ),
      ],
    );
  }

  /// 档位配色：count → 颜色
  /// 0 = 灰（空），1 = 浅，2 = 中，3+ = 深
  static Color _heatColor(int count, ColorScheme scheme) {
    if (count == 0) return scheme.surfaceContainerHighest;
    if (count == 1) return scheme.primaryContainer;
    if (count == 2) return Color.lerp(scheme.primaryContainer, scheme.primary, 0.6)!;
    return scheme.primary;
  }

  /// 档位文字色：保证深色背景上文字可读
  static Color _heatTextColor(int count, ColorScheme scheme) {
    if (count == 0) return scheme.onSurfaceVariant;
    if (count >= 2) return scheme.onPrimary;
    return scheme.onPrimaryContainer;
  }
}
