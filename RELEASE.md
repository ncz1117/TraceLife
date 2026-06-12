# TraceLife 版本总结

> 一日一记，生活有迹可循

---

## V3.0 — UI 重塑（已完成 ✅）

| 指标 | 数值 |
|------|------|
| 版本 | V3.0.0 |
| 提交 | ~20 commits |
| 评分 | 12/20 → **17.5/20**（+5.5, +46%）|
| 工期 | 1 天（密集 8 个命令）|
| 新增文件 | 2 个（`app_layout.dart`, `app_motion.dart`, `theme_presets.dart`, `theme_controller.dart`）|
| 净增行数 | ~1500+ |

### V3 的 8 个命令

| # | 命令 | 类型 | 评分 Δ | 关键产物 |
|---|------|------|--------|----------|
| 1 | `init` | 基线 | — | PRODUCT.md / DESIGN.md |
| 2 | `audit` | 诊断 | 12/20 | 12 项问题清单 |
| 3 | `colorize` (P1) | 修 | 13.5 | 17 处硬编码 → token；LinearGradient 改向；Stats 4 卡破模板 |
| 4 | `typeset` (P1) | 建 | 14.5 | 9 档 scale + 3 档 weight + 5 档 lh；思源宋 + Noto Sans |
| 5 | `polish` (P1) | 加 | 15.5 | AppMotion 框架 + Semantics + 48px 触控 + 表单错误态 + 错误页区分 |
| 6 | `layout` (P2) | 加 | 17 | 4 档断点 + contentMaxWidth + 6 档 radius + AppScaffold 响应式 |
| 7 | `animate` (P3) | 加 | 17 | 路由 fade+slide + 真实心率脉动 Pulse widget |
| 8 | `colorize` (P2) | 加 | **17.5** | 4 套主题预设（默/暮/雾/樱）+ ThemeController + 持久化 + 设置页 UI |

### V3 完整产物

#### 🎨 5 大设计令牌体系

| Token | 文件 | 内容 | 价值 |
|-------|------|------|------|
| **Spacing** | `app_spacing.dart` | 12 档 (xxs 2 → huge 64) | 解决"9 个 magic number 散落" |
| **Radius** | `app_layout.dart` | 6 档 (xs 4 → full 999) | max 12，避开 AI 痕 >16 圆角 |
| **Typography** | `app_typography.dart` | 9 档 scale + 3 档 weight + 5 档 lh | 解决"14 个 fontSize" |
| **Motion** | `app_motion.dart` | 6 档时长 + Pulse + 路由过场 | 100/300/500 规则 |
| **Theme** | `theme_presets.dart` + `app_theme.dart` | 4 预设 × 2 明暗 = 8 套 | 用户可选 + 持久化 |

#### 🎭 4 套主题预设

| 名字 | Seed | 情绪/时刻 | 适合 |
|------|------|---------|------|
| **默**（默认）| `#4F46E5` 蓝紫 | 沉静、克制 | 日常、晨间 |
| **暮** | `#EA580C` 橙红 | 温暖、回忆 | 黄昏、怀旧、纪念日 |
| **雾** | `#0F766E` 雾绿 | 静谧、冥想 | 日记、自我对话 |
| **樱** | `#DB2777` 粉红 | 浪漫、喜悦 | 纪念日、重要的人 |

不是 4 个差不多的颜色，**是 4 种不同的情感时刻**。

#### 🏗️ 架构升级

| 改动 | 价值 |
|------|------|
| `AppScaffold` 加 `LayoutBuilder` + `ConstrainedBox(maxWidth: contentMaxWidth)` | 5 个页面**自动**响应式（Web/桌面居中限宽）|
| `GoRouter` 5 个详情页用 `CustomTransitionPage` 300ms fade+slide | 入场有"深度"感 |
| `GoRouter` 4 个 Tab 路由用 `NoTransitionPage` | Tab 切换"秒切"不卡 |
| `ThemeController` (Notifier + SharedPreferences) | 主题/明暗模式**持久化** |

#### 💓 真实心率脉动

```dart
Pulse(
  heartbeat: true,           // 非对称 30/70 曲线
  maxScale: 1.03,            // 1.5px（避免亚像素抖动）
  period: Duration(ms: 1800), // 0.55Hz 接近静息心率
  child: Text('$days'),
)
```

**只在纪念日大数字本身跳动**，"天" 和 "今天/还剩 N 天" 状态标签**保持静止**。自动尊重 `prefers-reduced-motion`。

