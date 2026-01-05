package com.simstruct.tests.backend;

import io.restassured.RestAssured;
import io.restassured.http.ContentType;
import io.restassured.response.Response;
import io.restassured.specification.RequestSpecification;
import org.junit.jupiter.api.*;

import static io.restassured.RestAssured.*;
import static org.hamcrest.Matchers.*;
import static org.assertj.core.api.Assertions.assertThat;

/**
 * Tests professionnels pour l'API Backend Spring Boot
 * Utilise RestAssured pour les tests d'API REST
 * 
 * Pattern: Given-When-Then (BDD)
 * 
 * @author SimStruct Team
 * @version 1.0
 */
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
@DisplayName("Tests Backend API - RestAssured Professional")
public class BackendAPIProfessionalTest {
    
    private static final String BASE_URL = "http://localhost:8080/api/v1";
    private static String authToken;
    private static Long createdSimulationId;
    
    // Données de test
    private static final String TEST_EMAIL = "backend.test@simstruct.com";
    private static final String TEST_PASSWORD = "SecurePassword123!";
    private static final String TEST_NAME = "Backend Test User";
    
    @BeforeAll
    public static void setup() {
        RestAssured.baseURI = BASE_URL;
        RestAssured.enableLoggingOfRequestAndResponseIfValidationFails();
        
        System.out.println("\n========================================");
        System.out.println("  Tests Backend API - SimStruct");
        System.out.println("  Base URL: " + BASE_URL);
        System.out.println("========================================\n");
    }
    
    /**
     * Helper: Créer une requête avec authentification
     */
    private RequestSpecification authenticatedRequest() {
        return given()
            .contentType(ContentType.JSON)
            .header("Authorization", "Bearer " + authToken);
    }
    
    // ========== TESTS D'AUTHENTIFICATION ==========
    
    @Test
    @Order(1)
    @DisplayName("✅ Test 1: Inscription d'un nouvel utilisateur")
    @Tag("authentication")
    @Tag("critical")
    public void test01_RegisterNewUser() {
        // GIVEN: Les données d'inscription
        String requestBody = String.format("""
            {
                "name": "%s",
                "email": "%s",
                "password": "%s"
            }
            """, TEST_NAME, TEST_EMAIL, TEST_PASSWORD);
        
        System.out.println("📝 Inscription d'un nouvel utilisateur...");
        
        // WHEN: Envoi de la requête d'inscription
        Response response = given()
            .contentType(ContentType.JSON)
            .body(requestBody)
        .when()
            .post("/auth/register")
        .then()
            .log().ifValidationFails()
            .statusCode(anyOf(is(200), is(201)))
            .body("token", notNullValue())
            .body("user.email", equalTo(TEST_EMAIL))
            .body("user.name", equalTo(TEST_NAME))
        .extract().response();
        
        // THEN: Vérifier les données retournées
        authToken = response.jsonPath().getString("token");
        
        assertThat(authToken)
            .as("Le token JWT devrait être retourné")
            .isNotNull()
            .isNotEmpty();
        
        System.out.println("✅ Utilisateur créé avec succès");
        System.out.println("   Token: " + authToken.substring(0, 20) + "...");
    }
    
    @Test
    @Order(2)
    @DisplayName("✅ Test 2: Connexion avec credentials valides")
    @Tag("authentication")
    @Tag("smoke")
    public void test02_LoginWithValidCredentials() {
        // GIVEN: Les credentials de connexion
        String requestBody = String.format("""
            {
                "email": "%s",
                "password": "%s"
            }
            """, TEST_EMAIL, TEST_PASSWORD);
        
        System.out.println("🔐 Connexion avec credentials valides...");
        
        // WHEN: Tentative de connexion
        Response response = given()
            .contentType(ContentType.JSON)
            .body(requestBody)
        .when()
            .post("/auth/login")
        .then()
            .statusCode(200)
            .body("token", notNullValue())
            .body("user.email", equalTo(TEST_EMAIL))
        .extract().response();
        
        // THEN: Token mis à jour
        authToken = response.jsonPath().getString("token");
        
        System.out.println("✅ Connexion réussie");
    }
    
    @Test
    @Order(3)
    @DisplayName("❌ Test 3: Connexion avec credentials invalides")
    @Tag("authentication")
    @Tag("negative")
    public void test03_LoginWithInvalidCredentials() {
        // GIVEN: Des credentials invalides
        String requestBody = """
            {
                "email": "wrong@email.com",
                "password": "wrongpassword"
            }
            """;
        
        System.out.println("❌ Tentative de connexion avec credentials invalides...");
        
        // WHEN: Tentative de connexion
        // THEN: Erreur 401 Unauthorized
        given()
            .contentType(ContentType.JSON)
            .body(requestBody)
        .when()
            .post("/auth/login")
        .then()
            .statusCode(401);
        
        System.out.println("✅ Erreur 401 retournée comme attendu");
    }
    
