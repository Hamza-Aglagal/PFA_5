package com.simstruct.tests.professional;

import com.simstruct.tests.base.BaseTest;
import com.simstruct.tests.config.TestConfig;
import com.simstruct.tests.pages.*;
import org.junit.jupiter.api.*;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * Tests professionnels pour le flux de simulation complet
 * Teste l'intégration complète: Login → Simulation → Résultats
 * 
 * @author SimStruct Team
 * @version 1.0
 */
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
@DisplayName("Tests de Simulation - Flux Complet E2E")
public class SimulationFlowProfessionalTest extends BaseTest {
    
    private LoginPage loginPage;
    private DashboardPage dashboardPage;
    
    @BeforeEach
    @Override
    public void setUp(TestInfo testInfo) {
        super.setUp(testInfo);
        
        // Précondition: L'utilisateur doit être connecté pour tous les tests
        loginPage = new LoginPage(driver);
        loginPage.open();
        dashboardPage = loginPage.loginWithDefaultCredentials();
        dashboardPage.waitForDashboardToLoad();
    }
    
    @Test
    @Order(1)
    @DisplayName("✅ Test 1: Navigation vers nouvelle simulation")
    @Tag("smoke")
    @Tag("simulation")
    public void testNavigateToNewSimulation() {
        // GIVEN: L'utilisateur est sur le dashboard
        captureScreenshot("sim_01_dashboard");
        
        // WHEN: L'utilisateur clique sur "Nouvelle Simulation"
        SimulationPage simulationPage = dashboardPage.clickNewSimulation();
        captureScreenshot("sim_01_simulation_page");
        
        // THEN: L'utilisateur est redirigé vers la page de simulation
        assertThat(simulationPage.getCurrentUrl())
            .as("L'URL devrait contenir '/simulation'")
            .contains("/simulation");
        
        captureSuccessScreenshot("sim_01_navigation_success");
    }
    
    @Test
    @Order(2)
    @DisplayName("✅ Test 2: Créer une simulation complète - Flux E2E")
    @Tag("critical")
    @Tag("simulation")
    @Tag("e2e")
    public void testCompleteSimulationFlow() {
        // GIVEN: L'utilisateur est sur le dashboard
        captureScreenshot("sim_02_start_dashboard");
        
        // WHEN: L'utilisateur crée une nouvelle simulation
        SimulationPage simulationPage = dashboardPage.clickNewSimulation();
        captureScreenshot("sim_02_simulation_form");
        
        // AND: Remplit le formulaire avec les données par défaut
        simulationPage.fillDefaultSimulationForm();
        captureScreenshot("sim_02_form_filled");
        
        // AND: Lance la simulation
        ResultsPage resultsPage = simulationPage.runSimulation();
        captureScreenshot("sim_02_simulation_running");
        
        // THEN: Les résultats sont affichés
        resultsPage.waitForResults();
        captureScreenshot("sim_02_results_displayed");
        
        assertThat(resultsPage.getCurrentUrl())
            .as("L'URL devrait contenir '/results'")
            .contains("/results");
        
        assertThat(resultsPage.areAllResultsDisplayed())
            .as("Tous les résultats devraient être affichés")
            .isTrue();
        
        // Vérifier que les valeurs sont présentes
        String maxDeflection = resultsPage.getMaxDeflection();
        String maxStress = resultsPage.getMaxStress();
        String stabilityIndex = resultsPage.getStabilityIndex();
        String seismicResistance = resultsPage.getSeismicResistance();
        String status = resultsPage.getStatus();
        
        assertThat(maxDeflection)
            .as("La déflexion maximale devrait être affichée")
            .isNotEmpty();
        
        assertThat(maxStress)
            .as("La contrainte maximale devrait être affichée")
            .isNotEmpty();
        
        assertThat(stabilityIndex)
            .as("L'indice de stabilité devrait être affiché")
            .isNotEmpty();
        
        assertThat(seismicResistance)
            .as("La résistance sismique devrait être affichée")
            .isNotEmpty();
        
        assertThat(status)
            .as("Le statut devrait être l'un des statuts valides")
            .isIn("Excellent", "Bon", "Acceptable", "Faible");
        
        captureSuccessScreenshot("sim_02_simulation_complete");
        
        // Afficher les résultats dans la console
        System.out.println("\n📊 Résultats de la Simulation:");
        System.out.println("   Déflexion maximale: " + maxDeflection + " mm");
        System.out.println("   Contrainte maximale: " + maxStress + " MPa");
        System.out.println("   Indice de stabilité: " + stabilityIndex);
        System.out.println("   Résistance sismique: " + seismicResistance);
        System.out.println("   Statut: " + status + "\n");
    }
    
