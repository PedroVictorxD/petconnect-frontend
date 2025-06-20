package com.petconect.backend.controller;

import com.petconect.backend.model.Store;
import com.petconect.backend.repository.StoreRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/stores")
@RequiredArgsConstructor
public class StoreController {
    private final StoreRepository storeRepository;

    @GetMapping
    public List<Store> getAll() {
        return storeRepository.findAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<Store> getById(@PathVariable Long id) {
        return storeRepository.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public Store create(@RequestBody Store store) {
        return storeRepository.save(store);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Store> update(@PathVariable Long id, @RequestBody Store store) {
        return storeRepository.findById(id)
                .map(existing -> {
                    store.setId(id);
                    return ResponseEntity.ok(storeRepository.save(store));
                })
                .orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        if (storeRepository.existsById(id)) {
            storeRepository.deleteById(id);
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.notFound().build();
    }
} 