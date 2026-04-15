package com.sma2.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.sma2.dto.UserPreferencesDto;
import com.sma2.entity.User;
import com.sma2.repository.UserRepository;
import com.sma2.service.UserPreferencesService;

@RestController
@RequestMapping("/api/preferences")
public class UserPreferencesController {

    private final UserPreferencesService prefsService;
    private final UserRepository userRepository;

    public UserPreferencesController(UserPreferencesService prefsService,
                                     UserRepository userRepository) {
        this.prefsService = prefsService;
        this.userRepository = userRepository;
    }

    // ✅ GET using username param
    @GetMapping
    public ResponseEntity<UserPreferencesDto> getPreferences(@RequestParam String username) {

        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("User not found"));

        return ResponseEntity.ok(prefsService.getPreferences(user.getId()));
    }

    // ✅ POST using username from body
    @PostMapping
    public ResponseEntity<UserPreferencesDto> createOrUpdate(@RequestBody UserPreferencesDto dto) {

        User user = userRepository.findByUsername(dto.getUsername())
                .orElseThrow(() -> new RuntimeException("User not found"));

        return ResponseEntity.ok(
                prefsService.createOrUpdate(user.getId(), dto)
        );
    }
}