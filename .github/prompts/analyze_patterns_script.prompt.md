# Prompt: Generate analyze_patterns.sh

You are generating a Bash script named `analyze_patterns.sh`.
Return only the script in one fenced bash block.

## Goal
Analyze domain-migration reference patterns and emit a JSON report file with:
- categorized samples from code/config/database
- summary counters

## Algorithm requirements
1. Recursively scan the repository for legacy migration tokens, at minimum:
- `old.com`
- `legacy_admin`
- `@old.com`
2. Classify findings into three categories:
- code
- configuration
- database
3. Build a timestamped JSON (or JSON-like) report in the current directory.
4. The report schema must include:
- analysis timestamp
- pattern buckets for the three categories
- summary counters
5. For each category bucket, include representative findings with file/location and captured content or context.
6. Summary counters must quantify at least:
- code hits
- config hits
- database hits
- legacy username references
- email-domain references
7. Print a completion message with the report path.
8. Print the generated report content to stdout for immediate inspection.

## Constraints
- Keep implementation shell-native and dependency-light.
- Favor robust escaping/sanitization so captured text does not break the report format.
- Gracefully handle files that cannot be read.

## Acceptance checks
- A timestamped JSON report file is created.
- Report includes category buckets and summary counts.
- Script prints the report path and then the generated report contents.
