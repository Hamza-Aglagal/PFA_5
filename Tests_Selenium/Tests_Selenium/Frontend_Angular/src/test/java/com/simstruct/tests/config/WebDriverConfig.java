package com.simstruct.tests.config;

import org.openqa.selenium.WebDriver;
import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.chrome.ChromeOptions;
import org.openqa.selenium.firefox.FirefoxDriver;
import org.openqa.selenium.firefox.FirefoxOptions;
import org.openqa.selenium.edge.EdgeDriver;
import org.openqa.selenium.edge.EdgeOptions;
import io.github.bonigarcia.wdm.WebDriverManager;

import java.time.Duration;

/**
 * Configuration centralisée pour les WebDrivers
 * Pattern: Factory Pattern pour la création de drivers
 * 
 * @author SimStruct Team
 * @version 1.0
 */
public class WebDriverConfig {
    
    // Configuration par défaut
    private static final int DEFAULT_TIMEOUT = 10;
    private static final int PAGE_LOAD_TIMEOUT = 30;
    private static final int IMPLICIT_WAIT = 5;
    
    // Types de navigateurs supportés
    public enum BrowserType {
        CHROME,
        FIREFOX,
        EDGE,
        CHROME_HEADLESS
    }
    
    /**
     * Crée un WebDriver selon le type de navigateur spécifié
     * 
     * @param browserType Type de navigateur
     * @return WebDriver configuré
     */
    public static WebDriver createDriver(BrowserType browserType) {
        WebDriver driver;
        
        switch (browserType) {
            case CHROME:
                driver = createChromeDriver(false);
                break;
            case CHROME_HEADLESS:
                driver = createChromeDriver(true);
                break;
            case FIREFOX:
                driver = createFirefoxDriver();
                break;
            case EDGE:
                driver = createEdgeDriver();
                break;
            default:
                driver = createChromeDriver(false);
        }
        
        // Configuration commune
        configureDriver(driver);
        
        return driver;
    }
    
    /**
     * Crée un driver Chrome avec options personnalisées
     * 
     * @param headless Mode headless (sans interface graphique)
     * @return ChromeDriver configuré
     */
    private static WebDriver createChromeDriver(boolean headless) {
        WebDriverManager.chromedriver().setup();
        
        ChromeOptions options = new ChromeOptions();
        
        // Options de performance
        options.addArguments("--start-maximized");
        options.addArguments("--disable-notifications");
        options.addArguments("--disable-popup-blocking");
        options.addArguments("--disable-infobars");
        options.addArguments("--disable-extensions");
        
        // Désactiver les logs inutiles
        options.addArguments("--log-level=3");
        options.addArguments("--silent");
        
        // Mode headless si demandé
        if (headless) {
            options.addArguments("--headless");
            options.addArguments("--window-size=1920,1080");
        }
        
        // Préférences Chrome
        options.setExperimentalOption("excludeSwitches", new String[]{"enable-logging"});
        
        return new ChromeDriver(options);
    }
    
    /**
     * Crée un driver Firefox
     * 
     * @return FirefoxDriver configuré
     */
    private static WebDriver createFirefoxDriver() {
        WebDriverManager.firefoxdriver().setup();
        
        FirefoxOptions options = new FirefoxOptions();
        options.addArguments("--width=1920");
        options.addArguments("--height=1080");
        
        return new FirefoxDriver(options);
    }
    
    /**
     * Crée un driver Edge
     * 
     * @return EdgeDriver configuré
     */
    private static WebDriver createEdgeDriver() {
        WebDriverManager.edgedriver().setup();
        
        EdgeOptions options = new EdgeOptions();
        options.addArguments("--start-maximized");
        
        return new EdgeDriver(options);
    }
    
    /**
     * Configure les timeouts du driver
     * 
     * @param driver WebDriver à configurer
     */
    private static void configureDriver(WebDriver driver) {
        driver.manage().timeouts().implicitlyWait(Duration.ofSeconds(IMPLICIT_WAIT));
        driver.manage().timeouts().pageLoadTimeout(Duration.ofSeconds(PAGE_LOAD_TIMEOUT));
        driver.manage().timeouts().scriptTimeout(Duration.ofSeconds(DEFAULT_TIMEOUT));
    }
    
    /**
     * Crée un driver par défaut (Chrome)
     * 
     * @return WebDriver Chrome
     */
    public static WebDriver createDefaultDriver() {
        return createDriver(BrowserType.CHROME);
    }
}
