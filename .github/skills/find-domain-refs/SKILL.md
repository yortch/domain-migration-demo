---
name: find-domain-refs
description: Scans the repository for all references to legacy domain values (old.com, legacy_admin, etc.) and returns a structured list of findings grouped by file, category, and impact level. Use this skill at the start of any domain migration workflow.
parameters:
  - name: root_path
    description: The root directory or project subfolder to scan. Defaults to the entire repository.
    required: false
  - name: include_docs
    description: Whether to include markdown and documentation files in the scan. Defaults to true.
    required: false
  - name: impact_filter
    description: Limit results to a specific impact level — "High", "Medium", or "Low". Omit to return all.
    required: false
---

# Skill: Find Domain References

You are performing a targeted discovery scan to locate all legacy domain references that must be migrated.

## Targets

Scan for every occurrence of these legacy values:

| Pattern | Category | Impact |
|---|---|---|
| `old.com` (bare domain) | Domain | High |
| `api.old.com` | API Endpoints | High |
| `auth.old.com` | Auth / OAuth | High |
| `webhook.old.com` | Webhooks | High |
| `db.old.com` | Database | High |
| `cdn.old.com` | CDN | Medium |
| `@old.com` (email suffix) | Email | Medium |
| `legacy_admin` | Database Users | High |
| `legacy_support` | Database Users | Medium |
| `legacy_tech` | Database Users | Medium |
| `old.com.crt` / `old.com.key` | SSL | High |

## Scope

Search across all of these file types:

- **Source code**: `.js`, `.ts`, `.java`, `.py`, `.php`
- **Configuration**: `.json`, `.yml`, `.yaml`, `.env`, `.env.template`
- **Database**: `.sql`
- **Documentation**: `.md`, `.txt` (if `include_docs` is true)
- **Scripts**: `.sh`

Skip: `node_modules/`, `.git/`, `dist/`, `build/`, `target/`, `__pycache__/`

## Process

1. Walk every file in scope
2. For each file, search for each target pattern
3. Record: file path, line number, matched value, full line context
4. If the same pattern appears multiple times in one file, record each line separately
5. Assign an impact level (High / Medium / Low) per the table above
6. Apply `impact_filter` if provided

## Output Format

Return results as a structured JSON object:

```json
{
  "skill": "find-domain-refs",
  "summary": {
    "total_references": 0,
    "files_affected": 0,
    "high_impact": 0,
    "medium_impact": 0,
    "low_impact": 0
  },
  "findings": [
    {
      "id": "D001",
      "category": "API Endpoints",
      "file": "projects/ecommerce-web/app.js",
      "line": 12,
      "current_value": "https://api.old.com/v1",
      "impact": "High",
      "context": "const API_BASE = 'https://api.old.com/v1';"
    }
  ]
}
```

## Notes

- A file may produce multiple findings — list each one
- References inside comments still need updating; mark them as `Low` impact if they're comment-only
- Connection strings containing `legacy_admin` are `High` impact even if they appear in a config comment
- Pass this output directly to the `analyze-impact` skill for the next pipeline stage
