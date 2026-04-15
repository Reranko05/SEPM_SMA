package com.sma2.service;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

import com.sma2.foodapi.model.Meal;

public interface CartService {
    void addToCart(UUID userId, Meal meal);
    Optional<List<Meal>> getCart(UUID userId);
    void removeFromCart(UUID userId, String mealId);
    void clearCart(UUID userId);
}
