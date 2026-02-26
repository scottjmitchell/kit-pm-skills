---
description: Query or modify Kit account data via the API. Use this whenever you want to look something up in Kit, pull subscriber data, check stats, create or update records, test an endpoint, or interact with the Kit API in any way — even if you don't know the exact endpoint needed.
argument-hint: <what you want to do, e.g. "list my subscribers">
allowed-tools: [Task]
---

# Kit API Request

Execute a Kit API request: $ARGUMENTS

Delegate this entire task to a **coder** agent using the Task tool (`subagent_type: "coder"`). Pass the full prompt below, substituting `$ARGUMENTS` with the user's request. Do not perform any steps yourself.

---

```
Execute a Kit API request. The user wants to: $ARGUMENTS

## Step 1: Load credentials

Read `.claude/pm-skills/api.env` and parse:
- `KIT_API_KEY`
- `KIT_CLIENT_ID`
- `KIT_OAUTH_TOKEN`
- `KIT_OAUTH_REFRESH_TOKEN`

If the file is missing or `KIT_API_KEY` is empty → run **First-Time Setup** before continuing.

---

## First-Time Setup

Only run this section if credentials are missing.

### Welcome the user

Tell the user:

```
👋 Welcome to /api — let's get you set up first.

To make Kit API calls you'll need:
  - An API key (covers most GET/POST/PUT/DELETE endpoints)
  - OAuth tokens (optional — needed for bulk endpoints like /bulk/subscribers)
```

### Ask what to configure

Use `AskUserQuestion`:

"What do you want to set up?"
- `API key only — covers most endpoints`
- `API key + OAuth — adds bulk endpoint access (/bulk/subscribers, bulk tagging, purchases, etc.)`

**Wait for answer before continuing.**

---

### API key setup

Open the settings page:
```bash
open "https://app.kit.com/account_settings/developer_settings" 2>/dev/null || xdg-open "https://app.kit.com/account_settings/developer_settings" 2>/dev/null || true
```

Tell the user:
```
Get your v4 API key:
1. Scroll to "API Keys" in the page that just opened
2. Copy your v4 key
```

Use `AskUserQuestion` to ask: "Paste your Kit API key:"

Save to `.claude/pm-skills/api.env`:
```
KIT_API_KEY=<their key>
```

---

### OAuth setup (only if "API key + OAuth" was selected)

Open the settings page:
```bash
open "https://app.kit.com/account_settings/developer_settings" 2>/dev/null || xdg-open "https://app.kit.com/account_settings/developer_settings" 2>/dev/null || true
```

Tell the user:
```
🔐 OAuth Setup

Kit uses OAuth PKCE for bulk endpoints. You'll need to create a Kit App.

Steps (in the page that just opened):
1. Click "Add new app"
2. Name it anything (e.g. "Claude API Helper")
3. Set redirect URI to: https://localhost:3333/callback
4. Toggle OFF "Secure Application" — this enables PKCE (no client secret needed)
5. Save, then copy your Client ID
```

Use `AskUserQuestion` to ask: "What is your Kit Client ID?"

Run:
```bash
mkdir -p .claude/pm-skills/certs
```

Then write the following to `.claude/pm-skills/kit-oauth.js` (verbatim):

```javascript
#!/usr/bin/env node

const https = require('https');
const crypto = require('crypto');
const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

const PORT = 3333;
const REDIRECT_URI = `https://localhost:${PORT}/callback`;
const ENV_PATH = path.join(process.cwd(), '.claude', 'pm-skills', 'api.env');
const CERT_DIR = path.join(process.cwd(), '.claude', 'pm-skills', 'certs');

