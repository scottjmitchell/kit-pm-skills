# kit-pm-skills — Moved

This plugin has moved to the shared Kit org repo:

**[Kit/claude-code](https://github.com/Kit/claude-code/tree/main/plugins/kit-pm-skills)**

This repo is no longer maintained. New features, bug fixes, and PRs should go to `Kit/claude-code`.

---

## Migrate your installation

Because this repo was not transferred, GitHub won't redirect git operations — your local install will keep pulling from here and won't receive updates. Run the following to migrate:

```bash
rm -rf ~/.claude/plugins/marketplaces/kit-pm-skills
claude plugin marketplace add Kit/claude-code
claude plugin install kit-pm-skills
```

Then restart Claude Code and run `/kit-pm-skills:setup` to verify your config is intact — your existing `.claude/pm-skills/config.md` is untouched, so setup will just confirm your settings rather than asking everything from scratch.
