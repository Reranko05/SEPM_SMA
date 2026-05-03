package com.sma2.service.impl;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.Iterator;
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
        double calThreshold = 0.8 * targetCalories;
        double protThreshold = 0.8 * targetProtein;
        Meal single = candidates.stream()
            .filter(m -> m.getCalories() >= calThreshold && m.getProteinGrams() >= protThreshold)
            .max(Comparator.comparingInt(Meal::getProteinGrams))
            .orElse(null);
        if (single != null) {
            res.getItems().add(MealDto.fromMeal(single));
            res.setTotalCalories(single.getCalories());
            res.setTotalProtein(single.getProteinGrams());
            res.setTotalCarbs(single.getCarbsGrams());
            res.setTotalPrice(single.getPrice());
            return res;
        }

        // 2) Greedy combination by protein density (protein / calories)
        List<Meal> sorted = candidates.stream()
            .filter(m -> m.getCalories() > 0)
            .sorted(Comparator.comparingDouble(m -> -((double) m.getProteinGrams() / m.getCalories())))
            .collect(Collectors.toList());

        List<Meal> selected = new ArrayList<>();
        int totalCalories = 0;
        int totalProtein = 0;
        int totalCarbs = 0;
        double totalPrice = 0.0;

        for (Meal m : sorted) {
            if (maxCarbs != null && totalCarbs + m.getCarbsGrams() > maxCarbs) continue;
            if (maxBudget != null && totalPrice + m.getPrice() > maxBudget) continue;
            selected.add(m);
            totalCalories += m.getCalories();
            totalProtein += m.getProteinGrams();
            totalCarbs += m.getCarbsGrams();
            totalPrice += m.getPrice();
            if (totalCalories >= targetCalories && totalProtein >= targetProtein) break;
        }

        // 3) If still not meeting targets, return best-effort (selected may be empty)
        // Optional refinement: remove redundant meals while keeping constraints satisfied
        if (!selected.isEmpty()) {
            boolean changed;
            do {
                changed = false;
                Iterator<Meal> it = selected.iterator();
                while (it.hasNext()) {
                    Meal cand = it.next();
                    // try removing
                    int cals = totalCalories - cand.getCalories();
                    int prot = totalProtein - cand.getProteinGrams();
                    int carbs = totalCarbs - cand.getCarbsGrams();
                    double price = totalPrice - cand.getPrice();
                    boolean carbsOk = maxCarbs == null || carbs <= maxCarbs;
                    boolean priceOk = maxBudget == null || price <= maxBudget;
                    boolean goalsOk = (cals >= targetCalories && prot >= targetProtein) || (prot >= totalProtein);
                    if (carbsOk && priceOk && (cals >= targetCalories && prot >= targetProtein)) {
                        // safe to remove
                        it.remove();
                        totalCalories = cals; totalProtein = prot; totalCarbs = carbs; totalPrice = price;
                        changed = true;
                        break;
                    }
                }
            } while (changed);
        }

        // fill response
        for (Meal m : selected) res.getItems().add(MealDto.fromMeal(m));
        res.setTotalCalories(totalCalories);
        res.setTotalProtein(totalProtein);
        res.setTotalCarbs(totalCarbs);
        res.setTotalPrice(totalPrice);
        return res;
    }
}
