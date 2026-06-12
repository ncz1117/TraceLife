# Design

> TraceLife 视觉系统 — Google Stitch DESIGN.md 格式

---

## 主题概览

| 项目 | 值 |
|------|-----|
| Register | product（app UI） |
| 策略 | Restrained（中性 + 1 强调色 ≤ 10%） |
| 色彩空间 | OKLCH（感知均匀） |
| 字体策略 | 单家族多 weight（product 默认） |
| 字号策略 | 固定 rem（不用 fluid clamp） |
| 4 套主题 | 默认青 / 暖橙 / 樱粉 / 暗夜紫 |

---

## Color Palette

### 主色（4 套主题预设）

| 主题 | 主色 hue | 用途 |
|------|----------|------|
| **默认青** | hue 200-220 | 默认 / 工作 / 平静 |
| **暖橙** | hue 30-50 | 怀旧 / 温暖 / 节日 |
| **樱粉** | hue 340-360 | 浪漫 / 爱情纪念日 |
| **暗夜紫** | hue 270-290 | 暗色 / 夜读 / 高级感 |

### Token 结构（语义命名，不是值命名）

```
--color-bg              # 主背景
--color-surface         # 表面（卡片）
--color-surface-tint    # 表面变体（hover/active）
--color-text            # 主文本
--color-text-secondary  # 次要文本
--color-text-tertiary   # 辅助文本
--color-primary         # 主色（强调）
--color-on-primary      # 主色之上的文字
--color-success         # 成功状态
--color-warning         # 警告
--color-error           # 错误
--color-info            # 信息
```

**重要规则**：
- ❌ **不用 cream/sand/paper 等暖中性背景**（AI 痕 2026）
- ✅ 中性色用**真 off-white（C=0）**或**微微偏向品牌 hue**（C 0.005-0.015）
- ✅ 强调色占表面 10% 以下
- ✅ 暗色模式是真暗（不是浅色的反色）

### 心情色阶（5 档）

| 心情 | 档位 | OKLCH L | C | 含义 |
|------|------|---------|---|------|
| 1 | 灰 | 0.55 | 0.02 | 难过 |
| 2 | 浅蓝 | 0.65 | 0.05 | 不开心 |
| 3 | 米白 | 0.75 | 0.03 | 一般 |
| 4 | 暖黄 | 0.80 | 0.10 | 开心 |
| 5 | 橙红 | 0.70 | 0.15 | 很开心 |

---

## Typography

### 字体家族（混排策略）

> **V3 typeset 决定**：候选 2（衬线大数字 + sans 标题 + sans 正文，杂志感）。
> - 大数字（纪念日 / 统计大值）：**Noto Serif SC**（衬线，有时间感、文学感）
> - 标题 / 正文：**Noto Sans SC**（无衬线，易读）
> - 单家族多 weight；不引入第三字体（克制）

| 角色 | 字体 | 备选 |
|------|------|------|
| 标题 + 正文 | **Noto Sans SC** | — |
| 数字显示 + 衬线场景 | **Noto Serif SC** | Playfair Display（仅英文场景）|
| 数字显示 | Noto Sans SC Tabular | — |

### Type Scale（9 档 + 数字专用）

| Token | sp | 用途 |
|-------|-----|------|
| `text-caption` | 11 | 提示、辅助 |
| `text-body-sm` | 12 | 次要 UI |
| `text-body` | 14 | 正文 |
| `text-subheading` | 16 | 副标题 |
| `text-heading` | 20 | 标题 |
| `text-display` | 28 | 页面大标题 |
| `text-hero` | 36 | Hero 区 |
| `text-number-display` | 100 | 纪念日大数字 |
| `text-stat-large` | 48 | 统计大值 |

**比例**：1.25（major third），hero/number-display 单独特例

### 字重（限制 3 档）

| 用途 | weight |
|------|--------|
| 正文 | 400 (Regular) |
| 副标题/按钮 | 500 (Medium) |
| 标题/强调 | 700 (Bold) |
| 数字显示 | 900 (Black) |

