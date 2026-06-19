# Prompt: Generate analyze_patterns.sh

You are generating a Bash script named `analyze_patterns.sh`.
Return only the script in one fenced bash block.

## Goal
Analyze domain-migration reference patterns and emit a JSON report file with:
- categorized samples from code/config/database
- summary counters

## Algorithm requirements
1. Recursively scan only these project directories (under `projects/`) for legacy migration tokens:
- `admin-portal`
- `ecommerce-web`
- `legacy-svn-app`
- `payment-service`
- `database-schema`
- `configs`
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

## Constraints
- Keep implementation shell-native and dependency-light.
- Favor robust escaping/sanitization so captured text does not break the report format.
- Gracefully handle files that cannot be read.

## Acceptance checks
- A timestamped JSON report file is created.
- Report includes category buckets and summary counts.
- Script prints the report path and then the generated report contents.
