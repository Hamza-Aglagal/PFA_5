package com.simstruct.backend.repository;

import com.simstruct.backend.entity.SharedSimulation;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface SharedSimulationRepository extends JpaRepository<SharedSimulation, String> {

    // Find simulations shared by a user
    List<SharedSimulation> findBySharedByIdOrderBySharedAtDesc(String userId);

    // Find simulations shared with a user
    List<SharedSimulation> findBySharedWithIdOrderBySharedAtDesc(String userId);

    // Find simulations shared between two users (sent)
    List<SharedSimulation> findBySharedByIdAndSharedWithIdOrderBySharedAtDesc(String sharedById, String sharedWithId);

    // Find simulations shared between two users (received)
    @Query("SELECT ss FROM SharedSimulation ss WHERE ss.sharedBy.id = :friendId AND ss.sharedWith.id = :userId ORDER BY ss.sharedAt DESC")
    List<SharedSimulation> findReceivedFromFriend(@Param("userId") String userId, @Param("friendId") String friendId);

    // Check if simulation is already shared with user
    @Query("SELECT ss FROM SharedSimulation ss WHERE ss.simulation.id = :simulationId AND ss.sharedWith.id = :sharedWithId")
    Optional<SharedSimulation> findBySimulationIdAndSharedWithId(@Param("simulationId") String simulationId, @Param("sharedWithId") String sharedWithId);

    // Count shares by user
    long countBySharedById(String userId);

    // Count shares received by user
    long countBySharedWithId(String userId);
}
