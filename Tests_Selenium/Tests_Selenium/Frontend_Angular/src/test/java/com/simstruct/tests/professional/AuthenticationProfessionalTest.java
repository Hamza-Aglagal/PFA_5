package com.simstruct.tests.professional;

import com.simstruct.tests.base.BaseTest;
import com.simstruct.tests.config.TestConfig;
import com.simstruct.tests.pages.*;
import org.junit.jupiter.api.*;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * Tests professionnels pour l'authentification
 * Utilise le pattern Page Object Model
 * 
 * @author SimStruct Team
 * @version 1.0
 */
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
@DisplayName("Tests d'Authentification - Pattern POM")
public class AuthenticationProfessionalTest extends BaseTest {
    
    private LoginPage loginPage;
    
    @BeforeEach
    @Override
    public void setUp(TestInfo testInfo) {
        super.setUp(testInfo);
        loginPage = new LoginPage(driver);
    }
    
    @Test
    @Order(1)
    @DisplayName("✅ Test 1: Vérifier que la page de login s'affiche correctement")
    @Tag("smoke")
    @Tag("authentication")
    public void testLoginPageDisplays() {
        // GIVEN: L'utilisateur navigue vers la page de login
        loginPage.open();
        captureScreenshot("01_login_page_loaded");
        
        // WHEN: La page est chargée
        
        // THEN: Le formulaire de login est affiché
        assertThat(loginPage.isOnLoginPage())
            .as("L'utilisateur devrait être sur la page de login")
            .isTrue();
        
        assertThat(loginPage.isLoginFormDisplayed())
            .as("Le formulaire de login devrait être affiché")
            .isTrue();
        
        assertThat(loginPage.getPageTitle())
            .as("Le titre de la page devrait contenir 'SimStruct'")
            .contains("SimStruct");
        
        captureSuccessScreenshot("01_login_page_verified");
    }
    
    @Test
    @Order(2)
    @DisplayName("✅ Test 2: Login avec credentials valides - Flux complet")
    @Tag("critical")
    @Tag("authentication")
    public void testSuccessfulLogin() {
        // GIVEN: L'utilisateur est sur la page de login
        loginPage.open();
        captureScreenshot("02_before_login");
        
        // WHEN: L'utilisateur se connecte avec des credentials valides
        DashboardPage dashboardPage = loginPage
            .enterEmail(TestConfig.TEST_EMAIL)
            .enterPassword(TestConfig.TEST_PASSWORD)
            .clickLogin();
        
        captureScreenshot("02_after_login_click");
        
        // THEN: L'utilisateur est redirigé vers le dashboard
        dashboardPage.waitForDashboardToLoad();
        captureScreenshot("02_dashboard_loaded");
        
        assertThat(dashboardPage.isOnDashboard())
            .as("L'utilisateur devrait être sur le dashboard")
            .isTrue();
        
        assertThat(dashboardPage.getWelcomeMessage())
            .as("Le message de bienvenue devrait être affiché")
            .contains(TestConfig.SuccessMessages.LOGIN_SUCCESS);
        
        captureSuccessScreenshot("02_login_successful");
    }
    
    @Test
    @Order(3)
    @DisplayName("❌ Test 3: Login avec email invalide")
    @Tag("negative")
    @Tag("authentication")
    public void testLoginWithInvalidEmail() {
        // GIVEN: L'utilisateur est sur la page de login
        loginPage.open();
        
        // WHEN: L'utilisateur essaie de se connecter avec un email invalide
        loginPage
            .enterEmail(TestConfig.INVALID_EMAIL)
            .enterPassword(TestConfig.TEST_PASSWORD)
            .clickLogin();
        
        captureScreenshot("03_invalid_email_attempt");
        
        // THEN: Un message d'erreur est affiché
        assertThat(loginPage.isErrorMessageDisplayed())
            .as("Un message d'erreur devrait être affiché")
            .isTrue();
        
        assertThat(loginPage.getErrorMessage())
            .as("Le message d'erreur devrait indiquer des credentials incorrects")
            .contains(TestConfig.ErrorMessages.INVALID_LOGIN);
        
        assertThat(loginPage.isOnLoginPage())
            .as("L'utilisateur devrait rester sur la page de login")
            .isTrue();
        
        captureScreenshot("03_error_message_displayed");
    }
    
