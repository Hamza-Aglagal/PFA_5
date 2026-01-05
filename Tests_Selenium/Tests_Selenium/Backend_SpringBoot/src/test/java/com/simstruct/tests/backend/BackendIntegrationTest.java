package com.simstruct.tests.backend;

import io.restassured.RestAssured;
import io.restassured.http.ContentType;
import io.restassured.response.Response;
import org.junit.jupiter.api.*;

import static io.restassured.RestAssured.*;
import static org.hamcrest.Matchers.*;

/**
 * Tests d'intégration pour l'API Backend
 */
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
public class BackendIntegrationTest {

    private static final String BASE_URL = "http://localhost:8080/api/v1";
    private static String authToken;
    private static Long simulationId;

    @BeforeAll
    public static void setup() {
        RestAssured.baseURI = BASE_URL;
    }

    @Test
    @Order(1)
    @DisplayName("Test 1: Register new user")
    public void testRegister() {
        String requestBody = """
            {
                "name": "Test User",
                "email": "testuser@selenium.com",
                "password": "password123"
            }
            """;

        given()
            .contentType(ContentType.JSON)
            .body(requestBody)
        .when()
            .post("/auth/register")
        .then()
            .statusCode(200)
            .body("token", notNullValue())
            .body("user.email", equalTo("testuser@selenium.com"))
            .body("user.name", equalTo("Test User"));
    }

    @Test
    @Order(2)
    @DisplayName("Test 2: Login with valid credentials")
    public void testLogin() {
        String requestBody = """
            {
                "email": "testuser@selenium.com",
                "password": "password123"
            }
            """;

        Response response = given()
            .contentType(ContentType.JSON)
            .body(requestBody)
        .when()
            .post("/auth/login")
        .then()
            .statusCode(200)
            .body("token", notNullValue())
            .body("user.email", equalTo("testuser@selenium.com"))
        .extract().response();

        // Sauvegarder le token pour les tests suivants
        authToken = response.jsonPath().getString("token");
    }

    @Test
    @Order(3)
    @DisplayName("Test 3: Login with invalid credentials")
    public void testLoginInvalid() {
        String requestBody = """
            {
                "email": "wrong@email.com",
                "password": "wrongpassword"
            }
            """;

        given()
            .contentType(ContentType.JSON)
            .body(requestBody)
        .when()
            .post("/auth/login")
        .then()
            .statusCode(401);
    }

    @Test
    @Order(4)
    @DisplayName("Test 4: Create simulation without auth")
    public void testCreateSimulationUnauthorized() {
        String requestBody = """
            {
                "name": "Test Simulation",
                "numFloors": 10,
                "floorHeight": 3.5
            }
            """;

        given()
            .contentType(ContentType.JSON)
            .body(requestBody)
        .when()
            .post("/simulations")
        .then()
            .statusCode(401);
    }

    @Test
    @Order(5)
    @DisplayName("Test 5: Create simulation with auth")
    public void testCreateSimulation() {
        String requestBody = """
            {
                "name": "Selenium Test Building",
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

        Response response = given()
            .contentType(ContentType.JSON)
            .header("Authorization", "Bearer " + authToken)
            .body(requestBody)
        .when()
            .post("/simulations")
        .then()
            .statusCode(200)
            .body("name", equalTo("Selenium Test Building"))
            .body("status", equalTo("COMPLETED"))
            .body("maxDeflection", notNullValue())
            .body("maxStress", notNullValue())
            .body("stabilityIndex", notNullValue())
            .body("seismicResistance", notNullValue())
        .extract().response();

        simulationId = response.jsonPath().getLong("id");
    }

    @Test
    @Order(6)
    @DisplayName("Test 6: Get all user simulations")
    public void testGetUserSimulations() {
        given()
            .header("Authorization", "Bearer " + authToken)
        .when()
            .get("/simulations")
        .then()
            .statusCode(200)
            .body("$", hasSize(greaterThan(0)))
            .body("[0].name", notNullValue());
    }

    @Test
    @Order(7)
    @DisplayName("Test 7: Get simulation by ID")
    public void testGetSimulationById() {
        given()
            .header("Authorization", "Bearer " + authToken)
        .when()
            .get("/simulations/" + simulationId)
        .then()
            .statusCode(200)
            .body("id", equalTo(simulationId.intValue()))
            .body("name", equalTo("Selenium Test Building"));
    }

    @Test
    @Order(8)
    @DisplayName("Test 8: Delete simulation")
    public void testDeleteSimulation() {
        given()
            .header("Authorization", "Bearer " + authToken)
        .when()
            .delete("/simulations/" + simulationId)
        .then()
            .statusCode(204);

        // Vérifier que la simulation est bien supprimée
        given()
            .header("Authorization", "Bearer " + authToken)
        .when()
            .get("/simulations/" + simulationId)
        .then()
            .statusCode(404);
    }

    @Test
    @Order(9)
    @DisplayName("Test 9: Validation - Missing required fields")
    public void testValidationMissingFields() {
        String requestBody = """
            {
                "name": "Test"
            }
            """;

        given()
            .contentType(ContentType.JSON)
            .header("Authorization", "Bearer " + authToken)
            .body(requestBody)
        .when()
            .post("/simulations")
        .then()
            .statusCode(400);
    }

    @Test
    @Order(10)
    @DisplayName("Test 10: Validation - Invalid values")
    public void testValidationInvalidValues() {
        String requestBody = """
            {
                "name": "Test",
                "numFloors": 100,
                "floorHeight": 10.0,
                "numBeams": 1000,
                "numColumns": 500
            }
            """;

        given()
            .contentType(ContentType.JSON)
            .header("Authorization", "Bearer " + authToken)
            .body(requestBody)
        .when()
            .post("/simulations")
        .then()
            .statusCode(400);
    }
}
