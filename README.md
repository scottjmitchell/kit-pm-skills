# kit-pm-skills

A Claude Code plugin for PMs — research-backed PRD drafting, critical review, and release note generation, personalised to your Linear workspace, feature areas, and writing style.

---

## Quick start

```bash
claude plugin marketplace add scottjmitchell/kit-pm-skills
claude plugin install kit-pm-skills
```

Then restart Claude Code and run setup:

```bash
/kit-pm-skills:setup
```

---

## Commands

| Command | What it does |
|---|---|
| `/kit-pm-skills:setup` | Personalises the plugin for your workspace — run this first |
| `/kit-pm-skills:update` | Checks for plugin updates, pulls if available, and configures any new settings incrementally |
| `/kit-pm-skills:prd <topic>` | Researches and drafts a new PRD, then runs a critical review |
| `/kit-pm-skills:prd <ticket ID>` | Fetches an existing Linear ticket and produces a refined PRD |
| `/kit-pm-skills:ticket <description>` | Drafts and creates a Linear ticket — feature, bug, or spike |
| `/kit-pm-skills:competitor <topic>` | Researches and produces a competitor analysis — full or quick snapshot |
| `/kit-pm-skills:shipped <feature>` | Generates an internal Slack post and external developer release note |
| `/kit-pm-skills:kb <feature>` | Drafts a structured KB briefing for the support/docs team |
| `/kit-pm-skills:tone` | Builds or refreshes your persistent tone of voice reference from Granola meetings and Slack messages |
| `/kit-pm-skills:weekly` | Drafts your weekly Lattice check-in from Linear, Granola, Slack, and Notion activity |
| `/kit-pm-skills:api <request>` | Makes a Kit API request — sets up credentials on first use |

---

## Setup

`/setup` personalises the plugin for your workspace. Run it once after install, or re-run it any time to update your preferences.

### What it asks

