# Domain Migration Demo Repository

This repository is a hands-on demonstration of how to plan and execute a legacy domain migration across multiple applications, shared configuration, and SQL Server-backed data.

The simulated migration target is:
- domain values from old.com to xyz.com
- legacy user/account values such as legacy_admin to new_admin

## Repository Purpose

The repo is designed to show a realistic migration problem with cross-system dependencies, not a toy single-app replacement.

It demonstrates:
- how legacy values spread across different languages and frameworks
- why migration planning must include code, config, and database together
- how scripted discovery plus agent-guided analysis can reduce manual effort

## Legacy Projects: High-Level Overview

The environment contains four legacy-style applications plus shared infrastructure:

- ecommerce-web: Node.js service with API, webhook, and CDN references
- payment-service: Java/Spring service with external endpoint and integration settings
- admin-portal: Python/Flask app with environment-based configuration and email settings
- legacy-svn-app: PHP application representing older code patterns
- shared configs: common runtime and container orchestration files
- database schema: SQL Server schema and seed data carrying legacy domain/user values

For full technical details of each project and file, see [PROJECT_REFERENCE.md](PROJECT_REFERENCE.md).

## Demo Artifacts Overview

The demo uses three artifact layers:

1. Source and configuration artifacts
- legacy projects code under [projects](projects)
- environment and compose files under [configs/shared](configs/shared)
- SQL Server schema under [database/schema/schema.sql](database/schema/schema.sql)

2. Scripted discovery artifacts (created using GitHub Copilot)
- [scripts/discover_domains.sh](scripts/discover_domains.sh): broad scan and report generation
- [scripts/analyze_patterns.sh](scripts/analyze_patterns.sh): categorized pattern report
- [scripts/database_discovery.sh](scripts/database_discovery.sh): SQL discovery query bundle

3. GitHub Copilot context artifacts
- instructions under [.github/instructions](.github/instructions)
- specialist agents under [.github/agents](.github/agents)
- reusable skills under [.github/skills](.github/skills)
- script-generation prompts under [.github/prompts](.github/prompts)

## High-Level Demo Script

Use this sequence for a concise end-to-end story:

1. Frame the migration scope
- show where legacy values appear across applications, config, and database

2. Run discovery
- execute the shell scripts to capture raw findings and categorized output

3. Analyze impact and ordering
- use Copilot context (instructions, agents, skills) to group findings by risk and dependency

4. Produce a migration plan
- define replacement rules, change order, and rollback checkpoints

5. Validate completion
- confirm no legacy references remain and outputs are structurally consistent

For the full walkthrough with timings, presenter cues, and implementation notes, see [DEMO_GUIDE.md](DEMO_GUIDE.md).

## Documentation Map

- [README.md](README.md): repo purpose, high-level project and artifact overview, high-level demo flow
- [DEMO_GUIDE.md](DEMO_GUIDE.md): detailed walkthrough and build process
- [PROJECT_REFERENCE.md](PROJECT_REFERENCE.md): detailed legacy system documentation (demo-agnostic)

## Database Platform Note

This demo is configured for SQL Server so it can be executed with SQL Server MCP tooling in VS Code.

The same migration approach also works with Oracle databases: discovery, impact analysis, ordered DML, validation, and rollback planning remain the same; only SQL dialect and execution tooling differ.
