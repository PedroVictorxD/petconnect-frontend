package com.petconect.backend.repository;

import com.petconect.backend.model.Pet;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PetRepository extends JpaRepository<Pet, Long> {
} 