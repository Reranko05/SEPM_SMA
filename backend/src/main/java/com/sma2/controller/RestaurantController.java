package com.sma2.controller;

import java.util.List;
import java.util.UUID;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.sma2.entity.MenuItem;
import com.sma2.entity.Restaurant;
import com.sma2.repository.MenuItemRepository;
import com.sma2.repository.RestaurantRepository;

@RestController
@RequestMapping("/api")
public class RestaurantController {
    private final RestaurantRepository restaurantRepo;
    private final MenuItemRepository menuRepo;

    public RestaurantController(RestaurantRepository restaurantRepo, MenuItemRepository menuRepo) {
        this.restaurantRepo = restaurantRepo;
        this.menuRepo = menuRepo;
    }

    @GetMapping("/restaurants")
    public ResponseEntity<List<Restaurant>> listRestaurants() {
        // use repository method that fetches menuItems to avoid lazy-loading errors during JSON serialization
        return ResponseEntity.ok(restaurantRepo.findAllWithMenuItems());
    }

    @GetMapping("/restaurants/{id}/menu")
    public ResponseEntity<List<MenuItem>> menuFor(@PathVariable("id") UUID id) {
        return ResponseEntity.ok(menuRepo.findByRestaurantId(id));
    }
}