### 行高 / 字距

| 元素 | line-height | letter-spacing |
|------|-------------|----------------|
| Display | 1.0-1.1 | -0.02em |
| Heading | 1.2 | -0.01em |
| Body | 1.5-1.7 | 0 |
| Caption | 1.3 | 0 |
| All-caps | — | 0.05-0.12em |

### 加载策略

```css
font-display: swap
```

**回退字体**（避免 FOUT 抖动）：
- 中文：`-apple-system, "PingFang SC", "Microsoft YaHei"`
- 拉丁：`system-ui, -apple-system, BlinkMacSystemFont`

---

## Spacing

8 进制（line-height 的倍数）：

| Token | 值 | 用途 |
|-------|-----|------|
| `space-0` | 0 | 紧贴 |
| `space-1` | 4 | 极小间距 |
| `space-2` | 8 | 紧凑 |
| `space-3` | 12 | 适中 |
| `space-4` | 16 | 标准 |
| `space-5` | 24 | 大间距 |
| `space-6` | 32 | 区块 |
| `space-7` | 48 | 页面边距 |
| `space-8` | 64 | 大区块 |

---

## Radius

| Token | 值 | 用途 |
|-------|-----|------|
| `radius-sm` | 8 | 标签、按钮 |
| `radius-md` | 12 | 输入框、chip |
| `radius-lg` | 16 | 卡片（**上限**） |
| `radius-full` | 9999 | pill / 圆形 |

**重要规则**：
- ❌ **卡片圆角禁止 > 16px**（AI 痕）
- ✅ 卡片 12-16px，标签按钮 8px
- ✅ 头像/正圆元素用 full

---

## Shadows

| Token | 值 | 用途 |
|-------|-----|------|
| `shadow-xs` | `0 1px 2px rgba(0,0,0,0.04)` | 极轻 |
| `shadow-sm` | `0 2px 8px rgba(0,0,0,0.06)` | 卡片 |
| `shadow-md` | `0 4px 16px rgba(0,0,0,0.08)` | 浮层 |
| `shadow-lg` | `0 8px 32px rgba(0,0,0,0.12)` | Modal |

**重要规则**：
- ❌ **1px border + 16px+ shadow 鬼影卡禁用**
- ✅ 二选一：实色边框 OR ≤ 8px 模糊阴影
- ✅ 暗色模式阴影用黑色 + 边缘高光

---

## Motion

### 时长（100/300/500 规则）

| 时长 | 用途 | 例子 |
|------|------|------|
| 100-150ms | 即时反馈 | 按键、toggle |
| 200-300ms | 状态变化 | 菜单、tooltip、hover |
| 300-500ms | 布局变化 | accordion、modal、drawer |
| 500-800ms | 入场 | 页面加载、hero 揭示 |

### Easing

```css
--ease-out-quart:  cubic-bezier(0.25, 1, 0.5, 1)    /* 平滑（默认） */
--ease-out-quint:  cubic-bezier(0.22, 1, 0.36, 1)   /* 略快 */
--ease-out-expo:   cubic-bezier(0.16, 1, 0.3, 1)    /* 自信果断 */
```

❌ **绝对禁用**：bounce / elastic / 任何过度缓动

### 减弱动画（必做）

```css
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    transition-duration: 0.01ms !important;
  }
}
```

### 微交互

- 按钮 hover：scale 1.02-1.05
- 按钮 click：scale 0.95→1（100ms）
- 列表渐入：错峰 50ms × N（10 项 × 50ms = 500ms 上限）

---

## Components

### 现有（V2）

| 组件 | 文件 | 状态 |
|------|------|------|
| `AppScaffold` | `lib/shared/widgets/app_scaffold.dart` | 基础 |
| `AppCard` | `lib/shared/widgets/app_card.dart` | 基础 |
| `AppEmptyState` | `lib/shared/widgets/app_empty_state.dart` | 基础 |
| `AppSectionHeader` | `lib/shared/widgets/app_section_header.dart` | 基础 |
| `AppConfirmDialog` | `lib/shared/widgets/app_confirm_dialog.dart` | 基础 |

