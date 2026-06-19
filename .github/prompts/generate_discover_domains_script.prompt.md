# Prompt: Generate discover_domains.sh

You are generating a Bash script for Linux/macOS named `discover_domains.sh`.
Return only the script in one fenced bash block.

Save the generated script to `scripts/discover_domains.sh`.

## Goal
Create a discovery scanner that searches a repository for references to:
- domain: `old.com`
- username: `legacy_admin`
- email pattern: `@old.com`

## Algorithm requirements
1. Recursively scan only these project directories (under `projects/`):
- `admin-portal`
- `ecommerce-web`
- `legacy-svn-app`
- `payment-service`
- `database-schema`
- `configs`
2. Use the same directory resolution behavior as `analyze_patterns.sh`: prefer `projects/<dir>`, fallback to `<dir>` if needed.
3. Search for migration references at minimum:
- `old.com`
- `legacy_admin`
- `@old.com`
4. Classify files into at least these groups:
- source code files
- configuration files
- documentation files
5. In each group, identify files containing either the legacy domain or legacy username.
6. Produce a timestamped text report in the current working directory.
7. Report structure must include:
- metadata (generation time and search targets)
- grouped file lists by category
- a detailed findings section containing line-level matches for:
	- domain references
	- username references
	- email-domain references
8. At the end of script execution, print a concise terminal summary with total match counts for:
- domain references
- username references
- email-domain references
9. Print the generated report path so downstream tooling can pick it up.
10. Handle unreadable files/permission issues gracefully and continue scanning.

## Constraints
- Keep implementation shell-native with standard Unix tools available on common developer machines.
- Do not require non-default packages.
- Keep behavior deterministic for repeat demo runs.

## Acceptance checks
- Script executes as Bash and completes without interactive prompts.
- A timestamped report file is generated.
- Report includes grouped file discovery and detailed match output.
- Terminal output includes the three required totals and report location.