    // ========== TESTS CRUD SIMULATIONS ==========
    
    @Test
    @Order(4)
    @DisplayName("❌ Test 4: Créer simulation sans authentification")
    @Tag("simulation")
    @Tag("security")
    public void test04_CreateSimulationWithoutAuth() {
        // GIVEN: Une requête de simulation sans token
        String requestBody = """
            {
                "name": "Test Simulation",
                "numFloors": 10,
                "floorHeight": 3.5
            }
            """;
        
        System.out.println("🔒 Tentative de création sans authentification...");
        
        // WHEN: Tentative de création
        // THEN: Erreur 401
        given()
            .contentType(ContentType.JSON)
            .body(requestBody)
        .when()
            .post("/simulations")
        .then()
            .statusCode(401);
        
        System.out.println("✅ Accès refusé (401) comme attendu");
    }
    
    @Test
    @Order(5)
    @DisplayName("✅ Test 5: Créer une simulation complète avec authentification")
    @Tag("simulation")
    @Tag("critical")
    @Tag("e2e")
    public void test05_CreateSimulationWithAuth() {
        // GIVEN: Les données de simulation complètes
        String requestBody = """
            {
                "name": "Backend Professional Test Simulation",
                "numFloors": 10,
                "floorHeight": 3.5,
                "numBeams": 120,
                "numColumns": 36,
                "beamSection": 30.0,
                "columnSection": 40.0,
                "concreteStrength": 35.0,
                "steelGrade": 355.0,
                "windLoad": 1.5,
                "liveLoad": 3.0,
                "deadLoad": 5.0
            }
            """;
        
        System.out.println("🏗️  Création d'une simulation complète...");
        
        // WHEN: Création de la simulation
        Response response = authenticatedRequest()
            .body(requestBody)
        .when()
            .post("/simulations")
        .then()
            .statusCode(anyOf(is(200), is(201)))
            .body("name", equalTo("Backend Professional Test Simulation"))
            .body("status", notNullValue())
            .body("maxDeflection", notNullValue())
            .body("maxStress", notNullValue())
            .body("stabilityIndex", notNullValue())
            .body("seismicResistance", notNullValue())
        .extract().response();
        
        // THEN: Vérifier les résultats
        createdSimulationId = response.jsonPath().getLong("id");
        String status = response.jsonPath().getString("status");
        Double maxDeflection = response.jsonPath().getDouble("maxDeflection");
        Double maxStress = response.jsonPath().getDouble("maxStress");
        Double stabilityIndex = response.jsonPath().getDouble("stabilityIndex");
        Double seismicResistance = response.jsonPath().getDouble("seismicResistance");
        
        assertThat(createdSimulationId).isNotNull().isPositive();
        assertThat(status).isIn("COMPLETED", "PENDING", "FAILED");
        
        System.out.println("✅ Simulation créée avec succès");
        System.out.println("   ID: " + createdSimulationId);
        System.out.println("   Status: " + status);
        System.out.println("   Déflexion max: " + maxDeflection + " mm");
        System.out.println("   Contrainte max: " + maxStress + " MPa");
        System.out.println("   Stabilité: " + stabilityIndex);
        System.out.println("   Résistance sismique: " + seismicResistance);
    }
    
    @Test
    @Order(6)
    @DisplayName("✅ Test 6: Récupérer toutes les simulations de l'utilisateur")
    @Tag("simulation")
    @Tag("smoke")
    public void test06_GetAllUserSimulations() {
        System.out.println("📋 Récupération de toutes les simulations...");
        
        // WHEN: Récupération des simulations
        Response response = authenticatedRequest()
        .when()
            .get("/simulations")
        .then()
            .statusCode(200)
            .body("$", hasSize(greaterThan(0)))
            .body("[0].id", notNullValue())
            .body("[0].name", notNullValue())
        .extract().response();
        
        // THEN: Vérifier qu'on a au moins une simulation
        int simulationCount = response.jsonPath().getList("$").size();
        
        assertThat(simulationCount)
            .as("L'utilisateur devrait avoir au moins une simulation")
            .isGreaterThan(0);
        
        System.out.println("✅ " + simulationCount + " simulation(s) récupérée(s)");
    }
    
