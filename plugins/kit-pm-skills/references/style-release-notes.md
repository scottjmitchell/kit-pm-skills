# Communication Style: Release Notes

## Purpose

Release notes serve two distinct audiences with different needs:

**Internal (Slack #all-shipped):** Celebrate shipped work, build shared context across the team, and create a searchable record of what we've built. The audience includes engineers, designers, support, marketing, and leadership — many of whom aren't deeply technical. Focus on the "why it matters" and "what changes for users/business" rather than implementation details.

**External (Developer Changelog):** Inform third-party developers and technically-minded creators about new capabilities, API changes, and integration opportunities. The audience expects precision, brevity, and actionable detail. Focus on "what's new", "what it enables", and "how to use it".

Use internal release notes for every meaningful ship. Use external release notes for API changes, App Store/plugin updates, developer-facing features, and user-facing changes that affect integrations.

## Format Rules

### Internal Slack Post

**Structure:**
- Emoji + bold title (e.g., `*Custom Field Webhooks*`)
- **What shipped:** One sentence describing the feature/capability (not the task)
- **Problem solved:** Why this matters — user pain point or business opportunity
- **How it works:** Simple walkthrough in 2-4 bullets, no jargon
- **Expected impact:** User/business outcome
- **Dashboard/links:** Mixpanel links, Linear epics, or relevant docs

**Length:**
- Keep it scannable — 4-6 short paragraphs or bullet sections max
- Each section should be 1-3 sentences or 2-4 bullets

**Voice:**
- Celebratory but grounded — acknowledge the effort, focus on the outcome
- Accessible to non-technical readers — if you mention a technical term, immediately clarify what it means for users
- Use bold for key terms (feature names, product areas, important concepts)
- Active voice, present tense ("This lets developers..." not "This will let developers...")

**Slack mrkdwn format:**
- `*bold*` (single asterisks), not `**bold**`
- `_italic_` (underscores), not `*italic*`
- Bullet characters, not dashes
- Backticks for inline code
- `<url|link text>` for links, not `[text](url)`

### External Developer Release Note

**Structure:**
- No headings or sections — just a tight, scannable paragraph or bullet list
- Lead with what's new
- Follow with what it enables
- Include technical precision: endpoint URLs, HTTP methods, OAuth requirements, parameter names
- End with a link to full documentation

**Length:**
- Extremely concise — 1 short paragraph or 3-5 bullets max
- Think changelog entry, not blog post

**Voice:**
- Professional and technically precise
- Benefit-focused but no marketing fluff
- Developer-friendly — assume technical fluency, explain "why" only if it's not obvious

---

## Voice & Tone

### Internal Audience
- **Inclusive and accessible:** Assume non-technical readers. Translate technical terms into user benefits.
- **Celebratory but not over the top:** Acknowledge the effort, highlight the outcome, stay grounded.
- **Team-focused:** Use "we" and celebrate cross-functional collaboration where relevant.

### External Audience
- **Technically precise:** Use correct API terminology, parameter names, and response formats.
- **Benefit-focused but concise:** Lead with capability, not marketing spin.
- **Helpful and professional:** Assume the reader is competent but may need context on how this fits into their workflow.

---

## Word Choice

### Internal (include)
- "now available", "lets you", "makes it possible to", "shipped today"
- "for developers who", "for creators using", "for teams that need"
- Bold key terms: feature names, product areas, important concepts
- Phrases like "in real-time", "without manual work", "automatically syncs"

### Internal (avoid)
- Jargon without clarification: "dispatcher", "job queue", "PKCE flow" (unless immediately explained)
- Implementation details: "refactored the webhook service", "migrated to new schema"
- Hedging: "should allow", "we think this will", "potentially enables"

### External (include)
- Precise API terminology: endpoint paths, HTTP methods, OAuth requirements, webhook event names
- Action-oriented language: "call this endpoint", "subscribe to", "listen for"
- Technical benefits: "reduces API calls", "enables real-time sync", "supports pagination"

### External (avoid)
- Marketing fluff: "game-changing", "revolutionary", "powerful new capabilities"
- Vague descriptions: "improved webhooks", "better API support"
- Non-technical explanations — assume fluency

---

## Common Mistakes

### Internal
- Being too technical ("Refactored webhook dispatcher" — say "Custom fields now trigger webhooks")
- Forgetting the "why" — don't just say what shipped, say why it matters
- No metrics or dashboards — include Mixpanel links where relevant
- Treating it like a task update ("Finished webhook implementation") vs. a capability announcement ("Custom field webhooks are now live")

### External
- Being too vague ("We improved webhooks" vs. listing the specific new webhook events)
- Missing API details (HTTP method, endpoint path, OAuth requirements)
- Too much marketing language — developers want facts, not hype
- Forgetting the docs link

---

## Examples

### Example 1 — API/Platform Feature

**Input:** Shipped custom field webhooks and bulk update endpoint. 3 webhook events (field_created, field_deleted, field_value_updated). Bulk update via POST /v4/bulk/custom_fields/subscribers (OAuth only). Webhooks fire on both API and UI actions.

**Internal Slack Post:**

*Custom Field Webhooks*

*What shipped:* Webhooks now fire for custom field events, and we've added a bulk update endpoint for custom field values.

*Problem solved:* Developers building integrations needed a way to stay in sync when custom fields change — whether through the Kit UI or another integration. Without webhooks, they had to poll the API repeatedly or risk missing updates.

*How it works:*
- Three new webhook events: `field_created`, `field_deleted`, and `field_value_updated`
- Webhooks fire for both API actions _and_ UI actions (e.g., when a creator edits a field in Kit)
- Bulk updates via `POST /v4/bulk/custom_fields/subscribers` (OAuth-only endpoint) — update field values for up to 1,000 subscribers in a single request

*Expected impact:* Developers can now build real-time sync workflows and bulk-update field values without making hundreds of individual API calls. This unblocks several App Store partners who've been waiting for this capability.

*Links:*
- Mixpanel: Custom Field Webhook Events Dashboard
- Docs: developers.kit.com/webhooks/custom-fields

**External Developer Release Note:**

We've added three new webhook events for custom fields: `field_created`, `field_deleted`, and `field_value_updated`. These events fire when custom fields are created, deleted, or updated — whether through the Kit UI or via API. This lets you build real-time sync workflows without polling.

We've also shipped a bulk update endpoint: `POST /v4/bulk/custom_fields/subscribers` (OAuth-only). You can now update custom field values for up to 1,000 subscribers in a single request.

Full details: developers.kit.com/webhooks/custom-fields

### Example 2 — User-Facing Feature

**Input:** Shipped free plan app access. Shopify, WordPress, WooCommerce, WPForms, MemberMouse now installable on free plans with API-only access. Plugins still gated to paid plans. App directory now shows "Available on all plans" / "Available on paid plans only" sections. Upgrade modals for plugin features.

**Internal Slack Post:**

*App Store Now Available on Free Plans*

*What shipped:* Creators on free plans can now install and use select apps from the Kit App Store — starting with Shopify, WordPress, WooCommerce, WPForms, and MemberMouse.

*Problem solved:* Free plan creators couldn't access _any_ apps, even API-only integrations that don't require Visual Automations or advanced features. This blocked onboarding for creators who wanted to connect their store or website before upgrading. Now they can start sending, see the value of Kit, and upgrade when they need plugins or advanced automation.

*How it works:*
- Apps with API-only functionality (Shopify, WordPress, WooCommerce, WPForms, MemberMouse) are now installable on free plans
- Plugins (content blocks, media sources, VA action nodes) remain gated to paid plans
- App directory now shows two sections: *Available on all plans* and *Available on paid plans only*
- Upgrade modals guide free plan users when they try to access plugin features

*Expected impact:* Increased free-to-paid conversion as creators can now test integrations before upgrading. Reduced support volume and aligned with our PLG growth strategy.

*Links:*
- Mixpanel: App Installs by Plan Dashboard
- Linear: Free Plan App Access project

**External Developer Release Note:**

The Kit App Store is now available to creators on free plans. Apps that rely solely on API access (Shopify, WordPress, WooCommerce, WPForms, MemberMouse) can now be installed on free accounts. Plugins — including content blocks, media sources, and Visual Automation action nodes — remain available on paid plans only.

If you're building an app that uses only API endpoints (no plugins), your app will automatically appear in the "Available on all plans" section of the App Directory. Creators on free plans will see upgrade prompts if they attempt to access plugin features.

Learn more: developers.kit.com/app-store/plan-access
