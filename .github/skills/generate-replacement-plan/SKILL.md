---
name: generate-replacement-plan
description: Takes the discovery report and analysis report and produces a fully ordered, file-by-file migration plan with exact substitutions, a preflight checklist, and per-group rollback instructions. This is the final planning skill before the Migration Agent executes changes.
parameters:
  - name: discovery_report
    description: The JSON findings object from the find-domain-refs skill.
    required: true
  - name: analysis_report
    description: The JSON analysis object from the analyze-impact skill.
    required: true
  - name: include_sql_scripts
    description: Whether to include ready-to-run SQL migration scripts for database changes. Defaults to true.
    required: false
---

# Skill: Generate Replacement Plan

You are generating a complete, executable migration plan from discovery and analysis data.

## Input

- `discovery_report` — findings from `find-domain-refs`
- `analysis_report` — grouped, risk-ordered analysis from `analyze-impact`

## Substitution Table

Apply these exact replacements. More-specific patterns take precedence over generic ones:

| Find (exact) | Replace With |
|---|---|
| `api.old.com` | `api.xyz.com` |
| `auth.old.com` | `auth.xyz.com` |
| `webhook.old.com` | `webhook.xyz.com` |
| `db.old.com` | `db.xyz.com` |
| `cdn.old.com` | `cdn.xyz.com` |
| `old.com` | `xyz.com` |
| `@old.com` | `@xyz.com` |
| `legacy_admin` | `new_admin` |
| `legacy_support` | `new_support` |
| `legacy_tech` | `new_tech` |
| `/etc/ssl/certs/old.com.crt` | `/etc/ssl/certs/xyz.com.crt` |
| `/etc/ssl/private/old.com.key` | `/etc/ssl/private/xyz.com.key` |

## Plan Structure

For each group in `analysis_report.dependency_order` (in order):

### Per-Group

1. List the group name, risk level, and `execute_after` dependencies
2. For each file in the group, list:
   - File path
   - Line numbers to change
   - Exact substitutions to apply
   - Whether external action is required before or after this file
3. If `include_sql_scripts` is true and the group is G001 (Database), emit ready-to-run SQL

### SQL Migration Scripts (G001)

```sql
-- Phase 1: Update system_configuration
UPDATE system_configuration
SET config_value = REPLACE(config_value, 'old.com', 'xyz.com')
WHERE config_value LIKE '%old.com%';

UPDATE system_configuration
SET config_value = REPLACE(config_value, 'legacy_admin', 'new_admin')
WHERE config_value LIKE '%legacy_admin%';

-- Phase 2: Update admin_users emails
UPDATE admin_users
SET email = REPLACE(email, '@old.com', '@xyz.com')
WHERE email LIKE '%@old.com';

-- Phase 3: Update API integration URLs
UPDATE api_integrations
SET endpoint_url = REPLACE(endpoint_url, 'old.com', 'xyz.com'),
    webhook_url  = REPLACE(webhook_url,  'old.com', 'xyz.com')
WHERE endpoint_url LIKE '%old.com%'
   OR webhook_url  LIKE '%old.com%';

-- Verification: should return 0
SELECT COUNT(*) AS remaining_refs FROM (
  SELECT config_value AS val FROM system_configuration WHERE config_value LIKE '%old.com%'
  UNION ALL
  SELECT email        AS val FROM admin_users           WHERE email        LIKE '%@old.com'
  UNION ALL
  SELECT endpoint_url AS val FROM api_integrations      WHERE endpoint_url LIKE '%old.com%'
);
```

## Output Format

```json
{
  "skill": "generate-replacement-plan",
  "generated_at": "<ISO8601 timestamp>",
  "summary": {
    "total_steps": 0,
    "total_files": 0,
    "total_substitutions": 0,
    "external_actions": 0,
    "warnings": []
  },
  "preflight_checklist": [
    "[ ] Full repository backup completed",
    "[ ] Database backup completed",
    "[ ] Maintenance window scheduled and team notified",
    "[ ] New xyz.com DNS entries are live and resolving",
    "[ ] New SSL certificate for xyz.com is ready to deploy",
    "[ ] OAuth provider updated with new redirect URIs",
    "[ ] Rollback procedure reviewed by at least one engineer"
  ],
  "execution_steps": [
    {
      "step": 1,
      "group_id": "G001",
      "name": "Database Users & Connections",
      "risk": "Critical",
      "execute_after": [],
      "files": [
        {
          "file": "database/schema/schema.sql",
          "lines_to_change": [12, 34],
          "substitutions": [
            { "find": "legacy_admin", "replace": "new_admin" }
          ],
          "requires_external_action": false
        }
      ],
      "sql_scripts": "...included when include_sql_scripts=true...",
      "rollback": "Restore database from backup taken in preflight"
    }
  ],
  "post_migration_checklist": [
    "[ ] Run find-domain-refs skill — verify zero legacy references remain",
    "[ ] Smoke-test all API endpoints at api.xyz.com",
    "[ ] Verify OAuth login flow completes end-to-end",
    "[ ] Confirm database connectivity with new_admin credentials",
    "[ ] Check email delivery from new @xyz.com addresses",
    "[ ] Validate SSL certificate is trusted and not expired",
    "[ ] Review application logs for any residual old.com errors",
    "[ ] Disable (do not delete) legacy_admin database user"
  ]
}
```

## Safety Rules

- List every change explicitly — no "update all occurrences" shorthand
- Flag any substitution that could break OAuth, SSL, or DNS with `requires_external_action: true`
- Never combine changes from different groups into a single step
- The Migration Agent should not proceed to the next step until the current one is complete and verified
