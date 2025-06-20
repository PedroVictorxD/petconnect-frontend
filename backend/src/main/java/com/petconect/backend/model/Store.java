package com.petconect.backend.model;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Store {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String name;
    private String cnpj;
    private String email;
    private String location;
    private String phone;
    private String storeType;
    private Long ownerId;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
} 