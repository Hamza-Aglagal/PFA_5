package com.simstruct.backend;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;

/**
 * Test de base pour l'application Spring Boot
 */
@SpringBootTest
@ActiveProfiles("test")
class SimstructBackendApplicationTests {

    @Test
    void contextLoads() {
        // Le test réussit si le contexte Spring charge correctement
    }

    @Test
    void testMain() {
        // Teste le point d'entrée de l'application
        SimstructBackendApplication.main(new String[]{});
    }
}