function loadEnv() {
  const env = {};
  if (fs.existsSync(ENV_PATH)) {
    const content = fs.readFileSync(ENV_PATH, 'utf-8');
    content.split('\n').forEach(line => {
      const match = line.match(/^([^#=]+)=(.*)$/);
      if (match) env[match[1].trim()] = match[2].trim();
    });
  }
  return env;
}

function saveEnv(env) {
  const lines = Object.entries(env).map(([k, v]) => `${k}=${v}`);
  fs.writeFileSync(ENV_PATH, lines.join('\n') + '\n');
}

function ensureCerts() {
  const keyPath = path.join(CERT_DIR, 'key.pem');
  const certPath = path.join(CERT_DIR, 'cert.pem');
  if (fs.existsSync(keyPath) && fs.existsSync(certPath)) {
    return { key: fs.readFileSync(keyPath), cert: fs.readFileSync(certPath) };
  }
  console.log('Generating self-signed certificate for local HTTPS...');
  if (!fs.existsSync(CERT_DIR)) fs.mkdirSync(CERT_DIR, { recursive: true });
  execSync(
    `openssl req -x509 -newkey rsa:2048 -keyout "${keyPath}" -out "${certPath}" -days 365 -nodes -subj "/CN=localhost"`,
    { stdio: 'pipe' }
  );
  console.log('Certificate generated.\n');
  return { key: fs.readFileSync(keyPath), cert: fs.readFileSync(certPath) };
}

function generateCodeVerifier() { return crypto.randomBytes(32).toString('base64url'); }
function generateCodeChallenge(verifier) { return crypto.createHash('sha256').update(verifier).digest('base64url'); }
function openBrowser(url) {
  const cmd = process.platform === 'darwin' ? 'open' : process.platform === 'win32' ? 'start' : 'xdg-open';
  execSync(`${cmd} "${url}"`);
}

async function main() {
  const env = loadEnv();
  if (!env.KIT_CLIENT_ID) {
    console.error('\n❌ KIT_CLIENT_ID not found in', ENV_PATH);
    process.exit(1);
  }

  const codeVerifier = generateCodeVerifier();
  const codeChallenge = generateCodeChallenge(codeVerifier);

  const authUrl = new URL('https://app.kit.com/oauth/authorize');
  authUrl.searchParams.set('client_id', env.KIT_CLIENT_ID);
  authUrl.searchParams.set('redirect_uri', REDIRECT_URI);
  authUrl.searchParams.set('response_type', 'code');
  authUrl.searchParams.set('code_challenge', codeChallenge);
  authUrl.searchParams.set('code_challenge_method', 'S256');

  const certs = ensureCerts();

  const server = https.createServer(certs, async (req, res) => {
    const url = new URL(req.url, `https://localhost:${PORT}`);
    if (url.pathname !== '/callback') { res.writeHead(404); res.end('Not found'); return; }

    const code = url.searchParams.get('code');
    const error = url.searchParams.get('error');

    if (error) {
      res.writeHead(400, { 'Content-Type': 'text/html' });
      res.end(`<h1>❌ Error: ${error}</h1><p>${url.searchParams.get('error_description') || ''}</p>`);
      server.close(); process.exit(1);
    }

    if (code) {
      console.log('\n✅ Authorization code received — exchanging for tokens...');
      try {
        const tokenResponse = await fetch('https://api.kit.com/v4/oauth/token', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ client_id: env.KIT_CLIENT_ID, grant_type: 'authorization_code', code, redirect_uri: REDIRECT_URI, code_verifier: codeVerifier })
        });
        const tokens = await tokenResponse.json();
        if (tokens.access_token) {
          env.KIT_OAUTH_TOKEN = tokens.access_token;
          if (tokens.refresh_token) env.KIT_OAUTH_REFRESH_TOKEN = tokens.refresh_token;
          saveEnv(env);
          console.log('✅ Tokens saved to', ENV_PATH);
          res.writeHead(200, { 'Content-Type': 'text/html' });
          res.end('<html><body style="font-family:system-ui;padding:40px;text-align:center"><h1>✅ OAuth Complete!</h1><p>Tokens saved. You can close this window.</p></body></html>');
        } else {
          console.error('\n❌ Token exchange failed:', tokens);
          res.writeHead(400, { 'Content-Type': 'text/html' });
          res.end(`<h1>❌ Token exchange failed</h1><pre>${JSON.stringify(tokens, null, 2)}</pre>`);
        }
      } catch (err) {
        console.error('\n❌ Error:', err.message);
        res.writeHead(500, { 'Content-Type': 'text/html' });
        res.end(`<h1>❌ Error</h1><pre>${err.message}</pre>`);
      }
      setTimeout(() => { server.close(); process.exit(0); }, 1000);
    }
  });

  server.listen(PORT, () => {
    console.log('\n🔐 Kit OAuth PKCE Flow');
    console.log(`\nHTTPS callback server running on https://localhost:${PORT}`);
    console.log('\n⚠️  Your browser will show a certificate warning — click "Advanced" → "Proceed to localhost".\n');
    openBrowser(authUrl.toString());
  });
}

