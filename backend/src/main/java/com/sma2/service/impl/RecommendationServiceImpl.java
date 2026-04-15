package com.sma2.service.impl;

import java.util.Comparator;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;

import com.sma2.entity.UserPreferences;
import com.sma2.foodapi.FoodProviderService;
import com.sma2.foodapi.model.Meal;
import com.sma2.repository.RecommendationLogRepository;
import com.sma2.repository.UserPreferencesRepository;
import com.sma2.service.RecommendationService;

@Service
public class RecommendationServiceImpl implements RecommendationService {

    private final FoodProviderService foodProvider;
    private final UserPreferencesRepository prefsRepo;
    private final RecommendationLogRepository logRepo;

    // weights
    private final double w1 = 0.25; // calorie match
    private final double w2 = 0.25; // budget fit
    private final double w3 = 0.2;  // preference match
    private final double w4 = 0.3;  // rating

    public RecommendationServiceImpl(FoodProviderService foodProvider, UserPreferencesRepository prefsRepo, RecommendationLogRepository logRepo) {
        this.foodProvider = foodProvider;
        this.prefsRepo = prefsRepo;
        this.logRepo = logRepo;
    }

    @Override
    public Optional<Meal> recommendForUser(UUID userId) {
        UserPreferences prefs = prefsRepo.findByUserId(userId).orElse(null);
        List<Meal> meals = foodProvider.fetchMeals();
        if (prefs == null) return meals.stream().max(Comparator.comparingDouble(Meal::getRating));
        // try to find a combo of up to 3 items that meets calorie, protein and carbs constraints
        Meal bestCombo = findBestCombo(meals, prefs, 3);
        if (bestCombo != null) {
            com.sma2.entity.RecommendationLog log = new com.sma2.entity.RecommendationLog();
            log.setUserId(userId);
            log.setMealId(bestCombo.getId());
            log.setScore(score(bestCombo, prefs));
            logRepo.save(log);
            return Optional.of(bestCombo);
        }

        // fallback to single-item recommendations (previous behaviour)
        List<Meal> filtered = applyRules(meals, prefs);
        if (filtered.isEmpty()) {
            // fallback: relax constraints by 10%
            prefs.setCalorieLimit((int) Math.ceil(prefs.getCalorieLimit() * 1.1));
            prefs.setBudget(prefs.getBudget() * 1.1);
            filtered = applyRules(meals, prefs);
            if (filtered.isEmpty()) return Optional.empty();
        }

        Meal best = filtered.stream().max(Comparator.comparingDouble(m -> score(m, prefs))).orElse(null);
        // log
        if (best != null) {
            com.sma2.entity.RecommendationLog log = new com.sma2.entity.RecommendationLog();
            log.setUserId(userId);
            log.setMealId(best.getId());
            log.setScore(score(best, prefs));
            logRepo.save(log);
        }
        return Optional.ofNullable(best);
    }

    @Override
    public List<Meal> recommendTopForUser(UUID userId, int topN) {
        UserPreferences prefs = prefsRepo.findByUserId(userId).orElse(null);
        List<Meal> meals = foodProvider.fetchMeals();
        if (prefs == null) {
            return meals.stream().sorted(Comparator.comparingDouble(Meal::getRating).reversed()).limit(topN).collect(Collectors.toList());
        }

        List<Meal> filtered = applyRules(meals, prefs);
        if (filtered.isEmpty()) {
            // relax constraints
            prefs.setCalorieLimit((int) Math.ceil(prefs.getCalorieLimit() * 1.1));
            prefs.setBudget(prefs.getBudget() * 1.1);
            filtered = applyRules(meals, prefs);
            if (filtered.isEmpty()) return List.of();
        }

        return filtered.stream().sorted(Comparator.comparingDouble(m -> -score(m, prefs))).limit(topN).collect(Collectors.toList());
    }

    private List<Meal> applyRules(List<Meal> meals, UserPreferences prefs) {
        return meals.stream()
            .filter(m -> m.getPrice() <= prefs.getBudget())
            .filter(m -> matchesDiet(m.getDietType(), prefs.getDietType()))
            .collect(Collectors.toList());
    }

    private boolean matchesDiet(com.sma2.entity.DietType mealDiet, com.sma2.entity.DietType userDiet) {
        if (userDiet == null) return true;
        if (userDiet == com.sma2.entity.DietType.OMNIVORE) return true;
        return mealDiet == userDiet;
    }

