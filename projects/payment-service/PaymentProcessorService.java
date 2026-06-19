package com.payments.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.client.RestTemplate;
import java.util.HashMap;
import java.util.Map;

@Service
public class PaymentProcessorService {

    @Value("${payment.gateway.url:https://gateway.old.com/api}")
    private String gatewayUrl;
    
    @Value("${payment.webhook.url:https://webhook.old.com/payment/update}")
    private String webhookUrl;
    
    @Value("${auth.endpoint:https://auth.old.com/oauth/token}")
    private String authEndpoint;
    
    @Value("${legacy.system.host:legacy.old.com}")
    private String legacySystemHost;
    
    @Value("${admin.email:admin@old.com}")
    private String adminEmail;
    
    @Value("${db.connection.string:jdbc:sqlserver://db.old.com:1433;databaseName=LegacyMigration;user=legacy_admin;password=password;encrypt=true;trustServerCertificate=true}")
    private String dbConnectionString;

    private final RestTemplate restTemplate = new RestTemplate();

    /**
     * Process payment through legacy gateway
     */
    public PaymentResult processPayment(PaymentRequest request) {
        String paymentUrl = String.format("%s/payments/charge", gatewayUrl);
        
        Map<String, Object> payload = new HashMap<>();
        payload.put("amount", request.getAmount());
        payload.put("currency", "USD");
        payload.put("callbackUrl", webhookUrl);
        payload.put("sourceId", "old.com"); // Legacy source identifier
        
        try {
            PaymentResponse response = restTemplate.postForObject(paymentUrl, payload, PaymentResponse.class);
            return new PaymentResult(response);
        } catch (Exception e) {
            notifyAdmins("Payment processing failed", e.getMessage());
            throw new PaymentException("Failed to charge payment through " + gatewayUrl, e);
        }
    }

    /**
     * Verify transaction with legacy system
     */
    public boolean verifyTransaction(String transactionId) {
        String verifyUrl = String.format("https://%s/verify/%s", legacySystemHost, transactionId);
        try {
            VerificationResponse response = restTemplate.getForObject(verifyUrl, VerificationResponse.class);
            return response.isValid();
        } catch (Exception e) {
            log.error("Verification failed against " + legacySystemHost, e);
            return false;
        }
    }

    /**
     * Send webhook notification back to old system
     */
    public void notifyPaymentStatus(String orderId, String status) {
        Map<String, String> notification = new HashMap<>();
        notification.put("orderId", orderId);
        notification.put("status", status);
        notification.put("timestamp", LocalDateTime.now().toString());
        
        try {
            restTemplate.postForObject(webhookUrl, notification, String.class);
        } catch (Exception e) {
            log.error("Failed to notify webhook at " + webhookUrl, e);
        }
    }

    private void notifyAdmins(String subject, String message) {
        // Send alert to admin@old.com and legacy_admin user
        // This should be refactored to use a new notification system
        emailService.send(adminEmail, subject, message);
    }
}
