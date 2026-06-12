# 迹录 TraceLife

> 一日一记，生活有迹可循

一个轻量级的个人生活轨迹记录工具，Flutter 练手项目。纯本地存储，无需联网，数据 100% 在你手里。

![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20Web%20%7C%20Windows-blue)
![Flutter](https://img.shields.io/badge/Flutter-3.32-02569B)
![Version](https://img.shields.io/badge/V3-UI%E9%87%8D%E5%A1%98-success)
![License](https://img.shields.io/badge/License-MIT-green)

## ✨ 核心特性

| 模块 | 功能 |
|------|------|
| 📝 **日记** | 写日记、选心情、多图上传、**全文搜索**、**热力图日历** |
| 🎂 **纪念日** | 正数日/生日双模式、**封面图**、**大数字倒计时（真实心率脉动）**、**本地推送** |
| 🏠 **Today 首页** | 实时时钟（秒级）、今日日记、纪念日横向卡片 |
| 🔍 **全文搜索** | FTS5 索引，标题+内容+月份聚合 |
| 📊 **数据统计** | 心情趋势 / 月报 / 热力图 / 概览 |
| 💾 **数据导出** | 一键 JSON 导出 / 导入恢复 |
| 🎨 **4 套主题** | 默（蓝紫）/ 暮（橙红）/ 雾（绿）/ 樱（粉），可切换可持久化 |
| 🌓 **明暗双模** | 浅色/深色/跟随系统 |
| 📱 **本地推送** | 纪念日前 N 天提醒、生日每年自动 |
| 🔄 **跨平台** | Android / Web / Windows 体验一致（Web 自动居中限宽）|
| ♿ **无障碍** | Semantics / 48px 触控 / reduced-motion 尊重 |

## 🖼️ 截图

> V3 重塑后：思源宋体大数字 + 4 套主题切换 + 真实心率脉动

## 🛠️ 技术栈

| 层 | 选型 |
|---|------|
| 框架 | Flutter 3.32 + Dart 3.8 |
| 状态管理 | Riverpod 2 |
| 数据库 | sqflite 2.4（Native SQLite / Web 内存） |
| 数据模型 | freezed + json_serializable |
| 路由 | GoRouter（ShellRoute + CustomTransitionPage 300ms） |
| 日历 | table_calendar |
| 搜索 | FTS5 全文索引 |
| 图片 | image_picker（Web base64 / Native 文件） |
| 推送 | flutter_local_notifications + timezone |
| 字体 | google_fonts（Noto Serif SC / Noto Sans SC） |
| 持久化 | shared_preferences（主题/明暗模式） |

## 🚀 快速开始

```bash
# 环境要求
- Flutter SDK 3.32+
- Android SDK 34+
- JDK 17+

# 安装依赖
flutter pub get

# 代码生成（freezed）
flutter pub run build_runner build --delete-conflicting-outputs

# 运行（Web）
flutter run -d chrome

# 构建 APK
flutter build apk --debug
```

## 📁 项目结构

```
lib/
├── core/                        # 基础设施
│   ├── database/                # DatabaseHelper（v1→v6 跨平台抽象）
│   ├── theme/                   # V3 设计令牌系统
│   │   ├── app_theme.dart       # 8 套 ThemeData 工厂（4 主题 × 2 明暗）
│   │   ├── theme_presets.dart   # 4 套主题预设元数据
│   │   ├── app_colors.dart      # 心情色 + scrim 等扩展色
│   │   ├── app_typography.dart  # 字体 token（9 档 scale + 3 档 weight）
│   │   ├── app_spacing.dart     # 12 档 spacing
│   │   ├── app_layout.dart      # 4 档断点 + contentMaxWidth + 6 档 radius
│   │   └── app_motion.dart      # 6 档时长 + Pulse widget + 路由过场
│   ├── router/                  # GoRouter（ShellRoute + CustomTransitionPage）
│   ├── l10n/                    # ARB 国际化
│   ├── providers/               # 全局 Provider
│   └── services/                # ImageService / NotificationService / ThemeController / Backup
├── features/                    # 功能模块
│   ├── today/                   # Today 首页
│   ├── diary/                   # 日记
│   ├── day_counter/             # 纪念日（含真实心率脉动 ViewPage）
│   ├── stats/                   # 数据统计（IntrinsicHeight 3 小卡）
│   ├── search/                  # 全文搜索
│   └── settings/                # 设置（含 4 主题选择器 + 明暗切换）
└── shared/                      # 共享组件
    ├── extensions/              # ContextExtension
    └── widgets/                 # AppScaffold / AppCard / AppEmptyState / ErrorBoundary
```

## 📊 数据存储

| 表 | 说明 |
|---|------|
| `diaries` | id, date, content, mood, images, created_at, updated_at |
| `day_counters` | id, title, target_date, counter_type, emoji, image, color_index, sort_order, created_at |
| `diaries_fts` | FTS5 全文索引（content / date） |

**数据库版本链**：v1 → v2 → v3 → v4 → v5 → v6（每次平滑迁移）

## 🎨 设计系统

V3 完整建立的 5 大 token 体系：

| 体系 | 数量 | 状态 |
|------|------|------|
| **Spacing** | 12 档 (xxs 2px → huge 64px) | ✅ |
| **Radius** | 6 档 (xs 4 → full 999) | ✅ |
| **Typography** | 9 档 scale + 3 档 weight + 5 档 lh | ✅ |
| **Motion** | 6 档时长 + Pulse 心率 widget + 路由过场 | ✅ |
| **Theme** | 4 套预设 × 2 明暗 = 8 套 ThemeData | ✅ |

详细见 [DESIGN.md](DESIGN.md)

## 📦 版本

| 版本 | 状态 | 主要内容 |
|------|------|----------|
| **V1.0** | ✅ 完成 | 日记 + 纪念日 + Today + 暗色 |
| **V2.0** | ✅ 完成 | 搜索/统计/导出/推送/图片/设置 |
| **V3.0** | ✅ **完成** | 5 大设计令牌 + 8 套主题 + 真实心率脉动 + 响应式 + 无障碍 + Impeccable 10 维度打磨 |
| V4.0 | 📋 计划 | 午夜翻页 / 真机测试 / 资产/订阅/打卡新功能 |

详细见 [RELEASE.md](RELEASE.md) 和 [docs/plans/](docs/plans/)

## 🏆 V3 关键指标

| 指标 | V2 基线 | V3 终 | Δ |
|------|---------|-------|---|
| Impeccable 评分 | 12/20 | **17.5/20** | **+5.5 (+46%)** |
| A11y | 2/4 | 3.5 | +1.5 |
| 性能 | 3/4 | 3 | — |
| 主题 | 2/4 | 4 | +2 |
| 响应式 | 2/4 | 3.5 | +1.5 |
| Anti-Pattern | 3/4 | 3.5 | +0.5 |

## 🤝 参与

个人练手项目，欢迎参考学习。

## 📄 License

MIT