    @Test
    @Order(4)
    @DisplayName("❌ Test 4: Login avec mot de passe invalide")
    @Tag("negative")
    @Tag("authentication")
    public void testLoginWithInvalidPassword() {
        // GIVEN: L'utilisateur est sur la page de login
        loginPage.open();
        
        // WHEN: L'utilisateur essaie de se connecter avec un mot de passe invalide
        loginPage
            .enterEmail(TestConfig.TEST_EMAIL)
            .enterPassword(TestConfig.INVALID_PASSWORD)
            .clickLogin();
        
        captureScreenshot("04_invalid_password_attempt");
        
        // THEN: Un message d'erreur est affiché
        assertThat(loginPage.isErrorMessageDisplayed())
            .as("Un message d'erreur devrait être affiché")
            .isTrue();
        
        assertThat(loginPage.getErrorMessage())
            .as("Le message d'erreur devrait indiquer des credentials incorrects")
            .contains(TestConfig.ErrorMessages.INVALID_LOGIN);
        
        captureScreenshot("04_error_displayed");
    }
    
    @Test
    @Order(5)
    @DisplayName("❌ Test 5: Validation du formulaire - Champs vides")
    @Tag("validation")
    @Tag("authentication")
    public void testLoginFormValidation() {
        // GIVEN: L'utilisateur est sur la page de login
        loginPage.open();
        
        // WHEN: L'utilisateur essaie de se connecter sans remplir les champs
        loginPage.clickLogin();
        
        captureScreenshot("05_empty_form_submission");
        
        // THEN: Des messages de validation sont affichés
        assertThat(loginPage.getEmailError())
            .as("Un message d'erreur pour l'email devrait être affiché")
            .contains(TestConfig.ErrorMessages.REQUIRED_FIELD);
        
        assertThat(loginPage.getPasswordError())
            .as("Un message d'erreur pour le mot de passe devrait être affiché")
            .contains(TestConfig.ErrorMessages.REQUIRED_FIELD);
        
        captureScreenshot("05_validation_errors_displayed");
    }
    
    @Test
    @Order(6)
    @DisplayName("✅ Test 6: Flux complet - Login puis Logout")
    @Tag("smoke")
    @Tag("authentication")
    public void testCompleteLoginLogoutFlow() {
        // GIVEN: L'utilisateur est connecté
        loginPage.open();
        DashboardPage dashboardPage = loginPage.loginWithDefaultCredentials();
        dashboardPage.waitForDashboardToLoad();
        captureScreenshot("06_logged_in");
        
        // WHEN: L'utilisateur se déconnecte
        LoginPage returnedLoginPage = dashboardPage.logout();
        captureScreenshot("06_after_logout");
        
        // THEN: L'utilisateur est redirigé vers la page de login
        assertThat(returnedLoginPage.isOnLoginPage())
            .as("L'utilisateur devrait être redirigé vers la page de login")
            .isTrue();
        
        assertThat(returnedLoginPage.isLoginFormDisplayed())
            .as("Le formulaire de login devrait être affiché")
            .isTrue();
        
        captureSuccessScreenshot("06_logout_successful");
    }
    
    @Test
    @Order(7)
    @DisplayName("✅ Test 7: Navigation vers la page d'inscription")
    @Tag("navigation")
    @Tag("authentication")
    public void testNavigateToRegister() {
        // GIVEN: L'utilisateur est sur la page de login
        loginPage.open();
        
        // WHEN: L'utilisateur clique sur le lien d'inscription
        RegisterPage registerPage = loginPage.clickRegisterLink();
        captureScreenshot("07_register_page");
        
        // THEN: L'utilisateur est redirigé vers la page d'inscription
        assertThat(registerPage.getCurrentUrl())
            .as("L'URL devrait contenir '/register'")
            .contains("/register");
        
        captureSuccessScreenshot("07_navigation_successful");
    }
}