main().catch(console.error);
```

Update `.claude/pm-skills/api.env` to add `KIT_CLIENT_ID=<their client id>`.

Run the OAuth flow (3-minute timeout):
```bash
node .claude/pm-skills/kit-oauth.js
```

If the script errors, tell the user to check:
- Redirect URI is exactly `https://localhost:3333/callback`
- "Secure Application" is toggled OFF
- Client ID is correct

---

### Protect credentials

Check if `.claude/.gitignore` exists. If it does, check if `pm-skills/api.env` is covered. If not, append:
```
pm-skills/api.env
pm-skills/certs/
pm-skills/kit-oauth.js
```
If `.claude/.gitignore` doesn't exist, create it with those three lines.

---

### Setup complete

Print:
```
✅ Kit API setup complete

  🔑 API key: saved
  [🔐 OAuth: configured — bulk endpoints available]

You can now use /api for any Kit API operation.
```

Re-read `.claude/pm-skills/api.env` to pick up the freshly saved credentials and continue to Step 2.

---

## Step 2: Ensure kit-docs MCP is configured

Read `.mcp.json` if it exists. Parse as JSON (default to `{"mcpServers": {}}` if not found).

If no key named `kit-docs` exists in `mcpServers`, add it:
```json
"kit-docs": {
  "type": "http",
  "url": "https://developers.kit.com/mcp"
}
```

Write the updated JSON back to `.mcp.json`.

If you added kit-docs, note: "ℹ️ Added kit-docs MCP to `.mcp.json` — restart Claude Code to activate it for future sessions."

---

## Step 3: Find the right endpoint

Use the kit-docs MCP tool (`SearchKitDeveloperDocumentation`) to find the correct endpoint, parameters, and response format for what the user wants to do.

If kit-docs is unavailable, fall back to:
- Base URL: `https://api.kit.com/v4/`
- API Key header: `X-Kit-Api-Key: <key>`
- OAuth Bearer header: `Authorization: Bearer <token>`

---

## Step 4: Determine auth type

- **API Key**: most GET, POST, PUT, DELETE endpoints
- **OAuth required**: `/v4/bulk/*` endpoints, purchases endpoints
- If OAuth is needed but `KIT_OAUTH_TOKEN` is missing, tell the user to run `/api` again and select "API key + OAuth" during setup

---

## Step 5: Handle token refresh

If a request returns 401 Unauthorized and a refresh token is available, refresh automatically:

```bash
curl -s -X POST 'https://api.kit.com/v4/oauth/token' \
  -H 'Content-Type: application/json' \
  -d "{\"client_id\":\"$KIT_CLIENT_ID\",\"grant_type\":\"refresh_token\",\"refresh_token\":\"$KIT_OAUTH_REFRESH_TOKEN\"}"
```

Update `.claude/pm-skills/api.env` with the new `access_token` (as `KIT_OAUTH_TOKEN`) and `refresh_token`. Retry the original request.

---

## Step 6: Permission check

- **Read operations** (GET): execute directly
- **Write operations** (POST, PUT, DELETE): always show the user what will be sent before executing:
  - Endpoint and method
  - Full request body (formatted)
  - What this action will do in plain English

Wait for explicit user approval before proceeding.

---

## Step 7: Execute and present

Use curl via Bash. Format the JSON response clearly and highlight the key information.

## Common endpoints

| Action | Endpoint | Method | Auth |
|--------|----------|--------|------|
| Account info | `/v4/account` | GET | API Key |
| List subscribers | `/v4/subscribers` | GET | API Key |
| Get subscriber | `/v4/subscribers/:id` | GET | API Key |
| Create subscriber | `/v4/subscribers` | POST | API Key |
| List tags | `/v4/tags` | GET | API Key |
| Create tag | `/v4/tags` | POST | API Key |
| List broadcasts | `/v4/broadcasts` | GET | API Key |
| List sequences | `/v4/sequences` | GET | API Key |
| List forms | `/v4/forms` | GET | API Key |
| List purchases | `/v4/purchases` | GET | OAuth |
| Create purchase | `/v4/purchases` | POST | OAuth |
| Bulk create subscribers | `/v4/bulk/subscribers` | POST | OAuth |
| Bulk tag subscribers | `/v4/bulk/tags/subscribers` | POST | OAuth |

## Rate limits
- API Key: 120 requests/60 seconds
- OAuth: 600 requests/60 seconds
```
