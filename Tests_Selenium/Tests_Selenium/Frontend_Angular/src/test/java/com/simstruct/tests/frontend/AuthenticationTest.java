package com.simstruct.tests.frontend;

import io.github.bonigarcia.wdm.WebDriverManager;
import org.junit.jupiter.api.*;
import org.openqa.selenium.By;
import static com.simstruct.tests.frontend.ScreenshotUtil.*;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.chrome.ChromeOptions;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

import java.time.Duration;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * Tests E2E pour l'authentification (Login/Register)
 */
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
public class AuthenticationTest {

    private static WebDriver driver;
    private static WebDriverWait wait;
    private static final String BASE_URL = "http://localhost:4200";

    @BeforeAll
    public static void setupClass() {
        WebDriverManager.chromedriver().setup();
    }

    @BeforeEach
    public void setupTest() {
        ChromeOptions options = new ChromeOptions();
        options.addArguments("--start-maximized");
        options.addArguments("--disable-notifications");
        
        driver = new ChromeDriver(options);
        wait = new WebDriverWait(driver, Duration.ofSeconds(10));
    }

    @Test
    @Order(1)
    @DisplayName("Test 1: Accès à la page de login")
    public void testNavigateToLogin() {
        // Naviguer vers la page de login
        driver.get(BASE_URL + "/login");
        
        // 📸 Capture d'écran: Page de login
        captureScreenshot(driver, "01_page_login");

        // Vérifier le titre de la page
        String title = driver.getTitle();
        assertThat(title).contains("SimStruct");

        // Vérifier la présence du formulaire de login
        WebElement emailInput = driver.findElement(By.id("email"));
        WebElement passwordInput = driver.findElement(By.id("password"));
        WebElement loginButton = driver.findElement(By.id("loginBtn"));

        assertThat(emailInput).isNotNull();
        assertThat(passwordInput).isNotNull();
        assertThat(loginButton).isNotNull();
        
        // 📸 Capture d'écran: Formulaire visible
        captureSuccessScreenshot(driver, "01_formulaire_login_visible");
    }

    @Test
    @Order(2)
    @DisplayName("Test 2: Login avec credentials valides")
    public void testLoginSuccess() {
        driver.get(BASE_URL + "/login");
        
        // 📸 Capture: Page de login
        captureScreenshot(driver, "02_avant_login");

        // Remplir le formulaire
        WebElement emailInput = driver.findElement(By.id("email"));
        WebElement passwordInput = driver.findElement(By.id("password"));
        WebElement loginButton = driver.findElement(By.id("loginBtn"));

        emailInput.sendKeys("test@simstruct.com");
        passwordInput.sendKeys("password123");
        
        // 📸 Capture: Formulaire rempli
        captureScreenshot(driver, "02_formulaire_rempli");
        
        loginButton.click();

        // Attendre la redirection vers le dashboard
        wait.until(ExpectedConditions.urlContains("/dashboard"));
        
        // 📸 Capture: Dashboard après login
        captureScreenshot(driver, "02_dashboard_apres_login");

        // Vérifier qu'on est bien sur le dashboard
        String currentUrl = driver.getCurrentUrl();
        assertThat(currentUrl).contains("/dashboard");

        // Vérifier la présence d'éléments du dashboard
        WebElement welcomeMessage = wait.until(
            ExpectedConditions.presenceOfElementLocated(By.className("welcome-message"))
        );
        assertThat(welcomeMessage.getText()).contains("Bienvenue");
        
        // 📸 Capture finale: Succès
        captureSuccessScreenshot(driver, "02_login_success");
    }

    @Test
    @Order(3)
    @DisplayName("Test 3: Login avec credentials invalides")
    public void testLoginFailure() {
        driver.get(BASE_URL + "/login");

        WebElement emailInput = driver.findElement(By.id("email"));
        WebElement passwordInput = driver.findElement(By.id("password"));
        WebElement loginButton = driver.findElement(By.id("loginBtn"));

        emailInput.sendKeys("wrong@email.com");
        passwordInput.sendKeys("wrongpassword");
        
        // 📸 Capture: Avant tentative de login invalide
        captureScreenshot(driver, "03_avant_login_invalide");
        
        loginButton.click();

        // Attendre le message d'erreur
        WebElement errorMessage = wait.until(
            ExpectedConditions.presenceOfElementLocated(By.className("error-message"))
        );
        
        // 📸 Capture: Message d'erreur affiché
        captureScreenshot(driver, "03_message_erreur");

        assertThat(errorMessage.getText()).contains("Email ou mot de passe incorrect");
    }

    @Test
    @Order(4)
    @DisplayName("Test 4: Validation du formulaire de login")
    public void testLoginFormValidation() {
        driver.get(BASE_URL + "/login");

        WebElement loginButton = driver.findElement(By.id("loginBtn"));
        
        // Essayer de soumettre sans remplir
        loginButton.click();

        // Vérifier les messages de validation
        WebElement emailError = driver.findElement(By.id("email-error"));
        WebElement passwordError = driver.findElement(By.id("password-error"));

        assertThat(emailError.getText()).contains("Email requis");
        assertThat(passwordError.getText()).contains("Mot de passe requis");
    }

    @Test
    @Order(5)
    @DisplayName("Test 5: Navigation vers la page d'inscription")
    public void testNavigateToRegister() {
        driver.get(BASE_URL + "/login");

        // Cliquer sur le lien "S'inscrire"
        WebElement registerLink = driver.findElement(By.id("registerLink"));
        registerLink.click();

        // Attendre la redirection
        wait.until(ExpectedConditions.urlContains("/register"));

        // Vérifier qu'on est sur la page d'inscription
        String currentUrl = driver.getCurrentUrl();
        assertThat(currentUrl).contains("/register");
    }

    @Test
    @Order(6)
    @DisplayName("Test 6: Inscription d'un nouvel utilisateur")
    public void testRegisterNewUser() {
        driver.get(BASE_URL + "/register");

        // Remplir le formulaire d'inscription
        driver.findElement(By.id("name")).sendKeys("Test User");
        driver.findElement(By.id("email")).sendKeys("newuser@test.com");
        driver.findElement(By.id("password")).sendKeys("password123");
        driver.findElement(By.id("confirmPassword")).sendKeys("password123");
        
        // Accepter les conditions
        driver.findElement(By.id("termsCheckbox")).click();
        
        // Soumettre
        driver.findElement(By.id("registerBtn")).click();

        // Attendre la redirection vers le dashboard
        wait.until(ExpectedConditions.urlContains("/dashboard"));

        String currentUrl = driver.getCurrentUrl();
        assertThat(currentUrl).contains("/dashboard");
    }

    @Test
    @Order(7)
    @DisplayName("Test 7: Déconnexion")
    public void testLogout() {
        // D'abord se connecter
        driver.get(BASE_URL + "/login");
        driver.findElement(By.id("email")).sendKeys("test@simstruct.com");
        driver.findElement(By.id("password")).sendKeys("password123");
        driver.findElement(By.id("loginBtn")).click();

        wait.until(ExpectedConditions.urlContains("/dashboard"));

        // Cliquer sur le bouton de déconnexion
        WebElement logoutButton = driver.findElement(By.id("logoutBtn"));
        logoutButton.click();

        // Vérifier la redirection vers login
        wait.until(ExpectedConditions.urlContains("/login"));

        String currentUrl = driver.getCurrentUrl();
        assertThat(currentUrl).contains("/login");
    }

    @AfterEach
    public void teardown() {
        if (driver != null) {
            driver.quit();
        }
    }
}
