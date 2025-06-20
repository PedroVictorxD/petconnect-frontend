package com.petconect.backend.model;

import jakarta.persistence.Entity;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Entity
@Data
@EqualsAndHashCode(callSuper = true)
public class Lojista extends User {
    private String cnpj;
    private String responsibleName;
    private String storeType;
    private String operatingHours;
} 