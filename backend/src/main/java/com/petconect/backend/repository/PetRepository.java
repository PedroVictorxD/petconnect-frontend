package com.petconect.backend.repository;

import com.petconect.backend.model.Pet;
import org.springframework.data.jpa.repository.JpaRepository;
<<<<<<< HEAD

public interface PetRepository extends JpaRepository<Pet, Long> {
=======
import java.util.List;

public interface PetRepository extends JpaRepository<Pet, Long> {
    List<Pet> findByTutorId(Long tutorId);
>>>>>>> dev
} 