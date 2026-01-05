package com.simstruct.tests.frontend;

import org.openqa.selenium.OutputType;
import org.openqa.selenium.TakesScreenshot;
import org.openqa.selenium.WebDriver;
import org.apache.commons.io.FileUtils;

import java.io.File;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;

/**
 * Utilitaire pour capturer des screenshots pendant les tests Selenium
 */
public class ScreenshotUtil {
    
    private static final String SCREENSHOT_DIR = "target/screenshots/";
    
    /**
     * Capture un screenshot et le sauvegarde avec un nom personnalisé
     * 
     * @param driver Le WebDriver
     * @param screenshotName Le nom du screenshot
     * @return Le chemin du fichier créé
     */
    public static String captureScreenshot(WebDriver driver, String screenshotName) {
        try {
            // Créer le dossier si nécessaire
            File directory = new File(SCREENSHOT_DIR);
            if (!directory.exists()) {
                directory.mkdirs();
            }
            
            // Générer le nom du fichier avec timestamp
            String timestamp = new SimpleDateFormat("yyyyMMdd_HHmmss").format(new Date());
            String fileName = screenshotName + "_" + timestamp + ".png";
            String filePath = SCREENSHOT_DIR + fileName;
            
            // Capturer le screenshot
            TakesScreenshot screenshot = (TakesScreenshot) driver;
            File sourceFile = screenshot.getScreenshotAs(OutputType.FILE);
            File destinationFile = new File(filePath);
            
            // Copier le fichier
            FileUtils.copyFile(sourceFile, destinationFile);
            
            System.out.println("📸 Screenshot capturé: " + filePath);
            return filePath;
            
        } catch (IOException e) {
            System.err.println("❌ Erreur lors de la capture du screenshot: " + e.getMessage());
            return null;
        }
    }
    
    /**
     * Capture un screenshot en cas d'échec de test
     * 
     * @param driver Le WebDriver
     * @param testName Le nom du test
     * @param errorMessage Le message d'erreur
     * @return Le chemin du fichier créé
     */
    public static String captureFailureScreenshot(WebDriver driver, String testName, String errorMessage) {
        String screenshotName = "FAILURE_" + testName;
        String path = captureScreenshot(driver, screenshotName);
        
        if (path != null) {
            System.err.println("❌ Test échoué: " + testName);
            System.err.println("   Erreur: " + errorMessage);
            System.err.println("   Screenshot: " + path);
        }
        
        return path;
    }
    
    /**
     * Capture un screenshot de succès
     * 
     * @param driver Le WebDriver
     * @param testName Le nom du test
     * @return Le chemin du fichier créé
     */
    public static String captureSuccessScreenshot(WebDriver driver, String testName) {
        String screenshotName = "SUCCESS_" + testName;
        return captureScreenshot(driver, screenshotName);
    }
}