    @Test
    @Order(7)
    @DisplayName("✅ Test 7: Récupérer une simulation par ID")
    @Tag("simulation")
    public void test07_GetSimulationById() {
        System.out.println("🔍 Récupération de la simulation ID: " + createdSimulationId);
        
        // WHEN: Récupération par ID
        Response response = authenticatedRequest()
        .when()
            .get("/simulations/" + createdSimulationId)
        .then()
            .statusCode(200)
            .body("id", equalTo(createdSimulationId.intValue()))
            .body("name", equalTo("Backend Professional Test Simulation"))
        .extract().response();
        
        System.out.println("✅ Simulation récupérée avec succès");
    }
    
    @Test
    @Order(8)
    @DisplayName("❌ Test 8: Récupérer simulation inexistante")
    @Tag("simulation")
    @Tag("negative")
    public void test08_GetNonExistentSimulation() {
        System.out.println("❌ Tentative de récupération d'une simulation inexistante...");
        
        // WHEN: Tentative de récupération
        // THEN: Erreur 404
        authenticatedRequest()
        .when()
            .get("/simulations/999999")
        .then()
            .statusCode(404);
        
        System.out.println("✅ Erreur 404 retournée comme attendu");
    }
    
    @Test
    @Order(9)
    @DisplayName("❌ Test 9: Validation - Données manquantes")
    @Tag("validation")
    @Tag("negative")
    public void test09_ValidationMissingFields() {
        // GIVEN: Requête avec champs manquants
        String requestBody = """
            {
                "name": "Test"
            }
            """;
        
        System.out.println("❌ Tentative de création avec données incomplètes...");
        
        // WHEN: Tentative de création
        // THEN: Erreur 400 Bad Request
        authenticatedRequest()
            .body(requestBody)
        .when()
            .post("/simulations")
        .then()
            .statusCode(400);
        
        System.out.println("✅ Erreur 400 (Bad Request) retournée comme attendu");
    }
    
    @Test
    @Order(10)
    @DisplayName("❌ Test 10: Validation - Valeurs hors limites")
    @Tag("validation")
    @Tag("negative")
    public void test10_ValidationOutOfRangeValues() {
        // GIVEN: Requête avec valeurs invalides
        String requestBody = """
            {
                "name": "Test",
                "numFloors": 100,
                "floorHeight": 10.0,
                "numBeams": 1000,
                "numColumns": 500,
                "beamSection": 30.0,
                "columnSection": 40.0,
                "concreteStrength": 35.0,
                "steelGrade": 355.0,
                "windLoad": 1.5,
                "liveLoad": 3.0,
                "deadLoad": 5.0
            }
            """;
        
        System.out.println("❌ Tentative avec valeurs hors limites...");
        
        // WHEN: Tentative de création
        // THEN: Erreur 400
        authenticatedRequest()
            .body(requestBody)
        .when()
            .post("/simulations")
        .then()
            .statusCode(400);
        
        System.out.println("✅ Validation échouée comme attendu");
    }
    
    @Test
    @Order(11)
    @DisplayName("✅ Test 11: Supprimer une simulation")
    @Tag("simulation")
    public void test11_DeleteSimulation() {
        System.out.println("🗑️  Suppression de la simulation ID: " + createdSimulationId);
        
        // WHEN: Suppression
        authenticatedRequest()
        .when()
            .delete("/simulations/" + createdSimulationId)
        .then()
            .statusCode(anyOf(is(200), is(204)));
        
        // THEN: Vérifier que la simulation n'existe plus
        authenticatedRequest()
        .when()
            .get("/simulations/" + createdSimulationId)
        .then()
            .statusCode(404);
        
        System.out.println("✅ Simulation supprimée avec succès");
    }
    
    @Test
    @Order(12)
    @DisplayName("✅ Test 12: Performance - Temps de réponse API")
    @Tag("performance")
    public void test12_APIResponseTime() {
        System.out.println("⚡ Test de performance...");
        
        // WHEN: Appel API
        long startTime = System.currentTimeMillis();
        
        authenticatedRequest()
        .when()
            .get("/simulations")
        .then()
            .statusCode(200)
            .time(lessThan(2000L)); // Moins de 2 secondes
        
        long endTime = System.currentTimeMillis();
        long responseTime = endTime - startTime;
        
        System.out.println("✅ Temps de réponse: " + responseTime + " ms");
        
        assertThat(responseTime)
            .as("Le temps de réponse devrait être inférieur à 2000ms")
            .isLessThan(2000L);
    }
    
    @AfterAll
    public static void tearDown() {
        System.out.println("\n========================================");
        System.out.println("  Fin des tests Backend API");
        System.out.println("========================================\n");
    }
}