### V3 用户报告的 bug 与修复

| # | Bug | 原因 | 修复 |
|---|-----|------|------|
| 1 | stats 页无限滚动 | ListView 内 `Column` 漏 `mainAxisSize.min` | 加 min + `IntrinsicHeight` 包 `Row(stretch)` |
| 2 | 日记页日历双月份头 | `TableCalendar` 自带 header 未关 | `headerVisible: false` |
| 3 | 日历周几被截 | `daysOfWeekHeight: 16` 默认值装不下中文 | 改 24 + `daysOfWeekStyle` |
| 4 | 心跳不自然有卡顿 | 对称 easeInOut + 1.02 幅度 | 非对称 30/70 真实心率曲线 + 1.03 |

### V3 走的弯路（复盘）

| 错误 | 代价 | 教训 |
|------|------|------|
| **stats 无限滚动修 2 次** | 1 轮 | Column(min) 修了但忘了 Row(stretch) 也要修。**ListView 内 CrossAxisAlignment.stretch 必须配 IntrinsicHeight** |
| **心跳用了对称曲线** | 1 轮 | 我**自己**坚持"对称+1.02+2.4s 是 ambient"，用户亲自打开看指出问题。**动效是体验问题不是理论问题** |
| **patch 把 dart:io / dart:convert 删了** | 1 轮 | 用 `new_string` 重新构造 imports 时漏了 |
| **write_file 长内容被截** | 1 轮 | 长 content 要分块或用 patch |

### V3 评分细节

| 维度 | V2 | V3 终 | Δ | 关键变化 |
|------|-----|-------|---|---------|
| **A11y** | 2 | **3.5** | +1.5 | Semantics × 3 处 + 48px 触控 + 表单 errorText + 错误页区分 |
| **性能** | 3 | 3 | — | 无 regression，V3 未做 perf profile |
| **主题** | 2 | **4** | +2 | 4 套预设可切换可持久化 + AppColors extension |
| **响应式** | 2 | **3.5** | +1.5 | 4 档断点 + contentMaxWidth 自适应 |
| **Anti-Pattern** | 3 | 3.5 | +0.5 | Stats 4 卡破模板 + IntrinsicHeight 避免拉伸 |
| **总分** | 12 | **17.5** | **+5.5** | Excellent 偏 Good |

### V3 已知遗留 → V4

| # | 遗留 | V4 计划 |
|---|------|---------|
| 1 | 午夜翻页（你提的）| 数字在午夜跳变 > 心跳脉动 |
| 2 | 真机测试 | 暴露 Web 模拟器看不见的问题 |
| 3 | 主动 bug hunt | 走完所有用户路径 |
| 4 | 资产/订阅/打卡 | 最初想法还差 3 大模块 |
| 5 | 数据导入测试 | 现在只测了导出 |
| 6 | 用户测试 | 目标用户（怀旧向年轻人）未测过 |

---

## V2.0 — 功能补齐（已完成 ✅）

| 指标 | 数值 |
|------|------|
| 版本 | V2.0.0 |
| 提交 | 18 commits（V1 基础上） |
| 源码 | 48 个 Dart 文件 / ~5,615 行（+17 文件 / +3,574 行） |
| 工期 | ~1 天 |
| 数据库 | v1 → v6（5 次迁移） |
| 依赖新增 | 6 个（image_picker, flutter_local_notifications, timezone, flutter_timezone, permission_handler, shared_preferences, google_fonts） |

### V2 完成的 7 个 Phase

| Phase | 内容 | 关键能力 | 提交 |
|-------|------|----------|------|
| **1** | 数据导出/导入 | JSON 全量 + Web 下载 / Native 写入 | `983c461` |
| **2** | 全文搜索 | FTS5 索引 + 搜索页 + 高亮 + 关键词聚合 | `d9a8311` |
| **3** | 本地推送 | 提前 1/3/7 天 + 每日定时 + 生日每年重复 | `12dfd10` |
| **4** | 数据统计 | 心情趋势 + 月报 + 热力图 + 连续天数 | `2065bdd` |
| **5** | 主题色 | ⏭️ **跳过**（V3 重做） | — |
| **6** | 图片支持 | 日记多图 + 纪念日封面图 | `56aa211` |
| **7** | 设置页扩展 | 概览卡 + 搜索/统计入口 | `9ae0007` |
| **+** | ViewPage 设计 | 衬线体大数字 + 起始日/目标日 + 3 段布局 | `aaee5d9` |

