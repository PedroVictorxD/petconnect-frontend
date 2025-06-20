package com.petconect.backend.repository;

import com.petconect.backend.model.Veterinario;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface VeterinarioRepository extends JpaRepository<Veterinario, Long> {
    Optional<Veterinario> findByEmail(String email);
} 