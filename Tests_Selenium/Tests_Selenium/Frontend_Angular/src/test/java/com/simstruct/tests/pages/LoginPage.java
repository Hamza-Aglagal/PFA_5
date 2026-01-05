package com.simstruct.tests.pages;

import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import com.simstruct.tests.config.TestConfig;

/**
 * Page Object pour la page de Login
 * Encapsule tous les éléments et actions de la page de connexion
 * 
 * Pattern: Page Object Model
 * 
 * @author SimStruct Team
 * @version 1.0
 */
public class LoginPage extends BasePage {
    
    // ========== Locators ==========
    private final By emailInput = By.id(TestConfig.Selectors.EMAIL_INPUT);
    private final By passwordInput = By.id(TestConfig.Selectors.PASSWORD_INPUT);
    private final By loginButton = By.id(TestConfig.Selectors.LOGIN_BUTTON);
    private final By registerLink = By.id("registerLink");
    private final By forgotPasswordLink = By.id("forgotPasswordLink");
    private final By errorMessage = By.className("error-message");
    private final By emailError = By.id("email-error");
    private final By passwordError = By.id("password-error");
    
    /**
     * Constructeur
     * 
     * @param driver WebDriver
     */
    public LoginPage(WebDriver driver) {
        super(driver);
    }
    
    /**
     * Navigue vers la page de login
     * 
     * @return LoginPage pour method chaining
     */
    public LoginPage open() {
        navigateTo(TestConfig.BASE_URL + "/login");
        waitForElement(loginButton);
        return this;
    }
    
    /**
     * Saisit l'email
     * 
     * @param email Email à saisir
     * @return LoginPage pour method chaining
     */
    public LoginPage enterEmail(String email) {
        enterText(emailInput, email);
        return this;
    }
    
    /**
     * Saisit le mot de passe
     * 
     * @param password Mot de passe à saisir
     * @return LoginPage pour method chaining
     */
    public LoginPage enterPassword(String password) {
        enterText(passwordInput, password);
        return this;
    }
    
    /**
     * Clique sur le bouton de connexion
     * 
     * @return DashboardPage si succès
     */
    public DashboardPage clickLogin() {
        clickElement(loginButton);
        return new DashboardPage(driver);
    }
    
    /**
     * Effectue une connexion complète
     * 
     * @param email Email
     * @param password Mot de passe
     * @return DashboardPage si succès
     */
    public DashboardPage login(String email, String password) {
        enterEmail(email);
        enterPassword(password);
        return clickLogin();
    }
    
    /**
     * Connexion avec credentials par défaut
     * 
     * @return DashboardPage
     */
    public DashboardPage loginWithDefaultCredentials() {
        return login(TestConfig.TEST_EMAIL, TestConfig.TEST_PASSWORD);
    }
    
    /**
     * Clique sur le lien d'inscription
     * 
     * @return RegisterPage
     */
    public RegisterPage clickRegisterLink() {
        clickElement(registerLink);
        return new RegisterPage(driver);
    }
    
    /**
     * Clique sur "Mot de passe oublié"
     * 
     * @return ForgotPasswordPage
     */
    public ForgotPasswordPage clickForgotPassword() {
        clickElement(forgotPasswordLink);
        return new ForgotPasswordPage(driver);
    }
    
    /**
     * Récupère le message d'erreur général
     * 
     * @return Message d'erreur
     */
    public String getErrorMessage() {
        return getText(errorMessage);
    }
    
    /**
     * Récupère le message d'erreur de l'email
     * 
     * @return Message d'erreur email
     */
    public String getEmailError() {
        return getText(emailError);
    }
    
    /**
     * Récupère le message d'erreur du mot de passe
     * 
     * @return Message d'erreur password
     */
    public String getPasswordError() {
        return getText(passwordError);
    }
    
    /**
     * Vérifie si le message d'erreur est affiché
     * 
     * @return true si affiché
     */
    public boolean isErrorMessageDisplayed() {
        return isDisplayed(errorMessage);
    }
    
    /**
     * Vérifie si on est sur la page de login
     * 
     * @return true si sur la page de login
     */
    public boolean isOnLoginPage() {
        return getCurrentUrl().contains("/login");
    }
    
    /**
     * Vérifie si le formulaire de login est affiché
     * 
     * @return true si le formulaire est affiché
     */
    public boolean isLoginFormDisplayed() {
        return isDisplayed(emailInput) && 
               isDisplayed(passwordInput) && 
               isDisplayed(loginButton);
    }
}
