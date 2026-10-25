# SVG 片段速查

复制粘贴用。所有坐标示例按 1200 宽画布。

## 骨架

```svg
<svg xmlns="http://www.w3.org/2000/svg" width="1200" height="800" viewBox="0 0 1200 800"
     font-family="-apple-system, BlinkMacSystemFont, 'PingFang SC', 'Helvetica Neue', Arial, sans-serif">
  <defs>…marker…</defs>
  <rect width="1200" height="800" fill="#FFFFFF"/>
  <text x="60" y="54" font-size="30" font-weight="700" fill="#0F172A">标题</text>
  <text x="60" y="84" font-size="13.5" fill="#64748B">副标题 · 日期 · 环境</text>
</svg>
```

## 箭头 marker

```svg
<defs>
  <marker id="a" viewBox="0 0 10 10" refX="9" refY="5"
          markerWidth="7" markerHeight="7" orient="auto-start-reverse">
    <path d="M 0 0 L 10 5 L 0 10 z" fill="#64748B"/>
  </marker>
</defs>
<path d="M 600 240 L 600 300" stroke="#64748B" stroke-width="2" fill="none" marker-end="url(#a)"/>
```

需要第二种颜色（比如查询箭头）就再定义 `id="q"`，填 `#3B82F6`。

## 标准框

```svg
<rect x="380" y="465" width="440" height="115" rx="12"
      fill="#ECFDF5" stroke="#10B981" stroke-width="1.5"/>
<text x="600" y="495" font-size="16" font-weight="600" fill="#065F46" text-anchor="middle">标题</text>
<text x="600" y="518" font-size="11.5" fill="#047857" text-anchor="middle">第一行说明</text>
<text x="600" y="538" font-size="11.5" fill="#047857" text-anchor="middle">第二行说明</text>
```

框内居中文字 = `x` 取框中心 + `text-anchor="middle"`。

## 汇聚总线（一对多）

```svg
<!-- 源框底部 → 竖线 → 横线 → 三个目标 -->
<path d="M 600 580 L 600 600" stroke="#64748B" stroke-width="2" fill="none"/>
<path d="M 260 600 L 940 600" stroke="#64748B" stroke-width="2" fill="none"/>
<path d="M 260 600 L 260 618" stroke="#64748B" stroke-width="2" fill="none" marker-end="url(#a)"/>
<path d="M 600 600 L 600 618" stroke="#64748B" stroke-width="2" fill="none" marker-end="url(#a)"/>
<path d="M 940 600 L 940 618" stroke="#64748B" stroke-width="2" fill="none" marker-end="url(#a)"/>
```

多个来源汇聚成一个总线，反向同理：把竖线的 marker 去掉、方向反过来。

## 嵌套虚线框

```svg
<rect x="78" y="245" width="1044" height="725" rx="16" fill="none"
      stroke="#CBD5E1" stroke-width="1.5" stroke-dasharray="7 6"/>
<text x="96" y="272" font-size="12.5" fill="#64748B">Docker Engine 29.7.2</text>
```

三层嵌套时逐层内缩 28px 左右，标签放在各自左上角。

## 竖排层级标签

```svg
<text transform="translate(46,190) rotate(-90)" font-size="12"
      fill="#94A3B8" text-anchor="middle" letter-spacing="2">应用</text>
```

`translate` 的 y 取该层垂直中心。

## 标签 chip

```svg
<rect x="96" y="916" width="150" height="36" rx="9" fill="#F1F5F9" stroke="#CBD5E1"/>
<text x="171" y="939" font-size="11" fill="#475569" text-anchor="middle">tempo-data</text>
```

chip 宽 150、间距 20，一行五个占 830px。

## 三列布局的坐标算法

画布 1200、左右边距 60、`gap=50`：

```
可用宽 = 1200 - 120 = 1080
列宽 = (1080 - 2*50) / 3 = 326.7 → 取 290 或 300
x1 = 115, x2 = 115 + 290 + 50 = 455, x3 = 795
中心 = x + 145 → 260 / 600 / 940
```

先算槽位再填内容，比一边画一边挪省事得多。

## 排查表

| 现象 | 原因 | 改法 |
| --- | --- | --- |
| 文字溢出框 | 字号大 / 框窄 | 缩字号到 11.5，或换行拆成两个 text |
| 出现方块或怪符号 | 字体没有该字形 | 换成纯文字 |
| 箭头穿框 | 走的不是空白通道 | 改走总线，或调整框的 y |
| 背景是黑的 | 没铺背景 rect | 加白色底 rect |
| PNG 是空白 | Chrome 没等到渲染 | 脚本里加 sleep，或检查 SVG 是否有 XML 错误 |
