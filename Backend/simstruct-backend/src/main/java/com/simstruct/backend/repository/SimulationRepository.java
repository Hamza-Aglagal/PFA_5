package com.simstruct.backend.repository;

import com.simstruct.backend.entity.Simulation;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

/**
 * Simulation Repository
 */
@Repository
public interface SimulationRepository extends JpaRepository<Simulation, String> {

    // Find all simulations by user
    List<Simulation> findByUserIdOrderByCreatedAtDesc(String userId);

    // Find public simulations
    List<Simulation> findByIsPublicTrueOrderByCreatedAtDesc();

    // Find favorites by user
    List<Simulation> findByUserIdAndIsFavoriteTrueOrderByCreatedAtDesc(String userId);

    // Count simulations by user
    long countByUserId(String userId);

    // Count completed simulations by user
    long countByUserIdAndStatus(String userId, Simulation.SimulationStatus status);

    // Search simulations by name or description for a user
    @Query("SELECT s FROM Simulation s WHERE s.user.id = :userId " +
           "AND (LOWER(s.name) LIKE LOWER(CONCAT('%', :query, '%')) " +
           "OR LOWER(s.description) LIKE LOWER(CONCAT('%', :query, '%'))) " +
           "ORDER BY s.createdAt DESC")
    List<Simulation> searchByUser(@Param("query") String query, @Param("userId") String userId);

    // Search public simulations
    @Query("SELECT s FROM Simulation s WHERE s.isPublic = true " +
           "AND (LOWER(s.name) LIKE LOWER(CONCAT('%', :query, '%')) " +
           "OR LOWER(s.description) LIKE LOWER(CONCAT('%', :query, '%'))) " +
           "ORDER BY s.createdAt DESC")
    List<Simulation> searchPublic(@Param("query") String query);

    // Find recent simulations by user (limit 5)
    List<Simulation> findTop5ByUserIdOrderByCreatedAtDesc(String userId);

    // Find simulation by id and user (for security)
    Optional<Simulation> findByIdAndUserId(String id, String userId);

    // Check if simulation belongs to user
    boolean existsByIdAndUserId(String id, String userId);
}
