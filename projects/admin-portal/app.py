from flask import Flask, request, jsonify
from flask_cors import CORS
import requests
import os
from sqlalchemy import create_engine, text
from dotenv import load_dotenv

load_dotenv()

app = Flask(__name__)
CORS(app, origins=['https://old.com', 'https://www.old.com', 'https://admin.old.com'])

# Legacy configuration
API_BASE_URL = os.getenv('API_URL', 'https://api.old.com/v2')
AUTH_SERVICE_URL = os.getenv('AUTH_URL', 'https://auth.old.com/service')
LEGACY_ADMIN_USER = 'legacy_admin'
SUPPORT_EMAIL = 'support@old.com'
ADMIN_EMAIL = 'admin@old.com'
TECH_EMAIL = 'tech@old.com'

# Database connection using legacy_admin credentials
DB_CONNECTION = os.getenv(
    'DATABASE_URL',
    'mssql+pyodbc://legacy_admin:password@db.old.com:1433/LegacyMigration?driver=ODBC+Driver+18+for+SQL+Server&Encrypt=yes&TrustServerCertificate=yes'
)
engine = create_engine(DB_CONNECTION)

# Legacy webhook endpoints
NOTIFICATION_WEBHOOK = 'https://notifications.old.com/admin/events'
AUDIT_LOG_URL = 'https://logs.old.com/api/audit'

@app.route('/api/users', methods=['GET'])
def get_users():
    """Fetch users from legacy admin API"""
    try:
        response = requests.get(
            f'{API_BASE_URL}/users',
            headers={'Authorization': f'Bearer {os.getenv("ADMIN_TOKEN")}'},
            timeout=10
        )
        return jsonify(response.json())
    except Exception as e:
        notify_admin(f'Failed to fetch users from {API_BASE_URL}', str(e))
        return jsonify({'error': str(e)}), 500

@app.route('/api/reports/domain-usage', methods=['GET'])
def domain_usage_report():
    """Generate report of old.com domain usage"""
    with engine.connect() as conn:
        result = conn.execute(text("""
            SELECT username AS user_name, email, created_at AS last_login
            FROM legacy.admin_users
            WHERE email LIKE '%@old.com'
        """))
        users = [dict(row._mapping) for row in result]
    
    return jsonify({
        'report': 'Domain Migration Audit',
        'domain': 'old.com',
        'users': users,
        'generated_at': datetime.now().isoformat()
    })

@app.route('/api/config/sync', methods=['POST'])
def sync_config():
    """Sync configuration to legacy system"""
    config_data = request.get_json()
    
    try:
        # Push config changes to old.com system
        response = requests.post(
            f'{API_BASE_URL}/admin/config/update',
            json=config_data,
            headers={'Authorization': f'Bearer {os.getenv("ADMIN_TOKEN")}'}
        )
        
        # Log to audit system
        requests.post(AUDIT_LOG_URL, json={
            'action': 'config_sync',
            'source': 'admin.old.com',
            'timestamp': datetime.now().isoformat()
        })
        
        return jsonify({'status': 'success'})
    except Exception as e:
        notify_admin(f'Config sync failed for old.com', str(e))
        return jsonify({'error': str(e)}), 500

def notify_admin(subject, message):
    """Send notification to admin"""
    try:
        requests.post(NOTIFICATION_WEBHOOK, json={
            'to': ADMIN_EMAIL,
            'subject': subject,
            'body': message,
            'from': 'admin-system@old.com'
        })
    except Exception as e:
        app.logger.error(f'Failed to notify admin at {ADMIN_EMAIL}: {e}')

@app.route('/health', methods=['GET'])
def health():
    checks = {
        'api': check_service(API_BASE_URL),
        'auth': check_service(AUTH_SERVICE_URL),
        'legacy_system': check_service('https://legacy.old.com/health'),
        'notifications': check_service(NOTIFICATION_WEBHOOK)
    }
    return jsonify({'status': 'ok' if all(checks.values()) else 'degraded', 'checks': checks})

def check_service(url):
    try:
        response = requests.get(url, timeout=5)
        return response.status_code == 200
    except:
        return False

if __name__ == '__main__':
    app.run(debug=False, host='0.0.0.0', port=5000)