### V2 新增功能清单

| 模块 | 功能 | 状态 |
|------|------|------|
| 📝 **日记** | 多图（最多 9 张，每张 ≤2MB） | ✅ |
| 🔍 **搜索** | FTS5 全文索引（标题+内容+月份聚合） | ✅ |
| 📊 **统计** | 心情趋势 / 月报 / 热力图 / 连续天数 / 数据概览 | ✅ |
| 🔔 **推送** | 纪念日前 N 天提醒 / 生日每年自动 | ✅ |
| 🖼️ **纪念日** | 封面图 + ViewPage 设计升级 | ✅ |
| 💾 **数据** | 一键导出 JSON / 导入恢复 | ✅ |
| ⚙️ **设置** | 概览卡 + 4 个分区（功能/通知/数据/关于） | ✅ |

### V2 跨平台方案

| 平台 | 数据库 | 图片存储 | 推送 |
|------|--------|----------|------|
| 🌐 **Web** | 内存（无 UNIQUE） | base64 存 DB | 提示"仅手机端" |
| 📱 **Android** | sqflite | 文件存 `app docs/images/` | 完整支持 |
| 🪟 **Windows** | sqflite | 文件存 app docs | 提示"仅手机端" |

### V2 数据库迁移链

```
v1 (2026-07-11) → v2 (counter_type) → v3 (移除 UNIQUE 一天多篇)
                                          ↓
                              v4 (FTS5 索引) → v5 (日记 images) → v6 (纪念日 image)
```

### V2 关键修复

| # | 修复 | 提交 |
|---|------|------|
| 1 | Web 平台 `dart:io` 不兼容 → 导出用文本分享 | `07ebe88` |
| 2 | 编辑退出循环 → `onWillPop` 回调 + `confirmedExit` 标志 | `4d02af4` / `3c1ac78` |
| 3 | 日历缓存未失效 → 同时 invalidate `stats` + `search` | `3bfa7ea` |
| 4 | 热力图单值爆表 → 改档位配色（0/1/2/3+） | `938c86e` |
| 5 | image_picker 缺 web 实现 → `flutter clean` 重建 | （运行时修复） |

---

## V1.0 — 基础功能（已完成 ✅）

| 指标 | 数值 |
|------|------|
| 源码 | 31 个 Dart 文件 / ~2,041 行 |
| 文档 | 5 篇 / ~1,674 行 |
| 提交 | 21 commits |
| 构建 | Debug APK 88MB / Web PWA |

### V1 功能清单

| 模块 | 功能 | 状态 |
|------|------|------|
| 📝 **日记** | 写日记（心情 + 文字）、日历视图、一天多篇、编辑删除 | ✅ |
| 🎂 **纪念日** | 正数日/生日双模式、已过天数/剩余天数、编辑删除 | ✅ |
| 🏠 **Today 首页** | 实时时钟（秒级）、今日问候、日记预览、纪念日卡片 | ✅ |
| 🌙 **暗色模式** | Material 3 ThemeMode.system 自动跟随 | ✅ |
| 🔄 **跨平台** | Android SQLite / Web 内存数据库 | ✅ |
| 🇨🇳 **国际化** | 中文 l10n ARB（32 条） | ✅ |

### V1 技术栈

```
Flutter 3.32 + Dart 3.8  |  Riverpod 2  |  sqflite  |  freezed
GoRouter                  |  SQLite      |  MD3      |  table_calendar
```

### V1 架构

```
lib/
├── core/              # 基础设施
│   ├── database/      # DatabaseHelper（跨平台抽象层）
│   ├── theme/         # AppSpacing / AppColors / AppTheme
│   ├── router/        # GoRouter + ShellRoute
│   ├── l10n/          # ARB 国际化
│   └── utils/         # AppDateUtils
├── features/
│   ├── today/         # Today 首页
│   ├── diary/         # 日记
│   └── day_counter/   # 正数日
└── shared/            # 共享组件
```

### V1 数据库

| 表 | 字段 |
|---|------|
| `diaries` | id, date, content, mood, created_at, updated_at |
| `day_counters` | id, title, target_date, counter_type, emoji, color_index, sort_order, created_at |

---

*最后更新: 2026-07-12 | 构建者: ncz1117*
*V1 → V2 → V3 全部完成 ✅ → V4 计划已就绪（午夜翻页 / 真机测试 / 新功能）*
