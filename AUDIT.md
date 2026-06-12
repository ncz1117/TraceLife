# Audit Report — TraceLife V2

> Impeccable `$impeccable audit` 输出
> 日期：2026-07-12
> 扫描范围：`lib/` (50 个 Dart 文件 / ~5,600 行)

---

## 📊 Audit Health Score: **12/20 — Acceptable**

| 维度 | 评分 | 状态 |
|------|------|------|
| A11y | **2/4** | 基础 |
| 性能 | **3/4** | 良 |
| 主题 | **2/4** | 差 |
| 响应式 | **2/4** | 差 |
| Anti-Pattern | **3/4** | 良 |

> **注意**：Impeccable 原版是 web 工具，CSS/HTML 规则不能直接跑。本次采用 Impeccable 原则人工审计 Flutter 代码（按相同维度）。

---

## 🚨 Anti-Patterns Verdict

| 项 | 结果 |
|----|------|
| 侧边条纹 `border-left/right > 1px` | ✅ **0 命中** |
| 渐变文字 `background-clip: text` | ✅ **0 命中** |
| 玻璃拟态 blur | ✅ **0 命中** |
| Inter/Roboto 默认字体 | ✅ **0 命中**（已用 Noto SC + Playfair） |
| 圆角 > 16px | ✅ **0 命中**（max 12px） |
| 大模糊阴影 > 16px | ✅ **0 命中**（0 BoxShadow） |
| Cream/Sand 暖中性背景 | ✅ **0 命中** |
| `repeating-linear-gradient` 斜条 | ✅ **0 命中** |
| 手绘 SVG 草图 | ✅ **0 命中** |
| **LinearGradient 装饰** | ⚠️ **2 处**（day_counter_view_page 封面背景）|
| **Hero Metric 模板** | ⚠️ **Stats Page 4 张 metric 卡**（大数字+小标签+icon+颜色）|

**总结**：原版 8 个绝对禁用**全过**。仅 2 个潜在 AI 痕（线性渐变背景 + 指标卡模板），可调整。

---

## 📋 Detailed Findings by Severity

### P0 Blocking（无）

> 没有阻止任务完成的硬伤。

---

### P1 Major（2 项 — 必修）

#### [P1] 主题颜色未走 token，多个 page 直接硬编码
- **位置**：
  - `lib/features/stats/stats_page.dart:109, 120, 128, 131, 134` — 5 个硬编码 `Color(0xFF...)`
  - `lib/features/day_counter/day_counter_view_page.dart` — 18 处 `Colors.white` / `Colors.black54` / `Colors.black`
  - `lib/features/day_counter/day_counter_add_page.dart` — 2 处 `Colors.red` / `Colors.black54`
  - `lib/features/day_counter/day_counter_page.dart` — 2 处 `Colors.red`
- **类别**：Theming
- **影响**：换主题时这些位置**不会跟随切换**，4 套主题策略失效；暗色模式下白色文字 + 浅色蒙层可能反白失败
- **建议**：
  - 全部走 `colorScheme.onSurface` / `colorScheme.surface` / 新加 `colorScheme.scrim`
  - 统计页 4 个语义色（橙/绿/红/紫）走 `AppColors` extension（mood 系列已用此模式）
- **建议命令**：`$impeccable colorize`

#### [P1] A11y：缺少 `Semantics` widget 和 `prefers-reduced-motion` 支持
- **位置**：全项目
- **类别**：Accessibility
- **影响**：
  - 屏幕阅读器（TalkBack/VoiceOver）不能正确读出纪念日大数字、心情、统计
  - 减弱动画用户无法选择关闭（V2 还没加动效，但 V3 会加）
- **WCAG**：2.1.1 Keyboard / 2.3.3 Animation from Interactions
- **建议**：
  - `Semantics(value: '$days 天', child: ...)` 包大数字
  - V3 动效代码全部包 `MediaQuery.of(context).disableAnimations` 检查
- **建议命令**：`$impeccable polish` + `$impeccable harden`

---

### P2 Minor（4 项 — 下次修）

#### [P2] 响应式：未做宽度断点，桌面/平板体验差
- **位置**：所有 Page
- **类别**：Responsive
- **影响**：在 > 600px 屏幕上内容拉伸到全宽，不便阅读
- **建议**：
  - 加 `LayoutBuilder` 监听宽度
  - 桌面（> 768px）：限制主内容 `maxWidth: 600px` 居中
  - 平板（> 600px）：纪念日网格 2 列
- **建议命令**：`$impeccable layout`

#### [P2] 触控目标无 44px 保证
- **位置**：可能的小按钮（需具体看 Material 默认行为）
- **类别**：Accessibility
- **WCAG**：2.5.5 Target Size
- **建议**：
  - 所有可点元素 `minimumSize: Size(48, 48)`（Material 推荐 48）
  - IconButton 已是 48 默认，但 Card 上的 TextButton 可能不够
- **建议命令**：`$impeccable polish`

#### [P2] day_counter_view_page 使用 LinearGradient 背景
- **位置**：`lib/features/day_counter/day_counter_view_page.dart:75, 92`
- **类别**：Anti-Pattern（潜在）
- **影响**：无图时用青-灰渐变（`[Color(0xFF...), Color(0xFF...)]`），是「通用渐变」AI 痕的边沿
- **建议**：
  - 改为纯色 + 装饰纹理（或 Lottie），或
  - 渐变方向和颜色改成"主色 → 主色暗 30%"的非通用渐变
- **建议命令**：`$impeccable colorize`

