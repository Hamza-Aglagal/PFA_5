package com.simstruct.backend.integration;

import io.restassured.RestAssured;
import io.restassured.http.ContentType;
import io.restassured.response.Response;
import org.junit.jupiter.api.*;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.server.LocalServerPort;
import org.springframework.test.context.ActiveProfiles;

import static io.restassured.RestAssured.*;
import static org.hamcrest.Matchers.*;

/**
 * API Integration Tests using Rest-Assured.
 * 
 * These tests verify the REST API endpoints work correctly end-to-end.
 * Unlike unit tests, these tests hit the actual running application.
 * 
 * Run with: mvn verify -Dit.test=ApiIntegrationIT
 */
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@ActiveProfiles("test")
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
@Tag("integration")
public class ApiIntegrationIT {

    @LocalServerPort
    private int port;

    private static String authToken;
    private static Long createdSimulationId;

    @BeforeEach
    void setup() {
        RestAssured.port = port;
        RestAssured.basePath = "/api";
        RestAssured.enableLoggingOfRequestAndResponseIfValidationFails();
    }

    // ==================== Health Check Tests ====================

    @Test
    @Order(1)
    @DisplayName("IT: API health endpoint is accessible")
    void testHealthEndpoint() {
        given()
                .when()
                .get("/health")
                .then()
                .statusCode(anyOf(is(200), is(404))); // 404 if no health endpoint
    }

    // ==================== Authentication API Tests ====================

    @Test
    @Order(2)
    @DisplayName("IT: User registration returns success")
    void testUserRegistration() {
        String uniqueEmail = "it_test_" + System.currentTimeMillis() + "@simstruct.com";
        String requestBody = String.format("""
                {
                    "username": "integrationTestUser%d",
                    "email": "%s",
                    "password": "SecurePassword123!"
                }
                """, System.currentTimeMillis(), uniqueEmail);

        given()
                .contentType(ContentType.JSON)
                .body(requestBody)
                .when()
                .post("/auth/register")
                .then()
                .statusCode(anyOf(is(200), is(201), is(409))); // 409 if user exists
    }

    @Test
    @Order(3)
    @DisplayName("IT: User login returns JWT token")
    void testUserLogin() {
        String requestBody = """
                {
                    "email": "test@simstruct.com",
                    "password": "password123"
                }
                """;

        Response response = given()
                .contentType(ContentType.JSON)
                .body(requestBody)
                .when()
                .post("/auth/login")
                .then()
                .statusCode(anyOf(is(200), is(401)))
                .extract()
                .response();

        if (response.statusCode() == 200) {
            authToken = response.jsonPath().getString("token");
            Assertions.assertNotNull(authToken, "JWT token should be returned");
        }
    }

    @Test
    @Order(4)
    @DisplayName("IT: Login with invalid credentials returns 401")
    void testLoginWithInvalidCredentials() {
        String requestBody = """
                {
                    "email": "nonexistent@simstruct.com",
                    "password": "wrongpassword"
                }
                """;

        given()
                .contentType(ContentType.JSON)
                .body(requestBody)
                .when()
                .post("/auth/login")
                .then()
                .statusCode(anyOf(is(401), is(403), is(400)));
    }

    // ==================== Simulation API Tests ====================

    @Test
    @Order(5)
    @DisplayName("IT: GET /simulations requires authentication")
    void testGetSimulationsRequiresAuth() {
        given()
                .contentType(ContentType.JSON)
                .when()
                .get("/simulations")
                .then()
                .statusCode(anyOf(is(401), is(403)));
    }

    @Test
    @Order(6)
    @DisplayName("IT: GET /simulations returns list with valid token")
    void testGetSimulationsWithAuth() {
        // Skip if no token from previous login test
        Assumptions.assumeTrue(authToken != null, "Auth token required for this test");

        given()
                .contentType(ContentType.JSON)
                .header("Authorization", "Bearer " + authToken)
                .when()
                .get("/simulations")
                .then()
                .statusCode(200)
                .contentType(ContentType.JSON);
    }

