#!/bin/bash
# Analyze patterns in domain references
# Categorizes findings by file type and context

echo "Analyzing domain migration patterns..."
echo ""

TARGET_DIRS=(
    "admin-portal"
    "ecommerce-web"
    "legacy-svn-app"
    "payment-service"
    "database-schema"
    "configs"
)

PROJECTS_ROOT="projects"

SEARCH_DIRS=()
for dir in "${TARGET_DIRS[@]}"; do
    if [ -d "$PROJECTS_ROOT/$dir" ]; then
        SEARCH_DIRS+=("$PROJECTS_ROOT/$dir")
    elif [ -d "$dir" ]; then
        SEARCH_DIRS+=("$dir")
    fi
done

if [ ${#SEARCH_DIRS[@]} -eq 0 ]; then
    echo "No target project directories found. Expected: ${TARGET_DIRS[*]}"
    exit 1
fi

REPORT_FILE="pattern_analysis_$(date +%Y%m%d_%H%M%S).json"

{
    echo "{"
    echo '  "analysis_timestamp": "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'",'
    echo '  "patterns": {'
    echo '    "code_references": ['
} > "$REPORT_FILE"

# Find patterns in code
grep -r "old\.com" "${SEARCH_DIRS[@]}" --include="*.js" --include="*.py" --include="*.java" -B 2 -A 2 2>/dev/null | \
    sed 's/\\/\\\\/g; s/"/\\"/g' | \
    awk '{printf "      {\"file\": \"%s\", \"context\": \"%s\"},\n", $1, $0}' | head -20 >> "$REPORT_FILE"

{
    echo "      {}"
    echo "    ],"
    echo '    "configuration_references": ['
} >> "$REPORT_FILE"

# Find patterns in configs
grep -r "old\.com" "${SEARCH_DIRS[@]}" --include="*.json" --include="*.yml" --include="*.env" 2>/dev/null | \
    awk -F: '{printf "      {\"file\": \"%s\", \"value\": \"%s\"},\n", $1, $NF}' | head -20 >> "$REPORT_FILE"

{
    echo "      {}"
    echo "    ],"
    echo '    "database_references": ['
} >> "$REPORT_FILE"

# Find patterns in SQL
grep -r "old\.com" "${SEARCH_DIRS[@]}" --include="*.sql" 2>/dev/null | \
    sed 's/\\/\\\\/g; s/"/\\"/g' | \
    awk '{printf "      {\"table\": \"%s\", \"value\": \"%s\"},\n", $1, $0}' >> "$REPORT_FILE"

{
    echo "      {}"
    echo "    ]"
    echo "  },"
    echo '  "summary": {'
    echo '    "total_code_hits": '$(grep -r "old\.com" "${SEARCH_DIRS[@]}" --include="*.js" --include="*.py" --include="*.java" 2>/dev/null | wc -l)','
    echo '    "total_config_hits": '$(grep -r "old\.com" "${SEARCH_DIRS[@]}" --include="*.json" --include="*.yml" --include="*.env" 2>/dev/null | wc -l)','
    echo '    "total_database_hits": '$(grep -r "old\.com" "${SEARCH_DIRS[@]}" --include="*.sql" 2>/dev/null | wc -l)','
    echo '    "legacy_admin_references": '$(grep -r "legacy_admin" "${SEARCH_DIRS[@]}" 2>/dev/null | wc -l)','
    echo '    "email_domain_references": '$(grep -r "@old\.com" "${SEARCH_DIRS[@]}" 2>/dev/null | wc -l)
    echo "  }"
    echo "}"
} >> "$REPORT_FILE"

echo "Pattern analysis complete. Report saved to: $REPORT_FILE"
cat "$REPORT_FILE"
