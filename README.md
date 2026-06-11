# 迹录 TraceLife

> 一日一记，生活有迹可循

一个轻量级的个人生活轨迹记录工具，Flutter 练手项目。纯本地存储，无需联网，数据 100% 在你手里。

## 功能

| 模块 | 说明 |
|------|------|
| 📝 **日记** | 写日记、选心情、日历查看、编辑删除 |
| ⏰ **实时时钟** | 首页显示精确到秒的时钟 |
| 🎯 **正数日** | 记录纪念日，自动计算已过/剩余天数 |
| 🎂 **生日提醒** | 支持生日模式（仅月日），自动算到下次的天数 |
| 🌙 **暗色模式** | Material 3 自动跟随系统 |

## 技术栈

| 层 | 选型 |
|---|------|
| 框架 | Flutter 3.32 + Dart 3.8 |
| 状态管理 | Riverpod 2 |
| 数据库 | sqflite（Native SQLite / Web 内存） |
| 数据模型 | freezed |
| 路由 | GoRouter |
| 日历 | table_calendar |

## 快速开始

```bash
# 环境要求
- Flutter SDK 3.32+
- Android SDK 34+
- JDK 17+

# 安装依赖
flutter pub get

# 运行（Web）
flutter run -d chrome

# 构建 APK
flutter build apk --debug
```

## 项目结构

```
lib/
├── core/          # 数据库、主题、路由、工具
├── features/      # 功能模块
│   ├── today/     # Today 首页
│   ├── diary/     # 日记
│   └── day_counter/ # 正数日
└── shared/        # 共享组件
```

## License

MIT
