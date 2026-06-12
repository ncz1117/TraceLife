import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/stats_providers.dart';
import '../../shared/widgets/app_scaffold.dart';
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

          // 概览卡片
          Text('本月概览',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: colorScheme.primary,
                  )),
          const SizedBox(height: AppSpacing.sm),
          monthAsync.when(
            data: (stats) => Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _StatCard(
                      label: '日记篇数',
                      value: '${stats.diaryCount}',
                      icon: Icons.book_rounded,
                      color: colorScheme.primary,
                    )),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(child: _StatCard(
                      label: '平均心情',
                      value: stats.avgMood != null
                          ? stats.avgMood!.toStringAsFixed(1)
                          : '—',
                      icon: Icons.mood_rounded,
                      color: const Color(0xFFFFB74D),
                    )),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(child: _StatCard(
                      label: '总字数',
                      value: '${stats.totalWords}',
                      icon: Icons.text_fields_rounded,
                      color: const Color(0xFF66BB6A),
                    )),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(child: streakAsync.when(
                      data: (streak) => _StatCard(
                        label: '连续天数',
                        value: '$streak',
                        icon: Icons.local_fire_department_rounded,
                        color: const Color(0xFFEF5350),
                      ),
                      loading: () => const _StatCard(
                        label: '连续天数', value: '...', icon: Icons.local_fire_department_rounded, color: Color(0xFFEF5350),
                      ),
                      error: (e, _) => _StatCard(
                        label: '连续天数', value: '—', icon: Icons.local_fire_department_rounded, color: Color(0xFFEF5350),
                      ),
                    )),
                  ],
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
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        )),
              ],
            ),
            const SizedBox(height: 8),
            Text(value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: color,
                    )),
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
    final maxCount = dailyCount.values.isEmpty
        ? 1
        : dailyCount.values.reduce((a, b) => a > b ? a : b);

    return Column(
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
            final intensity = maxCount == 0 ? 0.0 : count / maxCount;
            final bg = count == 0
                ? colorScheme.surfaceContainerHighest
                : Color.lerp(
                    colorScheme.primaryContainer,
                    colorScheme.primary,
                    intensity,
                  )!;
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
                  color: count == 0
                      ? colorScheme.onSurfaceVariant
                      : intensity > 0.5
                          ? colorScheme.onPrimary
                          : colorScheme.onPrimaryContainer,
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
            ...[0.2, 0.4, 0.6, 0.8, 1.0].map((v) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1),
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: v == 0
                          ? colorScheme.surfaceContainerHighest
                          : Color.lerp(colorScheme.primaryContainer, colorScheme.primary, v),
                      borderRadius: BorderRadius.circular(2),
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
}
