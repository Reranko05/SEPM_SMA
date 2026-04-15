package com.sma2.service.impl;

import com.sma2.dto.AuthRequest;
import com.sma2.dto.AuthResponse;
import com.sma2.dto.RegisterRequest;
import com.sma2.entity.User;
import com.sma2.repository.UserRepository;
import com.sma2.security.JwtUtil;
import com.sma2.service.AuthService;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
public class AuthServiceImpl implements AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder encoder;
    private final JwtUtil jwtUtil;

    public AuthServiceImpl(UserRepository userRepository, PasswordEncoder encoder, JwtUtil jwtUtil) {
        this.userRepository = userRepository;
        this.encoder = encoder;
        this.jwtUtil = jwtUtil;
    }

    @Override
    public AuthResponse login(AuthRequest req) {
        Optional<User> u = userRepository.findByUsername(req.getUsername());
        if (!u.isPresent() || !encoder.matches(req.getPassword(), u.get().getPasswordHash())) {
            throw new RuntimeException("Invalid credentials");
        }
        String token = jwtUtil.generateToken(u.get().getUsername());
        return new AuthResponse(token);
    }

    @Override
    public AuthResponse register(RegisterRequest req) {
        if (userRepository.findByUsername(req.getUsername()).isPresent()) {
            throw new RuntimeException("Username already exists");
        }
        User u = new User();
        u.setUsername(req.getUsername());
        u.setPasswordHash(encoder.encode(req.getPassword()));
        u.setFullName(req.getFullName());
        userRepository.save(u);
        String token = jwtUtil.generateToken(u.getUsername());
        return new AuthResponse(token);
    }
}
