---
name: analyze-impact
description: Takes a discovery report from the find-domain-refs skill and produces a risk-ordered migration plan — grouping findings by category, identifying dependencies between changes, and flagging items that require external coordination (OAuth, SSL, DNS). Use this skill after discovery and before generating the replacement plan.
parameters:
  - name: discovery_report
    description: The JSON findings object produced by the find-domain-refs skill.
    required: true
  - name: include_rollback
    description: Whether to include rollback notes for each change group. Defaults to true.
    required: false
---

# Skill: Analyze Migration Impact

You are analyzing domain migration findings to produce a risk-ordered, dependency-aware change plan.

## Input

A `discovery_report` JSON object from the `find-domain-refs` skill containing a `findings` array.

## Step 1 — Group Findings by Category

Organize all findings into these groups. A finding belongs to the first group whose criteria it matches:

| Group ID | Name | Match Criteria |
|---|---|---|
| G001 | Database Users & Connections | category = `Database Users` or `Database` |
| G002 | SSL Certificates | category = `SSL` |
| G003 | Shared Configuration | file path starts with `configs/` |
| G004 | Auth / OAuth Endpoints | category = `Auth / OAuth` |
| G005 | API Endpoints & Webhooks | category = `API Endpoints` or `Webhooks` |
| G006 | Email & SMTP | category = `Email` |
| G007 | General Domain References | category = `Domain` or `CDN` |
| G008 | Documentation | file ends with `.md` or `.txt` |

## Step 2 — Assign Risk Levels

| Group | Risk | Reason |
|---|---|---|
| G001 | Critical | Services fail auth if DB user renamed without updating all connection strings atomically |
| G002 | Critical | HTTPS breaks if cert domain doesn't match hostname |
| G003 | High | All services read shared config; must update before service restarts |
| G004 | Critical | OAuth redirect URIs must be updated in code AND provider dashboard simultaneously |
| G005 | High | Wrong API/webhook URLs cause silent failures |
| G006 | Medium | Bounced email is visible but not an outage |
| G007 | Medium | Catch-all; verify no runtime impact case by case |
| G008 | Low | No runtime impact; cosmetic only |

## Step 3 — Build Dependency Order

Apply this execution sequence. A group must not be executed until all its dependencies are done:

```
G001 (Database)  ──→  G003 (Shared Config)  ──→  G004 (Auth/OAuth)
                                             ──→  G005 (API/Webhooks)
                                             ──→  G006 (Email)
                                             ──→  G007 (General)
G002 (SSL)       ──→  (standalone, no dependents — schedule with G001)
                                                   G008 (Docs) runs last
```

## Step 4 — Flag External Actions

Mark any group that requires work outside the codebase:

- **G002** → Regenerate SSL certificate for `xyz.com`; deploy before switching DNS
- **G004** → Update OAuth redirect URIs in the identity provider dashboard
- DNS changes → Must be live before any service restart

## Output Format

```json
{
  "skill": "analyze-impact",
  "summary": {
    "total_findings": 0,
    "groups_identified": 0,
    "critical_groups": 0,
    "external_actions": 0
  },
  "dependency_order": ["G001", "G002", "G003", "G004", "G005", "G006", "G007", "G008"],
  "change_groups": [
    {
      "group_id": "G001",
      "name": "Database Users & Connections",
      "risk": "Critical",
      "finding_count": 0,
      "finding_ids": ["D045", "D046"],
      "execute_after": [],
      "notes": "Rename legacy_admin → new_admin; update all connection strings atomically",
      "external_action": null,
      "rollback_note": "Restore database backup if service connectivity breaks after rename"
    }
  ],
  "warnings": [
    "OAuth redirect URIs must be updated in code AND provider dashboard simultaneously"
  ],
  "external_actions_required": [
    "Regenerate SSL certificate for xyz.com",
    "Update OAuth redirect URIs in identity provider dashboard"
  ]
}
```

## Notes

- Groups with zero findings should still appear in the output with `finding_count: 0` so the full picture is visible
- If `include_rollback` is false, omit `rollback_note` from each group
- Pass this output along with the original discovery report to the `generate-replacement-plan` skill
