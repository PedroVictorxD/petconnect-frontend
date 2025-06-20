package com.petconect.backend.controller;

import com.petconect.backend.model.SecurityQuestion;
import com.petconect.backend.repository.SecurityQuestionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/securityquestions")
@RequiredArgsConstructor
public class SecurityQuestionController {
    private final SecurityQuestionRepository securityQuestionRepository;

    @GetMapping
    public List<SecurityQuestion> getAll() {
        return securityQuestionRepository.findAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<SecurityQuestion> getById(@PathVariable Long id) {
        return securityQuestionRepository.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public SecurityQuestion create(@RequestBody SecurityQuestion securityQuestion) {
        return securityQuestionRepository.save(securityQuestion);
    }

    @PutMapping("/{id}")
    public ResponseEntity<SecurityQuestion> update(@PathVariable Long id, @RequestBody SecurityQuestion securityQuestion) {
        return securityQuestionRepository.findById(id)
                .map(existing -> {
                    securityQuestion.setId(id);
                    return ResponseEntity.ok(securityQuestionRepository.save(securityQuestion));
                })
                .orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        if (securityQuestionRepository.existsById(id)) {
            securityQuestionRepository.deleteById(id);
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.notFound().build();
    }
} 