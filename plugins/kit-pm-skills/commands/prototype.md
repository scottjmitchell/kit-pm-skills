---
description: Build an interactive product prototype — researches the feature area, generates an overview page and interactive prototype, and pushes to prototypes.kit.com. Run any time you want to create a new clickable prototype to share with design, engineering, or leadership.
argument-hint: <feature name, e.g. "App Store redesign" or "Email scheduling">
allowed-tools: [Bash, Read, Write, Edit, Glob, Grep, Task, AskUserQuestion, WebFetch]
---

# Build a Prototype

Create a new prototype in the Kit prototypes repo for: $ARGUMENTS

## Step 1 — Setup

1. Run: `mkdir -p .claude/state`
2. Read `.claude/pm-skills/config.md` if it exists. Extract:
   - `editor` — preferred editor (`vscode`, `cursor`, `zed`, or `system`; default: `system`)
   - `feature_areas` — PM's owned features (use for context)
3. Ensure the kit-prototypes repo is available:
   ```bash
   if [ -d /tmp/kit-prototypes/.git ]; then
     git -C /tmp/kit-prototypes pull
   else
     gh repo clone Kit/kit-prototypes /tmp/kit-prototypes
   fi
   ```

---

## Step 2 — Gather info

Use `AskUserQuestion` to collect what's missing (skip any already provided in `$ARGUMENTS`):

1. **Feature/product area name** — e.g. "App Store redesign", "Sequence scheduling", "Visual automations branching"
2. **Linear ticket ID** (optional) — will be linked in the prototype README
3. **What are 2–3 things you want to validate with this prototype?** — these become the "Questions for the team" section
4. **Who is the primary reviewer?** — Design / Engineering / Leadership / All

Ask all missing questions in a **single** `AskUserQuestion` call. Wait for the answers before continuing.

From the feature name, derive:
- `feature_name` — the display name (e.g. "App Store Redesign")
- `dir_name` — slugified: lowercase, hyphens, no special chars (e.g. "App Store Redesign" → `app-store-redesign`)
- `feature_area` — the Kit product area for the eyebrow (e.g. "Ecosystem · App Store", "Automations · Visual Automations")

---

## Step 3 — Research (parallel background agents)

Launch **two agents in the background** immediately after Step 2 — don't wait for results before starting Step 4:

**Agent A — Internal context** (`subagent_type: "kit-knowledge-curator"`)

```
Search the workspace for existing context on: [feature_name]

Search in order of priority:
1. prds/ — for any PRD excerpts related to this feature area
2. my-features/ — for feature documentation
3. competitor-analysis/ — for any existing competitor context on this topic

Use Grep to search for the feature name and related terms. Read any relevant files fully.

Return:
- Current Kit feature state (what exists today)
- Known user problems and friction
- Prior decisions and constraints from PRDs
- Any relevant competitor analysis findings

Write findings to .claude/state/prototype-internal.md
```

**Agent B — Competitor & UX research** (`subagent_type: "senior-research-analyst"`)

```
Research competitor implementations and UX best practices for: [feature_name]

Cover:
- How 2-3 most relevant competitors handle this (ActiveCampaign, Mailchimp, Beehiiv, Stripe, GitHub, Shopify — pick whoever is most relevant to this feature type)
- Specific UX patterns and design decisions worth considering
- Any published design system approaches or best practices for this type of UI

Return 3–5 concrete patterns worth including in the prototype, each with:
- What the pattern is
- Why it's notable (the design decision it represents)
- Source (URL or platform)

Write findings to .claude/state/prototype-research.md
```

---

## Step 4 — Plan the prototype

While the research agents run, outline the prototype content. Think through:

1. **Core flows** — what are the 2–3 key user journeys this prototype should demonstrate?
2. **Feature cards** (4–6) — what's in this prototype? Sketch: emoji icon, title, one-paragraph description
3. **Design decisions** — what choices are being made that reviewers should understand? What are the "why" decisions embedded in this prototype?
4. **Validation questions** — from Step 2 answers, plus any you identify from planning

Wait for both background research agents to complete, then merge findings:
- Enrich feature card descriptions with research context where useful
- Add research-backed design decisions (each with a `.decision-source` badge citing the PRD or research)
- Expand validation questions based on what's uncertain

