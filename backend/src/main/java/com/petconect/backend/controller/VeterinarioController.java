package com.petconect.backend.controller;

import com.petconect.backend.model.Veterinario;
import com.petconect.backend.repository.VeterinarioRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/veterinarios")
@RequiredArgsConstructor
public class VeterinarioController {
    private final VeterinarioRepository veterinarioRepository;

    @GetMapping
    public List<Veterinario> getAll() {
        return veterinarioRepository.findAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<Veterinario> getById(@PathVariable Long id) {
        return veterinarioRepository.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public Veterinario create(@RequestBody Veterinario veterinario) {
        return veterinarioRepository.save(veterinario);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Veterinario> update(@PathVariable Long id, @RequestBody Veterinario veterinario) {
        return veterinarioRepository.findById(id)
                .map(existing -> {
                    veterinario.setId(id);
                    return ResponseEntity.ok(veterinarioRepository.save(veterinario));
                })
                .orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        if (veterinarioRepository.existsById(id)) {
            veterinarioRepository.deleteById(id);
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.notFound().build();
    }
} 