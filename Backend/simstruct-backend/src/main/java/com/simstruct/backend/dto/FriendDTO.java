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
public class FriendDTO {
    private String id;
    private String friendshipId;
    private String name;
    private String email;
    private String avatarUrl;
    private String company;
    private String status;
    private LocalDateTime connectedAt;
    private int sharedSimulations;
}
