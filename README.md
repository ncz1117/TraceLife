# 迹录 TraceLife

> 一日一记，生活有迹可循

一个轻量级的个人生活轨迹记录工具，Flutter 练手项目。纯本地存储，无需联网，数据 100% 在你手里。

![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20Web%20%7C%20Windows-blue)
![Flutter](https://img.shields.io/badge/Flutter-3.32-02569B)
![License](https://img.shields.io/badge/License-MIT-green)

## ✨ 核心特性

| 模块 | 功能 |
|------|------|
| 📝 **日记** | 写日记、选心情、多图上传、**全文搜索**、**热力图日历** |
| 🎂 **纪念日** | 正数日/生日双模式、**封面图**、**大数字倒计时**、**本地推送** |
| 🏠 **Today 首页** | 实时时钟（秒级）、今日日记、纪念日横向卡片 |
| 🔍 **全文搜索** | FTS5 索引，标题+内容+月份聚合 |
| 📊 **数据统计** | 心情趋势 / 月报 / 连续天数 / 概览 |
| 💾 **数据导出** | 一键 JSON 导出 / 导入恢复 |
| 🌙 **暗色模式** | Material 3 自动跟随系统 |
| 📱 **本地推送** | 纪念日前 N 天提醒、生日每年自动 |
| 🔄 **跨平台** | Android / Web / Windows 体验一致 |

## 🖼️ 截图

> V3 计划中添加插画系统

## 🛠️ 技术栈

| 层 | 选型 |
|---|------|
| 框架 | Flutter 3.32 + Dart 3.8 |
| 状态管理 | Riverpod 2 |
| 数据库 | sqflite 2.4（Native SQLite / Web 内存） |
| 数据模型 | freezed + json_serializable |
| 路由 | GoRouter |
| 日历 | table_calendar |
| 搜索 | FTS5 全文索引 |
| 图片 | image_picker（Web base64 / Native 文件） |
| 推送 | flutter_local_notifications + timezone |
| 字体 | google_fonts（衬线/无衬线混排） |

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
├── core/                     # 基础设施
│   ├── database/             # DatabaseHelper（v1→v6 跨平台抽象）
│   ├── theme/                # AppSpacing / AppColors / AppTheme
│   ├── router/               # GoRouter + ShellRoute
│   ├── l10n/                 # ARB 国际化
│   ├── providers/            # 全局 Provider（通知等）
│   └── services/             # ImageService / NotificationService / Backup
├── features/                 # 功能模块（每个含 model/repository/providers/widgets）
│   ├── today/                # Today 首页
│   ├── diary/                # 日记
│   ├── day_counter/          # 纪念日
│   ├── stats/                # 数据统计
│   ├── search/               # 全文搜索
│   └── settings/             # 设置
└── shared/                   # 共享组件
    ├── extensions/           # ContextExtension
    └── widgets/              # AppScaffold / AppCard / AppEmptyState / ...
```

## 📊 数据存储

| 表 | 说明 |
|---|------|
| `diaries` | id, date, content, mood, images, created_at, updated_at |
| `day_counters` | id, title, target_date, counter_type, emoji, image, color_index, sort_order, created_at |
| `diaries_fts` | FTS5 全文索引（content / date） |

**数据库版本链**：v1 → v2 → v3 → v4 → v5 → v6（每次平滑迁移）

## 📦 版本

| 版本 | 状态 | 主要内容 |
|------|------|----------|
| **V1.0** | ✅ 完成 | 日记 + 纪念日 + Today + 暗色 |
| **V2.0** | ✅ 完成 | 搜索/统计/导出/推送/图片/设置 |
| **V3.0** | 📋 计划 | UI 重塑（设计令牌+4 主题+组件库+插画+动效） |

详细见 [RELEASE.md](RELEASE.md) 和 [docs/plans/](docs/plans/)

## 🤝 参与

个人练手项目，欢迎参考学习。

## 📄 License

MIT