### V3 新增（计划）

| 组件 | 用途 | 优先级 |
|------|------|--------|
| `AppBottomSheet` | 统一底部弹窗 | P0 |
| `AppSnackbar` | 替换默认（图标+操作） | P0 |
| `AppButton` | 渐变按钮 + 加载态 | P1 |
| `AppTextField` | 浮动 label + 聚焦动画 | P1 |
| `AppBadge` | 角标数字 | P1 |
| `AppChip` | 标签筛选 | P2 |
| `AppTooltip` | 长按提示 | P3 |
| `AppLoadingDots` | 加载占位 | P1 |
| `AppImagePicker` | 统一图片选择 | P0 |
| `EmptyStateIllustration` | 4 张插画 | P1 |

### 心情图标（V3 决定）

- V2：emoji（跨平台不一致）
- V3 候选：
  - A 继续 emoji（最简单）
  - B 自绘 SVG 矢量（5 档，跨平台一致）
  - C 字体图标（Iconfont）
- V3 启动时 audit + typeset 决定

---

## Layout

### 页面结构

| 区域 | 规范 |
|------|------|
| 顶部 | 24px 内边距 + 标题 + 操作 |
| 内容 | 16-24px 内边距 |
| 底部 Tab | 64-72px 高度 + 顶部 1px 分割线 |

### 卡片网格

- 移动端：1 列
- 平板/桌面（> 768px）：2 列
- 不超过 3 列（避免同质化）

### 触控目标

- 最小 44x44 px
- 卡片整体可点（不光是文字）
- 间距 ≥ 8px

---

## 8 个绝对禁用（match-and-refuse）

写任何 UI 前先扫这些：

| # | 禁用 | 替代 |
|---|------|------|
| 1 | **侧边条纹** `border-left/right > 1px` | 全边框/背景色/前置图标 |
| 2 | **渐变文字** `background-clip: text` | 纯色 + 字重/字号 |
| 3 | **玻璃拟态当默认** | 极少且有目的 |
| 4 | **英雄指标模板** | 个性化设计 |
| 5 | **千篇一律卡片网格** | 变化尺寸/形态 |
| 6 | **段首小帽 eyebrow** | 选不同节奏 |
| 7 | **01/02/03 数字标头** | 真的有序序列才用 |
| 8 | **1px border + 16px+ shadow 鬼影卡** | 二选一 |

---

## 文件结构

```
lib/core/theme/
├── app_theme.dart            # 主题入口（8 套 ThemeData 工厂）
├── app_colors.dart           # 颜色 extension（心情/scrim/onImage 等）
├── app_typography.dart       # 字体 + 字号 + 字重（9 档 scale + 3 weight）
├── app_spacing.dart          # 间距 token（12 档）
├── app_layout.dart           # 布局 token（4 档断点 + 6 档 radius + contentMaxWidth）
├── app_motion.dart           # 动效 token（6 档时长 + Pulse widget + 路由过场）
└── theme_presets.dart        # 4 套主题预设元数据（默/暮/雾/樱）
```

> **V3 实施后的命名约定调整**：
> - `app_radii.dart` / `app_shadows.dart` 合并到 `app_layout.dart`（radius 属于布局，shadow 留空未实装）
> - `presets/*.dart` 拆 4 个文件 → 合并为 `theme_presets.dart` 单 enum（避免 4 个文件）
> - `app_motion.dart` 提升为一级 token 文件（含 Pulse widget 和 buildRouteTransition）

---

*创建日期：2026-07-12*
*来源：Impeccable init 命令 + PRODUCT.md 战略方向*
*版本：V3 设计基线 v2.0（V3 实施后回填）*
*状态：V3 完成 ✅，4 主题 / 真实心率脉动 / 响应式 / 无障碍 全部交付*
