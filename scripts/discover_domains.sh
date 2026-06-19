#!/bin/bash
# Domain Migration Discovery Script
# Searches for references to old.com and legacy_admin across the codebase

echo "=========================================="
echo "Domain Migration Discovery Scanner"
echo "=========================================="
echo ""

SEARCH_DOMAIN="old.com"
SEARCH_USER="legacy_admin"
OUTPUT_FILE="discovery_report_$(date +%Y%m%d_%H%M%S).txt"

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

echo "Scanning for: $SEARCH_DOMAIN and $SEARCH_USER"
echo "Report will be saved to: $OUTPUT_FILE"
echo ""

# Create report header
{
    echo "Domain Migration Discovery Report"
    echo "Generated: $(date)"
    echo "Scanning for: $SEARCH_DOMAIN and $SEARCH_USER"
    echo ""
    echo "========== CODE FILES =========="
} > "$OUTPUT_FILE"

# Search in source files
find "${SEARCH_DIRS[@]}" -type f \( -name "*.js" -o -name "*.ts" -o -name "*.java" -o -name "*.py" -o -name "*.php" -o -name "*.go" \) -exec grep -l "old\.com\|$SEARCH_USER" {} \; >> "$OUTPUT_FILE" 2>/dev/null

{
    echo ""
    echo "========== CONFIGURATION FILES =========="
} >> "$OUTPUT_FILE"

# Search in config files
find "${SEARCH_DIRS[@]}" -type f \( -name "*.json" -o -name "*.yml" -o -name "*.yaml" -o -name "*.env" -o -name "*.conf" \) -exec grep -l "old\.com\|$SEARCH_USER" {} \; >> "$OUTPUT_FILE" 2>/dev/null

{
    echo ""
    echo "========== DOCUMENTATION =========="
} >> "$OUTPUT_FILE"

# Search in docs
find "${SEARCH_DIRS[@]}" -type f \( -name "*.md" -o -name "*.txt" -o -name "*.rst" \) -exec grep -l "old\.com\|$SEARCH_USER" {} \; >> "$OUTPUT_FILE" 2>/dev/null

{
    echo ""
    echo "========== DETAILED FINDINGS =========="
    echo ""
    echo "--- References to old.com ---"
} >> "$OUTPUT_FILE"

grep -r "old\.com" "${SEARCH_DIRS[@]}" --include="*.js" --include="*.ts" --include="*.java" --include="*.py" --include="*.php" --include="*.json" --include="*.yml" --include="*.env" 2>/dev/null >> "$OUTPUT_FILE"

{
    echo ""
    echo "--- References to legacy_admin ---"
} >> "$OUTPUT_FILE"

grep -r "$SEARCH_USER" "${SEARCH_DIRS[@]}" --include="*.js" --include="*.ts" --include="*.java" --include="*.py" --include="*.php" --include="*.json" --include="*.yml" --include="*.env" --include="*.sql" 2>/dev/null >> "$OUTPUT_FILE"

{
    echo ""
    echo "--- Email References ---"
} >> "$OUTPUT_FILE"

grep -r "@old\.com" "${SEARCH_DIRS[@]}" 2>/dev/null >> "$OUTPUT_FILE"

# Print summary
echo ""
echo "Discovery Summary:"
echo "=================="
echo "Total files with old.com references: $(grep -r "old\.com" "${SEARCH_DIRS[@]}" 2>/dev/null | wc -l)"
echo "Total files with legacy_admin references: $(grep -r "legacy_admin" "${SEARCH_DIRS[@]}" 2>/dev/null | wc -l)"
echo "Total email references: $(grep -r "@old\.com" "${SEARCH_DIRS[@]}" 2>/dev/null | wc -l)"
echo ""
echo "Full report saved to: $OUTPUT_FILE"
