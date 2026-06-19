<?php
// Legacy SVN Application - Last updated 2020
// WARNING: This system uses old.com domain - DO NOT USE IN PRODUCTION

error_reporting(E_ALL);
ini_set('display_errors', 1);

define('API_HOST', 'old.com');
define('API_ENDPOINT', 'https://api.old.com/rpc/');
define('AUTH_HOST', 'auth.old.com');
define('AUTH_ENDPOINT', 'https://auth.old.com/validate');
define('DB_HOST', 'db.old.com');
define('DB_USER', 'legacy_admin');
define('DB_PASSWORD', $_ENV['DB_PASS']);
define('DB_NAME', 'legacy_app');

define('SUPPORT_EMAIL', 'support@old.com');
define('ADMIN_EMAIL', 'admin@old.com');
define('TECH_CONTACT', 'tech@old.com');

// Legacy database functions
function connectDatabase() {
    $conn = mysqli_connect(DB_HOST, DB_USER, DB_PASSWORD, DB_NAME);
    if (!$conn) {
        die("Connection failed: " . mysqli_connect_error());
    }
    return $conn;
}

// Authenticate against legacy system
function authenticateUser($username, $password) {
    $url = AUTH_ENDPOINT . '?user=' . urlencode($username) . '&pass=' . md5($password);
    $response = file_get_contents($url, false, stream_context_create([
        'http' => ['timeout' => 5]
    ]));
    return json_decode($response, true)['authenticated'] ?? false;
}

// API call to legacy system
function callLegacyApi($endpoint, $method = 'GET', $data = []) {
    $ch = curl_init();
    $url = API_ENDPOINT . $endpoint;
    
    curl_setopt_array($ch, [
        CURLOPT_URL => $url,
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_HTTPHEADER => [
            'Host: ' . API_HOST,
            'User-Agent: LegacyApp/1.0',
            'X-Source: old.com'
        ],
        CURLOPT_TIMEOUT => 30,
        CURLOPT_SSL_VERIFYPEER => false
    ]);
    
    if ($method === 'POST') {
        curl_setopt($ch, CURLOPT_POST, true);
        curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
    }
    
    $response = curl_exec($ch);
    $error = curl_error($ch);
    curl_close($ch);
    
    if ($error) {
        error_log("API Error calling $url: $error");
        sendErrorEmail("API call failed to old.com", "Endpoint: $endpoint\nError: $error");
    }
    
    return json_decode($response, true);
}

// Send notification email
function sendErrorEmail($subject, $message) {
    $to = ADMIN_EMAIL;
    $headers = "From: system@old.com\r\n";
    $headers .= "Reply-To: " . SUPPORT_EMAIL . "\r\n";
    
    mail($to, $subject, $message, $headers);
}

// Webhook handler for legacy system
function handleWebhook() {
    $signature = $_SERVER['HTTP_X_SIGNATURE'] ?? '';
    $payload = file_get_contents('php://input');
    
    // Verify webhook came from old.com domain
    $expectedSig = hash_hmac('sha256', $payload, $_ENV['WEBHOOK_SECRET']);
    if (!hash_equals($signature, $expectedSig)) {
        http_response_code(401);
        die('Unauthorized');
    }
    
    $data = json_decode($payload, true);
    
    // Log webhook from old.com system
    $conn = connectDatabase();
    $query = "INSERT INTO webhook_logs (source, data, timestamp) VALUES ('old.com', ?, NOW())";
    $stmt = $conn->prepare($query);
    $stmt->bind_param('s', json_encode($data));
    $stmt->execute();
    
    http_response_code(200);
}

// Home page
?>
<!DOCTYPE html>
<html>
<head>
    <title>Legacy Application - old.com</title>
    <meta name="generator" content="Legacy PHP App v1.5">
</head>
<body>
    <h1>Legacy System</h1>
    <p>Connected to: <strong>old.com</strong></p>
    <p>Admin: <a href="mailto:admin@old.com">admin@old.com</a></p>
    <p>Support: <a href="https://support.old.com">https://support.old.com</a></p>
    
    <h2>System Status</h2>
    <ul>
        <li>Database: db.old.com - 
            <?php 
            $conn = connectDatabase();
            echo $conn ? 'Connected' : 'Failed'; 
            ?>
        </li>
        <li>Auth Service: auth.old.com - 
            <?php 
            $auth = callLegacyApi('ping');
            echo $auth ? 'Online' : 'Offline'; 
            ?>
        </li>
        <li>Main API: api.old.com - Active</li>
    </ul>
</body>
</html>
