package com.sma2.service.impl;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;

import com.sma2.entity.UserPreferences;
import com.sma2.foodapi.model.Meal;
import com.sma2.service.model.MealDto;
import com.sma2.service.model.MealPlanResponse;

@Service
public class MealPlannerService {

    public MealPlanResponse buildMealPlan(List<Meal> candidates, UserPreferences prefs) {
        MealPlanResponse res = new MealPlanResponse();
        if (candidates == null || candidates.isEmpty() || prefs == null) return res;

        int targetCalories = prefs.getCalorieLimit();
        int targetProtein = prefs.getProteinGoalGrams();
        Integer maxCarbs = prefs.getCarbsLimitGrams() > 0 ? prefs.getCarbsLimitGrams() : null;
        Double maxBudget = prefs.getBudget() > 0 ? prefs.getBudget() : null;

        // 1) try single-meal solution (>=80% of targets)
            // 2) Attempt to build combinations greedily starting from best protein-density meals
            List<Meal> sorted = candidates.stream()
                .filter(m -> m.getCalories() > 0)
                .sorted(Comparator.comparingDouble(m -> -((double) m.getProteinGrams() / m.getCalories())))
                .collect(Collectors.toList());

            // enforce an upper bound on allowed calories (10-15% over target)
            double overhead = (targetCalories <= 400) ? 0.10 : 0.15;
            int allowedMax = (int) Math.ceil(targetCalories * (1.0 + overhead));
            int maxComboItems = (targetCalories <= 400) ? 2 : Integer.MAX_VALUE;

            List<Meal> bestCombo = new ArrayList<>();
            int bestCalories = 0;
            int bestProtein = 0;
            int bestCloseness = Integer.MAX_VALUE;
            boolean bestMeets = false;

            // Try seeding combos from each meal and greedily add others
            for (int i = 0; i < sorted.size(); i++) {
                List<Meal> sel = new ArrayList<>();
                int totalCalories = 0;
                int totalProtein = 0;
                int totalCarbs = 0;
                double totalPrice = 0.0;

                Meal seed = sorted.get(i);
                // try to add seed if it doesn't immediately violate constraints
                if ((maxCarbs != null && seed.getCarbsGrams() > maxCarbs) || (maxBudget != null && seed.getPrice() > maxBudget) || seed.getCalories() > allowedMax) {
                    continue;
                }
                sel.add(seed);
                totalCalories += seed.getCalories();
                totalProtein += seed.getProteinGrams();
                totalCarbs += seed.getCarbsGrams();
                totalPrice += seed.getPrice();

                // greedily add other meals in order of protein density
                for (int j = 0; j < sorted.size() && sel.size() < maxComboItems; j++) {
                    if (j == i) continue;
                    Meal cand = sorted.get(j);
                    if (maxCarbs != null && totalCarbs + cand.getCarbsGrams() > maxCarbs) continue;
                    if (maxBudget != null && totalPrice + cand.getPrice() > maxBudget) continue;
                    if (totalCalories + cand.getCalories() > allowedMax) continue;
                    sel.add(cand);
                    totalCalories += cand.getCalories();
                    totalProtein += cand.getProteinGrams();
                    totalCarbs += cand.getCarbsGrams();
                    totalPrice += cand.getPrice();
                    // stop early if we met both targets
                    if (totalCalories >= targetCalories && totalProtein >= targetProtein) break;
                }

                // Evaluate this selection against the best seen so far
                int closeness = Math.abs(targetCalories - totalCalories);
                boolean meets = (totalCalories >= targetCalories && totalProtein >= targetProtein);

                boolean update = false;
                if (meets && !bestMeets) {
                    // prefer any combo that meets targets over one that doesn't
                    update = true;
                } else if (meets == bestMeets) {
                    // both meet or both don't: prefer smaller closeness, then higher protein
                    if (closeness < bestCloseness) update = true;
                    else if (closeness == bestCloseness && totalProtein > bestProtein) update = true;
                }

                if (update) {
                    bestCombo = new ArrayList<>(sel);
                    bestCalories = totalCalories;
                    bestProtein = totalProtein;
                    bestCloseness = closeness;
                    bestMeets = meets;
                }
            }
            // If we found a best combo (meets targets or best partial), return it
            if (!bestCombo.isEmpty()) {
                int totalCalories = bestCombo.stream().mapToInt(Meal::getCalories).sum();
                int totalProtein = bestCombo.stream().mapToInt(Meal::getProteinGrams).sum();
                int totalCarbs = bestCombo.stream().mapToInt(Meal::getCarbsGrams).sum();
                double totalPrice = bestCombo.stream().mapToDouble(Meal::getPrice).sum();
                for (Meal m : bestCombo) res.getItems().add(MealDto.fromMeal(m));
                res.setTotalCalories(totalCalories);
                res.setTotalProtein(totalProtein);
                res.setTotalCarbs(totalCarbs);
                res.setTotalPrice(totalPrice);
                return res;
            }

            // No valid combo found — pick best single meal under allowedMax if possible,
            // otherwise pick the single meal closest to targetCalories
            Meal singleFallback = candidates.stream()
                .filter(m -> m.getCalories() <= allowedMax)
                .min(Comparator.comparingInt(m -> Math.abs(m.getCalories() - targetCalories)))
                .orElse(null);
            if (singleFallback == null) {
                singleFallback = candidates.stream()
                    .min(Comparator.comparingInt(m -> Math.abs(m.getCalories() - targetCalories)))
                    .orElse(null);
            }
            if (singleFallback != null) {
                res.getItems().add(MealDto.fromMeal(singleFallback));
                res.setTotalCalories(singleFallback.getCalories());
                res.setTotalProtein(singleFallback.getProteinGrams());
                res.setTotalCarbs(singleFallback.getCarbsGrams());
                res.setTotalPrice(singleFallback.getPrice());
            }
            return res;
    }
}
