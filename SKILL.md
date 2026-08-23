---
name: eli5
description: "Explain like I'm 5: picture-first HTML, any model. /eli5."
version: 2.0.0
author: SS (sscodeai)
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [eli5, explainer, html, svg, education, multi-language, quiz, export]
    related_skills: [claude-design, manim-video]
---

# ELI5 Skill — 大图少字 · 多模型 · 多语言 · 可交互

把任何主题讲给"完全不懂的人"听,输出为**单文件 HTML**:大号 SVG 简笔画讲故事,文字只做配角。不依赖任何特定模型的 Artifact/专属工具——任何 LLM(Claude、GPT、DeepSeek、Gemini、本地模型)只要会写 HTML 就能照此输出。支持**中文 / English / 日本語 / 한국어**,自动检测或显式指定,可一键出多语言全套。

## When to Use

- 用户输入 `/eli5 <topic>`(本 skill 的 slash 触发)
- 用户说"用大白话讲一下 X""解释给我妈听""explain like I'm 5""子どもに説明する""쉽게 설명해줘"
- 用户要"简单可视化讲解""一图流科普"某个概念
- 用户要"多语言版""中英日""多国语言讲解"
- 主题在代码库/会话里时,先 `read_file` 相关代码再讲,保证准确

Don't use for: 深度技术文档、需要精确术语的教学、纯文字问答(没有可视化需求)。

## 语言规则(多语言核心)

1. **自动检测**:看用户消息语言 + 会话上下文。中文消息 → 中文;English → English;日本語 → 日本語;한국어 → 한국어。
2. **显式指定优先**:`/eli5 X in Japanese`、`/eli5 X 用日语`、`/eli5 X を日本語で` → 按指定输出。
3. **一键多语言**:`/eli5 X 多语言`、`/eli5 X in all languages`、`/eli5 X 中英日韩` → 一次生成 `zh/en/ja/ko` 四份,共享同一套 SVG 图(只换文字),命名 `<slug>-zh.html` `<slug>-en.html` `<slug>-ja.html` `<slug>-ko.html`。
4. `<html lang="zh">` / `lang="en"` / `lang="ja"` / `lang="ko"` 与内容语言严格一致;正文不得混入其他语言的大段文字。
5. **术语处理**:保留英文原词,括号里给本地语言解释,如"队列(queue)"。首次出现后可用本地简称。
6. 字体栈:中文 `"PingFang SC","Microsoft YaHei","Noto Sans CJK SC",sans-serif`;日文 `"Hiragino Sans","Noto Sans JP","Yu Gothic",sans-serif`;韩文 `"Apple SD Gothic Neo","Malgun Gothic","Noto Sans KR",sans-serif`;英文 `system-ui,-apple-system,sans-serif`。

## 交互增强(模板内置)

生成的 HTML 默认带三样交互,按模板 `templates/eli5-template.html` 实现:

1. **悬停术语(glossary)**:正文里专业词首次出现时包 `<span class="term" data-gloss="大白话解释">词</span>`,鼠标悬停/点按弹出气泡解释。收尾附"术语表"区,列出所有术语。
2. **Quiz 小测验**:结尾 recap 后加 3–4 道单选题(`<div class="quiz">`),每题 3 选项;点选后即时反馈对/错,错题提示"回到第 N 步再看看"。模板里的 JS 处理交互,生成时只需按结构填题。
3. **步骤动画**:SVG 图默认静态(保证导出正常),但给流程类图加 `class="anim"` 与 `<style>` 里的 keyframes(元素从左到右依次淡入/滑动),仅在屏幕查看时生效,打印/导出时静止。

## Procedure

