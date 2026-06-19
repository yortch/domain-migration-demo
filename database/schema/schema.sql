-- SQL Server Schema - Sensitive Data with Legacy References
-- Tables are grouped under the legacy schema for migration scoping.

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'legacy')
BEGIN
    EXEC('CREATE SCHEMA legacy');
END;
GO

IF OBJECT_ID('legacy.admin_users', 'U') IS NOT NULL DROP TABLE legacy.admin_users;
IF OBJECT_ID('legacy.user_accounts', 'U') IS NOT NULL DROP TABLE legacy.user_accounts;
IF OBJECT_ID('legacy.system_configuration', 'U') IS NOT NULL DROP TABLE legacy.system_configuration;
IF OBJECT_ID('legacy.api_integrations', 'U') IS NOT NULL DROP TABLE legacy.api_integrations;
IF OBJECT_ID('legacy.audit_logs', 'U') IS NOT NULL DROP TABLE legacy.audit_logs;
GO

CREATE TABLE legacy.admin_users (
    user_id INT NOT NULL PRIMARY KEY,
    username NVARCHAR(100) NOT NULL UNIQUE,
    email NVARCHAR(100) NULL,
    full_name NVARCHAR(200) NULL,
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);
GO

CREATE TABLE legacy.user_accounts (
    account_id INT NOT NULL PRIMARY KEY,
    account_name NVARCHAR(200) NULL,
    owner_name NVARCHAR(100) NULL,
    owner_email NVARCHAR(100) NULL,
    domain NVARCHAR(100) NULL,
    created_date DATE NULL
);
GO

CREATE TABLE legacy.system_configuration (
    config_id INT NOT NULL PRIMARY KEY,
    config_key NVARCHAR(200) NULL,
    config_value NVARCHAR(1000) NULL,
    description NVARCHAR(500) NULL,
    last_modified_by NVARCHAR(100) NULL,
    last_modified_date DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);
GO

CREATE TABLE legacy.api_integrations (
    integration_id INT NOT NULL PRIMARY KEY,
    service_name NVARCHAR(100) NULL,
    endpoint_url NVARCHAR(500) NULL,
    api_key_ref NVARCHAR(100) NULL,
    webhook_url NVARCHAR(500) NULL,
    created_by NVARCHAR(100) NULL,
    created_date DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);
GO

CREATE TABLE legacy.audit_logs (
    log_id INT NOT NULL PRIMARY KEY,
    action NVARCHAR(200) NULL,
    user_name NVARCHAR(100) NULL,
    source_domain NVARCHAR(100) NULL,
    description NVARCHAR(1000) NULL,
    log_timestamp DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);
GO

INSERT INTO legacy.admin_users (user_id, username, email, full_name)
VALUES (1, 'legacy_admin', 'admin@old.com', 'System Administrator');

INSERT INTO legacy.admin_users (user_id, username, email, full_name)
VALUES (2, 'legacy_support', 'support@old.com', 'Support Team Lead');

INSERT INTO legacy.admin_users (user_id, username, email, full_name)
VALUES (3, 'legacy_tech', 'tech@old.com', 'Technical Operations');

INSERT INTO legacy.system_configuration (config_id, config_key, config_value, description, last_modified_by)
VALUES (1, 'PRIMARY_API_ENDPOINT', 'https://api.old.com/v1', 'Main API endpoint', 'legacy_admin');

INSERT INTO legacy.system_configuration (config_id, config_key, config_value, description, last_modified_by)
VALUES (2, 'AUTH_SERVICE_URL', 'https://auth.old.com/oauth', 'OAuth service endpoint', 'legacy_admin');

INSERT INTO legacy.system_configuration (config_id, config_key, config_value, description, last_modified_by)
VALUES (3, 'WEBHOOK_CALLBACK', 'https://webhook.old.com/events', 'Event webhook callback', 'legacy_admin');

INSERT INTO legacy.system_configuration (config_id, config_key, config_value, description, last_modified_by)
VALUES (4, 'NOTIFICATION_EMAIL', 'notifications@old.com', 'Notification sender email', 'legacy_admin');

INSERT INTO legacy.system_configuration (config_id, config_key, config_value, description, last_modified_by)
VALUES (5, 'ADMIN_EMAIL_DOMAIN', 'old.com', 'Admin email domain', 'legacy_admin');

INSERT INTO legacy.system_configuration (config_id, config_key, config_value, description, last_modified_by)
VALUES (6, 'DATABASE_HOST', 'db.old.com', 'Primary database host', 'legacy_admin');

INSERT INTO legacy.api_integrations (integration_id, service_name, endpoint_url, webhook_url, created_by)
VALUES (1, 'Payment Gateway', 'https://gateway.old.com/api', 'https://webhook.old.com/payment', 'legacy_admin');

INSERT INTO legacy.api_integrations (integration_id, service_name, endpoint_url, webhook_url, created_by)
VALUES (2, 'Email Service', 'https://email.old.com/send', 'https://webhook.old.com/email', 'legacy_admin');

INSERT INTO legacy.api_integrations (integration_id, service_name, endpoint_url, webhook_url, created_by)
VALUES (3, 'Analytics Platform', 'https://analytics.old.com/track', NULL, 'legacy_admin');

INSERT INTO legacy.api_integrations (integration_id, service_name, endpoint_url, webhook_url, created_by)
VALUES (4, 'Logging Service', 'https://logs.old.com/api', 'https://webhook.old.com/logs', 'legacy_admin');

INSERT INTO legacy.audit_logs (log_id, action, user_name, source_domain, description)
VALUES (1, 'System Bootstrap', 'legacy_admin', 'old.com', 'Initial system configuration');

INSERT INTO legacy.audit_logs (log_id, action, user_name, source_domain, description)
VALUES (2, 'Config Update', 'legacy_admin', 'old.com', 'Updated API endpoints for old.com');

INSERT INTO legacy.audit_logs (log_id, action, user_name, source_domain, description)
VALUES (3, 'User Login', 'legacy_support', 'old.com', 'Support user login from old.com');
GO