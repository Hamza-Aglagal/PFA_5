package com.simstruct.tests.pages;

import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import com.simstruct.tests.config.TestConfig;

/**
 * Page Object pour la page de Résultats
 * 
 * @author SimStruct Team
 * @version 1.0
 */
public class ResultsPage extends BasePage {
    
    // ========== Locators ==========
    private final By maxDeflection = By.id(TestConfig.Selectors.MAX_DEFLECTION);
    private final By maxStress = By.id(TestConfig.Selectors.MAX_STRESS);
    private final By stabilityIndex = By.id(TestConfig.Selectors.STABILITY_INDEX);
    private final By seismicResistance = By.id(TestConfig.Selectors.SEISMIC_RESISTANCE);
    private final By statusBadge = By.className(TestConfig.Selectors.STATUS_BADGE);
    private final By statusCard = By.className("status-card");
    private final By backButton = By.id("backBtn");
    private final By saveButton = By.id("saveBtn");
    private final By exportButton = By.id("exportBtn");
    
    public ResultsPage(WebDriver driver) {
        super(driver);
    }
    
    /**
     * Attend que les résultats soient chargés
     * 
     * @return ResultsPage
     */
    public ResultsPage waitForResults() {
        waitForUrl("/results");
        waitForElement(statusCard);
        return this;
    }
    
    /**
     * Récupère la déflexion maximale
     * 
     * @return Déflexion maximale
     */
    public String getMaxDeflection() {
        return getText(maxDeflection);
    }
    
    /**
     * Récupère la contrainte maximale
     * 
     * @return Contrainte maximale
     */
    public String getMaxStress() {
        return getText(maxStress);
    }
    
    /**
     * Récupère l'indice de stabilité
     * 
     * @return Indice de stabilité
     */
    public String getStabilityIndex() {
        return getText(stabilityIndex);
    }
    
    /**
     * Récupère la résistance sismique
     * 
     * @return Résistance sismique
     */
    public String getSeismicResistance() {
        return getText(seismicResistance);
    }
    
    /**
     * Récupère le statut
     * 
     * @return Statut (Excellent, Bon, Acceptable, Faible)
     */
    public String getStatus() {
        return getText(statusBadge);
    }
    
    /**
     * Vérifie si tous les résultats sont affichés
     * 
     * @return true si tous les résultats sont affichés
     */
    public boolean areAllResultsDisplayed() {
        return isDisplayed(maxDeflection) &&
               isDisplayed(maxStress) &&
               isDisplayed(stabilityIndex) &&
               isDisplayed(seismicResistance) &&
               isDisplayed(statusBadge);
    }
    
    /**
     * Retourne au dashboard
     * 
     * @return DashboardPage
     */
    public DashboardPage goBack() {
        clickElement(backButton);
        return new DashboardPage(driver);
    }
}
