# ELI5 — Picture-First Explainer Generator

[English](README.md) | [日本語](README.ja.md)

**Explain anything to someone who knows nothing — as a single self-contained HTML file with big SVG illustrations and minimal text.**

ELI5 turns any topic into a **picture-first, 5-minute read**: large hand-drawn-style SVG figures carry the story, words stay in the background. The output is a single HTML file with zero external requests — it works offline, on an intranet, or double-clicked from disk.

Model-agnostic by design: any LLM that can write HTML (Claude, GPT, DeepSeek, Gemini, local models) can follow the spec in [SKILL.md](SKILL.md) and produce the same quality output. No Artifacts, no proprietary tools.

## What you get

- **`SKILL.md`** — the full methodology spec (procedures, language rules, HTML hard rules, pitfalls, verification checklist). Feed it to any LLM as a system prompt to generate explainers.
- **`templates/eli5-template.html`** — the canonical output skeleton: interactive glossary, quiz, step animations, responsive layout, light/dark themes.
- **`scripts/export.sh`** — one-command HTML → PDF/PNG export (auto-discovers Chromium).
- **`examples/`** — a real generated explainer in three languages: *What is an API?* (`what-is-api-{en,ja,zh}.html`) — open it to see the format in action.

## Feature highlights

| Feature | What it does |
|---|---|
| 🖼️ **Picture-first** | Each step = a large inline SVG + one-line caption. Text is the supporting actor. |
| 🌍 **Multi-language** | Auto-detects zh / en / ja / ko, or one-shot generates all four from the same SVGs. |
| 🧩 **Interactive glossary** | Hover any term for a plain-language bubble; a glossary section recaps at the end. |
| ✅ **Quiz recap** | 3–4 multiple-choice questions with instant right/wrong feedback and "go back to step N". |
| 📦 **Zero-dependency output** | Single self-contained HTML — no CDN, no fonts, no external JS. Offline-safe. |
| ♻️ **Model-agnostic** | Any LLM can reproduce the format from the spec alone. |

## Quick start

**Option 1 — ask an AI assistant.** Load `SKILL.md` into your agent (as a skill or system prompt), then say: `eli5 <topic>` or *"explain X like I'm 5"*. The assistant writes the HTML.

**Option 2 — hand-author from the template.** Copy `templates/eli5-template.html`, fill each step with your own SVG + one caption, keep the text minimal.

**Option 3 — study the example.** Open `examples/what-is-api-en.html` in a browser to see the target quality bar.

## Export to PDF/PNG (optional)

```bash
./scripts/export.sh examples/what-is-api-en.html pdf
./scripts/export.sh examples/what-is-api-en.html png
```

The script auto-discovers `chromium` / `google-chrome` / Playwright caches. No browser on the server? Open the HTML and Ctrl+P → Save as PDF (disable headers/footers in print settings).

## Design philosophy

> *"If you can't explain it simply, you don't understand it well enough."*

ELI5 exists because the best way to verify understanding is to explain to a beginner — with pictures. The output is designed to be read in **under 5 minutes**, understood **without prior knowledge**, and **beautiful enough to share**.

## License

MIT
