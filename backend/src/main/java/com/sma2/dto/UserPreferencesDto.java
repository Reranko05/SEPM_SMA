package com.sma2.dto;

import com.sma2.entity.DietType;

public class UserPreferencesDto {
    private String username;
    private DietType dietType;
    private int calorieLimit;
    private double budget;
    private int spiceLevel;
    private int proteinGoalGrams;
    private int carbsLimitGrams;

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public DietType getDietType() { return dietType; }
    public void setDietType(DietType dietType) { this.dietType = dietType; }

    public int getCalorieLimit() { return calorieLimit; }
    public void setCalorieLimit(int calorieLimit) { this.calorieLimit = calorieLimit; }

    public double getBudget() { return budget; }
    public void setBudget(double budget) { this.budget = budget; }

    public int getSpiceLevel() { return spiceLevel; }
    public void setSpiceLevel(int spiceLevel) { this.spiceLevel = spiceLevel; }

    public int getProteinGoalGrams() { return proteinGoalGrams; }
    public void setProteinGoalGrams(int proteinGoalGrams) { this.proteinGoalGrams = proteinGoalGrams; }

    public int getCarbsLimitGrams() { return carbsLimitGrams; }
    public void setCarbsLimitGrams(int carbsLimitGrams) { this.carbsLimitGrams = carbsLimitGrams; }
}