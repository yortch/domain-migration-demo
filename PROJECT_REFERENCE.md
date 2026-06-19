# Legacy Project Reference

This document provides detailed technical reference for the legacy system components in this repository. It is intentionally project-focused and does not describe demo flow.

## System Topology

The repository models a federated legacy environment with four applications, shared runtime configuration, and a SQL Server schema.

Applications:
- ecommerce-web (Node.js)
- payment-service (Java/Spring)
- admin-portal (Python/Flask)
- legacy-svn-app (PHP)

Shared layers:
- common runtime configuration in [configs/shared](configs/shared)
- relational schema and seed data in [database/schema/schema.sql](database/schema/schema.sql)

## Project Details

### ecommerce-web

Location:
- [projects/ecommerce-web](projects/ecommerce-web)

Primary files:
- [projects/ecommerce-web/app.js](projects/ecommerce-web/app.js)
- [projects/ecommerce-web/config.json](projects/ecommerce-web/config.json)
- [projects/ecommerce-web/README.md](projects/ecommerce-web/README.md)

Role:
- customer-facing web/API layer with endpoint, webhook, and CDN-style references

Typical migration-sensitive values in this project:
- API base URLs and auth endpoints
- webhook callback targets
- service hostnames and email-domain literals

### payment-service

Location:
- [projects/payment-service](projects/payment-service)

Primary files:
- [projects/payment-service/PaymentProcessorService.java](projects/payment-service/PaymentProcessorService.java)
- [projects/payment-service/application.yml](projects/payment-service/application.yml)

Role:
- payment processing microservice with integration and configuration-heavy logic

Typical migration-sensitive values in this project:
- upstream endpoint URLs
- OAuth or auth-provider references
- service account and connection parameters

### admin-portal

Location:
- [projects/admin-portal](projects/admin-portal)

Primary files:
- [projects/admin-portal/app.py](projects/admin-portal/app.py)
- [projects/admin-portal/.env.template](projects/admin-portal/.env.template)

Role:
- administrative operations portal with environment-driven runtime behavior

Typical migration-sensitive values in this project:
- SMTP and email-domain configuration
- admin account tokens and usernames
- API target hostnames in environment values

### legacy-svn-app

Location:
- [projects/legacy-svn-app](projects/legacy-svn-app)

Primary files:
- [projects/legacy-svn-app/index.php](projects/legacy-svn-app/index.php)

Role:
- older monolithic endpoint representative of historical code patterns

Typical migration-sensitive values in this project:
- hardcoded URLs and path fragments
- legacy user/account identifiers
- inline configuration strings

## Shared Configuration Layer

Location:
- [configs/shared](configs/shared)

Primary files:
- [configs/shared/config.env](configs/shared/config.env)
- [configs/shared/docker-compose.yml](configs/shared/docker-compose.yml)

Role:
- centralized configuration used by multiple services

Migration-sensitive surfaces:
- environment key/value pairs containing domains and usernames
- container-level hostnames, ports, and cross-service references

## Database Reference Layer

Location:
- [database/schema/schema.sql](database/schema/schema.sql)

Role:
- relational structures and seed data holding identity, config, and integration values

Common entity patterns represented:
- administrative users
- system configuration key/value records
- API integration endpoint definitions
- audit/log style records tied to usernames and source domains

## Scripts and Automation Assets

Location:
- [scripts](scripts)

Files:
- [scripts/discover_domains.sh](scripts/discover_domains.sh)
- [scripts/analyze_patterns.sh](scripts/analyze_patterns.sh)
- [scripts/database_discovery.sh](scripts/database_discovery.sh)

Purpose:
- shell-native discovery and reporting utilities for identifying migration targets

## Copilot Context Assets

Instructions:
- [.github/instructions/discover_migration.instructions.md](.github/instructions/discover_migration.instructions.md)
- [.github/instructions/migrate_codebase.instructions.md](.github/instructions/migrate_codebase.instructions.md)
- [.github/instructions/validate_migration.instructions.md](.github/instructions/validate_migration.instructions.md)

Agents:
- [.github/agents/discovery.md](.github/agents/discovery.md)
- [.github/agents/analysis.md](.github/agents/analysis.md)
- [.github/agents/database.md](.github/agents/database.md)
- [.github/agents/migration.md](.github/agents/migration.md)
- [.github/agents/validation.md](.github/agents/validation.md)
- [.github/agents/orchestrator.md](.github/agents/orchestrator.md)

Skills:
- [.github/skills/find-domain-refs/SKILL.md](.github/skills/find-domain-refs/SKILL.md)
- [.github/skills/analyze-impact/SKILL.md](.github/skills/analyze-impact/SKILL.md)
- [.github/skills/generate-replacement-plan/SKILL.md](.github/skills/generate-replacement-plan/SKILL.md)

Prompt assets for script regeneration:
- [.github/prompts/discover_domains_script.prompt.md](.github/prompts/discover_domains_script.prompt.md)
- [.github/prompts/analyze_patterns_script.prompt.md](.github/prompts/analyze_patterns_script.prompt.md)
- [.github/prompts/database_discovery_script.prompt.md](.github/prompts/database_discovery_script.prompt.md)

## Migration Token Set Used in This Repository

Primary token families currently represented:
- legacy domain family: old.com and related subdomain/address usage
- legacy user/account family: legacy_admin, legacy_support, legacy_tech

Representative replacement family:
- xyz.com domain family
- new_admin, new_support, new_tech user/account family

## Constraints and Notes

- This repository is a controlled legacy simulation and should not be treated as production configuration.
- The content is structured to maximize coverage of realistic migration patterns across technology boundaries.
- This reference is SQL Server-oriented for MCP compatibility, but the same migration pattern can be applied to Oracle with dialect/tooling adjustments.