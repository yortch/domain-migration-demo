---
applyTo: "**/*.js,**/*.ts,**/*.java,**/*.py,**/*.php,**/*.json,**/*.yml,**/*.yaml,**/*.env,**/*.sql"
---

# Copilot Instructions: Migrate Codebase References

You are an expert at applying safe, precise domain migration changes across polyglot codebases.

## Migration Mappings

Apply these replacements **exactly** — do not paraphrase or infer alternate forms:

| Find | Replace With |
|---|---|
| `old.com` | `xyz.com` |
| `api.old.com` | `api.xyz.com` |
| `auth.old.com` | `auth.xyz.com` |
| `webhook.old.com` | `webhook.xyz.com` |
| `db.old.com` | `db.xyz.com` |
| `cdn.old.com` | `cdn.xyz.com` |
| `@old.com` | `@xyz.com` |
| `legacy_admin` | `new_admin` |
| `legacy_support` | `new_support` |
| `legacy_tech` | `new_tech` |
| `/etc/ssl/certs/old.com.crt` | `/etc/ssl/certs/xyz.com.crt` |
| `/etc/ssl/private/old.com.key` | `/etc/ssl/private/xyz.com.key` |

## File-Type Specific Rules

### JavaScript / TypeScript (`.js`, `.ts`)
- Update string literals, template literals, and comments
- Check `fetch()`, `axios`, `https.get()` calls
- Update CORS `origin` arrays
- Update `process.env` fallback defaults that contain `old.com`

### Java / Spring (`.java`, `.yml`, `.yaml`)
- Update `spring.datasource.url` in `application.yml`
- Update `@Value` annotation defaults
- Update `RestTemplate` / `WebClient` base URLs
- Update `allowedOrigins` in CORS config beans

### Python / Flask (`.py`, `.env`, `.env.template`)
- Update `SQLALCHEMY_DATABASE_URI`
- Update `OAUTH_*` and `API_*` config variables
- Update `requests.get()` / `requests.post()` URL strings

### PHP (`.php`)
- Update `define()` constants
- Update connection strings in `mysqli_connect()` / `PDO`
- Update hardcoded URL strings in HTML output

### Configuration Files (`.json`, `.yml`, `.env`)
- Replace all string values containing `old.com`
- Preserve key names — only values change
- Keep structure and formatting identical

### SQL (`.sql`)
- Update `INSERT` values containing `old.com`
- Update `CREATE USER` statements
- Do NOT change table/column names

## Change Safety Rules

1. **Never** change key names, variable names, or identifiers — only string values
2. **Never** modify test fixtures or mock data unless they directly test the domain value
3. **Preserve** all existing comments; update any domain refs within them too
4. **One change per logical unit** — don't bundle unrelated edits
5. **Flag** any reference where the replacement could break functionality (e.g., OAuth redirect URIs) with a `# TODO: verify with team` comment

## After Each Change

Confirm:
- [ ] Value updated correctly
- [ ] No surrounding code broken
- [ ] File formatting preserved
- [ ] No accidental partial replacements (e.g., `xoldxyz.com` artifacts)
