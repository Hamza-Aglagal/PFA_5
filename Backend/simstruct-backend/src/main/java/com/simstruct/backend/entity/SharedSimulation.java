package com.simstruct.backend.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

/**
 * SharedSimulation Entity - represents a simulation shared with a friend
 */
@Entity
@Table(name = "shared_simulations")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SharedSimulation {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "simulation_id", nullable = false)
    private Simulation simulation;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "shared_by_id", nullable = false)
    private User sharedBy;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "shared_with_id", nullable = false)
    private User sharedWith;

    @Column(length = 500)
    private String message;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private SharePermission permission;

    @CreationTimestamp
    private LocalDateTime sharedAt;

    public enum SharePermission {
        VIEW,       // Can only view
        COMMENT,    // Can view and comment
        EDIT        // Can view, comment, and edit
    }
}
