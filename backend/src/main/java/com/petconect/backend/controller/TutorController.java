package com.petconect.backend.controller;

import com.petconect.backend.model.Tutor;
import com.petconect.backend.repository.TutorRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/tutores")
@RequiredArgsConstructor
public class TutorController {
    private final TutorRepository tutorRepository;

    @GetMapping
    public List<Tutor> getAll() {
        return tutorRepository.findAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<Tutor> getById(@PathVariable Long id) {
        return tutorRepository.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public Tutor create(@RequestBody Tutor tutor) {
        return tutorRepository.save(tutor);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Tutor> update(@PathVariable Long id, @RequestBody Tutor tutor) {
        return tutorRepository.findById(id)
                .map(existing -> {
                    tutor.setId(id);
                    return ResponseEntity.ok(tutorRepository.save(tutor));
                })
                .orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        if (tutorRepository.existsById(id)) {
            tutorRepository.deleteById(id);
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.notFound().build();
    }
} 