1. **定主题 + 定语言**(按上面的语言规则;多语言模式直接出四份)。
2. **搭讲解结构**:一句话 hook("这是啥、为啥跟你有关")→ 3–6 个编号步骤(每步 = 标题 + 一张大 SVG + 一句图注)→ 结尾 3 点 recap。
3. **写 HTML 文件**:用 `write_file` 输出到 `~/eli5-output/<slug>-<lang>.html`(目录不存在先建)。参照 `templates/eli5-template.html` 的骨架,里面已含交互增强的 CSS/JS。
4. **导出(可选)**:装好工具后可一键转 PDF/PNG:
   ```bash
   ./scripts/export.sh ~/eli5-output/<file>.html pdf
   ./scripts/export.sh ~/eli5-output/<file>.html png
   ```
   输出到同目录。脚本自动发现 `chromium`/`google-chrome`/playwright 缓存。
   **缺系统库时**(`error while loading shared libraries`):在 Debian/Ubuntu 上跑
   `sudo apt install -y libnspr4 libnss3 libatk1.0-0 libatk-bridge2.0-0 libcups2 libxcomposite1 libxdamage1 libatspi2.0-0`,
   或**在任何有浏览器的机器上本地导出**:打开 HTML → Ctrl+P → 另存为 PDF(打印时可去掉页眉页脚)。
5. **汇报**:给用户文件路径;若在 LAN 上,可顺带建议 `python3 -m http.server` 起服务看效果。

## HTML 规范(专业版硬规则)

- **单文件自包含**:CSS + SVG 全部内联,零外部请求(不引 CDN 字体/JS/图片,内网和离线都能开)。
- **响应式**:`<meta viewport>`,移动端单列、桌面端内容宽 ≤ 900px 居中。
- **大图优先**:每个步骤一张内联 SVG,占内容宽度 80%+;简笔画风格(圆角矩形、圆圈小人、箭头、数据库圆柱、云朵)。每张图里每个元素必须"有意义",不要装饰性剪贴画。
- **少字**:标题 ≤ 8 个词;图注 ≤ 1 句话;段落 ≤ 2 句话;能砍就砍。
- **配色**:明亮友好的调色板,CSS 变量定义(主色/背景/强调色),浅色主题优先,可加 `prefers-color-scheme` 深色适配。
- **编号感**:步骤用大号数字 ①②③ 或 "Step 1" 徽章,读者永远知道讲到哪。
- **SVG 图形词汇表**:人 = 圆头 + 身体/衣服;盒子/服务 = 圆角矩形 + 标签;数据库 = 圆柱体;流程 = 从左到右箭头 + 编号;对比 = 并排两列;时间 = 横轴箭头。
- **交互三件套**(见上节):悬停术语 + Quiz + 步骤动画。

## Pitfalls

- 不要写 `<img src="https://...">` 或外链 CSS/JS —— 内网/离线打不开,必须内联 SVG。
- 图注超过一句 = 违规;宁可拆两张图。
- 术语连发不解释 = 违规;先大白话,再括号补术语。
- 不要用 `<foreignObject>` 里塞 HTML 的 SVG 技巧,部分渲染器不支持。
- emoji 慎用(部分系统缺字体),图形信息靠 SVG 不靠 emoji。
- 别输出 2 万字的"图文"—— 目标是 5 分钟读完。
- 多语言版**共用同一套 SVG**(只改文字),别为每种语言重画图。
- 导出脚本依赖 Chromium,服务器没装就跑不了;可提示用户本地装,或跳过导出只给 HTML。

## Verification

- [ ] 文件以 `<!DOCTYPE html>` 开头、`</html>` 结尾,无外部 http(s) 引用
- [ ] `lang` 属性与正文语言一致
- [ ] 每步都有 ≥1 张内联 SVG,且宽度明显大于文字
- [ ] 所有段落 ≤ 2 句、图注 ≤ 1 句
- [ ] 交互三件套齐全:悬停术语有 `data-gloss`、Quiz 有对错反馈、动画在打印时静止
- [ ] 用 `python3 -m http.server` 或直接双击能打开,无白屏
- [ ] 导出时 `export.sh` 正常产出 pdf/png,文件非空
