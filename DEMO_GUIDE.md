# Domain Migration Demo Guide

This guide is the detailed walkthrough for running the migration demo and the implementation notes describing how the demo itself was built.

## Session Plan (90 Minutes)

1. Context and objective (10 min)
2. Discovery and evidence collection (20 min)
3. Agent-guided analysis and planning (30 min)
4. Validation and closeout (20 min)
5. Q and A (10 min)

## Demo Objective

Show a complete migration workflow from discovery to validation across:
- multi-language application code
- shared environment configuration
- SQL Server schema and reference data

Primary migration story:
- domain transition from old.com to xyz.com
- legacy account transitions such as legacy_admin to new_admin

## Detailed Walkthrough

### 1) Context and objective (10 min)

Presenter actions:
1. Open [README.md](README.md) and explain scope.
2. Open [PROJECT_REFERENCE.md](PROJECT_REFERENCE.md) and briefly show the four legacy projects.
3. State migration targets and expected outcomes.

Audience takeaway:
- migration risk is distributed across code, config, and data
- a successful effort needs ordered, evidence-backed execution

### 2) Discovery and evidence collection (20 min)

Presenter actions:
1. Run the scripted scanners:
   - bash scripts/discover_domains.sh
   - bash scripts/analyze_patterns.sh
   - bash scripts/database_discovery.sh
2. Show generated reports and call out:
   - file categories impacted
   - reference density hot spots
   - database entities requiring migration

Suggested talking points:
- discovery should be broad first, precise second
- text search plus schema-aware queries catches more than either one alone

Expected outputs:
- timestamped text discovery report
- timestamped pattern analysis report
- SQL discovery bundle for DBA review

### 3) Agent-guided analysis and planning (30 min)

Presenter actions:
1. Open the context assets:
   - [.github/instructions](.github/instructions)
   - [.github/skills](.github/skills)
   - [.github/agents](.github/agents)
2. Show staged responsibilities:
   - discovery stage
   - impact/risk analysis stage
   - migration planning stage
   - validation stage
3. Ask Copilot to produce:
   - grouped findings by impact
   - dependency-aware execution order
   - rollback points per stage

Suggested talking points:
- separating concerns increases repeatability
- structured outputs make handoffs auditable
- orchestrated stages reduce missed dependencies

Expected outputs:
- categorized findings
- ordered migration plan
- validation checklist

### 4) Validation and closeout (20 min)

Presenter actions:
1. Re-scan for legacy references after proposed replacements.
2. Verify structural correctness:
   - JSON and YAML integrity
   - env key/value shape
   - SQL validity and execution ordering
3. Confirm cross-file consistency (for example hostnames and base URLs).

Suggested talking points:
- completion requires zero legacy survivors in target scope
- replacement correctness matters as much as replacement coverage

Expected outputs:
- pass/fail validation report with exact file and line evidence

### 5) Q and A (10 min)

Recommended topics:
- scaling this pattern to larger service portfolios
- adding CI gates for discovery and validation
- adapting token sets for different migration programs

## How This Demo Was Created

This section documents implementation choices so the demo can be reproduced or adapted.

### Design principles

1. Realistic heterogeneity
- include multiple languages and config formats to reflect enterprise drift

2. Deliberate migration surface area
- embed legacy tokens across application logic, configuration, docs, and schema

3. Layered execution model
- scripts for deterministic discovery
- Copilot context artifacts for guided reasoning and orchestration

4. Verifiable outcomes
- every stage produces concrete outputs that can be inspected independently

### Build steps used

1. Seeded legacy values in:
- [projects/ecommerce-web/app.js](projects/ecommerce-web/app.js)
- [projects/payment-service/PaymentProcessorService.java](projects/payment-service/PaymentProcessorService.java)
- [projects/admin-portal/app.py](projects/admin-portal/app.py)
- [projects/legacy-svn-app/index.php](projects/legacy-svn-app/index.php)
- [configs/shared/config.env](configs/shared/config.env)
- [configs/shared/docker-compose.yml](configs/shared/docker-compose.yml)
- [database/schema/schema.sql](database/schema/schema.sql)

2. Added deterministic discovery scripts in [scripts](scripts).

3. Added Copilot context artifacts:
- instructions in [.github/instructions](.github/instructions)
- agents in [.github/agents](.github/agents)
- skills in [.github/skills](.github/skills)

4. Added script-generation prompts in [.github/prompts](.github/prompts) so script files can be regenerated during live demos.

### Database portability note

This repository is currently tuned for SQL Server MCP usage, but the same workflow applies to Oracle migrations as well. The discovery logic, staged planning, and validation gates are platform-agnostic; only SQL syntax and execution tools change.

### Reproducibility notes

- Keep migration token set stable during a session.
- Preserve report naming with timestamps for easy comparison between runs.
- Run discovery before and after changes to demonstrate measurable progress.

## Presenter Checklist

Before session:
1. Confirm repository opens and file tree is visible.
2. Confirm shell scripts execute in your environment.
3. Pre-generate one sample report set as backup.

During session:
1. Use evidence-first narration (show findings before proposing fixes).
2. Keep stage boundaries explicit (discover, analyze, plan, validate).
3. Capture audience questions by stage.

After session:
1. Share the three primary docs.
2. Share report artifacts generated during the run.
3. Record follow-up actions for environment-specific adaptation.

1. **Context Engineering** (Instructions + Structure)
   - Tells Copilot what to do and why

2. **Agent Orchestration** (Multi-specialist workflow)
   - Breaks complexity into manageable pieces

3. **System Integration** (MCP + External Systems)
   - Connects AI to real data and real change

### The Real Power

"The real power isn't Copilot replacing engineers. It's Copilot augmenting teams to think bigger, move faster, and handle complexity that would otherwise require months of planning."

### Call to Action

- Try this demo repo in your own Copilot Chat
- Experiment with the instruction files
- Consider your own domain migration or complex project
- What would your agent team look like?

---

## Appendix: Conversation Starters for Demo

### For Discovery Phase
- "What files mention old.com?"
- "Show me all the API endpoints that need updating"
- "Which services depend on the payment-service?"

### For Analysis Phase
- "Organize these findings by risk level"
- "What would break if we changed this API endpoint?"
- "Create a dependency graph of the services"

### For Migration Phase
- "Generate a before/after comparison for each file"
- "Write the database migration scripts"
- "Create a validation checklist for this change set"

### For Validation Phase
- "Are there any remaining references to old.com?"
- "What could go wrong with this migration plan?"
- "Create a rollback procedure"

---

**Last Updated**: June 2024
**Estimated Prep Time**: 15-20 minutes
**Estimated Delivery Time**: 90 minutes (with 5-10 min buffer)
