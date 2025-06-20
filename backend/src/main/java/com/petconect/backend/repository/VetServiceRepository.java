package com.petconect.backend.repository;

import com.petconect.backend.model.VetService;
import org.springframework.data.jpa.repository.JpaRepository;

public interface VetServiceRepository extends JpaRepository<VetService, Long> {
} 