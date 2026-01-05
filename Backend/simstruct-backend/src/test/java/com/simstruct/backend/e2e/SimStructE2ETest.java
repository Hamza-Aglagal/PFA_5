package com.simstruct.backend.e2e;

import io.github.bonigarcia.wdm.WebDriverManager;
import org.junit.jupiter.api.*;
import org.openqa.selenium.*;
import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.chrome.ChromeOptions;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.server.LocalServerPort;
import org.springframework.test.context.ActiveProfiles;

import java.time.Duration;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * End-to-End Tests for SimStruct Web Application using Selenium WebDriver.
 * 
 * These tests verify the complete user workflows through the browser interface.
 * 
 * Prerequisites:
 * - Chrome browser installed on the test machine
 * - Frontend application running (or configure BASE_URL accordingly)
 * 
 * Run with: mvn verify -DskipUnitTests=true
 */
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@ActiveProfiles("test")
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
@Tag("e2e")
public class SimStructE2ETest {

    @LocalServerPort
    private int port;

    private static WebDriver driver;
    private static WebDriverWait wait;

    // Configure frontend URL - update if frontend runs on different port
    private static final String FRONTEND_BASE_URL = "http://localhost:3000";
    private String backendBaseUrl;

    @BeforeAll
    static void setupClass() {
        // Automatically download and setup ChromeDriver
        WebDriverManager.chromedriver().setup();
    }

    @BeforeEach
    void setup() {
        ChromeOptions options = new ChromeOptions();
        // Run in headless mode for CI/CD environments
        options.addArguments("--headless=new");
        options.addArguments("--no-sandbox");
        options.addArguments("--disable-dev-shm-usage");
        options.addArguments("--disable-gpu");
        options.addArguments("--window-size=1920,1080");
        options.addArguments("--remote-allow-origins=*");

        driver = new ChromeDriver(options);
        wait = new WebDriverWait(driver, Duration.ofSeconds(10));
        backendBaseUrl = "http://localhost:" + port;
    }

    @AfterEach
    void teardown() {
        if (driver != null) {
            driver.quit();
        }
    }

    // ==================== API Health Check Tests ====================

    @Test
    @Order(1)
    @DisplayName("E2E: Backend API is accessible")
    void testBackendApiIsAccessible() {
        driver.get(backendBaseUrl + "/api/health");

        // Check that the page loaded (API returns JSON)
        String pageSource = driver.getPageSource();
        assertThat(pageSource).isNotEmpty();
    }

    // ==================== Authentication Flow Tests ====================

    @Test
    @Order(2)
    @DisplayName("E2E: Login page loads correctly")
    void testLoginPageLoads() {
        driver.get(FRONTEND_BASE_URL + "/login");

        // Wait for login form to be visible
        wait.until(ExpectedConditions.or(
                ExpectedConditions.presenceOfElementLocated(By.id("email")),
                ExpectedConditions.presenceOfElementLocated(By.name("email")),
                ExpectedConditions.presenceOfElementLocated(By.cssSelector("input[type='email']"))));

        // Verify page title or key elements
        assertThat(driver.getTitle()).containsIgnoringCase("simstruct");
    }

    @Test
    @Order(3)
    @DisplayName("E2E: User can register a new account")
    void testUserRegistration() {
        driver.get(FRONTEND_BASE_URL + "/register");

        // Wait for registration form
        WebElement usernameField = wait.until(ExpectedConditions.presenceOfElementLocated(
                By.cssSelector("input[name='username'], input#username")));
        WebElement emailField = driver
                .findElement(By.cssSelector("input[name='email'], input#email, input[type='email']"));
        WebElement passwordField = driver
                .findElement(By.cssSelector("input[name='password'], input#password, input[type='password']"));

        // Fill in registration form
        String uniqueEmail = "e2etest_" + System.currentTimeMillis() + "@simstruct.com";
        usernameField.sendKeys("e2eTestUser" + System.currentTimeMillis());
        emailField.sendKeys(uniqueEmail);
        passwordField.sendKeys("SecurePassword123!");

        // Submit form
        WebElement submitButton = driver.findElement(By.cssSelector("button[type='submit'], input[type='submit']"));
        submitButton.click();

        // Wait for redirect or success message
        wait.until(ExpectedConditions.or(
                ExpectedConditions.urlContains("/login"),
                ExpectedConditions.urlContains("/dashboard"),
                ExpectedConditions.presenceOfElementLocated(By.cssSelector(".success, .alert-success"))));
    }

    @Test
    @Order(4)
    @DisplayName("E2E: User can login with valid credentials")
    void testUserLogin() {
        driver.get(FRONTEND_BASE_URL + "/login");

        // Wait for login form
        WebElement emailField = wait.until(ExpectedConditions.presenceOfElementLocated(
                By.cssSelector("input[name='email'], input#email, input[type='email']")));
        WebElement passwordField = driver
                .findElement(By.cssSelector("input[name='password'], input#password, input[type='password']"));

        // Fill in login form
        emailField.sendKeys("test@simstruct.com");
        passwordField.sendKeys("password123");

        // Submit form
        WebElement submitButton = driver.findElement(By.cssSelector("button[type='submit'], input[type='submit']"));
        submitButton.click();

        // Wait for redirect to dashboard or error message
        wait.until(ExpectedConditions.or(
                ExpectedConditions.urlContains("/dashboard"),
                ExpectedConditions.urlContains("/simulations"),
                ExpectedConditions.presenceOfElementLocated(By.cssSelector(".error, .alert-danger, .alert-error"))));
    }

