package com.sma2.foodapi;

import com.sma2.foodapi.model.Meal;

import java.util.List;

public interface FoodProviderService {
    List<Meal> fetchMeals();
}
