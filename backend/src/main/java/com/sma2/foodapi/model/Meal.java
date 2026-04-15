package com.sma2.foodapi.model;

import com.sma2.entity.DietType;

public class Meal {
    private String id;
    private String name;
    private int calories;
    private double price;
    private double rating;
    private DietType dietType;
    private int proteinGrams;
    private int carbsGrams;

    public Meal() {}
    public Meal(String id, String name, int calories, double price, double rating, DietType dietType) {
        this.id = id; this.name = name; this.calories = calories; this.price = price; this.rating = rating; this.dietType = dietType;
    }
    public Meal(String id, String name, int calories, double price, double rating, DietType dietType, int proteinGrams, int carbsGrams) {
        this.id = id; this.name = name; this.calories = calories; this.price = price; this.rating = rating; this.dietType = dietType; this.proteinGrams = proteinGrams; this.carbsGrams = carbsGrams;
    }
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public int getCalories() { return calories; }
    public void setCalories(int calories) { this.calories = calories; }
    public double getPrice() { return price; }
    public void setPrice(double price) { this.price = price; }
    public double getRating() { return rating; }
    public void setRating(double rating) { this.rating = rating; }
    public DietType getDietType() { return dietType; }
    public void setDietType(DietType dietType) { this.dietType = dietType; }
    public int getProteinGrams() { return proteinGrams; }
    public void setProteinGrams(int proteinGrams) { this.proteinGrams = proteinGrams; }
    public int getCarbsGrams() { return carbsGrams; }
    public void setCarbsGrams(int carbsGrams) { this.carbsGrams = carbsGrams; }
}
