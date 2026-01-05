package com.simstruct.tests.config;

/**
 * Configuration centralisée de l'application
 * Contient toutes les URLs, timeouts, et constantes
 * 
 * Pattern: Singleton pour configuration globale
 * 
 * @author SimStruct Team
 * @version 1.0
 */
public class TestConfig {
    
    // ========== URLs ==========
    public static final String BASE_URL = getProperty("base.url", "http://localhost:4200");
    public static final String API_URL = getProperty("api.url", "http://localhost:8080/api/v1");
    public static final String AI_API_URL = getProperty("ai.api.url", "http://localhost:8000");
    
    // ========== Timeouts (en secondes) ==========
    public static final int DEFAULT_TIMEOUT = 10;
    public static final int LONG_TIMEOUT = 30;
    public static final int SHORT_TIMEOUT = 5;
    public static final int ANIMATION_TIMEOUT = 2;
    
    // ========== Credentials de Test ==========
    public static final String TEST_EMAIL = "test@simstruct.com";
    public static final String TEST_PASSWORD = "password123";
    public static final String TEST_NAME = "Test User";
    
    // Credentials invalides pour tests négatifs
    public static final String INVALID_EMAIL = "wrong@email.com";
    public static final String INVALID_PASSWORD = "wrongpassword";
    
    // ========== Données de Test - Simulation ==========
    public static class SimulationData {
        public static final String DEFAULT_NAME = "Test Simulation";
        public static final int DEFAULT_NUM_FLOORS = 10;
        public static final double DEFAULT_FLOOR_HEIGHT = 3.5;
        public static final int DEFAULT_NUM_BEAMS = 120;
        public static final int DEFAULT_NUM_COLUMNS = 36;
        public static final double DEFAULT_BEAM_SECTION = 30.0;
        public static final double DEFAULT_COLUMN_SECTION = 40.0;
        public static final double DEFAULT_CONCRETE_STRENGTH = 35.0;
        public static final double DEFAULT_STEEL_GRADE = 355.0;
        public static final double DEFAULT_WIND_LOAD = 1.5;
        public static final double DEFAULT_LIVE_LOAD = 3.0;
        public static final double DEFAULT_DEAD_LOAD = 5.0;
    }
    
    // ========== Chemins des Screenshots ==========
    public static final String SCREENSHOT_DIR = "target/screenshots/";
    public static final String REPORT_DIR = "target/surefire-reports/";
    
    // ========== Messages d'Erreur Attendus ==========
    public static class ErrorMessages {
        public static final String INVALID_LOGIN = "Email ou mot de passe incorrect";
        public static final String REQUIRED_FIELD = "requis";
        public static final String INVALID_EMAIL_FORMAT = "Email invalide";
        public static final String PASSWORD_TOO_SHORT = "Le mot de passe doit contenir au moins 4 caractères";
    }
    
    // ========== Messages de Succès Attendus ==========
    public static class SuccessMessages {
        public static final String LOGIN_SUCCESS = "Bienvenue";
        public static final String SIMULATION_CREATED = "Simulation créée";
        public static final String SIMULATION_DELETED = "supprimée";
    }
    
    // ========== Sélecteurs CSS/ID Communs ==========
    public static class Selectors {
        // Auth
        public static final String EMAIL_INPUT = "email";
        public static final String PASSWORD_INPUT = "password";
        public static final String LOGIN_BUTTON = "loginBtn";
        public static final String REGISTER_BUTTON = "registerBtn";
        public static final String LOGOUT_BUTTON = "logoutBtn";
        
        // Navigation
        public static final String DASHBOARD_LINK = "dashboardLink";
        public static final String SIMULATION_LINK = "simulationLink";
        public static final String HISTORY_LINK = "historyLink";
        public static final String PROFILE_LINK = "profileLink";
        
        // Simulation
        public static final String SIMULATION_NAME = "simulationName";
        public static final String RUN_SIMULATION_BTN = "runSimulationBtn";
        public static final String NEW_SIMULATION_BTN = "newSimulationBtn";
        
        // Results
        public static final String MAX_DEFLECTION = "maxDeflection";
        public static final String MAX_STRESS = "maxStress";
        public static final String STABILITY_INDEX = "stabilityIndex";
        public static final String SEISMIC_RESISTANCE = "seismicResistance";
        public static final String STATUS_BADGE = "status-badge";
    }
    
    /**
     * Récupère une propriété système ou retourne la valeur par défaut
     * 
     * @param key Clé de la propriété
     * @param defaultValue Valeur par défaut
     * @return Valeur de la propriété
     */
    private static String getProperty(String key, String defaultValue) {
        return System.getProperty(key, defaultValue);
    }
    
    /**
     * Vérifie si on est en mode CI/CD
     * 
     * @return true si en mode CI/CD
     */
    public static boolean isCIMode() {
        return Boolean.parseBoolean(System.getProperty("ci.mode", "false"));
    }
    
    /**
     * Retourne le type de navigateur à utiliser
     * 
     * @return Type de navigateur
     */
    public static WebDriverConfig.BrowserType getBrowserType() {
        String browser = System.getProperty("browser", "chrome");
        
        if (isCIMode()) {
            return WebDriverConfig.BrowserType.CHROME_HEADLESS;
        }
        
        return switch (browser.toLowerCase()) {
            case "firefox" -> WebDriverConfig.BrowserType.FIREFOX;
            case "edge" -> WebDriverConfig.BrowserType.EDGE;
            case "headless" -> WebDriverConfig.BrowserType.CHROME_HEADLESS;
            default -> WebDriverConfig.BrowserType.CHROME;
        };
    }
}
