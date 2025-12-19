package com.simstruct.backend.service;

import com.simstruct.backend.dto.AIPredictionResponse;
import com.simstruct.backend.dto.BuildingPredictionRequest;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.springframework.web.reactive.function.client.WebClient;
import org.springframework.web.reactive.function.client.WebClientResponseException;
import reactor.core.publisher.Mono;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.*;

/**
 * Tests simples pour AIModelService
 * 
 * Ce fichier teste les méthodes du service AI:
 * - Vérification de santé (health check)
 * - Récupération des informations du modèle
 * - Appel de prédiction (predict)
 */
class AIModelServiceTest {

    // Mock pour simuler WebClient (appels HTTP)
    @Mock
    private WebClient webClient;

    @Mock
    private WebClient.Builder webClientBuilder;

    @Mock
    private WebClient.RequestBodyUriSpec requestBodyUriSpec;

    @Mock
    private WebClient.RequestHeadersUriSpec requestHeadersUriSpec;

    @Mock
    private WebClient.RequestBodySpec requestBodySpec;

    @Mock
    private WebClient.RequestHeadersSpec requestHeadersSpec;

    @Mock
    private WebClient.ResponseSpec responseSpec;

    private AIModelService aiModelService;

    // URL de test pour l'API AI
    private final String TEST_AI_URL = "http://localhost:8000";

    /**
     * Méthode exécutée avant chaque test
     * Initialise les mocks et le service
     */
    @BeforeEach
    void setUp() {
        // Initialise Mockito
        MockitoAnnotations.openMocks(this);

        // Configure le builder pour retourner notre webClient mocké
        when(webClientBuilder.baseUrl(anyString())).thenReturn(webClientBuilder);
        when(webClientBuilder.build()).thenReturn(webClient);

        // Crée le service avec le mock
        aiModelService = new AIModelService(webClientBuilder, TEST_AI_URL);
    }

    /**
     * Test de vérification de santé - API disponible
     * Vérifie que isHealthy() retourne true quand l'API répond correctement
     */
    @Test
    void testIsHealthy_Success() {
        // ARRANGE: Prépare la réponse mock
        String healthResponse = "{\"status\":\"healthy\",\"message\":\"API opérationnelle\"}";

        // Configure le comportement du WebClient
        when(webClient.get()).thenReturn(requestHeadersUriSpec);
        when(requestHeadersUriSpec.uri(anyString())).thenReturn(requestHeadersSpec);
        when(requestHeadersSpec.retrieve()).thenReturn(responseSpec);
        when(responseSpec.bodyToMono(String.class)).thenReturn(Mono.just(healthResponse));

        // ACT: Exécute le test
        boolean result = aiModelService.isHealthy();

        // ASSERT: Vérifie le résultat
        assertTrue(result, "Le service doit être en bonne santé");

        // Vérifie que les appels ont été faits
        verify(webClient, times(1)).get();
    }

    /**
     * Test de vérification de santé - API non disponible
     * Vérifie que isHealthy() retourne false en cas d'erreur
     */
    @Test
    void testIsHealthy_Failed() {
        // ARRANGE: Simule une erreur de connexion
        when(webClient.get()).thenReturn(requestHeadersUriSpec);
        when(requestHeadersUriSpec.uri(anyString())).thenReturn(requestHeadersSpec);
        when(requestHeadersSpec.retrieve()).thenReturn(responseSpec);
        when(responseSpec.bodyToMono(String.class))
                .thenReturn(Mono.error(new RuntimeException("Connection refused")));

        // ACT
        boolean result = aiModelService.isHealthy();

        // ASSERT
        assertFalse(result, "Le service doit être considéré comme non disponible");
    }

    /**
     * Test de récupération des informations du modèle
     * Vérifie qu'on récupère bien les informations
     */
    @Test
    void testGetModelInfo_Success() {
        // ARRANGE
        String modelInfo = "{\"version\":\"1.0\",\"architecture\":\"Neural Network\"}";

        when(webClient.get()).thenReturn(requestHeadersUriSpec);
        when(requestHeadersUriSpec.uri(anyString())).thenReturn(requestHeadersSpec);
        when(requestHeadersSpec.retrieve()).thenReturn(responseSpec);
        when(responseSpec.bodyToMono(String.class)).thenReturn(Mono.just(modelInfo));

        // ACT
        String result = aiModelService.getModelInfo();

        // ASSERT
        assertNotNull(result, "Les informations ne doivent pas être null");
        assertTrue(result.contains("version"), "Les infos doivent contenir la version");
    }

    /**
     * Test de récupération d'informations - Erreur
     */
    @Test
    void testGetModelInfo_Error() {
        // ARRANGE
        when(webClient.get()).thenReturn(requestHeadersUriSpec);
        when(requestHeadersUriSpec.uri(anyString())).thenReturn(requestHeadersSpec);
        when(requestHeadersSpec.retrieve()).thenReturn(responseSpec);
        when(responseSpec.bodyToMono(String.class))
                .thenReturn(Mono.error(new RuntimeException("Service error")));

        // ACT
        String result = aiModelService.getModelInfo();

        // ASSERT
        assertNotNull(result, "Ne doit pas retourner null même en cas d'erreur");
        assertTrue(result.contains("Error"), "Le message doit indiquer une erreur");
    }

