package com.sma2.service.model;

import com.sma2.entity.DietType;
import com.sma2.foodapi.model.Meal;

public class MealDto {
    private String id;
    private String name;
    private int calories;
    private int proteinGrams;
    private int carbsGrams;
    private double price;
    private double rating;
    private DietType dietType;

    public MealDto() {}

    public MealDto(String id, String name, int calories, int proteinGrams, int carbsGrams, double price, double rating, DietType dietType) {
        this.id = id; this.name = name; this.calories = calories; this.proteinGrams = proteinGrams; this.carbsGrams = carbsGrams; this.price = price; this.rating = rating; this.dietType = dietType;
    }

    public static MealDto fromMeal(Meal m) {
        return new MealDto(m.getId(), m.getName(), m.getCalories(), m.getProteinGrams(), m.getCarbsGrams(), m.getPrice(), m.getRating(), m.getDietType());
    }

    public String getId() { return id; }
    public String getName() { return name; }
    public int getCalories() { return calories; }
    public int getProteinGrams() { return proteinGrams; }
    public int getCarbsGrams() { return carbsGrams; }
    public double getPrice() { return price; }
    public double getRating() { return rating; }
    public DietType getDietType() { return dietType; }
}
