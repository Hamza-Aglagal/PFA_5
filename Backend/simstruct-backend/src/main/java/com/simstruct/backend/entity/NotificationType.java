package com.simstruct.backend.entity;

/**
 * NotificationType Enum - defines all notification types
 */
public enum NotificationType {
    // Simulation related
    SIMULATION_COMPLETE,
    SIMULATION_FAILED,
    SIMULATION_SHARED,
    
    // Friend related
    FRIEND_REQUEST,
    FRIEND_ACCEPTED,
    FRIEND_REJECTED,
    
    // Chat related
    NEW_MESSAGE,
    
    // Share related
    SIMULATION_RECEIVED,
    
    // System related
    SYSTEM,
    WELCOME,
    ACCOUNT_UPDATE
}
