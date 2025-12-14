package com.simstruct.backend.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SharedSimulationDTO {
    private String id;
    private String simulationId;
    private String simulationName;
    private String simulationDescription;
    private String materialType;
    private String supportType;
    private Double safetyFactor;
    private Boolean isSafe;
    private String sharedById;
    private String sharedByName;
    private String sharedWithId;
    private String sharedWithName;
    private String permission;
    private String message;
    private LocalDateTime sharedAt;
}
