package com.sma2.service;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

import com.sma2.foodapi.model.Meal;

public interface RecommendationService {
    Optional<Meal> recommendForUser(UUID userId);
    List<Meal> recommendTopForUser(UUID userId, int topN);
}
