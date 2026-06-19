#!/bin/bash
# Database discovery script for SQL Server users and configuration references

echo "Database Migration Discovery"
echo "============================"
echo ""
echo "This script would connect to SQL Server and discover:"
echo "- Users with old domain references"
echo "- Configuration values referencing old.com"
echo "- Sensitive data requiring migration"
echo ""

cat << 'EOF'

# SQL queries to run against SQL Server (legacy schema)

-- 1. Find all admin users and their emails
SELECT username, email, full_name
FROM legacy.admin_users
WHERE email LIKE '%@old.com';

-- 2. Find configuration values referencing old.com
SELECT config_key, config_value
FROM legacy.system_configuration
WHERE config_value LIKE '%old.com%' OR config_value LIKE '%legacy_admin%';

-- 3. Find API integrations with old domain
SELECT service_name, endpoint_url, webhook_url
FROM legacy.api_integrations
WHERE endpoint_url LIKE '%old.com%' OR webhook_url LIKE '%old.com%';

-- 4. Audit trail of changes from legacy_admin
SELECT action, user_name, source_domain, log_timestamp
FROM legacy.audit_logs
WHERE user_name = 'legacy_admin' OR source_domain = 'old.com'
ORDER BY log_timestamp DESC;

-- 5. Count of all references by type
SELECT
    'admin_users' as entity_type,
    COUNT(*) as count
FROM legacy.admin_users
WHERE email LIKE '%@old.com'
UNION ALL
SELECT 'config_values' as entity_type,
    COUNT(*) as count
FROM legacy.system_configuration
WHERE config_value LIKE '%old.com%'
UNION ALL
SELECT 'api_integrations' as entity_type,
    COUNT(*) as count
FROM legacy.api_integrations
WHERE endpoint_url LIKE '%old.com%' OR webhook_url LIKE '%old.com%';

EOF

echo ""
echo "To execute these queries, run:"
echo "sqlcmd -S db.old.com -d LegacyMigration -U legacy_admin -i database_discovery.sql"
