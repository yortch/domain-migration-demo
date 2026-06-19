# Prompt: Generate analyze_patterns.sh

You are generating a Bash script named `analyze_patterns.sh`.
Return only the script in one fenced bash block.
After generating it, save it to `scripts/analyze_patterns.sh` in the workspace.

## Reliability and performance requirements
- Prefer a simple `grep`/`awk` pipeline approach over deeply nested per-match shell loops.
- Avoid repeated subprocess calls inside match-processing loops for counting.
- Keep representative findings bounded (for example, max 20 per category) so output remains responsive.
- Target completion in a few seconds on this demo repository
- Use `#!/usr/bin/env bash` and safe shell options (`set -u`, `set -o pipefail`).

## Goal
Analyze domain-migration reference patterns and emit a JSON report file with:
- categorized samples from code/config/database
- summary counters

## Algorithm requirements
1. Recursively scan only these project directories for legacy migration tokens:
- `admin-portal`
- `ecommerce-web`
- `legacy-svn-app`
- `payment-service`
- `database-schema`
- `configs`
For each logical directory, resolve in this order:
- `projects/<name>`
- `<name>` (fallback at repository root)
Skip missing directories without failing the script.
2. Search for legacy migration tokens, at minimum:
- `old.com`
- `legacy_admin`
- `@old.com`
3. Classify findings into three categories:
- code
- configuration
- database
4. Build a timestamped JSON (or JSON-like) report in the current directory.
5. The report schema must include:
- analysis timestamp
- pattern buckets for the three categories
- summary counters
6. For each category bucket, include representative findings with file/location and captured content or context.
7. Summary counters must quantify at least:
- code hits
- config hits
- database hits
- legacy username references
- email-domain references
8. Print a completion message with the report path.
9. Print the generated report content to stdout for immediate inspection.
10. Ensure the emitted JSON is structurally valid (no trailing commas, no sentinel placeholder objects like `{}`).

## Constraints
- Keep implementation shell-native and dependency-light.
- Favor robust escaping/sanitization so captured text does not break the report format.
- Gracefully handle files that cannot be read.
- Avoid scanning dependency/build output directories if encountered (`node_modules`, `dist`, `build`, `target`, `.git`).

## Acceptance checks
- A timestamped JSON report file is created.
- Report includes category buckets and summary counts.
- Script prints the report path and then the generated report contents.
- `bash -n scripts/analyze_patterns.sh` passes.
