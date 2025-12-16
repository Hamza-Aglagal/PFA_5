package com.simstruct.backend.service;

import com.simstruct.backend.dto.AIPredictionResponse;
import com.simstruct.backend.dto.BuildingPredictionRequest;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;
import org.springframework.web.reactive.function.client.WebClientResponseException;

import java.time.Duration;

/**
 * AI Model Service
 * Handles communication with Python FastAPI AI Model
 * Simple service for calling the Deep Learning prediction endpoint
 */
@Service
public class AIModelService {

    private final WebClient webClient;
    private final String aiApiUrl;

    /**
     * Constructor with dependency injection
     * WebClient is configured automatically by Spring Boot
     */
    public AIModelService(
            WebClient.Builder webClientBuilder,
            @Value("${ai.api.url:http://localhost:8000}") String aiApiUrl) {
        this.aiApiUrl = aiApiUrl;
        this.webClient = webClientBuilder
                .baseUrl(aiApiUrl)
                .build();
        
        System.out.println("AIModelService initialized with URL: " + aiApiUrl);
    }

    /**
     * Call AI Model to predict structural response
     * 
     * @param request Building parameters (11 inputs)
     * @return AI prediction response (4 outputs + status)
     * @throws RuntimeException if AI API call fails
     */
    public AIPredictionResponse predict(BuildingPredictionRequest request) {
        System.out.println("AIModelService: Calling AI API at " + aiApiUrl + "/predict");
        
        try {
            AIPredictionResponse response = webClient
                    .post()
                    .uri("/predict")
                    .bodyValue(request)
                    .retrieve()
                    .bodyToMono(AIPredictionResponse.class)
                    .timeout(Duration.ofSeconds(30))
                    .block();
            
            System.out.println("AIModelService: Prediction successful - Status: " + response.getStatus());
            return response;
            
        } catch (WebClientResponseException e) {
            System.err.println("AIModelService: HTTP Error " + e.getStatusCode() + " - " + e.getResponseBodyAsString());
            throw new RuntimeException("AI API returned error: " + e.getMessage(), e);
            
        } catch (Exception e) {
            System.err.println("AIModelService: Failed to connect to AI API - " + e.getMessage());
            throw new RuntimeException("Cannot reach AI API at " + aiApiUrl + ": " + e.getMessage(), e);
        }
    }

    /**
     * Check if AI API is healthy and ready
     * 
     * @return true if AI is available, false otherwise
     */
    public boolean isHealthy() {
        try {
            String response = webClient
                    .get()
                    .uri("/health")
                    .retrieve()
                    .bodyToMono(String.class)
                    .timeout(Duration.ofSeconds(5))
                    .block();
            
            System.out.println("AIModelService: Health check OK");
            return response != null && response.contains("healthy");
            
        } catch (Exception e) {
            System.err.println("AIModelService: Health check failed - " + e.getMessage());
            return false;
        }
    }

    /**
     * Get AI model information
     * 
     * @return Model info as string
     */
    public String getModelInfo() {
        try {
            String info = webClient
                    .get()
                    .uri("/model-info")
                    .retrieve()
                    .bodyToMono(String.class)
                    .timeout(Duration.ofSeconds(5))
                    .block();
            
            return info != null ? info : "Model info not available";
            
        } catch (Exception e) {
            System.err.println("AIModelService: Cannot get model info - " + e.getMessage());
            return "Error: " + e.getMessage();
        }
    }

    /**
     * Get AI API URL (for logging/debugging)
     */
    public String getApiUrl() {
        return aiApiUrl;
    }
}
