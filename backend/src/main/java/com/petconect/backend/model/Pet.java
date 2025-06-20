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
<<<<<<< HEAD
    private Long ownerId;
=======
    @ManyToOne
    @JoinColumn(name = "tutor_id")
    private Tutor tutor;
>>>>>>> dev
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
} 