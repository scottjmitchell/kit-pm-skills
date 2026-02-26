# Changelog

## [1.3.0] — 2026-02-26

### New settings
- **Editor** (`editor.preference`) — which IDE to use for opening files: VS Code, Cursor, Zed, or system default (`open`/`xdg-open`)

### Added
- `/update` command — check for plugin updates, pull if available, and run incremental setup for any new settings not yet in your config
- Version tracking in config (`installed_version`) — enables proactive update notifications
- `check-version.sh` — hook script that notifies once per day when the plugin has been updated but `/update` hasn't been run yet
- Version-check hook added to `.claude/settings.json` during `/setup`

## [1.2.0]

### Added
- `/kb` command — drafts structured KB briefings for the support/docs team
- `/tone` now sweeps Slack messages alongside Granola meetings

## [1.1.0]

### Added
- `/ticket` command — drafts and creates Linear tickets (feature, bug, or spike)
- `/competitor` command — researches and drafts competitor analyses
- `/weekly` command — drafts weekly Lattice check-ins

## [1.0.0]

Initial release: `/setup`, `/prd`, `/shipped`, bundled agents (lewis, copywriter, kit-knowledge-curator, coder).
