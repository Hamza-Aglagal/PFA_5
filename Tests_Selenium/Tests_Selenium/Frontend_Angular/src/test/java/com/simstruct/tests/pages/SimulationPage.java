package com.simstruct.tests.pages;

import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import com.simstruct.tests.config.TestConfig;

/**
 * Page Object pour la page de Simulation
 * 
 * @author SimStruct Team
 * @version 1.0
 */
public class SimulationPage extends BasePage {
    
    // ========== Locators ==========
    private final By simulationNameInput = By.id("simulationName");
    private final By numFloorsSlider = By.id("numFloorsSlider");
    private final By floorHeightSlider = By.id("floorHeightSlider");
    private final By numBeamsInput = By.id("numBeams");
    private final By numColumnsInput = By.id("numColumns");
    private final By beamSectionInput = By.id("beamSection");
    private final By columnSectionInput = By.id("columnSection");
    private final By concreteStrengthInput = By.id("concreteStrength");
    private final By steelGradeInput = By.id("steelGrade");
    private final By windLoadInput = By.id("windLoad");
    private final By liveLoadInput = By.id("liveLoad");
    private final By deadLoadInput = By.id("deadLoad");
    private final By runSimulationButton = By.id("runSimulationBtn");
    private final By loadingModal = By.className("loading-modal");
    
    public SimulationPage(WebDriver driver) {
        super(driver);
    }
    
    /**
     * Remplit le formulaire de simulation avec les données par défaut
     * 
     * @return SimulationPage
     */
    public SimulationPage fillDefaultSimulationForm() {
        return fillSimulationForm(
            TestConfig.SimulationData.DEFAULT_NAME,
            TestConfig.SimulationData.DEFAULT_NUM_BEAMS,
            TestConfig.SimulationData.DEFAULT_NUM_COLUMNS,
            TestConfig.SimulationData.DEFAULT_BEAM_SECTION,
            TestConfig.SimulationData.DEFAULT_COLUMN_SECTION,
            TestConfig.SimulationData.DEFAULT_CONCRETE_STRENGTH,
            TestConfig.SimulationData.DEFAULT_STEEL_GRADE,
            TestConfig.SimulationData.DEFAULT_WIND_LOAD,
            TestConfig.SimulationData.DEFAULT_LIVE_LOAD,
            TestConfig.SimulationData.DEFAULT_DEAD_LOAD
        );
    }
    
    /**
     * Remplit le formulaire de simulation
     * 
     * @param name Nom de la simulation
     * @param numBeams Nombre de poutres
     * @param numColumns Nombre de colonnes
     * @param beamSection Section de poutre
     * @param columnSection Section de colonne
     * @param concreteStrength Résistance du béton
     * @param steelGrade Grade d'acier
     * @param windLoad Charge de vent
     * @param liveLoad Charge vive
     * @param deadLoad Charge morte
     * @return SimulationPage
     */
    public SimulationPage fillSimulationForm(
            String name,
            int numBeams,
            int numColumns,
            double beamSection,
            double columnSection,
            double concreteStrength,
            double steelGrade,
            double windLoad,
            double liveLoad,
            double deadLoad) {
        
        enterText(simulationNameInput, name);
        enterText(numBeamsInput, String.valueOf(numBeams));
        enterText(numColumnsInput, String.valueOf(numColumns));
        enterText(beamSectionInput, String.valueOf(beamSection));
        enterText(columnSectionInput, String.valueOf(columnSection));
        enterText(concreteStrengthInput, String.valueOf(concreteStrength));
        enterText(steelGradeInput, String.valueOf(steelGrade));
        enterText(windLoadInput, String.valueOf(windLoad));
        enterText(liveLoadInput, String.valueOf(liveLoad));
        enterText(deadLoadInput, String.valueOf(deadLoad));
        
        return this;
    }
    
    /**
     * Lance la simulation
     * 
     * @return ResultsPage
     */
    public ResultsPage runSimulation() {
        clickElement(runSimulationButton);
        // Attendre que le modal de chargement apparaisse puis disparaisse
        waitForElement(loadingModal);
        waitForElementToDisappear(loadingModal);
        return new ResultsPage(driver);
    }
}