1. **English preference** — British (the correct spelling) or American English
2. **Linear team** — which team PRDs should be created in. Options are fetched live from your Linear workspace (falls back to manual entry if Linear isn't connected yet)
3. **PRD label** — whether to apply a Squad label when creating PRDs in Linear. Squad label options are fetched live from the Linear `Squad` label group
4. **Issue or project** — whether approved PRDs are created as Linear issues (default) or projects
5. **Editor / IDE** — VS Code, Cursor, Zed, or system default (`open`/`xdg-open`). Used by `/prd`, `/shipped`, and `/kb` to open output files
6. **Optional integrations** — Granola (tone of voice matching), kit-docs (developer doc search), and/or Kit API (credentials for `/api`)
7. **Feature areas** — the areas you own, used to focus research in `/prd` and `/shipped`

### What it creates

| File | Purpose |
|---|---|
| `.claude/pm-skills/config.md` | Stores your preferences (English, editor, Linear team, label, issue vs project, feature areas) — read by `/prd`, `/shipped`, and `/kb` at runtime |
| `.claude/pm-skills/api.env` | Kit API credentials — API key and OAuth tokens (gitignored automatically) |
| `.claude/agents/lewis.md` | Personalised critical reviewer with your feature context and English preference |
| `.claude/agents/copywriter.md` | Personalised writing editor with your English preference |
| `.mcp.json` | Configured MCP servers (Linear always; Granola, kit-docs, and Kit API if selected) |
| `prds/`, `shipped-notes/`, `weekly-updates/`, `.claude/state/` | Workspace directories |

### MCP authentication

Linear and Granola use OAuth. After setup, restart Claude Code — it will prompt you to authenticate in your browser on first use. kit-docs is public and requires no authentication.

---

## /update

Checks for remote updates, pulls if available, then runs incremental setup for any new settings added since your last setup.

### Flow

1. Reads the current local plugin version and your config's `installed_version`
2. Runs `git fetch` to check for remote commits
3. If updates are available: shows the version bump and new commits, asks to confirm before pulling
4. After pulling (or if already up to date): scans your config for missing or new fields
5. Asks only the questions for missing fields — skips anything already configured
6. Updates config and stamps `installed_version` with the current version

### Proactive notifications

After `/setup`, a `UserPromptSubmit` hook is added to `.claude/settings.json`. This hook runs a lightweight script (`check-version.sh`) that compares the plugin version to your config's `installed_version`. If they differ — because the plugin was updated via `git pull` — it outputs a once-per-day notice asking you to run `/update`.

### Example usage

```
/update                    # check for updates and apply new settings
/kit-pm-skills:update      # fully qualified form
```

---

## /api

Makes Kit API requests in plain English — no curl commands or auth headers required.

### First-time setup

On first use, `/api` runs a setup wizard:

1. **API key** — prompts you to paste your v4 API key from [Developer Settings](https://app.kit.com/account_settings/developer_settings) (opens the page automatically)
2. **OAuth** (optional) — walks you through creating a Kit App for PKCE OAuth, generates a local callback server script, and runs the browser auth flow automatically
3. **Credentials saved** to `.claude/pm-skills/api.env` (gitignored automatically)
4. **kit-docs MCP** added to `.mcp.json` if not already present

You can also configure API credentials during `/setup` by selecting "Kit API" in the optional integrations step.

### Authentication

| Endpoint type | Auth used |
|---|---|
| Most GET / POST / PUT / DELETE | API key |
| `/v4/bulk/*`, purchase creation | OAuth Bearer token |

The command detects which auth type each endpoint requires and uses the right one automatically. If an OAuth token expires, it refreshes using the stored refresh token and retries without interrupting you.

### Write operations

For any request that creates, updates, or deletes data, `/api` shows you exactly what it's about to send — endpoint, method, and full request body — and asks for approval before executing.

### Examples

```
/api list my subscribers
/api create a subscriber with email hello@example.com and first name Sam
/api tag subscriber 12345 with the "newsletter" tag
/api show me my broadcast stats
/api bulk import subscribers from this CSV: name,email\nSam,sam@example.com
```

---

## /competitor

Researches and produces a competitor analysis for any feature area or topic.

### Flow

1. Asks two questions: context (PRD context, competitive pressure, exploration, standalone) and depth (full analysis or quick snapshot)
2. Runs parallel research agents — Kit's current state via `kit-knowledge-curator` (dev docs, help centre, Linear), plus competitor research grouped for efficiency
3. Drafts the analysis following the style guide: insight-driven, honest about gaps, always includes Kit in comparisons
4. For full analyses, runs a **lewis** critical review to check for unsupported claims and missing angles
5. Saves to `competitor-analysis/YYYY-MM-DD-topic.md` and opens it

### Formats

**Full analysis** — complete structured document: TL;DR, competitive landscape (2–3 sentences per competitor), feature comparison table, key insights (interpretation, not facts), gaps & opportunities (honest about where Kit is behind or ahead), and specific actionable recommendations.

**Quick snapshot** — condensed format suited for dropping into a PRD: TL;DR, feature comparison table, and 3–5 key takeaways with implications for Kit.

### Default competitors

ActiveCampaign, Klaviyo, Mailchimp, Beehiiv. Additional competitors are added automatically based on the topic — or specify them directly in your prompt.

### Example usage

```
/competitor automation organisation features
/competitor how do competitors handle webhook delivery failures
/competitor app store and integration marketplace — quick snapshot for my PRD
```

---

## /ticket

Drafts and creates a Linear ticket from a plain-English description. Works for features, bugs, and spikes.

### Flow

1. Detects ticket type (feature, bug, or spike) from your description — asks if ambiguous
2. **Runs a background research agent** — searches Linear for related/duplicate issues, scans `prds/` for prior decisions and constraints. Flags any clear duplicates immediately
3. Asks 2–3 targeted questions for anything genuinely missing (Figma link, reproduction steps, timebox, etc.)
4. Drafts a properly structured ticket using the correct template for the type, referencing related issues and PRD context found in research
4. Shows the draft for your review before creating anything
6. Creates the issue in your configured Linear team with your configured Squad label, then opens it in your browser

### Templates

**Feature** — user story, context, acceptance criteria (testable, covering happy path and edge cases), design link, technical notes (optional), out of scope

**Bug** — observed behaviour, expected behaviour, steps to reproduce, environment, impact

**Spike** — specific question to answer, context, suggested approach (optional), expected output, timebox, resources

### Acceptance criteria

Criteria are testable and describe outcomes, not implementation. If you can't write acceptance criteria, the scope isn't ready — the command will flag this rather than leaving them vague.

### Example usage

```
/ticket add search to the webhooks list page
/ticket fix 404 error when clicking "Use this template" on a VA template
/ticket investigate rate limiting options for API V4
```

---

## /prd

Drafts a new PRD or refines an existing Linear ticket.

### New PRD flow

1. Asks 2–4 clarifying questions, including:
   - **Pricing & Packaging depth** — full assessment (for significant new features) or abridged one-liner (for iterations)
2. Runs two parallel research agents:
   - **Internal context** — uses the `kit-knowledge-curator` agent to search Kit dev docs, help centre, marketing site, Linear, your `prds/` directory, and `my-features/` (if present), focused on your configured feature areas
   - **Competitive research** — surveys ActiveCampaign, Mailchimp, Beehiiv, Klaviyo, and other relevant competitors; includes which plan tiers each competitor gates the feature behind
3. Drafts the PRD using the bundled style guide and template, saved to `prds/`
4. Runs a **lewis** critical review to surface blind spots and risks
5. On approval, creates a Linear issue in your configured team with your configured Squad label

### Revision flow

Pass a Linear ticket ID (e.g. `/prd ECO-123`):

1. Fetches the full ticket and related issues from Linear
2. Drafts a refined PRD based on the ticket content and your instructions
3. Runs a **lewis** critical review
4. On approval, updates the existing Linear issue with the revised PRD content

### PRD style

PRDs follow the bundled style guide (`references/style-prd.md`): problem-first, British or American English per your preference, specific measurable goals, clear MVP scope, active voice.

Every PRD includes a **Pricing & Packaging** section — either a full assessment (background questions, 2×2 quadrant, plan recommendation with rationale, competitor packaging table) or an abridged version (one-line recommendation + brief rationale), depending on the depth you select at the start. Plan principles are drawn from `references/pricing-packaging.md`.

The **Launch Checklist** includes a DMF naming item that is auto-filled during drafting: recommended **Yes** for net new creator-facing features or significant overhauls, **No** for iterations.

---

## /shipped

Generates release notes for a shipped feature in two formats: an internal Slack post for `#all-shipped`, and a concise external developer changelog entry.

### Flow

1. Reads your tone of voice from `.claude/pm-skills/tone-of-voice.md` (built by `/tone`) — instant, no Granola fetch needed
2. Runs two parallel data-gathering agents:
   - **Linear context** — finds the shipped project or issue, collects all assignees to credit
   - **PRDs & docs** — searches `prds/`, `my-features/`, and kit-docs (if configured) for context
3. Checks for any missing information and asks if needed
4. Hands off to **copywriter** to produce both formats
5. Saves to `shipped-notes/YYYY-MM-DD-feature-name.md` and opens it
6. Spawns a **background tone refresh** (if Granola is configured) so the tone file stays current for next time

### Formats

**Internal Slack post** — celebrates the ship for the whole team. Includes what shipped, the problem it solved, how it works, expected impact, and tracking links. Written in Slack mrkdwn, ready to copy-paste.

**External developer release note** — tight and precise. One paragraph or a few bullets covering what's new, what it enables, and a link to docs. Written for third-party developers and technically-minded creators.

---

## /kb

Drafts a structured Knowledge Base briefing for the support/docs writing team, covering everything they need to produce or update a help article — without coming back to the PM with questions.

### Flow

1. Asks what the feature or change is (if not provided as an argument)
2. Determines release type: **new feature** or **feature update**
3. Collects all missing details in a single question round:
   - How it works (step-by-step, including conditional paths and plan-tier differences)
   - Audience (which creators are affected)
   - Release date
   - 3–5 questions creators are likely to ask
   - *(For updates only)* what changed before/after, creator implications, and links to existing KB articles
4. Fetches any existing KB article URLs provided to understand current content structure
5. Drafts the briefing using the bundled style guide (`references/communication-styles/style-kb.md`)
6. Runs a **lewis** critical review to check completeness, clarity, and FAQ coverage from the writer's perspective
7. Saves to `kb-briefings/YYYY-MM-DD-feature-name.md` and opens it

### Output formats

**New feature briefing** — includes: purpose of the article, audience, step-by-step how-it-works, FAQs to anticipate, screenshots needed, and messaging priorities.

**Feature update briefing** — includes: background (what existed before), what changed (before/after), implications for existing users, FAQs, documentation update guidance per article (with specific section-level edit instructions), and screenshots needed.

### Example usage

```bash
/kit-pm-skills:kb visual automation branching
/kit-pm-skills:kb RSS feed auto-publishing for sequences
/kb              # prompts you to describe the feature
```

### Style guide

KB briefings follow the bundled style guide at `references/communication-styles/style-kb.md`. Key principles:

- Navigation paths written in full (e.g. `Automations → Rules → Add Rule`)
- Plan-tier differences called out explicitly at every step
- FAQs framed as the exact question a creator would type into search
- For updates: old text and replacement text quoted where possible, not just described

---

## /tone

Builds or refreshes the persistent tone of voice reference used by `/shipped` and `/weekly`.

### Why it exists

Rather than fetching Granola on every run of `/shipped` and `/weekly` (slow), `/tone` extracts your voice once and caches it at `.claude/pm-skills/tone-of-voice.md`. The writing skills read from this file instantly, and a background task refreshes it after each run so it stays current.

### Flow

1. Runs two parallel agents — one fetches the 6 most content-rich Granola meeting transcripts, the other searches your recent Slack messages for substantive updates and product decisions
2. Synthesises both sources into a merged tone file: a voice profile (3–5 bullets), representative samples from meetings and Slack separately, and key patterns — noting where spoken and written voice differ
3. Writes or overwrites `.claude/pm-skills/tone-of-voice.md` with a `Last updated` timestamp and source list
4. Confirms how many samples were captured from each source
5. Falls back gracefully if Slack is unavailable — builds from Granola only

### When to run

- **Once after setup** — to seed the file before using `/shipped` or `/weekly`
- **Any time output doesn't sound like you** — re-run to refresh with more recent meetings
- Ongoing refresh happens automatically in the background after each `/shipped` and `/weekly` run

---

## /weekly

Drafts your weekly Lattice check-in from the past 7 days of activity.

### Flow

1. Reads your tone of voice from `.claude/pm-skills/tone-of-voice.md` (built by `/tone`) — instant, no Granola fetch needed for voice matching
2. Runs up to four parallel research agents depending on your configured integrations:
   - **Linear** — completed issues, in-progress work, project updates (always active)
   - **Granola** — meeting wins and decisions (content only, no tone fetch — if `granola: yes`)
   - **Slack** — cross-team discussions and decisions not captured in Linear (if `slack: yes`)
   - **Notion todos** — completed and in-progress personal tasks (if `notion_todos_db` is set in config)
3. Asks a few quick questions — biggest wins, next-week priorities, any blockers
4. Hands off to the **copywriter** to produce the check-in in your natural voice, drawing from all active sources
5. Saves to `weekly-updates/YYYY-MM-DD.md` and opens it
6. Spawns a **background tone refresh** (if Granola is configured) so the tone file stays current for next time

### Configuration

| Config key | How to enable |
|---|---|
| `granola` | Set during `/setup` or add `granola: yes` to config |
| `slack` | Set during first `/weekly` run, or add `slack: yes` to config |
| `notion_todos_db` | Advanced — add `notion_todos_db: collection://<your-db-id>` to config manually |

### Format

Follows the Lattice check-in format: **What's going well** (wins, outcomes) and **Align on expectations** (1-3 next-week priorities) are always included. Optional sections — challenges, learnings, support asks — only appear if there's genuine content.

The output sounds like you wrote it: outcome-focused, specific, skimmable in 2 minutes.

### Example usage

```
/weekly
/weekly focused on extensibility work this week
```

---

## Bundled agents

These agents are included in the plugin and available in your workspace after install. Running `/setup` creates personalised versions in `.claude/agents/` that take precedence.

| Agent | Model | Purpose |
|---|---|---|
| `lewis` | opus | Critical reviewer for PRDs, hypotheses, and strategy docs. Surfaces blind spots, weak assumptions, and risks using 🔴/🟡/🔵 severity ratings. |
| `copywriter` | sonnet | Professional editor for PM writing. Polishes PRDs, Slack posts, emails, and release notes. Returns clean output only. |
| `kit-knowledge-curator` | sonnet | Kit-specific researcher. Searches dev docs MCP, help.kit.com, kit.com, Linear, and internal docs for verified Kit feature state. Used by `/prd` and `/competitor` for the internal research agent — never guesses or speculates. |
| `coder` | sonnet | Kit API specialist. Executes API requests via curl, handles OAuth token refresh, parses responses, and checks endpoint docs via kit-docs MCP before every call. Used by `/api`. |

`lewis`, `copywriter`, and `kit-knowledge-curator` are aware of the bundled style guides and apply them when reviewing, editing, or producing documents. Running `/setup` creates personalised versions of `lewis` and `copywriter` in `.claude/agents/`. If you already have any of these agents in your workspace, your version takes precedence over the plugin's.

---

## Workspace structure

The plugin creates required directories automatically. The optional `my-features/` directory is used by `/prd` and `/shipped` for additional internal context:

```
your-workspace/
├── .claude/
│   ├── agents/          # Personalised agent overrides (written by /setup)
│   ├── .gitignore       # Auto-created to protect api.env and OAuth certs
│   └── pm-skills/
│       ├── config.md              # Your preferences (written by /setup)
│       ├── pricing-packaging.md   # Plan principles reference (written by /setup)
│       ├── api.env                # Kit API credentials — API key + OAuth tokens (gitignored)
│       ├── kit-oauth.js           # OAuth PKCE callback server (generated by /api on first OAuth setup)
│       └── certs/                 # Self-signed cert for local HTTPS OAuth callback (gitignored)
├── prds/                # PRD markdown files
├── shipped-notes/       # Release notes output
├── kb-briefings/        # KB briefing output (created by /kb)
├── weekly-updates/      # Weekly Lattice check-in drafts
└── my-features/         # (Optional) Feature area docs for internal research context
```

---

## References

Style guides and templates are bundled in `references/` for human reading and for runtime use. Running `/setup` installs concise runtime versions to `.claude/pm-skills/communication-styles/` in your workspace — commands read from these files when drafting.

### Communication styles (`references/communication-styles/`)

| File | Used by | Contents |
|---|---|---|
| `style-prd.md` | `/prd` | PRD voice, tone, structure, and common mistakes |
| `prd-template.md` | `/prd` | Full PRD template including Pricing & Packaging section |
| `style-release-notes.md` | `/shipped` | Release notes format for internal Slack and external changelog |
| `style-ticket.md` | `/ticket` | Feature, bug, and spike ticket templates with acceptance criteria guidance |
| `style-competitor.md` | `/competitor` | Full analysis and quick snapshot formats with writing principles |
| `style-weekly-update.md` | `/weekly` | Weekly Lattice check-in structure, voice, and word choice |

### Other references

| File | Contents |
|---|---|
| `references/pricing-packaging.md` | Pricing & Packaging philosophy — background questions, 2×2 assessment, Free/Creator/Creator Pro plan principles, competitor packaging guidance |
| `references/communication-styles/style-kb.md` | KB briefing templates and writing guidelines for new features and feature updates |

---

## Local development

To load the plugin from a local directory without installing:

```bash
claude --plugin-dir ~/path/to/kit-pm-skills/plugins/kit-pm-skills
```

Note: when loaded this way, commands are still namespaced (e.g. `/kit-pm-skills:prd`).
