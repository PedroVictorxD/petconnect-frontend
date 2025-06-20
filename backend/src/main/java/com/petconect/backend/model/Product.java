package com.petconect.backend.model;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Product {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String name;
    private String description;
    private double price;
    private String imageUrl;
    private String measurementUnit;
    private Long ownerId;
    private String ownerName;
    private String ownerLocation;
    private String ownerPhone;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
} 