Save the merged plan to `.claude/state/prototype-plan.md` covering: feature name, dir_name, feature_area, flows, feature cards, design decisions, validation questions.

---

## Step 5 — Build (parallel)

Launch **two tasks in parallel**:

---

### Task A — Interactive prototype (`subagent_type: "ui-expert"`)

```
Build the interactive prototype HTML file for: [feature_name]

Context:
- Core flows to cover: [from Step 4 plan]
- Research findings: read from .claude/state/prototype-research.md
- Internal Kit context: read from .claude/state/prototype-internal.md

Style reference:
Read /tmp/kit-prototypes/webhooks/webhooks-2-prototype.html for the design system:
- Inter font loaded from Google Fonts
- CSS variables for the full colour system (defined in :root)
- Sidebar (232px) + main content layout, full viewport height
- Panel patterns (480px side panel)
- Kit top bar with "Kit" logo, sidebar navigation

Requirements:
- Self-contained HTML — all styles and scripts inline; only external deps allowed are Google Fonts and unpkg.com (Lucide icons)
- Relative paths only — no absolute /paths
- Priority: working v1 fast — cover the core flow, use realistic mock data
- The primary user journey must be interactive and clickable end-to-end
- Include realistic Kit-style mock data (real-feeling creator names, realistic numbers)

Write the complete file to: /tmp/kit-prototypes/[dir_name]/prototype.html
After writing, report the 2-3 key interactions you built and any intentional gaps.
```

---

### Task B — Overview page (Claude builds directly)

**While Task A runs**, build `index.html` using the webhooks overview page as the exact template.

First, read the webhooks overview page to use as the CSS template:
- `/tmp/kit-prototypes/webhooks/index.html` — copy the entire `<style>` block exactly

Then build `index.html` with this structure (substituting [feature_name], [dir_name], [feature_area], and content from the Step 4 plan):

```html
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>[Feature Name] — Kit Prototype</title>
<!-- Google Fonts (Inter) -->
<!-- [EXACT CSS from webhooks/index.html — copy the full <style> block] -->
</head>
<body>

  <!-- Top bar -->
  <div class="top-bar">
    <div class="top-bar-logo">Kit</div>
    <div class="top-bar-divider"></div>
    <div class="top-bar-label">Product Prototypes</div>
  </div>

  <!-- Hero -->
  <div class="hero">
    <div class="hero-eyebrow">[feature_area, e.g. "Ecosystem · App Store"]</div>
    <h1 class="hero-title">[Feature Name]</h1>
    <p class="hero-desc">[First paragraph: what problem does this feature solve? Be specific about the friction.]</p>
    <p class="hero-desc" style="margin-bottom:28px;">[Second paragraph: what is the goal of this prototype? What are we trying to validate?]</p>
    <a href="prototype.html" class="btn-primary">
      <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polygon points="5 3 19 12 5 21 5 3"/></svg>
      Open prototype
    </a>
  </div>

  <!-- What's in this prototype (4–6 feature cards) -->
  <div class="section">
    <div class="section-title">What's in this prototype</div>
    <div class="feature-grid">
      <!-- For each feature from the plan: -->
      <div class="feature-card">
        <span class="feature-card-icon">[emoji]</span>
        <div class="feature-card-title">[Feature title]</div>
        <div class="feature-card-desc">[One paragraph description — what it does, how it works in the prototype, what's notable about this implementation]</div>
      </div>
      <!-- ... repeat for each feature card ... -->
    </div>
  </div>

  <!-- Design & product decisions (3–6 decisions) -->
  <div class="section">
    <div class="section-title">Design &amp; product decisions</div>
    <div class="decision-list">
      <!-- For each design decision from the plan: -->
      <div class="decision">
        <div class="decision-title">[Decision title — frame as the choice made, e.g. "Inline editing over modal dialogs"]</div>
        <div class="decision-body">[First paragraph: what's the context or problem that required a decision?]</div>
        <div class="decision-body">[Second paragraph: what did we decide and why? What tradeoffs does this represent?]</div>
        <span class="decision-source">[Source — e.g. "PRD — Problem Alignment" or "Stripe analysis — UX patterns"]</span>
      </div>
      <!-- ... repeat for each decision ... -->
    </div>
  </div>

  <!-- Questions for the team -->
  <div class="section">
    <div class="section-title">Questions for the team</div>
    <div class="questions">
      <div class="questions-title">Things to explore and validate</div>
      <ul class="question-list">
        <!-- For each validation question: -->
        <li><div class="q-bullet">1</div><span><strong>[Topic]:</strong> [The specific question — be concrete about what feedback you're looking for]</span></li>
        <!-- ... numbered sequentially ... -->
      </ul>
    </div>
  </div>

</body>
</html>
```

