package com.petconect.backend.controller;

import com.petconect.backend.model.VetService;
import com.petconect.backend.repository.VetServiceRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/services")
@RequiredArgsConstructor
public class VetServiceController {
    private final VetServiceRepository vetServiceRepository;

    @GetMapping
    public List<VetService> getAll() {
        return vetServiceRepository.findAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<VetService> getById(@PathVariable Long id) {
        return vetServiceRepository.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public VetService create(@RequestBody VetService vetService) {
        return vetServiceRepository.save(vetService);
    }

    @PutMapping("/{id}")
    public ResponseEntity<VetService> update(@PathVariable Long id, @RequestBody VetService vetService) {
        return vetServiceRepository.findById(id)
                .map(existing -> {
                    vetService.setId(id);
                    return ResponseEntity.ok(vetServiceRepository.save(vetService));
                })
                .orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        if (vetServiceRepository.existsById(id)) {
            vetServiceRepository.deleteById(id);
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.notFound().build();
    }
} 