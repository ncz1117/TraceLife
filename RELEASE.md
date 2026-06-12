# TraceLife 版本总结

> 一日一记，生活有迹可循

---

## V1.0 — 基础功能（已完成）

| 指标 | 数值 |
|------|------|
| 版本 | V1.0.0 |
| 提交 | 21 commits |
| 源码 | 31 个 Dart 文件 / ~2,041 行 |

**核心模块**：📝 日记（心情+文字+日历） / 🎂 纪念日（正数日+生日） / 🏠 Today 首页 / 🌙 暗色模式 / 🔄 跨平台

**已知限制**：无数据导出、无搜索、无推送、无统计、无测试

详见下方 V1 章节。

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

### V2 已知遗留

| # | 问题 | V3 解决 |
|---|------|---------|
| 1 | 品牌感弱 / Material 默认配色 | Phase 1（4 套主题） |
| 2 | 卡片扁平 / 阴影单薄 | Phase 2（AppCard 重做） |
| 3 | 缺动效 | Phase 5（系统化动效） |
| 4 | 字体单调（Roboto 一种） | google_fonts 衬线混排（部分已做） |
| 5 | 空状态简陋 | Phase 4（插画 + 呼吸动效） |
| 6 | ViewPage 卡片化（C 范围） | V3 P1.5（推迟） |

---

## V3 — UI 重塑（计划中）

详见 [docs/plans/V3-实施计划-UI重塑.md](docs/plans/V3-实施计划-UI重塑.md)

| 指标 | 计划 |
|------|------|
| 工时 | ~6.5 天（8 个 Phase） |
| 核心 | 设计令牌 + 4 套主题 + 组件库 + 页面重设 + 插画 + 动效 + 暗色 + 跨平台测试 |
| 新增依赖 | `flutter_svg` |

**V3 优先级**：P1 设计令牌 → P1.5 ViewPage C 范围 → P2 组件库 → P3 页面重设 → P4 插画 → P5 动效 → P6 暗色 → P7 跨平台测试

---

## V1 详细（参考）

<details>
<summary>点击展开 V1.0 内容</summary>

### V1.0 — 基础功能

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

</details>

---

*最后更新: 2026-07-12 | 构建者: ncz1117*
*V2 完工 ✅ → V3 计划已就绪*