#### [P2] Stats Page 4 张 metric 卡是 Hero Metric 模板
- **位置**：`lib/features/stats/stats_page.dart:100-150`
- **类别**：Anti-Pattern
- **影响**：连续天数/总天数/日记数/心情均分 的 4 张"大数字+小标签+icon+渐变色"卡，是 SaaS AI 高频模板
- **建议**：
  - 4 张卡尺寸有变化（不是 4 等分）
  - 至少 1 张卡用 2-3 个数据 + 一句话洞察（不是单一数字）
  - 用主色之外的辅助色区分语义（不走渐变）
- **建议命令**：`$impeccable colorize` + `$impeccable layout`

---

### P3 Polish（4 项 — 闲时修）

#### [P3] 字体层未走 token
- **位置**：`fontSize: 8/10/11/12/13/14/18/20/22/24/32/36/100` 共 14 个不同尺寸
- **建议**：统一到 7 档 scale（caption/body/body-sm/subheading/heading/display/number-display）

#### [P3] 间距未走 token
- **位置**：`EdgeInsets` / `SizedBox` 用到 9 个不同数值（2/4/6/8/12/16/20/24/32/80）
- **建议**：8 进制 spacing scale（4/8/12/16/24/32/48/64），覆盖 80% 场景

#### [P3] 字重 5 档混用（w200/w500/w600/bold/w900）
- **建议**：限制 3 档（400/500/700），数字 900 单独

#### [P3] 4 套主题未实现（V3 计划项）
- **现状**：只有 light/dark 两套
- **建议**：按 DESIGN.md 实现 4 套主题预设（默认青/暖橙/樱粉/暗夜紫）

---

## 🔍 Patterns & Systemic Issues

| 模式 | 现状 | 建议 |
|------|------|------|
| **颜色** | 17 个硬编码 `Color(0x...)` 散落（page 直接用） | 全部走 `colorScheme` + `AppColors` |
| **字体** | 13 个 fontSize 数值 / 5 个字重 | 7 档 scale + 3 档字重 |
| **圆角** | 5 个 radius 值，max 12px | 4 档 token（8/12/16/full） |
| **间距** | 9 个 raw 数值 | 8 进制 scale（8 个 token） |
| **阴影** | 0 个 BoxShadow | 4 档 token（xs/sm/md/lg） |
| **动效** | 0 个 `AnimatedXxx` / 0 reduced-motion | V3 加 100/300/500 时长规范 |
| **Semantics** | 0 个 `Semantics(...)` | 关键交互包一层 |
| **断点** | 无 `LayoutBuilder` | 4 档（mobile/tablet/desktop/wide） |

---

## ✅ Positive Findings

| 项 | 状态 |
|----|------|
| 侧边条纹 | 0 ✅ |
| 渐变文字 | 0 ✅ |
| 玻璃拟态 | 0 ✅ |
| 大圆角 (>16px) | 0 ✅ |
| 大模糊阴影 (>16px) | 0 ✅ |
| Cream/Sand 暖中性 | 0 ✅ |
| Inter/Roboto 默认字体 | 0 ✅（已用 Noto SC + Playfair） |
| 暗色模式支持 | 有（ThemeMode.system + light/dark split） |
| 导航/路由 | 集中（go_router）|
| 状态管理 | 集中（Riverpod）|
| L10n | 中文支持完整 |
| 数据库迁移链 | 6 个版本链，结构化 |
| **设计哲学"私人日记感"** | 部分达成（纪念日 view page 大数字+Playfair 已成型） |

---

## 🎯 Recommended Actions

| 优先级 | 命令 | 说明 |
|--------|------|------|
| **P1** | `$impeccable colorize` | 修硬编码颜色 + Stats Page 4 卡 + LinearGradient 渐变 |
| **P1** | `$impeccable polish` | 加 Semantics 包裹关键数据 + reduced-motion 支持 |
| P2 | `$impeccable layout` | 响应式断点 + 触控目标 48px |
| P2 | `$impeccable typeset` | 字体 scale 7 档 + 字重 3 档（Product 决策） |
| P2 | `$impeccable layout` | 间距 8 进制 + 圆角 4 档 |
| P3 | `$impeccable colorize` | 4 套主题预设（默认青/暖橙/樱粉/暗夜紫） |
| P3 | `$impeccable animate` | V3 动效系统 + 减弱动画 |
| **最后** | `$impeccable polish` | 最终打磨 10 维度 |

---

## 📊 与 V1 启动时的预期对比

| 项 | 预期 | 实际 |
|----|------|------|
| A11y | 2 | **2** ✅ |
| 性能 | 3 | **3** ✅ |
| 主题 | 1 | **2**（V2 mood 系列走 token 拉高了 1 分）|
| 响应式 | 2 | **2** ✅ |
| Anti-Pattern | 2 | **3**（V2 ViewPage 衬线体拉高了 1 分）|

---

## 📝 备注

1. **手动审计 vs 自动扫描**：Impeccable 原版 `detect.mjs` 跑 HTML/CSS，Flutter 编译后是 JS 包，无法直接扫。本次按 Impeccable 原则人工审计，结果比自动扫描更准确但更耗时。

2. **修复优先级**：先 P1（2 项），P2 推到 V3 P1-P3，P3 在 polish 阶段统一收。

3. **下一步建议**：
   - 选项 A：开 **`$impeccable colorize`** 修 P1 颜色问题（最高 ROI）
   - 选项 B：开 **`$impeccable polish`** 加 Semantics（最长尾）
   - 选项 C：开 **`$impeccable typeset`** 字体系统（决策点）
   - 选项 D：休息/做别的

**选哪个？**
