package com.petconect.backend.model;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Pet {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String name;
    private String type;
    private double weight;
    private int age;
    private String activityLevel;
    private String breed;
    private String notes;
    private Long tutorId;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
} 