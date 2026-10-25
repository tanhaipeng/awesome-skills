---
name: svg-diagram
description: "手写 SVG 画架构图 / 数据流图 / 部署拓扑图，再用 headless Chrome 渲染成 2 倍 PNG。用于需要精确控制布局的示意图：分层、汇聚分叉、框内多行中文、端口与数据流向。不依赖 Mermaid/Graphviz 的自动布局。"
---

# SVG 架构图

用**手写 SVG 标记**画图，再用 headless Chrome 截图成 PNG。不用绘图库、不用 Mermaid、不用 draw.io。

## 何时用

- 用户说"画个图 / 架构图 / 流程图 / 拓扑图 / 部署图"
- 图需要精确布局：分层结构、一对多汇聚、框内多行文字、中文标签
- 需要 PNG 内嵌到回答里，同时保留可编辑的 SVG 源文件

**不适用**：节点超过 20 个的复杂图（自动布局更合适）、需要交互或动画的图。

## 流程

1. **定画布**：宽度以 1200 为基准，页边距 60px；行高按 100–160px 排，先算出每层的 y 坐标再动手。
2. **写 SVG**：落到 `<项目>/docs/<名字>.svg`，用 `write` 工具直接写文本。
3. **校验 XML**：`python3 -c "import xml.etree.ElementTree as ET; ET.parse('x.svg')"`。
4. **渲染**：`scripts/render-svg.sh x.svg`（本技能自带）。
5. **复核**：用 `read_image` 打开 PNG，对着下面的检查清单逐条看，改完重新渲染。

第 5 步不能省——代码看起来对，渲染出来文字溢出、缺字形、箭头穿框都很常见。

## 画布约定

- `width` / `height` / `viewBox` 三者一致，单位 px
- 先铺一层 `<rect width="100%" height="100%" fill="#FFFFFF"/>`，否则背景透明
- 字体统一：`-apple-system, BlinkMacSystemFont, 'PingFang SC', 'Helvetica Neue', Arial, sans-serif`
- 字号：主标题 30/700，副标题 13.5/400，框标题 15–18/600，正文 11.5–12.5，脚注 11.5
- 圆角 `rx` 12–14，边框 `stroke-width` 1.5，箭头线宽 2

## 配色（浅色主题）

| 用途 | 填充 | 描边 | 文字 |
| --- | --- | --- | --- |
| 应用 / 主体 | `#EEF2FF` | `#6366F1` | `#312E81` |
| 网关 / 中性 | `#F8FAFC` | `#94A3B8` | `#334155` |
| 采集 / 处理 | `#ECFDF5` | `#10B981` | `#065F46` |
| 存储 A | `#F5F3FF` | `#8B5CF6` | `#4C1D95` |
| 存储 B | `#FFF1F2` | `#F43F5E` | `#881337` |
| 存储 C | `#FFFBEB` | `#F59E0B` | `#78350F` |
| 查询 / UI | `#EFF6FF` | `#3B82F6` | `#1E3A8A` |

同类框用同色，跨层用不同色系——颜色本身就是分组信息。

## 构件

完整片段见 `references/svg-patterns.md`，核心几样：

- **箭头**：`<defs>` 里定义一次 marker，路径上 `marker-end="url(#a)"`
- **汇聚总线**：竖线 → 横线 → 多条竖线，避免每根线各画一条斜线
- **嵌套虚线框**：`stroke-dasharray="7 6"`，标签写在框内左上角
- **竖排标签**：`transform="translate(46,190) rotate(-90)"` + `text-anchor="middle"`
- **标签 chip**：小圆角 rect + 居中 text，用来表示卷、标签、枚举值

## 质量检查清单

1. 文字不溢出框、不压边框线，长英文单词尤其要看
2. **没有缺字形**：`↳ ⇢ ⟶` 这类冷门符号在苹方里可能没有，会渲染成方块或乱码；中文标点用全角
3. 箭头不穿过框体，只走空白通道；交叉不可避免时用总线
4. 同层级的框宽高一致、基线对齐
5. 必须有图例或脚注解释颜色/箭头方向，图要能自解释
6. 渲染后 `read_image` 复核，不要凭代码想象结果

## 渲染

```bash
scripts/render-svg.sh input.svg            # 输出同名 .png，2 倍图
scripts/render-svg.sh input.svg out.png 1200 1080
```

原理：Chrome headless `--screenshot` + `--force-device-scale-factor=2`。

已知坑（脚本已处理大部分）：

| 坑 | 处理 |
| --- | --- |
| Chrome 截完图不退出，命令一直挂 | 轮询产物文件，出现后主动 kill |
| crashpad 无权写 `~/Library`，刷一屏报错 | `--disable-crash-reporter --disable-breakpad` |
| 沙箱里不一定有 `rsvg-convert` / `cairosvg` / `qlmanage` | 统一走 Chrome，不依赖这些 |
| 中文缺字形 | 换纯文字表达，不要用符号 |
| 首次启动慢 | 脚本最多等 15 秒 |

## 交付

- 回答里内嵌：`![说明](路径.png)`
- 同时保留 `.svg` 源文件，并告诉用户可以直接改
- 用 `present` 给出 PNG + SVG 两张文件卡
- 图多时说明每张图的视角差异（数据流 vs 部署拓扑），不要让用户猜
