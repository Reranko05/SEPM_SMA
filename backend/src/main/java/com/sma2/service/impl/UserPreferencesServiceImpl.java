package com.sma2.service.impl;

import java.util.UUID;

import org.springframework.stereotype.Service;

import com.sma2.dto.UserPreferencesDto;
import com.sma2.entity.User;
import com.sma2.entity.UserPreferences;
import com.sma2.repository.UserPreferencesRepository;
import com.sma2.repository.UserRepository;
import com.sma2.service.UserPreferencesService;

@Service
public class UserPreferencesServiceImpl implements UserPreferencesService {

    private final UserRepository userRepository;
    private final UserPreferencesRepository prefsRepo;

    public UserPreferencesServiceImpl(UserRepository userRepository, UserPreferencesRepository prefsRepo) {
        this.userRepository = userRepository;
        this.prefsRepo = prefsRepo;
    }

    @Override
    public UserPreferencesDto getPreferences(UUID userId) {
        return prefsRepo.findByUserId(userId).map(this::toDto).orElse(null);
    }

    @Override
    public UserPreferencesDto createOrUpdate(UUID userId, UserPreferencesDto dto) {
        User user = userRepository.findById(userId).orElseThrow(() -> new RuntimeException("User not found"));
        UserPreferences prefs = prefsRepo.findByUserId(userId).orElseGet(UserPreferences::new);
        prefs.setUser(user);
        prefs.setDietType(dto.getDietType());
        prefs.setCalorieLimit(dto.getCalorieLimit());
        prefs.setBudget(dto.getBudget());
        prefs.setSpiceLevel(dto.getSpiceLevel());
        prefs.setProteinGoalGrams(dto.getProteinGoalGrams());
        prefs.setCarbsLimitGrams(dto.getCarbsLimitGrams());
        prefs = prefsRepo.save(prefs);
        return toDto(prefs);
    }

    private UserPreferencesDto toDto(UserPreferences p) {
        UserPreferencesDto d = new UserPreferencesDto();
        d.setDietType(p.getDietType());
        d.setCalorieLimit(p.getCalorieLimit());
        d.setBudget(p.getBudget());
        d.setSpiceLevel(p.getSpiceLevel());
        d.setProteinGoalGrams(p.getProteinGoalGrams());
        d.setCarbsLimitGrams(p.getCarbsLimitGrams());
        return d;
    }
}
