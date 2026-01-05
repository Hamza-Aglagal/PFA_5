package com.simstruct.tests.pages;

import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;

/**
 * Page Object pour la page Dashboard
 * 
 * @author SimStruct Team
 * @version 1.0
 */
public class DashboardPage extends BasePage {
    
    // ========== Locators ==========
    private final By welcomeMessage = By.className("welcome-message");
    private final By newSimulationButton = By.id("newSimulationBtn");
    private final By historyLink = By.id("historyLink");
    private final By profileLink = By.id("profileLink");
    private final By logoutButton = By.id("logoutBtn");
    private final By recentSimulations = By.className("recent-simulations");
    private final By statsCard = By.className("stats-card");
    
    public DashboardPage(WebDriver driver) {
        super(driver);
    }
    
    /**
     * Attend que le dashboard soit chargé
     * 
     * @return DashboardPage
     */
    public DashboardPage waitForDashboardToLoad() {
        waitForUrl("/dashboard");
        waitForElement(welcomeMessage);
        return this;
    }
    
    /**
     * Clique sur "Nouvelle Simulation"
     * 
     * @return SimulationPage
     */
    public SimulationPage clickNewSimulation() {
        clickElement(newSimulationButton);
        return new SimulationPage(driver);
    }
    
    /**
     * Navigue vers l'historique
     * 
     * @return HistoryPage
     */
    public HistoryPage goToHistory() {
        clickElement(historyLink);
        return new HistoryPage(driver);
    }
    
    /**
     * Navigue vers le profil
     * 
     * @return ProfilePage
     */
    public ProfilePage goToProfile() {
        clickElement(profileLink);
        return new ProfilePage(driver);
    }
    
    /**
     * Se déconnecte
     * 
     * @return LoginPage
     */
    public LoginPage logout() {
        clickElement(logoutButton);
        return new LoginPage(driver);
    }
    
    /**
     * Récupère le message de bienvenue
     * 
     * @return Message de bienvenue
     */
    public String getWelcomeMessage() {
        return getText(welcomeMessage);
    }
    
    /**
     * Vérifie si on est sur le dashboard
     * 
     * @return true si sur le dashboard
     */
    public boolean isOnDashboard() {
        return getCurrentUrl().contains("/dashboard") && 
               isDisplayed(welcomeMessage);
    }
    
    /**
     * Vérifie si les simulations récentes sont affichées
     * 
     * @return true si affichées
     */
    public boolean areRecentSimulationsDisplayed() {
        return isDisplayed(recentSimulations);
    }
}
