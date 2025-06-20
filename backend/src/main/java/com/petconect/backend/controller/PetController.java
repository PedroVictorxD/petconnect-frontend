package com.petconect.backend.controller;

import com.petconect.backend.model.Pet;
import com.petconect.backend.repository.PetRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
<<<<<<< HEAD
@RequestMapping("/pets")
=======
@RequestMapping("/api/pets")
>>>>>>> dev
@RequiredArgsConstructor
public class PetController {
    private final PetRepository petRepository;

    @GetMapping
<<<<<<< HEAD
    public List<Pet> getAll() {
=======
    public List<Pet> getByTutor(@RequestParam(required = false) Long tutorId) {
        if (tutorId != null) {
            return petRepository.findByTutorId(tutorId);
        }
>>>>>>> dev
        return petRepository.findAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<Pet> getById(@PathVariable Long id) {
        return petRepository.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public Pet create(@RequestBody Pet pet) {
        return petRepository.save(pet);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Pet> update(@PathVariable Long id, @RequestBody Pet pet) {
        return petRepository.findById(id)
                .map(existing -> {
                    pet.setId(id);
                    return ResponseEntity.ok(petRepository.save(pet));
                })
                .orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        if (petRepository.existsById(id)) {
            petRepository.deleteById(id);
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.notFound().build();
    }
} 