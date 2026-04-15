package com.sma2.service.impl;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

import org.springframework.stereotype.Service;

import com.sma2.foodapi.model.Meal;
import com.sma2.service.CartService;

@Service
public class CartServiceImpl implements CartService {

    private final ConcurrentHashMap<UUID, List<Meal>> carts = new ConcurrentHashMap<>();

    @Override
    public void addToCart(UUID userId, Meal meal) {
        carts.compute(userId, (k, v) -> {
            if (v == null) v = new ArrayList<>();
            v.add(meal);
            return v;
        });
    }

    @Override
    public Optional<List<Meal>> getCart(UUID userId) {
        return Optional.ofNullable(carts.get(userId));
    }

    @Override
    public void removeFromCart(UUID userId, String mealId) {
        carts.computeIfPresent(userId, (k, list) -> {
            list.removeIf(m -> m.getId().equals(mealId));
            return list.isEmpty() ? null : list;
        });
    }

    @Override
    public void clearCart(UUID userId) {
        carts.remove(userId);
    }
}
