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
| `/kit-pm-skills:prd <topic>` | Researches and drafts a new PRD, then runs a critical review |
| `/kit-pm-skills:prd <ticket ID>` | Fetches an existing Linear ticket and produces a refined PRD |
| `/kit-pm-skills:shipped <feature>` | Generates an internal Slack post and external developer release note |
| `/kit-pm-skills:api <request>` | Makes a Kit API request — sets up credentials on first use |

---

## Setup

`/setup` personalises the plugin for your workspace. Run it once after install, or re-run it any time to update your preferences.

### What it asks

1. **English preference** — British (the correct spelling) or American English
2. **Linear team** — which team PRDs should be created in. Options are fetched live from your Linear workspace (falls back to manual entry if Linear isn't connected yet)
3. **PRD label** — whether to apply a Squad label when creating PRDs in Linear. Squad label options are fetched live from the Linear `Squad` label group
4. **Issue or project** — whether approved PRDs are created as Linear issues (default) or projects
5. **Optional integrations** — Granola (tone of voice matching), kit-docs (developer doc search), and/or Kit API (credentials for `/api`)
6. **Feature areas** — the areas you own, used to focus research in `/prd` and `/shipped`

### What it creates

| File | Purpose |
|---|---|
| `.claude/pm-skills/config.md` | Stores your preferences (English, Linear team, label, issue vs project, feature areas) — read by `/prd` and `/shipped` at runtime |
| `.claude/pm-skills/api.env` | Kit API credentials — API key and OAuth tokens (gitignored automatically) |
| `.claude/agents/lewis.md` | Personalised critical reviewer with your feature context and English preference |
| `.claude/agents/copywriter.md` | Personalised writing editor with your English preference |
| `.mcp.json` | Configured MCP servers (Linear always; Granola, kit-docs, and Kit API if selected) |
| `prds/`, `shipped-notes/`, `.claude/state/` | Workspace directories |

### MCP authentication

Linear and Granola use OAuth. After setup, restart Claude Code — it will prompt you to authenticate in your browser on first use. kit-docs is public and requires no authentication.

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

## /prd

Drafts a new PRD or refines an existing Linear ticket.

### New PRD flow

1. Asks 2–4 clarifying questions, including:
   - **Pricing & Packaging depth** — full assessment (for significant new features) or abridged one-liner (for iterations)
2. Runs two parallel research agents:
   - **Internal context** — searches Linear, your `prds/` directory, and `my-features/` (if present), focused on your configured feature areas
   - **Competitive research** — surveys ActiveCampaign, Mailchimp, Beehiiv, Klaviyo, and other relevant competitors; includes which plan tiers each competitor gates the feature behind
3. Drafts the PRD using the bundled style guide and template, saved to `prds/`
4. Runs a **lewis** critical review to surface blind spots and risks
5. On approval, creates a Linear issue in your configured team with your configured Squad label

### Revision flow

Pass a Linear ticket ID (e.g. `/prd ECO-123`):

1. Fetches the full ticket and related issues from Linear
2. Drafts a refined PRD based on the ticket content and your instructions
3. Runs a **lewis** critical review
4. On approval, creates a Linear issue

### PRD style

PRDs follow the bundled style guide (`references/style-prd.md`): problem-first, British or American English per your preference, specific measurable goals, clear MVP scope, active voice.

Every PRD includes a **Pricing & Packaging** section — either a full assessment (background questions, 2×2 quadrant, plan recommendation with rationale, competitor packaging table) or an abridged version (one-line recommendation + brief rationale), depending on the depth you select at the start. Plan principles are drawn from `references/pricing-packaging.md`.

The **Launch Checklist** includes a DMF naming item that is auto-filled during drafting: recommended **Yes** for net new creator-facing features or significant overhauls, **No** for iterations.

---

## /shipped

Generates release notes for a shipped feature in two formats: an internal Slack post for `#all-shipped`, and a concise external developer changelog entry.

### Flow

1. Runs three parallel data-gathering agents:
   - **Linear context** — finds the shipped project or issue, collects all assignees to credit
   - **PRDs & docs** — searches `prds/`, `my-features/`, and kit-docs (if configured) for context
   - **Tone of voice** — fetches Granola meeting notes to match your natural writing style (skipped if Granola is not configured)
2. Checks for any missing information and asks if needed
3. Hands off to **copywriter** to produce both formats
4. Saves to `shipped-notes/YYYY-MM-DD-feature-name.md` and opens it

### Formats

**Internal Slack post** — celebrates the ship for the whole team. Includes what shipped, the problem it solved, how it works, expected impact, and tracking links. Written in Slack mrkdwn, ready to copy-paste.

**External developer release note** — tight and precise. One paragraph or a few bullets covering what's new, what it enables, and a link to docs. Written for third-party developers and technically-minded creators.

---

## Bundled agents

These agents are included in the plugin and available in your workspace after install. Running `/setup` creates personalised versions in `.claude/agents/` that take precedence.

| Agent | Model | Purpose |
|---|---|---|
| `lewis` | opus | Critical reviewer for PRDs, hypotheses, and strategy docs. Surfaces blind spots, weak assumptions, and risks using 🔴/🟡/🔵 severity ratings. |
| `copywriter` | sonnet | Professional editor for PM writing. Polishes PRDs, Slack posts, emails, and release notes. Returns clean output only. |
| `coder` | sonnet | Kit API specialist. Executes API requests via curl, handles OAuth token refresh, parses responses, and checks endpoint docs via kit-docs MCP before every call. Used by `/api`. |

`lewis` and `copywriter` are aware of the bundled style guides and apply them when reviewing or editing relevant document types. Running `/setup` creates personalised versions of `lewis` and `copywriter` in `.claude/agents/` — if you already have a `coder` agent in your workspace, that takes precedence over the plugin's version.

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
└── my-features/         # (Optional) Feature area docs for internal research context
```

---

## References

Style guides and templates are bundled in `references/` for human reading. The commands have the key rules inlined and don't depend on these files at runtime.

| File | Contents |
|---|---|
| `references/style-prd.md` | PRD voice, tone, structure, and common mistakes |
| `references/style-release-notes.md` | Release notes format for internal Slack and external changelog |
| `references/prd-template.md` | Blank PRD template |
| `references/pricing-packaging.md` | Pricing & Packaging philosophy — background questions, 2×2 assessment, Free/Creator/Creator Pro plan principles, competitor packaging guidance |

---

## Local development

To load the plugin from a local directory without installing:

```bash
claude --plugin-dir ~/path/to/kit-pm-skills/plugins/kit-pm-skills
```

Note: when loaded this way, commands are still namespaced (e.g. `/kit-pm-skills:prd`).
