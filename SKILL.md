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

# ELI5 Skill — Big pictures, few words · any model · multi-language · interactive

Explain any topic to someone who knows **nothing** about it, as a **single-file HTML** output: large hand-drawn-style SVG figures tell the story, text stays in the background. No dependency on any specific model's Artifacts or proprietary tools — any LLM (Claude, GPT, DeepSeek, Gemini, local models) that can write HTML can follow this spec and produce the same output. Supports **中文 / English / 日本語 / 한국어** with auto-detection or explicit selection, and one-shot generation of the full multi-language set.

## When to Use

- User types `/eli5 <topic>` (this skill's slash trigger)
- User says "explain X like I'm 5" / "用大白话讲一下 X" / "解释给我妈听" / "子どもに説明する" / "쉽게 설명해줘"
- User asks for a "simple visual explanation" / "one-picture科普" of a concept
- User asks for "multi-language version" / "中英日" / "multi-language explanation"
- When the topic lives in the codebase/session, `read_file` the relevant code first so the explanation is accurate

Don't use for: deep technical documentation, teaching that needs precise terminology, plain-text Q&A (no visualization needed).

## Language rules (multi-language core)

1. **Auto-detect**: look at the user's message language + session context. Chinese message → 中文; English → English; 日本語 → 日本語; 한국어 → 한국어.
2. **Explicit request wins**: `/eli5 X in Japanese`、`/eli5 X 用日语`、`/eli5 X を日本語で` → output in the requested language.
3. **One-shot multi-language**: `/eli5 X 多语言`、`/eli5 X in all languages`、`/eli5 X 中英日韩` → generate four files `zh/en/ja/ko` at once, sharing the same set of SVGs (only text changes), named `<slug>-zh.html` `<slug>-en.html` `<slug>-ja.html` `<slug>-ko.html`.
4. `<html lang="zh">` / `lang="en"` / `lang="ja"` / `lang="ko"` must strictly match the content language; the body must not mix large passages from other languages.
5. **Term handling**: keep the English term, give a local-language gloss in parentheses, e.g. "队列(queue)". After first use, the local abbreviation is fine.
6. Font stacks: Chinese `"PingFang SC","Microsoft YaHei","Noto Sans CJK SC",sans-serif`; Japanese `"Hiragino Sans","Noto Sans JP","Yu Gothic",sans-serif`; Korean `"Apple SD Gothic Neo","Malgun Gothic","Noto Sans KR",sans-serif`; English `system-ui,-apple-system,sans-serif`.

## Interactive enhancements (built into the template)

Generated HTML ships with three interactions by default, implemented per `templates/eli5-template.html`:

1. **Hover glossary**: wrap a technical term at first occurrence in `<span class="term" data-gloss="plain-language explanation">term</span>`; hover/tap pops a plain-language bubble. End with a "glossary" section listing all terms.
2. **Quiz recap**: after the recap, add 3–4 single-choice questions (`<div class="quiz">`), 3 options each; clicking gives instant right/wrong feedback; wrong answers hint "go back to step N". The template's JS handles interaction — generation only needs to fill in the questions.
3. **Step animations**: SVGs are static by default (so export stays clean), but flow diagrams can take `class="anim"` plus the keyframes in `<style>` (elements fade/slide in left-to-right). Screen-only; still in print/export.

## Procedure

1. **Pick topic + language** (per the language rules above; multi-language mode emits all four at once).
2. **Structure the explanation**: a one-line hook ("what is this, why do you care") → 3–6 numbered steps (each = title + one big SVG + one-line caption) → a 3-point recap at the end.
3. **Write the HTML file**: use `write_file` to output to `~/eli5-output/<slug>-<lang>.html` (create the directory first if missing). Follow the skeleton in `templates/eli5-template.html`, which already contains the interactive CSS/JS.
4. **Export (optional)**: once tooling is installed, one command converts to PDF/PNG:
   ```bash
   ./scripts/export.sh ~/eli5-output/<file>.html pdf
   ./scripts/export.sh ~/eli5-output/<file>.html png
   ```
   Output lands in the same directory. The script auto-discovers `chromium`/`google-chrome`/playwright caches.
   **Missing system libraries** (`error while loading shared libraries`): on Debian/Ubuntu run
   `sudo apt install -y libnspr4 libnss3 libatk1.0-0 libatk-bridge2.0-0 libcups2 libxcomposite1 libxdamage1 libatspi2.0-0`,
   or **export locally on any machine with a browser**: open the HTML → Ctrl+P → Save as PDF (disable headers/footers in print settings).
5. **Report**: give the user the file path; if on a LAN, suggest `python3 -m http.server` to preview.

## HTML spec (hard rules, professional grade)

- **Single-file self-contained**: CSS + SVG fully inline, zero external requests (no CDN fonts/JS/images — must open on intranet and offline).
- **Responsive**: `<meta viewport>`; single column on mobile, desktop content ≤ 900px centered.
- **Picture-first**: one inline SVG per step, ≥ 80% of content width; sketch style (rounded rectangles, circle-head people, arrows, database cylinders, clouds). Every element in every figure must *mean something* — no decorative clip-art.
- **Few words**: titles ≤ 8 words; captions ≤ 1 sentence; paragraphs ≤ 2 sentences. Cut ruthlessly.
- **Palette**: bright, friendly palette via CSS variables (primary/background/accent), light theme first, optional `prefers-color-scheme` dark adaptation.
- **Numbered feel**: big ①②③ numerals or "Step 1" badges so the reader always knows where they are.
- **SVG shape vocabulary**: person = circle head + body/clothes; box/service = rounded rect + label; database = cylinder; flow = left-to-right arrows + numbers; comparison = two columns side by side; time = horizontal arrow axis.
- **Interaction trio** (see above): hover glossary + Quiz + step animations.

## Pitfalls

- Don't write `<img src="https://...">` or external CSS/JS — breaks intranet/offline; SVG must be inline.
- Caption longer than one sentence = violation; split into two figures instead.
- Terms fired without explanation = violation; plain language first, then the term in parentheses.
- Don't use the `<foreignObject>`-containing-HTML SVG trick — some renderers don't support it.
- Use emoji sparingly (some systems lack glyphs); visual information comes from SVG, not emoji.
- Don't produce a 20,000-word "illustrated essay" — the goal is a 5-minute read.
- Multi-language versions **share one SVG set** (text only changes) — don't redraw figures per language.
- The export script depends on Chromium; if the server lacks it, suggest local install or skip export and deliver HTML only.

## Verification

- [ ] File starts with `<!DOCTYPE html>` and ends with `</html>`, no external http(s) references
- [ ] `lang` attribute matches the body language
- [ ] Every step has ≥ 1 inline SVG, visibly wider than the text
- [ ] All paragraphs ≤ 2 sentences, captions ≤ 1 sentence
- [ ] Interaction trio complete: hover terms have `data-gloss`, Quiz gives right/wrong feedback, animations are still in print
- [ ] Opens with `python3 -m http.server` or double-click, no white screen
- [ ] `export.sh` produces a non-empty pdf/png on export