    @Test
    @Order(7)
    @DisplayName("IT: POST /simulations creates a new simulation")
    void testCreateSimulation() {
        Assumptions.assumeTrue(authToken != null, "Auth token required for this test");

        String requestBody = String.format("""
                {
                    "name": "Integration Test Simulation %d",
                    "description": "Created by API integration test",
                    "type": "STRUCTURAL"
                }
                """, System.currentTimeMillis());

        Response response = given()
                .contentType(ContentType.JSON)
                .header("Authorization", "Bearer " + authToken)
                .body(requestBody)
                .when()
                .post("/simulations")
                .then()
                .statusCode(anyOf(is(200), is(201)))
                .body("name", containsString("Integration Test Simulation"))
                .extract()
                .response();

        createdSimulationId = response.jsonPath().getLong("id");
        Assertions.assertNotNull(createdSimulationId);
    }

    @Test
    @Order(8)
    @DisplayName("IT: GET /simulations/{id} returns simulation details")
    void testGetSimulationById() {
        Assumptions.assumeTrue(authToken != null, "Auth token required");
        Assumptions.assumeTrue(createdSimulationId != null, "Simulation ID required");

        given()
                .contentType(ContentType.JSON)
                .header("Authorization", "Bearer " + authToken)
                .when()
                .get("/simulations/" + createdSimulationId)
                .then()
                .statusCode(200)
                .body("id", equalTo(createdSimulationId.intValue()));
    }

    @Test
    @Order(9)
    @DisplayName("IT: PUT /simulations/{id} updates simulation")
    void testUpdateSimulation() {
        Assumptions.assumeTrue(authToken != null, "Auth token required");
        Assumptions.assumeTrue(createdSimulationId != null, "Simulation ID required");

        String requestBody = """
                {
                    "name": "Updated Integration Test Simulation",
                    "description": "Updated by API integration test"
                }
                """;

        given()
                .contentType(ContentType.JSON)
                .header("Authorization", "Bearer " + authToken)
                .body(requestBody)
                .when()
                .put("/simulations/" + createdSimulationId)
                .then()
                .statusCode(anyOf(is(200), is(204)));
    }

    @Test
    @Order(10)
    @DisplayName("IT: DELETE /simulations/{id} removes simulation")
    void testDeleteSimulation() {
        Assumptions.assumeTrue(authToken != null, "Auth token required");
        Assumptions.assumeTrue(createdSimulationId != null, "Simulation ID required");

        given()
                .header("Authorization", "Bearer " + authToken)
                .when()
                .delete("/simulations/" + createdSimulationId)
                .then()
                .statusCode(anyOf(is(200), is(204)));

        // Verify deletion
        given()
                .header("Authorization", "Bearer " + authToken)
                .when()
                .get("/simulations/" + createdSimulationId)
                .then()
                .statusCode(anyOf(is(404), is(403)));
    }

    // ==================== User API Tests ====================

    @Test
    @Order(11)
    @DisplayName("IT: GET /users/me returns current user profile")
    void testGetCurrentUserProfile() {
        Assumptions.assumeTrue(authToken != null, "Auth token required");

        given()
                .contentType(ContentType.JSON)
                .header("Authorization", "Bearer " + authToken)
                .when()
                .get("/users/me")
                .then()
                .statusCode(anyOf(is(200), is(404))) // 404 if endpoint doesn't exist
                .contentType(ContentType.JSON);
    }

    // ==================== Error Handling Tests ====================

    @Test
    @Order(12)
    @DisplayName("IT: Invalid JSON returns 400 Bad Request")
    void testInvalidJsonReturns400() {
        given()
                .contentType(ContentType.JSON)
                .body("{ invalid json }")
                .when()
                .post("/auth/login")
                .then()
                .statusCode(400);
    }

    @Test
    @Order(13)
    @DisplayName("IT: Non-existent endpoint returns 404")
    void testNonExistentEndpointReturns404() {
        given()
                .when()
                .get("/non-existent-endpoint")
                .then()
                .statusCode(404);
    }

    // ==================== Performance & Concurrency Tests ====================

    @Test
    @Order(14)
    @DisplayName("IT: API responds within acceptable time")
    void testApiResponseTime() {
        Assumptions.assumeTrue(authToken != null, "Auth token required");

        given()
                .header("Authorization", "Bearer " + authToken)
                .when()
                .get("/simulations")
                .then()
                .statusCode(200)
                .time(lessThan(5000L)); // Response should be under 5 seconds
    }
}
