package com.simstruct.tests.pages;

import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

import java.time.Duration;

/**
 * Classe de base pour tous les Page Objects
 * Implémente le pattern Page Object Model (POM)
 * 
 * Pattern: Page Object Model
 * 
 * @author SimStruct Team
 * @version 1.0
 */
public abstract class BasePage {
    
    protected WebDriver driver;
    protected WebDriverWait wait;
    protected WebDriverWait longWait;
    
    /**
     * Constructeur de la page de base
     * 
     * @param driver WebDriver
     */
    public BasePage(WebDriver driver) {
        this.driver = driver;
        this.wait = new WebDriverWait(driver, Duration.ofSeconds(10));
        this.longWait = new WebDriverWait(driver, Duration.ofSeconds(30));
    }
    
    /**
     * Attend qu'un élément soit visible
     * 
     * @param by Locator de l'élément
     * @return WebElement visible
     */
    protected WebElement waitForElement(By by) {
        return wait.until(ExpectedConditions.visibilityOfElementLocated(by));
    }
    
    /**
     * Attend qu'un élément soit cliquable
     * 
     * @param by Locator de l'élément
     * @return WebElement cliquable
     */
    protected WebElement waitForClickable(By by) {
        return wait.until(ExpectedConditions.elementToBeClickable(by));
    }
    
    /**
     * Attend qu'un élément soit présent dans le DOM
     * 
     * @param by Locator de l'élément
     * @return WebElement présent
     */
    protected WebElement waitForPresence(By by) {
        return wait.until(ExpectedConditions.presenceOfElementLocated(by));
    }
    
    /**
     * Attend que l'URL contienne un texte spécifique
     * 
     * @param urlPart Partie de l'URL attendue
     */
    protected void waitForUrl(String urlPart) {
        wait.until(ExpectedConditions.urlContains(urlPart));
    }
    
    /**
     * Clique sur un élément de manière sécurisée
     * 
     * @param by Locator de l'élément
     */
    protected void clickElement(By by) {
        waitForClickable(by).click();
    }
    
    /**
     * Saisit du texte dans un champ de manière sécurisée
     * 
     * @param by Locator du champ
     * @param text Texte à saisir
     */
    protected void enterText(By by, String text) {
        WebElement element = waitForElement(by);
        element.clear();
        element.sendKeys(text);
    }
    
    /**
     * Récupère le texte d'un élément
     * 
     * @param by Locator de l'élément
     * @return Texte de l'élément
     */
    protected String getText(By by) {
        return waitForElement(by).getText();
    }
    
    /**
     * Vérifie si un élément est affiché
     * 
     * @param by Locator de l'élément
     * @return true si affiché
     */
    protected boolean isDisplayed(By by) {
        try {
            return driver.findElement(by).isDisplayed();
        } catch (Exception e) {
            return false;
        }
    }
    
    /**
     * Attend qu'un élément disparaisse
     * 
     * @param by Locator de l'élément
     */
    protected void waitForElementToDisappear(By by) {
        wait.until(ExpectedConditions.invisibilityOfElementLocated(by));
    }
    
    /**
     * Scroll vers un élément
     * 
     * @param by Locator de l'élément
     */
    protected void scrollToElement(By by) {
        WebElement element = driver.findElement(by);
        ((org.openqa.selenium.JavascriptExecutor) driver)
            .executeScript("arguments[0].scrollIntoView(true);", element);
    }
    
    /**
     * Retourne l'URL actuelle
     * 
     * @return URL actuelle
     */
    public String getCurrentUrl() {
        return driver.getCurrentUrl();
    }
    
    /**
     * Retourne le titre de la page
     * 
     * @return Titre de la page
     */
    public String getPageTitle() {
        return driver.getTitle();
    }
    
    /**
     * Rafraîchit la page
     */
    public void refresh() {
        driver.navigate().refresh();
    }
    
    /**
     * Navigue vers une URL
     * 
     * @param url URL de destination
     */
    public void navigateTo(String url) {
        driver.get(url);
    }
}
