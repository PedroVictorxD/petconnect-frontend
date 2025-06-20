package com.petconect.backend.controller;

import com.petconect.backend.model.Lojista;
import com.petconect.backend.repository.LojistaRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/lojistas")
@RequiredArgsConstructor
public class LojistaController {
    private final LojistaRepository lojistaRepository;

    @GetMapping
    public List<Lojista> getAll() {
        return lojistaRepository.findAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<Lojista> getById(@PathVariable Long id) {
        return lojistaRepository.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public Lojista create(@RequestBody Lojista lojista) {
        return lojistaRepository.save(lojista);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Lojista> update(@PathVariable Long id, @RequestBody Lojista lojista) {
        return lojistaRepository.findById(id)
                .map(existing -> {
                    lojista.setId(id);
                    return ResponseEntity.ok(lojistaRepository.save(lojista));
                })
                .orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        if (lojistaRepository.existsById(id)) {
            lojistaRepository.deleteById(id);
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.notFound().build();
    }
} 