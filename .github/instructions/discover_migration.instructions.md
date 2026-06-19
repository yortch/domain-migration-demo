---
applyTo: "**/*.js,**/*.ts,**/*.java,**/*.py,**/*.php,**/*.json,**/*.yml,**/*.yaml,**/*.env,**/*.sql,**/*.md"
---

# Copilot Instructions: Discover Migration Points

You are an expert at identifying domain migration targets across a multi-project codebase.

## Your Goal

Find every reference to the legacy domain and usernames that must be migrated:

| Legacy Value | Replacement |
|---|---|
| `old.com` (and all subdomains) | `xyz.com` |
| `legacy_admin` | `new_admin` |
| `legacy_support` | `new_support` |
| `legacy_tech` | `new_tech` |
| `*@old.com` (email addresses) | `*@xyz.com` |

## Search Patterns

### Domains & Subdomains
- `old.com`
- `api.old.com`
- `auth.old.com`
- `webhook.old.com`
- `db.old.com`
- `cdn.old.com`
- `*.old.com` (any subdomain)

### URLs
- `https://old.com`
- `http://old.com`
- `https://api.old.com/v1`
- `https://auth.old.com/oauth`

### Email Addresses
- `support@old.com`
- `admin@old.com`
- `*@old.com`

### Database / Infrastructure
- `legacy_admin`
- `legacy_support`
- `legacy_tech`
- `/etc/ssl/certs/old.com.crt`

## Discovery Process

1. Scan each file in the repository systematically
2. Record every match with file path, line number, and surrounding context
3. Flag files with multiple references
4. Note any references inside comments — they still need updating
5. Identify references that appear in connection strings or credential blocks as **Critical**

## Output Format

Return findings as structured JSON:

```json
{
  "summary": {
    "total_references": 0,
    "files_affected": 0,
    "critical_count": 0
  },
  "findings": [
    {
      "category": "API Endpoints | Config | Email | Database | SSL | Docs",
      "file": "relative/path/to/file",
      "line": 42,
      "current_value": "https://api.old.com/v1",
      "replacement_value": "https://api.xyz.com/v1",
      "impact": "High | Medium | Low",
      "notes": "Used in payment webhook — coordinate with payment-service team"
    }
  ]
}
```

## Impact Classification

- **High**: API endpoints, database connection strings, auth/OAuth URLs, webhook callbacks
- **Medium**: Email addresses, SMTP settings, non-auth configuration values
- **Low**: Code comments, documentation, historical log references

## After Each File

Always ask yourself: *"Where else in this codebase would a developer have put this same value?"*
