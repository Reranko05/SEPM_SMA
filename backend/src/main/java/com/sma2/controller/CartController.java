package com.sma2.controller;

import java.util.UUID;

import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PathVariable;

import com.sma2.foodapi.model.Meal;
import com.sma2.service.CartService;

@RestController
@RequestMapping("/api/cart")
public class CartController {

    private final CartService cartService;
    private final com.sma2.repository.UserRepository userRepo;

    public CartController(CartService cartService, com.sma2.repository.UserRepository userRepo) {
        this.cartService = cartService;
        this.userRepo = userRepo;
    }

    private UUID resolveUserId(UserDetails user, String usernameFallback) {
        if (user != null) {
            com.sma2.entity.User u = userRepo.findByUsername(user.getUsername()).orElseThrow(() -> new RuntimeException("User not found"));
            return u.getId();
        }
        if (usernameFallback != null && !usernameFallback.isBlank()) {
            com.sma2.entity.User u = userRepo.findByUsername(usernameFallback).orElseThrow(() -> new RuntimeException("User not found"));
            return u.getId();
        }
        throw new RuntimeException("User not provided");
    }

    @PostMapping
    public ResponseEntity<?> addToCart(@AuthenticationPrincipal UserDetails user, @RequestBody Meal meal, @RequestParam(required = false) String username) {
        UUID userId = resolveUserId(user, username);
        cartService.addToCart(userId, meal);
        return ResponseEntity.ok().build();
    }

    @DeleteMapping("/{mealId}")
    public ResponseEntity<?> removeFromCart(@AuthenticationPrincipal UserDetails user, @PathVariable String mealId, @RequestParam(required = false) String username) {
        UUID userId = resolveUserId(user, username);
        cartService.removeFromCart(userId, mealId);
        return ResponseEntity.ok().build();
    }

    @DeleteMapping
    public ResponseEntity<?> clearCart(@AuthenticationPrincipal UserDetails user, @RequestParam(required = false) String username) {
        UUID userId = resolveUserId(user, username);
        cartService.clearCart(userId);
        return ResponseEntity.ok().build();
    }

    @GetMapping
    public ResponseEntity<?> getCart(@AuthenticationPrincipal UserDetails user, @RequestParam(required = false) String username) {
        UUID userId = resolveUserId(user, username);
        return cartService.getCart(userId)
                .map(list -> {
                    // aggregate duplicates into items with quantity
                    java.util.Map<String, java.util.Map<String, Object>> agg = new java.util.HashMap<>();
                    for (com.sma2.foodapi.model.Meal m : list) {
                        final String id = m.getId();
                        if (!agg.containsKey(id)) {
                            java.util.Map<String, Object> map = new java.util.HashMap<>();
                            map.put("id", m.getId());
                            map.put("name", m.getName());
                            map.put("calories", m.getCalories());
                            map.put("price", m.getPrice());
                            map.put("rating", m.getRating());
                            map.put("dietType", m.getDietType());
                            map.put("quantity", 1);
                            agg.put(id, map);
                        } else {
                            java.util.Map<String, Object> existing = agg.get(id);
                            int q = (Integer) existing.get("quantity");
                            existing.put("quantity", q + 1);
                        }
                    }
                    return ResponseEntity.ok(new java.util.ArrayList<>(agg.values()));
                }).orElse(ResponseEntity.ok(java.util.List.of()));
    }
}
