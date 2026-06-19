# Prompt: Generate database_discovery.sh

You are generating a Bash script named `database_discovery.sh`.
Return only the script in one fenced bash block.

## Goal
Produce a database discovery helper script that prints SQL Server migration SQL queries for legacy domain cleanup.

## Algorithm requirements
1. Output an instructional discovery workflow for SQL Server migration validation.
2. Emit a readable SQL query bundle (for copy/paste execution) that covers:
- user/account references to legacy email domains
- configuration values containing legacy domain or username tokens
- integration endpoints/webhooks referencing the legacy domain
- audit/history records linked to legacy user/domain values
- aggregate counts by entity/type for quick scoping
3. Use schema-qualified table names under `legacy` (for example `legacy.admin_users`).
4. Include enough SQL detail that a DBA can run queries directly with minimal edits.
5. Keep the script non-invasive: it should only print guidance and SQL text, not execute database connections.
6. Provide an example execution command showing how an operator could run SQL via `sqlcmd`.

## Constraints
- Maintain a read-only, instructional behavior.
- Keep SQL organized and easy to review in sections.

## Acceptance checks
- Script prints SQL that covers all required discovery categories and final sqlcmd guidance.
- No side effects beyond terminal output.