    private double score(Meal m, UserPreferences prefs) {
        double budgetFit = 1.0 - (m.getPrice() / (prefs.getBudget()+0.01));
        if (budgetFit < 0) budgetFit = 0;
        double prefMatch = m.getDietType() == prefs.getDietType() ? 1.0 : 0.0;
        double rating = m.getRating() / 5.0;
        return w2 * budgetFit + w3 * prefMatch + w4 * rating;
    }

    // try to find a combination of up to maxItems meals that meets the user's calorie target,
    // protein goal, carbs limit and budget. Returns a synthetic Meal representing the combo.
    private Meal findBestCombo(List<Meal> meals, UserPreferences prefs, int maxItems) {
        List<Meal> candidates = meals.stream().filter(m -> matchesDiet(m.getDietType(), prefs.getDietType())).collect(Collectors.toList());
        Meal best = null;
        double bestScore = -1;
        int n = candidates.size();
        // brute-force combos up to size maxItems (1..maxItems)
        for (int size = 1; size <= maxItems; size++) {
            if (size == 1) {
                for (int i = 0; i < n; i++) {
                    Meal a = candidates.get(i);
                    if (meetsComboConstraints(List.of(a), prefs)) {
                        Meal combo = buildComboMeal(List.of(a));
                        double sc = score(combo, prefs);
                        if (sc > bestScore) { bestScore = sc; best = combo; }
                    }
                }
            } else if (size == 2) {
                for (int i = 0; i < n; i++) for (int j = i+1; j < n; j++) {
                    Meal a = candidates.get(i); Meal b = candidates.get(j);
                    if (meetsComboConstraints(List.of(a,b), prefs)) {
                        Meal combo = buildComboMeal(List.of(a,b));
                        double sc = score(combo, prefs);
                        if (sc > bestScore) { bestScore = sc; best = combo; }
                    }
                }
            } else if (size == 3) {
                for (int i = 0; i < n; i++) for (int j = i+1; j < n; j++) for (int k = j+1; k < n; k++) {
                    Meal a = candidates.get(i); Meal b = candidates.get(j); Meal c = candidates.get(k);
                    if (meetsComboConstraints(List.of(a,b,c), prefs)) {
                        Meal combo = buildComboMeal(List.of(a,b,c));
                        double sc = score(combo, prefs);
                        if (sc > bestScore) { bestScore = sc; best = combo; }
                    }
                }
            }
        }
        return best;
    }

    private boolean meetsComboConstraints(List<Meal> combo, UserPreferences prefs) {
        int totalCalories = combo.stream().mapToInt(Meal::getCalories).sum();
        int totalProtein = combo.stream().mapToInt(Meal::getProteinGrams).sum();
        int totalCarbs = combo.stream().mapToInt(Meal::getCarbsGrams).sum();
        double totalPrice = combo.stream().mapToDouble(Meal::getPrice).sum();
        if (totalPrice > prefs.getBudget()) return false;
        if (totalCarbs > prefs.getCarbsLimitGrams()) return false;
        if (totalProtein < prefs.getProteinGoalGrams()) return false;
        if (totalCalories < prefs.getCalorieLimit()) return false;
        return true;
    }

    private Meal buildComboMeal(List<Meal> combo) {
        int totalCalories = combo.stream().mapToInt(Meal::getCalories).sum();
        int totalProtein = combo.stream().mapToInt(Meal::getProteinGrams).sum();
        int totalCarbs = combo.stream().mapToInt(Meal::getCarbsGrams).sum();
        double totalPrice = combo.stream().mapToDouble(Meal::getPrice).sum();
        double avgRating = combo.stream().mapToDouble(Meal::getRating).average().orElse(0.0);
        String name = "Combo: " + combo.stream().map(Meal::getName).collect(Collectors.joining(" + "));
        String id = "combo:" + UUID.randomUUID().toString();
        // diet type: choose user's diet will be enforced earlier; pick first meal diet for representation
        com.sma2.entity.DietType diet = combo.get(0).getDietType();
        Meal m = new Meal(id, name, totalCalories, totalPrice, avgRating, diet, totalProtein, totalCarbs);
        return m;
    }
}