Write to: `/tmp/kit-prototypes/[dir_name]/index.html`

---

Also create `/tmp/kit-prototypes/[dir_name]/README.md`:

```markdown
# [Feature Name] Prototype

**Status:** Active
**Owner:** Scott Mitchell
**URL:** [prototypes.kit.com/[dir_name]/](https://prototypes.kit.com/[dir_name]/)
[**Linear:** [ticket_id]](https://linear.app/kit/issue/[ticket_id])
<!-- Remove the Linear line if no ticket_id was provided -->

## Overview

[One paragraph description of what this prototype explores and what's being validated.]

## Files

- `index.html` — Overview page: decisions, features, and validation questions
- `prototype.html` — Interactive prototype
```

---

## Step 6 — Review

After both tasks complete, spawn a **lewis** Task agent (`model: "opus"`) to review the decisions section:

```
Review the "Design & product decisions" section of this prototype overview page.
Read the file at: /tmp/kit-prototypes/[dir_name]/index.html

Check for:
1. Clarity — Is each decision clearly explained? Would a design or engineering reviewer understand the "why"?
2. Completeness — Are the key decisions documented? Are there obvious ones missing?
3. Honest framing — Are decisions presented as choices with rationale, or as foregone conclusions?
4. Source quality — Are the decision sources specific and appropriate?

Flag issues using 🔴 Critical / 🟡 Worth examining / 🔵 Minor.
Focus on the decisions section only — don't review the rest of the page.
```

Apply any 🔴 Critical feedback before pushing.

Also spawn a **code-reviewer** Task agent in the background (don't block on it):

```
Review these two prototype files for broken relative paths and correctness:
- /tmp/kit-prototypes/[dir_name]/index.html
- /tmp/kit-prototypes/[dir_name]/prototype.html

Check for:
1. Broken relative paths — any href/src that isn't relative (./file) or from Google Fonts/unpkg CDN
2. The CTA in index.html links to prototype.html (not another filename)
3. Obvious JavaScript errors that would cause console errors
4. Missing alt attributes on images

Report confirmed issues only.
```

Apply any CRITICAL code-review findings before the git push.

---

## Step 7 — Update root files and push

**Update the root landing page** — add a card to `/tmp/kit-prototypes/index.html`:

Find the `.prototype-grid` div and add a new card **inside** it (after existing cards):

```html
      <a href="./[dir_name]/" class="prototype-card">
        <div class="card-area">[feature_area, e.g. "Ecosystem · App Store"]</div>
        <div class="card-header">
          <div class="card-title">[Feature Name]</div>
          <span class="badge badge-active">Active</span>
        </div>
        <div class="card-desc">[One sentence describing what this prototype explores — same energy as the webhooks card desc]</div>
        <div class="card-link">
          Open prototype
          <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M5 12h14M12 5l7 7-7 7"/></svg>
        </div>
      </a>
```

**Update the root README** — add a row to the Prototypes table in `/tmp/kit-prototypes/README.md`:

```
| [[Feature Name]](./[dir_name]/) | [One sentence description] | Active | [/[dir_name]/](https://prototypes.kit.com/[dir_name]/) | Scott Mitchell |
```

**Git push:**

```bash
git -C /tmp/kit-prototypes add [dir_name]/ index.html README.md
git -C /tmp/kit-prototypes commit -m "Add [feature_name] prototype"
git -C /tmp/kit-prototypes push origin main
```

---

## Step 8 — Share URL

Print:

```
✓ Prototype pushed. GitHub Pages deploys in ~1 min.

  https://prototypes.kit.com/[dir_name]/

Want me to open it in your browser? (yes/no)
```

If yes: `open "https://prototypes.kit.com/[dir_name]/"`

---

## Step 9 — Clean up

Delete temporary state files:
```bash
rm -f .claude/state/prototype-internal.md .claude/state/prototype-research.md .claude/state/prototype-plan.md
```
