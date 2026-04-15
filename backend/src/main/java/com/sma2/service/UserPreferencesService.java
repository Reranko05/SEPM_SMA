package com.sma2.service;

import com.sma2.dto.UserPreferencesDto;

import java.util.UUID;

public interface UserPreferencesService {
    UserPreferencesDto getPreferences(UUID userId);
    UserPreferencesDto createOrUpdate(UUID userId, UserPreferencesDto dto);
}
