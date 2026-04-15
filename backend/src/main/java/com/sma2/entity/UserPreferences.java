package com.sma2.entity;

import java.util.UUID;

import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.Id;
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;

@Entity
@Table(name = "user_preferences")
public class UserPreferences {
    @Id
    @GeneratedValue
    private UUID id;

    @OneToOne
    private User user;

    @Enumerated(EnumType.STRING)
    private DietType dietType = DietType.OMNIVORE;

    private int calorieLimit = 2000;
    private double budget = 15.0;
    private int spiceLevel = 2; // 0-5
    private int proteinGoalGrams = 50;
    private int carbsLimitGrams = 300;

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    public User getUser() { return user; }
    public void setUser(User user) { this.user = user; }
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
