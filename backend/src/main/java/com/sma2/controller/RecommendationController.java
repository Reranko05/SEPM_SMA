package com.sma2.controller;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.sma2.entity.User;
import com.sma2.foodapi.FoodProviderService;
import com.sma2.foodapi.model.Meal;
import com.sma2.repository.RecommendationLogRepository;
import com.sma2.repository.UserRepository;
import com.sma2.service.RecommendationService;


@RestController
@RequestMapping("/api/recommendation")
public class RecommendationController {

    private final RecommendationService recommendationService;
    private final UserRepository userRepository;
    private final RecommendationLogRepository logRepository;
    private final FoodProviderService foodProvider;

    public RecommendationController(RecommendationService recommendationService,
                                    UserRepository userRepository,
                                    RecommendationLogRepository logRepository,
                                    FoodProviderService foodProvider) {
        this.recommendationService = recommendationService;
        this.userRepository = userRepository;
        this.logRepository = logRepository;
        this.foodProvider = foodProvider;
    }

    @GetMapping
    public ResponseEntity<?> getRecommendation(@RequestParam String username, @RequestParam(required = false, defaultValue = "3") int top) {

        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("User not found"));

        List<Meal> list = recommendationService.recommendTopForUser(user.getId(), top);
        if (list.isEmpty()) return ResponseEntity.noContent().build();
        return ResponseEntity.ok(list);
    }

    @GetMapping("/latest")
    public ResponseEntity<?> getLatestRecommendation(@RequestParam String username) {
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("User not found"));

        // find latest log entry for user
        return logRepository.findFirstByUserIdOrderByCreatedAtDesc(user.getId())
                .map(l -> {
                    Meal meal = foodProvider.fetchMeals().stream().filter(m -> m.getId().equals(l.getMealId())).findFirst().orElse(null);
                    if (meal == null) return ResponseEntity.noContent().build();
                    return ResponseEntity.ok(meal);
                }).orElse(ResponseEntity.noContent().build());
    }
}