    @Test
    @Order(3)
    @DisplayName("✅ Test 3: Créer simulation avec données personnalisées")
    @Tag("simulation")
    @Tag("custom-data")
    public void testSimulationWithCustomData() {
        // GIVEN: L'utilisateur est sur la page de simulation
        SimulationPage simulationPage = dashboardPage.clickNewSimulation();
        
        // WHEN: L'utilisateur remplit le formulaire avec des données personnalisées
        simulationPage.fillSimulationForm(
            "Immeuble 15 Étages - Test",
            200,  // numBeams
            64,   // numColumns
            40.0, // beamSection
            60.0, // columnSection
            50.0, // concreteStrength
            420.0, // steelGrade
            2.0,  // windLoad
            4.0,  // liveLoad
            6.0   // deadLoad
        );
        
        captureScreenshot("sim_03_custom_form_filled");
        
        // AND: Lance la simulation
        ResultsPage resultsPage = simulationPage.runSimulation();
        resultsPage.waitForResults();
        
        captureScreenshot("sim_03_custom_results");
        
        // THEN: Les résultats sont affichés
        assertThat(resultsPage.areAllResultsDisplayed())
            .as("Tous les résultats devraient être affichés")
            .isTrue();
        
        captureSuccessScreenshot("sim_03_custom_simulation_success");
    }
    
    @Test
    @Order(4)
    @DisplayName("✅ Test 4: Retour au dashboard depuis les résultats")
    @Tag("navigation")
    @Tag("simulation")
    public void testNavigateBackFromResults() {
        // GIVEN: L'utilisateur a créé une simulation et est sur la page de résultats
        SimulationPage simulationPage = dashboardPage.clickNewSimulation();
        simulationPage.fillDefaultSimulationForm();
        ResultsPage resultsPage = simulationPage.runSimulation();
        resultsPage.waitForResults();
        
        captureScreenshot("sim_04_on_results_page");
        
        // WHEN: L'utilisateur clique sur "Retour"
        DashboardPage returnedDashboard = resultsPage.goBack();
        
        captureScreenshot("sim_04_back_to_dashboard");
        
        // THEN: L'utilisateur est redirigé vers le dashboard
        assertThat(returnedDashboard.isOnDashboard())
            .as("L'utilisateur devrait être de retour sur le dashboard")
            .isTrue();
        
        captureSuccessScreenshot("sim_04_navigation_back_success");
    }
    
    @Test
    @Order(5)
    @DisplayName("✅ Test 5: Scénario réaliste - Petit immeuble")
    @Tag("scenario")
    @Tag("simulation")
    public void testSmallBuildingScenario() {
        // GIVEN: Un scénario de petit immeuble (5 étages)
        SimulationPage simulationPage = dashboardPage.clickNewSimulation();
        
        // WHEN: Création d'une simulation pour un petit immeuble
        simulationPage.fillSimulationForm(
            "Petit Immeuble 5 Étages",
            60,   // numBeams
            16,   // numColumns
            25.0, // beamSection
            35.0, // columnSection
            30.0, // concreteStrength
            355.0, // steelGrade
            1.0,  // windLoad
            2.5,  // liveLoad
            4.0   // deadLoad
        );
        
        captureScreenshot("sim_05_small_building_form");
        
        ResultsPage resultsPage = simulationPage.runSimulation();
        resultsPage.waitForResults();
        
        captureScreenshot("sim_05_small_building_results");
        
        // THEN: Les résultats devraient montrer une bonne stabilité
        String status = resultsPage.getStatus();
        
        assertThat(status)
            .as("Un petit immeuble devrait avoir un bon statut")
            .isIn("Excellent", "Bon");
        
        captureSuccessScreenshot("sim_05_small_building_success");
        
        System.out.println("\n🏢 Scénario: Petit Immeuble");
        System.out.println("   Statut: " + status);
    }
    
    @Test
    @Order(6)
    @DisplayName("✅ Test 6: Scénario réaliste - Grand immeuble")
    @Tag("scenario")
    @Tag("simulation")
    public void testLargeBuildingScenario() {
        // GIVEN: Un scénario de grand immeuble (20 étages)
        SimulationPage simulationPage = dashboardPage.clickNewSimulation();
        
        // WHEN: Création d'une simulation pour un grand immeuble
        simulationPage.fillSimulationForm(
            "Grand Immeuble 20 Étages",
            300,  // numBeams
            100,  // numColumns
            50.0, // beamSection
            80.0, // columnSection
            60.0, // concreteStrength
            460.0, // steelGrade
            2.5,  // windLoad
            5.0,  // liveLoad
            7.0   // deadLoad
        );
        
        captureScreenshot("sim_06_large_building_form");
        
        ResultsPage resultsPage = simulationPage.runSimulation();
        resultsPage.waitForResults();
        
        captureScreenshot("sim_06_large_building_results");
        
        // THEN: Les résultats sont affichés
        assertThat(resultsPage.areAllResultsDisplayed())
            .as("Tous les résultats devraient être affichés")
            .isTrue();
        
        String status = resultsPage.getStatus();
        
        captureSuccessScreenshot("sim_06_large_building_success");
        
        System.out.println("\n🏙️  Scénario: Grand Immeuble");
        System.out.println("   Statut: " + status);
    }
}
