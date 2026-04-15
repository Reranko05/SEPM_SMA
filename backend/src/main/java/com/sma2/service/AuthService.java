package com.sma2.service;

import com.sma2.dto.AuthRequest;
import com.sma2.dto.AuthResponse;
import com.sma2.dto.RegisterRequest;

public interface AuthService {
    AuthResponse login(AuthRequest req);
    AuthResponse register(RegisterRequest req);
}
