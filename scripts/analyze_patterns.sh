#!/bin/bash
# Analyze patterns in domain references
# Categorizes findings by file type and context

echo "Analyzing domain migration patterns..."
echo ""

REPORT_FILE="pattern_analysis_$(date +%Y%m%d_%H%M%S).json"

{
    echo "{"
    echo '  "analysis_timestamp": "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'\",'
    echo '  "patterns": {'
    echo '    "code_references": ['
} > "$REPORT_FILE"

# Find patterns in code
grep -r "old\.com" . --include="*.js" --include="*.py" --include="*.java" -B 2 -A 2 2>/dev/null | \
    sed 's/\\/\\\\/g; s/"/\\"/g' | \
    awk '{printf "      {\\"file\\": \\"%s\\", \\"context\\": \\"%s\\"},\n", $1, $0}' | head -20 >> "$REPORT_FILE"

{
    echo "      {}"
    echo "    ],"
    echo '    "configuration_references": ['
} >> "$REPORT_FILE"

# Find patterns in configs
grep -r "old\.com" . --include="*.json" --include="*.yml" --include="*.env" 2>/dev/null | \
    awk -F: '{printf "      {\\"file\\": \\"%s\\", \\"value\\": \\"%s\\"},\n", $1, $NF}' | head -20 >> "$REPORT_FILE"

{
    echo "      {}"
    echo "    ],"
    echo '    "database_references": ['
} >> "$REPORT_FILE"

# Find patterns in SQL
grep -r "old\.com" . --include="*.sql" 2>/dev/null | \
    sed 's/\\/\\\\/g; s/"/\\"/g' | \
    awk '{printf "      {\\"table\\": \\"%s\\", \\"value\\": \\"%s\\"},\n", $1, $0}' >> "$REPORT_FILE"

{
    echo "      {}"
    echo "    ]"
    echo "  },"
    echo '  "summary": {'
    echo '    "total_code_hits": '$(grep -r "old\.com" . --include="*.js" --include="*.py" --include="*.java" 2>/dev/null | wc -l)','
    echo '    "total_config_hits": '$(grep -r "old\.com" . --include="*.json" --include="*.yml" --include="*.env" 2>/dev/null | wc -l)','
    echo '    "total_database_hits": '$(grep -r "old\.com" . --include="*.sql" 2>/dev/null | wc -l)','
    echo '    "legacy_admin_references": '$(grep -r "legacy_admin" . 2>/dev/null | wc -l)','
    echo '    "email_domain_references": '$(grep -r "@old\.com" . 2>/dev/null | wc -l)
    echo "  }"
    echo "}"
} >> "$REPORT_FILE"

echo "Pattern analysis complete. Report saved to: $REPORT_FILE"
cat "$REPORT_FILE"