    /**
     * Test de prédiction réussie
     * Vérifie qu'on peut appeler l'API AI pour obtenir une prédiction
     */
    @Test
    void testPredict_Success() {
        // ARRANGE: Crée une requête de test
        BuildingPredictionRequest request = BuildingPredictionRequest.builder()
                .numFloors(5.0)
                .floorHeight(3.0)
                .numBeams(20)
                .numColumns(16)
                .beamSection(30.0)
                .columnSection(40.0)
                .concreteStrength(30.0)
                .steelGrade(400.0)
                .windLoad(1.5)
                .liveLoad(3.0)
                .deadLoad(5.0)
                .build();

        // Crée une réponse de test
        AIPredictionResponse expectedResponse = AIPredictionResponse.builder()
                .maxDeflection(5.2)
                .maxStress(150.0)
                .stabilityIndex(85.0)
                .seismicResistance(75.0)
                .status("Bon")
                .build();

        // Configure le mock pour retourner cette réponse
        when(webClient.post()).thenReturn(requestBodyUriSpec);
        when(requestBodyUriSpec.uri(anyString())).thenReturn(requestBodySpec);
        when(requestBodySpec.bodyValue(any())).thenReturn(requestHeadersSpec);
        when(requestHeadersSpec.retrieve()).thenReturn(responseSpec);
        when(responseSpec.bodyToMono(AIPredictionResponse.class))
                .thenReturn(Mono.just(expectedResponse));

        // ACT
        AIPredictionResponse result = aiModelService.predict(request);

        // ASSERT
        assertNotNull(result, "La réponse ne doit pas être null");
        assertEquals("Bon", result.getStatus(), "Le statut doit être 'Bon'");
        assertEquals(85.0, result.getStabilityIndex(), "L'index de stabilité doit être 85.0");
        assertEquals(75.0, result.getSeismicResistance(), "La résistance sismique doit être 75.0");

        // Vérifie que l'API a été appelée
        verify(webClient, times(1)).post();
    }

    /**
     * Test de prédiction avec erreur HTTP
     * Vérifie qu'une exception est levée en cas d'erreur API
     */
    @Test
    void testPredict_HttpError() {
        // ARRANGE
        BuildingPredictionRequest request = BuildingPredictionRequest.builder()
                .numFloors(5.0)
                .floorHeight(3.0)
                .numBeams(20)
                .numColumns(16)
                .beamSection(30.0)
                .columnSection(40.0)
                .concreteStrength(30.0)
                .steelGrade(400.0)
                .windLoad(1.5)
                .liveLoad(3.0)
                .deadLoad(5.0)
                .build();

        // Simule une erreur HTTP 500
        WebClientResponseException error = WebClientResponseException.create(
                500, 
                "Internal Server Error", 
                null, 
                null, 
                null
        );

        when(webClient.post()).thenReturn(requestBodyUriSpec);
        when(requestBodyUriSpec.uri(anyString())).thenReturn(requestBodySpec);
        when(requestBodySpec.bodyValue(any())).thenReturn(requestHeadersSpec);
        when(requestHeadersSpec.retrieve()).thenReturn(responseSpec);
        when(responseSpec.bodyToMono(AIPredictionResponse.class))
                .thenReturn(Mono.error(error));

        // ACT & ASSERT: Vérifie qu'une exception est levée
        assertThrows(RuntimeException.class, () -> {
            aiModelService.predict(request);
        }, "Une exception doit être levée en cas d'erreur HTTP");
    }

    /**
     * Test de prédiction avec erreur de connexion
     * Vérifie qu'une exception est levée si l'API n'est pas joignable
     */
    @Test
    void testPredict_ConnectionError() {
        // ARRANGE
        BuildingPredictionRequest request = BuildingPredictionRequest.builder()
                .numFloors(5.0)
                .floorHeight(3.0)
                .numBeams(20)
                .numColumns(16)
                .beamSection(30.0)
                .columnSection(40.0)
                .concreteStrength(30.0)
                .steelGrade(400.0)
                .windLoad(1.5)
                .liveLoad(3.0)
                .deadLoad(5.0)
                .build();

        // Simule une erreur de connexion
        when(webClient.post()).thenReturn(requestBodyUriSpec);
        when(requestBodyUriSpec.uri(anyString())).thenReturn(requestBodySpec);
        when(requestBodySpec.bodyValue(any())).thenReturn(requestHeadersSpec);
        when(requestHeadersSpec.retrieve()).thenReturn(responseSpec);
        when(responseSpec.bodyToMono(AIPredictionResponse.class))
                .thenReturn(Mono.error(new RuntimeException("Connection refused")));

        // ACT & ASSERT
        assertThrows(RuntimeException.class, () -> {
            aiModelService.predict(request);
        }, "Une exception doit être levée en cas d'erreur de connexion");
    }

    /**
     * Test de récupération de l'URL de l'API
     * Vérifie qu'on peut obtenir l'URL configurée
     */
    @Test
    void testGetApiUrl() {
        // ACT
        String url = aiModelService.getApiUrl();

        // ASSERT
        assertNotNull(url, "L'URL ne doit pas être null");
        assertEquals(TEST_AI_URL, url, "L'URL doit correspondre à celle configurée");
    }
}
