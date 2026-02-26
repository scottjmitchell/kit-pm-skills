---
description: Draft a Knowledge Base briefing for the support/docs team for a new feature or update
argument-hint: <feature or product description>
allowed-tools: [Bash, Read, Write, Glob, Grep, Task, AskUserQuestion, WebFetch]
---

# KB Briefing

Draft a Knowledge Base briefing for the support/docs team based on: $ARGUMENTS

## Setup

Before doing anything else:

1. Run: `mkdir -p kb-briefings .claude/state`
2. Read `.claude/pm-skills/config.md` if it exists. Extract and store:
   - `feature_areas` — PM's owned features (use to focus context)
   - `english` — British or American (default: British)
   - `editor` — preferred editor (`vscode`, `cursor`, `zed`, or `system`; default: `system`)
3. Read the style guide from this plugin's `references/communication-styles/style-kb.md` — it contains the briefing templates and writing guidelines.

If the config file doesn't exist, use defaults.

---

## Step 1: Understand the feature

If `$ARGUMENTS` contains a meaningful feature description, use it as the starting point.

Otherwise, use `AskUserQuestion` to ask:

> **Describe the feature or product change you need a KB briefing for.** What does it do? Who is it for?

**Wait for the user's answer before proceeding.**

---

## Step 2: Determine release type

Use `AskUserQuestion` (single-select):

> **Is this a new feature or an update to an existing feature?**

- **New feature** — Something that doesn't exist in Kit today
- **Feature update** — A change to something already documented in the KB

Store the answer as `release_type: new` or `release_type: update`.

**Wait for the answer before proceeding.**

---

## Step 3: Gather missing information

Based on the release type, check what information the user has already provided and ask follow-up questions **only for what's missing**. Use a single `AskUserQuestion` message — group questions clearly.

### For ALL releases, ensure you have:

1. **How it works** — Step-by-step: what does the user see, where in the app, what actions can they take? Include any conditional paths (e.g. different behaviour for free vs. paid plans, new vs. existing users).
2. **Audience** — Which users are impacted? (All creators, specific plan tiers, specific feature users, subscribers/customers?)
3. **Release date** — When is this going live?
4. **Questions to anticipate** — 3–5 likely questions creators will ask about this.

### For FEATURE UPDATES only, also ensure you have:

5. **What changed** — Specific before/after: what was the old behaviour, what is the new behaviour?
6. **Implications** — Does this affect existing workflows? Do creators need to take any action? Any breaking changes?
7. **Existing KB articles** — URL(s) to the current help.kit.com article(s) that need updating.

**Wait for the user's answers before proceeding.**

---

## Step 4: Research (if existing KB articles were provided)

If the user provided existing KB article URLs, fetch each one using `WebFetch` to understand the current content and structure. Note which sections need updating based on the changes described.

If this is a new feature, optionally search `help.kit.com` for related articles the KB writer should cross-link to.

Save any research findings to `.claude/state/kb-research.md`.

---

## Step 5: Draft the briefing

Using the templates in `references/communication-styles/style-kb.md`, generate the briefing in the appropriate format for `release_type`.

### Writing guidelines (from style-kb.md):

- Be specific and concrete — the KB writer shouldn't need to guess
- Include navigation paths (e.g. `Automations → Rules → Add Rule → Trigger`)
- Call out plan-level differences explicitly (free vs. Creator vs. Creator Pro)
- Frame FAQs as actual creator questions with direct answers
- List every screenshot/visual the writer will need, including error states
- For updates: be explicit about what language to change in existing articles
- Keep the briefing scannable — bullets over paragraphs, bold key terms
- Use the English spelling from config (`british` or `american`, default: British)

### Filename and output:

- Generate a kebab-case filename with today's date: `YYYY-MM-DD-feature-name.md`
- Save to `kb-briefings/`
- Open using the editor from config:
  - `vscode` → `code kb-briefings/<filename>.md`
  - `cursor` → `cursor kb-briefings/<filename>.md`
  - `zed` → `zed kb-briefings/<filename>.md`
  - `system` (or missing) → `open kb-briefings/<filename>.md` (macOS); fall back to `xdg-open` if on Linux

---

## Step 6: Critical review

Spawn a **lewis** Task agent (`model: "opus"`) with this prompt:

```
Review this KB briefing document. Read it at: [filepath]

Evaluate it from the perspective of a KB writer who needs to turn this into a help article. Check for:

1. **Completeness** — Could a writer produce the article without coming back to the PM for more information?
2. **Clarity** — Are the "how it works" steps unambiguous? Any vague language?
3. **User questions** — Are there obvious FAQs missing that creators would ask?
4. **Screenshots** — Are all necessary visual assets listed, including edge cases and error states?
5. **For updates** — Is the before/after clear enough? Is every affected article identified?

Flag issues using severity levels:
- Critical: The writer would be blocked without this
- Worth examining: Could lead to a confusing or incomplete article
- Minor: Polish suggestions
```

Present the review feedback to the user and offer to incorporate it.

---

## Step 7: Next steps

After the briefing is finalised, print:

> **Next step:** Go to the [Documentation Hub in Notion](https://www.notion.so/kitinc/Knowledge-Base-Hub-1730dfceaa554e528afdd8c36f8dc7f7) and hit **Add KB Request**, then drop your briefing in the new page.

---

## Step 8: Clean up

Delete `.claude/state/kb-research.md` if it was created.
