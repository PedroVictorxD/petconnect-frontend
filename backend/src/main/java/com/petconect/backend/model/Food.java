package com.petconect.backend.model;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Food {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String brand;
    private String name;
    private String type;
    private double recommendedDailyAmount;
    private String notes;
    private Long ownerId;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
} 