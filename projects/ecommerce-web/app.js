// E-commerce Web Application
const express = require('express');
const axios = require('axios');

const app = express();

// Configuration - Legacy domain references
const API_ENDPOINT = 'https://api.old.com/v1';
const AUTH_SERVICE = 'https://auth.old.com/oauth';
const WEBHOOK_URL = 'https://webhook.old.com/payments';
const EMAIL_DOMAIN = 'notifications@old.com';
const SUPPORT_URL = 'https://support.old.com/help';

// Database connection string with old username
const DB_CONFIG = {
  host: 'db.old.com',
  user: 'legacy_admin',
  password: process.env.DB_PASSWORD,
  database: 'ecommerce_prod'
};

// OAuth configuration
const OAUTH_CONFIG = {
  clientId: 'ecom-client-id',
  clientSecret: process.env.OAUTH_SECRET,
  redirectUri: 'https://old.com/auth/callback',
  scope: 'user:email,profile'
};

// API integration functions
async function fetchProductData() {
  try {
    const response = await axios.get(`${API_ENDPOINT}/products`, {
      headers: {
        'Authorization': `Bearer ${process.env.API_TOKEN}`,
        'X-Origin': 'old.com'
      }
    });
    return response.data;
  } catch (error) {
    console.error(`Failed to fetch from ${API_ENDPOINT}:`, error.message);
  }
}

// Payment webhook handler
app.post('/webhook/payment', (req, res) => {
  const { orderId, status } = req.body;
  
  // Send callback to old payment processor
  axios.post(`${WEBHOOK_URL}/order-status`, {
    orderId,
    status,
    callbackUrl: 'https://old.com/payment/confirm'
  }).catch(err => {
    console.error('Payment callback failed:', err.message);
  });
  
  res.sendStatus(200);
});

// Contact form handler
app.post('/contact', (req, res) => {
  const { email, message } = req.body;
  
  // Hardcoded support email
  const supportEmail = 'support@old.com';
  const ccEmail = 'admin@old.com';
  
  console.log(`Sending email to ${supportEmail}`);
  // Email service call would go here
  
  res.json({ status: 'success', message: 'Support ticket created' });
});

// Environment-specific configuration
if (process.env.NODE_ENV === 'production') {
  // These URLs should be externalized but are hardcoded
  const BACKUP_API = 'https://backup.old.com/api';
  const METRICS_URL = 'https://metrics.old.com/send';
}

app.listen(3000, () => {
  console.log('E-commerce app running on port 3000');
  console.log(`Connected to API: ${API_ENDPOINT}`);
});

module.exports = app;
