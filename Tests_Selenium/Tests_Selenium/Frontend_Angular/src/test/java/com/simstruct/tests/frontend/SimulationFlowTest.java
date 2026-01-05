package com.simstruct.tests.frontend;

import io.github.bonigarcia.wdm.WebDriverManager;
import org.junit.jupiter.api.*;
import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.chrome.ChromeOptions;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.Select;
import org.openqa.selenium.support.ui.WebDriverWait;

import java.time.Duration;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * Tests E2E pour le flux complet de simulation
 */
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
public class SimulationFlowTest {

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
        
        driver = new ChromeDriver(options);
        wait = new WebDriverWait(driver, Duration.ofSeconds(15));
        
        // Se connecter avant chaque test
        login();
    }

    private void login() {
        driver.get(BASE_URL + "/login");
        driver.findElement(By.id("email")).sendKeys("test@simstruct.com");
        driver.findElement(By.id("password")).sendKeys("password123");
        driver.findElement(By.id("loginBtn")).click();
        wait.until(ExpectedConditions.urlContains("/dashboard"));
    }

    @Test
    @Order(1)
    @DisplayName("Test 1: Navigation vers nouvelle simulation")
    public void testNavigateToNewSimulation() {
        // Cliquer sur "Nouvelle Simulation"
        WebElement newSimBtn = driver.findElement(By.id("newSimulationBtn"));
        newSimBtn.click();

        // Vérifier la redirection
        wait.until(ExpectedConditions.urlContains("/simulation"));
        
        String currentUrl = driver.getCurrentUrl();
        assertThat(currentUrl).contains("/simulation");
    }

    @Test
    @Order(2)
    @DisplayName("Test 2: Remplir formulaire de simulation - Étape 1")
    public void testFillSimulationFormStep1() {
        driver.get(BASE_URL + "/simulation");

        // Étape 1: Paramètres de base
        driver.findElement(By.id("simulationName")).sendKeys("Test Building 10 Floors");
        
        // Nombre d'étages (slider)
        WebElement floorsSlider = driver.findElement(By.id("numFloorsSlider"));
        // Simuler le changement de valeur
        floorsSlider.sendKeys("10");
        
        // Hauteur par étage
        WebElement heightSlider = driver.findElement(By.id("floorHeightSlider"));
        heightSlider.sendKeys("3.5");
        
        // Nombre de poutres
        driver.findElement(By.id("numBeams")).clear();
        driver.findElement(By.id("numBeams")).sendKeys("120");
        
        // Nombre de colonnes
        driver.findElement(By.id("numColumns")).clear();
        driver.findElement(By.id("numColumns")).sendKeys("36");
        
        // Vérifier que les valeurs sont bien remplies
        WebElement nameInput = driver.findElement(By.id("simulationName"));
        assertThat(nameInput.getAttribute("value")).isEqualTo("Test Building 10 Floors");
    }

    @Test
    @Order(3)
    @DisplayName("Test 3: Remplir formulaire complet et soumettre")
    public void testCompleteSimulationFlow() throws InterruptedException {
        driver.get(BASE_URL + "/simulation");

        // Étape 1: Informations de base
        driver.findElement(By.id("simulationName")).sendKeys("Complete Test Simulation");
        driver.findElement(By.id("numBeams")).clear();
        driver.findElement(By.id("numBeams")).sendKeys("120");
        driver.findElement(By.id("numColumns")).clear();
        driver.findElement(By.id("numColumns")).sendKeys("36");
        
        // Sections
        driver.findElement(By.id("beamSection")).clear();
        driver.findElement(By.id("beamSection")).sendKeys("30");
        driver.findElement(By.id("columnSection")).clear();
        driver.findElement(By.id("columnSection")).sendKeys("40");
        
        // Matériaux
        driver.findElement(By.id("concreteStrength")).clear();
        driver.findElement(By.id("concreteStrength")).sendKeys("35");
        driver.findElement(By.id("steelGrade")).clear();
        driver.findElement(By.id("steelGrade")).sendKeys("355");
        
        // Charges
        driver.findElement(By.id("windLoad")).clear();
        driver.findElement(By.id("windLoad")).sendKeys("1.5");
        driver.findElement(By.id("liveLoad")).clear();
        driver.findElement(By.id("liveLoad")).sendKeys("3.0");
        driver.findElement(By.id("deadLoad")).clear();
        driver.findElement(By.id("deadLoad")).sendKeys("5.0");
        
        // Soumettre le formulaire
        WebElement submitBtn = driver.findElement(By.id("runSimulationBtn"));
        submitBtn.click();
        
        // Attendre le modal de chargement
        WebElement loadingModal = wait.until(
            ExpectedConditions.presenceOfElementLocated(By.className("loading-modal"))
        );
        assertThat(loadingModal.isDisplayed()).isTrue();
        
        // Attendre la redirection vers les résultats (peut prendre du temps)
        wait.withTimeout(Duration.ofSeconds(30))
            .until(ExpectedConditions.urlContains("/results"));
        
        String currentUrl = driver.getCurrentUrl();
        assertThat(currentUrl).contains("/results");
    }

    @Test
    @Order(4)
    @DisplayName("Test 4: Vérifier les résultats de simulation")
    public void testViewSimulationResults() throws InterruptedException {
        // D'abord créer une simulation
        testCompleteSimulationFlow();
        
        // Vérifier la présence des résultats
        WebElement statusCard = wait.until(
            ExpectedConditions.presenceOfElementLocated(By.className("status-card"))
        );
        assertThat(statusCard.isDisplayed()).isTrue();
        
        // Vérifier les métriques
        WebElement deflectionValue = driver.findElement(By.id("maxDeflection"));
        WebElement stressValue = driver.findElement(By.id("maxStress"));
        WebElement stabilityValue = driver.findElement(By.id("stabilityIndex"));
        WebElement seismicValue = driver.findElement(By.id("seismicResistance"));
        
        assertThat(deflectionValue.getText()).isNotEmpty();
        assertThat(stressValue.getText()).isNotEmpty();
        assertThat(stabilityValue.getText()).isNotEmpty();
        assertThat(seismicValue.getText()).isNotEmpty();
        
        // Vérifier le statut
        WebElement statusBadge = driver.findElement(By.className("status-badge"));
        String status = statusBadge.getText();
        assertThat(status).isIn("Excellent", "Bon", "Acceptable", "Faible");
    }

    @Test
    @Order(5)
    @DisplayName("Test 5: Validation du formulaire")
    public void testFormValidation() {
        driver.get(BASE_URL + "/simulation");

        // Essayer de soumettre sans remplir
        WebElement submitBtn = driver.findElement(By.id("runSimulationBtn"));
        submitBtn.click();

        // Vérifier les messages d'erreur
        WebElement nameError = driver.findElement(By.id("name-error"));
        assertThat(nameError.getText()).contains("requis");
    }

    @Test
    @Order(6)
    @DisplayName("Test 6: Navigation vers l'historique")
    public void testNavigateToHistory() {
        // Cliquer sur le menu Historique
        WebElement historyLink = driver.findElement(By.id("historyLink"));
        historyLink.click();

        wait.until(ExpectedConditions.urlContains("/history"));
        
        String currentUrl = driver.getCurrentUrl();
        assertThat(currentUrl).contains("/history");
        
        // Vérifier la présence de la liste
        WebElement simulationList = wait.until(
            ExpectedConditions.presenceOfElementLocated(By.className("simulation-list"))
        );
        assertThat(simulationList.isDisplayed()).isTrue();
    }

    @Test
    @Order(7)
    @DisplayName("Test 7: Recherche dans l'historique")
    public void testSearchHistory() throws InterruptedException {
        driver.get(BASE_URL + "/history");

        // Utiliser la barre de recherche
        WebElement searchInput = driver.findElement(By.id("searchInput"));
        searchInput.sendKeys("Test");
        
        // Attendre les résultats filtrés
        Thread.sleep(500); // Debounce
        
        // Vérifier que les résultats contiennent "Test"
        WebElement firstResult = driver.findElement(By.className("simulation-card"));
        assertThat(firstResult.getText()).containsIgnoringCase("Test");
    }

    @Test
    @Order(8)
    @DisplayName("Test 8: Supprimer une simulation")
    public void testDeleteSimulation() {
        driver.get(BASE_URL + "/history");

        // Cliquer sur le bouton supprimer de la première simulation
        WebElement deleteBtn = driver.findElement(By.className("delete-btn"));
        deleteBtn.click();

        // Confirmer dans le modal
        WebElement confirmBtn = wait.until(
            ExpectedConditions.presenceOfElementLocated(By.id("confirmDeleteBtn"))
        );
        confirmBtn.click();

        // Vérifier le message de succès
        WebElement successMessage = wait.until(
            ExpectedConditions.presenceOfElementLocated(By.className("success-toast"))
        );
        assertThat(successMessage.getText()).contains("supprimée");
    }

    @AfterEach
    public void teardown() {
        if (driver != null) {
            driver.quit();
        }
    }
}
