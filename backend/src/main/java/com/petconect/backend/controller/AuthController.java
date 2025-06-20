package com.petconect.backend.controller;

import com.petconect.backend.model.Lojista;
import com.petconect.backend.repository.LojistaRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Optional;

@RestController
@RequestMapping("/api/auth")
public class AuthController {
    @Autowired
    private LojistaRepository lojistaRepository;

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody LoginRequest loginRequest) {
        Optional<Lojista> lojistaOpt = lojistaRepository.findByEmail(loginRequest.getEmail());
        if (lojistaOpt.isPresent() && lojistaOpt.get().getPassword().equals(loginRequest.getPassword())) {
            return ResponseEntity.ok(lojistaOpt.get());
        }
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Email ou senha incorretos");
    }

    public static class LoginRequest {
        private String email;
        private String password;
        public String getEmail() { return email; }
        public void setEmail(String email) { this.email = email; }
        public String getPassword() { return password; }
        public void setPassword(String password) { this.password = password; }
    }
} 