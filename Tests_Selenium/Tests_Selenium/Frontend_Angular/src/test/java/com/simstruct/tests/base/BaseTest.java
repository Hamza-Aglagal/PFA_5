package com.simstruct.tests.base;

import com.simstruct.tests.config.TestConfig;
import com.simstruct.tests.config.WebDriverConfig;
import com.simstruct.tests.frontend.ScreenshotUtil;
import org.junit.jupiter.api.*;
import org.openqa.selenium.WebDriver;

/**
 * Classe de base pour tous les tests
 * Gère le cycle de vie du WebDriver et les hooks de test
 * 
 * Pattern: Template Method Pattern
 * 
 * @author SimStruct Team
 * @version 1.0
 */
public abstract class BaseTest {
    
    protected static WebDriver driver;
    protected static String testClassName;
    
    /**
     * Setup avant tous les tests de la classe
     */
    @BeforeAll
    public static void setUpClass(TestInfo testInfo) {
        testClassName = testInfo.getTestClass().get().getSimpleName();
        System.out.println("\n========================================");
        System.out.println("  Démarrage des tests: " + testClassName);
        System.out.println("========================================\n");
        
        // Créer le driver
        driver = WebDriverConfig.createDriver(TestConfig.getBrowserType());
    }
    
    /**
     * Setup avant chaque test
     */
    @BeforeEach
    public void setUp(TestInfo testInfo) {
        String testName = testInfo.getDisplayName();
        System.out.println("\n▶️  Exécution: " + testName);
    }
    
    /**
     * Teardown après chaque test
     */
    @AfterEach
    public void tearDown(TestInfo testInfo) {
        String testName = testInfo.getTestMethod().get().getName();
        
        // Capturer screenshot en cas d'échec
        if (testInfo.getTags().contains("failed")) {
            ScreenshotUtil.captureFailureScreenshot(driver, testName, "Test failed");
        }
        
        System.out.println("✅  Terminé: " + testName + "\n");
    }
    
    /**
     * Teardown après tous les tests de la classe
     */
    @AfterAll
    public static void tearDownClass() {
        System.out.println("\n========================================");
        System.out.println("  Fin des tests: " + testClassName);
        System.out.println("========================================\n");
        
        if (driver != null) {
            driver.quit();
        }
    }
    
    /**
     * Capture un screenshot
     * 
     * @param screenshotName Nom du screenshot
     */
    protected void captureScreenshot(String screenshotName) {
        ScreenshotUtil.captureScreenshot(driver, screenshotName);
    }
    
    /**
     * Capture un screenshot de succès
     * 
     * @param testName Nom du test
     */
    protected void captureSuccessScreenshot(String testName) {
        ScreenshotUtil.captureSuccessScreenshot(driver, testName);
    }
}
