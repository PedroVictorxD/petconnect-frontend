package com.petconect.backend.controller;

import com.petconect.backend.model.Admin;
import com.petconect.backend.model.Lojista;
import com.petconect.backend.model.Tutor;
import com.petconect.backend.model.User;
import com.petconect.backend.model.Veterinario;
import com.petconect.backend.repository.AdminRepository;
import com.petconect.backend.repository.LojistaRepository;
import com.petconect.backend.repository.TutorRepository;
import com.petconect.backend.repository.VeterinarioRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Optional;

@RestController
@RequestMapping("/api/auth")
public class AuthController {
    @Autowired
    private AdminRepository adminRepository;
    @Autowired
    private LojistaRepository lojistaRepository;
    @Autowired
    private TutorRepository tutorRepository;
    @Autowired
    private VeterinarioRepository veterinarioRepository;

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody LoginRequest loginRequest) {
        Optional<? extends User> user =
            adminRepository.findByEmail(loginRequest.getEmail())
            .map(u -> (User) u)
            .or(() -> lojistaRepository.findByEmail(loginRequest.getEmail()).map(u -> (User) u))
            .or(() -> tutorRepository.findByEmail(loginRequest.getEmail()).map(u -> (User) u))
            .or(() -> veterinarioRepository.findByEmail(loginRequest.getEmail()).map(u -> (User) u));

        if (user.isPresent() && user.get().getPassword().equals(loginRequest.getPassword())) {
            return ResponseEntity.ok(user.get());
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