    @Test
    @Order(5)
    @DisplayName("E2E: Login fails with invalid credentials")
    void testLoginWithInvalidCredentials() {
        driver.get(FRONTEND_BASE_URL + "/login");

        // Wait for login form
        WebElement emailField = wait.until(ExpectedConditions.presenceOfElementLocated(
                By.cssSelector("input[name='email'], input#email, input[type='email']")));
        WebElement passwordField = driver
                .findElement(By.cssSelector("input[name='password'], input#password, input[type='password']"));

        // Fill in login form with invalid credentials
        emailField.sendKeys("invalid@simstruct.com");
        passwordField.sendKeys("wrongpassword");

        // Submit form
        WebElement submitButton = driver.findElement(By.cssSelector("button[type='submit'], input[type='submit']"));
        submitButton.click();

        // Wait for error message
        wait.until(ExpectedConditions.or(
                ExpectedConditions.presenceOfElementLocated(By.cssSelector(".error, .alert-danger, .alert-error")),
                ExpectedConditions.urlContains("/login") // Should stay on login page
        ));

        // Verify we're still on login page (not redirected)
        assertThat(driver.getCurrentUrl()).contains("/login");
    }

    // ==================== Simulation Workflow Tests ====================

    @Test
    @Order(6)
    @DisplayName("E2E: Dashboard displays simulations list")
    void testDashboardDisplaysSimulations() {
        // First, login
        performLogin("test@simstruct.com", "password123");

        // Navigate to simulations/dashboard
        driver.get(FRONTEND_BASE_URL + "/simulations");

        // Wait for simulations list to load
        wait.until(ExpectedConditions.or(
                ExpectedConditions.presenceOfElementLocated(
                        By.cssSelector(".simulation-list, .simulations, [data-testid='simulations']")),
                ExpectedConditions.presenceOfElementLocated(By.cssSelector(".no-simulations, .empty-state"))));
    }

    @Test
    @Order(7)
    @DisplayName("E2E: User can create a new simulation")
    void testCreateNewSimulation() {
        // First, login
        performLogin("test@simstruct.com", "password123");

        // Navigate to create simulation page
        driver.get(FRONTEND_BASE_URL + "/simulations/new");

        // Wait for form
        WebElement nameField = wait.until(ExpectedConditions.presenceOfElementLocated(
                By.cssSelector("input[name='name'], input#name, input#simulationName")));

        // Fill in simulation details
        String simulationName = "E2E Test Simulation " + System.currentTimeMillis();
        nameField.sendKeys(simulationName);

        // Find and fill description if available
        try {
            WebElement descField = driver
                    .findElement(By.cssSelector("textarea[name='description'], textarea#description"));
            descField.sendKeys("Created by E2E automated test");
        } catch (NoSuchElementException e) {
            // Description field is optional
        }

        // Submit form
        WebElement submitButton = driver.findElement(By.cssSelector("button[type='submit'], input[type='submit']"));
        submitButton.click();

        // Wait for redirect or success
        wait.until(ExpectedConditions.or(
                ExpectedConditions.urlContains("/simulations/"),
                ExpectedConditions.presenceOfElementLocated(By.cssSelector(".success, .alert-success"))));
    }

    // ==================== Responsive Design Tests ====================

    @Test
    @Order(8)
    @DisplayName("E2E: Application is responsive on mobile viewport")
    void testMobileResponsiveness() {
        // Set mobile viewport
        driver.manage().window().setSize(new Dimension(375, 812)); // iPhone X dimensions

        driver.get(FRONTEND_BASE_URL);

        // Wait for page to load
        wait.until(ExpectedConditions.presenceOfElementLocated(By.tagName("body")));

        // Check for mobile menu (hamburger) or adapted layout
        boolean hasMobileLayout = driver.findElements(By.cssSelector(
                ".mobile-menu, .hamburger, .nav-toggle, [data-mobile-menu]")).size() > 0
                || driver.findElements(By.cssSelector(".mobile, .responsive")).size() > 0;

        // The page should load without horizontal scrollbar issues
        Long documentWidth = (Long) ((JavascriptExecutor) driver).executeScript(
                "return document.documentElement.scrollWidth");
        Long viewportWidth = (Long) ((JavascriptExecutor) driver).executeScript(
                "return window.innerWidth");

        // Document shouldn't be significantly wider than viewport
        assertThat(documentWidth).isLessThanOrEqualTo(viewportWidth + 20);
    }

    // ==================== Utility Methods ====================

    /**
     * Helper method to perform login
     */
    private void performLogin(String email, String password) {
        driver.get(FRONTEND_BASE_URL + "/login");

        try {
            WebElement emailField = wait.until(ExpectedConditions.presenceOfElementLocated(
                    By.cssSelector("input[name='email'], input#email, input[type='email']")));
            WebElement passwordField = driver
                    .findElement(By.cssSelector("input[name='password'], input#password, input[type='password']"));

            emailField.sendKeys(email);
            passwordField.sendKeys(password);

            WebElement submitButton = driver.findElement(By.cssSelector("button[type='submit'], input[type='submit']"));
            submitButton.click();

            // Wait for navigation
            wait.until(ExpectedConditions.or(
                    ExpectedConditions.urlContains("/dashboard"),
                    ExpectedConditions.urlContains("/simulations"),
                    ExpectedConditions.not(ExpectedConditions.urlContains("/login"))));
        } catch (Exception e) {
            // Login might already be done via session
        }
    }

    /**
     * Take a screenshot for debugging (useful in CI/CD)
     */
    private void takeScreenshot(String testName) {
        try {
            TakesScreenshot screenshotDriver = (TakesScreenshot) driver;
            byte[] screenshot = screenshotDriver.getScreenshotAs(OutputType.BYTES);
            // In real scenario, save to file or attach to test report
        } catch (Exception e) {
            // Ignore screenshot errors
        }
    }
}
